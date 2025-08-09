import 'package:finance_tracker/data/models/notification_model.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database.dart';
import '../../presentation/providers/budget_provider.dart';
import '../../presentation/providers/goal_provider.dart';
import '../../presentation/providers/transaction_provider.dart';
import 'notification_service.dart';

// Add extension for firstOrNull if not available
extension IterableExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class ActivityMonitorService {
  final Ref _ref;
  
  ActivityMonitorService(this._ref);

  // Monitor khi có transaction mới được thêm
  Future<void> onTransactionAdded(Transaction transaction) async {
    await _checkBudgetStatus(transaction);
    await _checkLargeExpense(transaction);
    await _checkGoalProgress();
  }

  // Monitor khi có tiền được thêm vào goal
  Future<void> onMoneyAddedToGoal(String goalId, double amount) async {
    await _checkGoalProgress(goalId: goalId);
  }

  // Kiểm tra trạng thái ngân sách khi có giao dịch mới
  Future<void> _checkBudgetStatus(Transaction transaction) async {
    if (transaction.type != TransactionType.expense) return;

    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final budgets = await _ref.read(budgetsByMonthProvider(currentMonth).future);
      
      // Tìm budget cho category của transaction
      final categoryBudget = budgets.where((b) => b.category == transaction.category).firstOrNull;
      if (categoryBudget == null) return;

      final spentAmount = categoryBudget.spentAmount;
      final budgetAmount = categoryBudget.budgetAmount;
      
      // Avoid division by zero
      if (budgetAmount <= 0) return;
      
      final percentage = (spentAmount / budgetAmount * 100);

      // Nếu vượt ngân sách
      if (spentAmount > budgetAmount) {
        await NotificationService.createBudgetOverAlert(
          ref: _ref,
          category: transaction.category,
          budgetAmount: budgetAmount,
          spentAmount: spentAmount,
        );
      }
      // Nếu sắp vượt ngân sách (80%, 90%)
      else if (percentage >= 90 && !_hasWarningBeenSent(transaction.category, 90)) {
        await NotificationService.createBudgetWarning(
          ref: _ref,
          category: transaction.category,
          budgetAmount: budgetAmount,
          spentAmount: spentAmount,
        );
        _markWarningAsSent(transaction.category, 90);
      } else if (percentage >= 80 && !_hasWarningBeenSent(transaction.category, 80)) {
        await NotificationService.createBudgetWarning(
          ref: _ref,
          category: transaction.category,
          budgetAmount: budgetAmount,
          spentAmount: spentAmount,
        );
        _markWarningAsSent(transaction.category, 80);
      }
    } catch (e) {
      print('Error checking budget status: $e');
    }
  }

  // Kiểm tra chi tiêu lớn
  Future<void> _checkLargeExpense(Transaction transaction) async {
    if (transaction.type != TransactionType.expense) return;

    try {
      // Lấy chi tiêu trung bình tháng cho category này
      final monthlyAverage = await _getMonthlyAverageExpense(transaction.category);
      
      // Nếu giao dịch hiện tại gấp đôi mức trung bình
      if (transaction.amount > monthlyAverage * 2 && monthlyAverage > 0) {
        await NotificationService.createLargeExpenseAlert(
          ref: _ref,
          amount: transaction.amount,
          category: transaction.category,
          monthlyAverage: monthlyAverage,
        );
      }
    } catch (e) {
      print('Error checking large expense: $e');
    }
  }

  // Kiểm tra tiến độ mục tiêu
  Future<void> _checkGoalProgress({String? goalId}) async {
    try {
      final goalState = _ref.read(goalProvider);
      if (goalState.goals.isEmpty) return;

      final goalsToCheck = goalId != null 
          ? goalState.goals.where((g) => g.id.toString() == goalId).toList()
          : goalState.goals;

      for (final goal in goalsToCheck) {
        if (goal.targetAmount <= 0) continue; // Avoid division by zero
        
        final percentage = (goal.currentAmount / goal.targetAmount * 100);
        
        // Kiểm tra hoàn thành mục tiêu
        if (percentage >= 100 && !goal.isCompleted) {
          await NotificationService.createGoalAchieved(
            ref: _ref,
            goalName: goal.name,
            targetAmount: goal.targetAmount,
          );
        }
        // Kiểm tra các milestone (25%, 50%, 75%)
        else if (percentage < 100) {
          await _checkGoalMilestones(goal, percentage.round());
        }
      }
    } catch (e) {
      print('Error checking goal progress: $e');
    }
  }

  // Kiểm tra các milestone của mục tiêu
  Future<void> _checkGoalMilestones(GoalEntity goal, int percentage) async {
    final milestones = [25, 50, 75];
    
    for (final milestone in milestones) {
      if (percentage >= milestone && 
          !_hasMilestoneBeenReached(goal.id.toString(), milestone)) {
        await NotificationService.createGoalProgress(
          ref: _ref,
          goalName: goal.name,
          currentAmount: goal.currentAmount,
          targetAmount: goal.targetAmount,
          milestonePercent: milestone,
        );
        _markMilestoneAsReached(goal.id.toString(), milestone);
        break; // Chỉ gửi 1 thông báo milestone mỗi lần
      }
    }
  }

  // Kiểm tra cuối tháng và tạo tổng kết
  Future<void> checkMonthlyReview() async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      
      // Lấy tất cả transactions của tháng hiện tại
      final transactions = await _getTransactionsByDateRange(currentMonth, nextMonth);
      
      double totalIncome = 0;
      double totalExpense = 0;
      
      for (final transaction in transactions) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }
      
      final savings = totalIncome - totalExpense;
      
      await NotificationService.createMonthlyReminder(
        ref: _ref,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        savings: savings,
      );
    } catch (e) {
      print('Error creating monthly review: $e');
    }
  }

  // Kiểm tra streak tiết kiệm
  Future<void> checkSavingStreak() async {
    try {
      final daysWithoutExpense = await _getDaysWithoutExpense();
      if (daysWithoutExpense >= 3) { // 3 ngày không chi tiêu
        final savedAmount = await _getEstimatedSavings(daysWithoutExpense);
        
        await NotificationService.createSavingEncouragement(
          ref: _ref,
          daysWithoutExpense: daysWithoutExpense,
          savedAmount: savedAmount,
        );
      }
    } catch (e) {
      print('Error checking saving streak: $e');
    }
  }

  // Helper methods
  Future<double> _getMonthlyAverageExpense(String category) async {
    try {
      final transactionState = _ref.read(transactionProvider);
      final now = DateTime.now();
      
      // Get transactions from the last 3 months
      final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
      
      final categoryExpenses = transactionState.transactions
          .where((t) => 
              t.type == TransactionType.expense &&
              t.category == category &&
              t.date.isAfter(threeMonthsAgo))
          .map((t) => t.amount)
          .toList();
      
      if (categoryExpenses.isEmpty) return 0;
      
      final totalExpense = categoryExpenses.fold<double>(0, (sum, amount) => sum + amount);
      final monthCount = 3; // Calculate based on 3 months
      
      return totalExpense / monthCount;
    } catch (e) {
      print('Error calculating monthly average: $e');
      return 500000; // Default fallback
    }
  }

  Future<List<Transaction>> _getTransactionsByDateRange(DateTime start, DateTime end) async {
    try {
      final transactionState = _ref.read(transactionProvider);
      return transactionState.transactions
          .where((t) => 
              t.date.isAfter(start) && 
              t.date.isBefore(end))
          .toList();
    } catch (e) {
      print('Error getting transactions by date range: $e');
      return [];
    }
  }

  Future<int> _getDaysWithoutExpense() async {
    try {
      final transactionState = _ref.read(transactionProvider);
      final now = DateTime.now();
      
      // Get expenses sorted by date (newest first)
      final expenses = transactionState.transactions
          .where((t) => t.type == TransactionType.expense)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      
      if (expenses.isEmpty) return 0;
      
      int daysWithoutExpense = 0;
      for (int i = 0; i < 30; i++) { // Check last 30 days
        final checkDate = DateTime(now.year, now.month, now.day - i);
        final hasExpenseOnDate = expenses.any((expense) => 
            expense.date.year == checkDate.year &&
            expense.date.month == checkDate.month &&
            expense.date.day == checkDate.day);
        
        if (hasExpenseOnDate) {
          break;
        }
        daysWithoutExpense++;
      }
      
      return daysWithoutExpense;
    } catch (e) {
      print('Error calculating days without expense: $e');
      return 0;
    }
  }

  Future<double> _getEstimatedSavings(int days) async {
    try {
      final averageDaily = await _getAverageDailyExpense();
      return days * averageDaily;
    } catch (e) {
      print('Error calculating estimated savings: $e');
      return days * 50000.0; // Fallback calculation
    }
  }

  Future<double> _getAverageDailyExpense() async {
    try {
      final transactionState = _ref.read(transactionProvider);
      final now = DateTime.now();
      final monthAgo = DateTime(now.year, now.month - 1, now.day);
      
      final monthlyExpenses = transactionState.transactions
          .where((t) => 
              t.type == TransactionType.expense &&
              t.date.isAfter(monthAgo))
          .map((t) => t.amount)
          .toList();
      
      if (monthlyExpenses.isEmpty) return 0;
      
      final totalExpense = monthlyExpenses.fold<double>(0, (sum, amount) => sum + amount);
      return totalExpense / 30; // Average per day
    } catch (e) {
      print('Error calculating average daily expense: $e');
      return 50000; // Default daily average
    }
  }

  // Cache để tránh spam notifications
  static final Map<String, Set<int>> _warningsSent = {};
  static final Map<String, Set<int>> _milestonesReached = {};

  bool _hasWarningBeenSent(String category, int percentage) {
    return _warningsSent[category]?.contains(percentage) ?? false;
  }

  void _markWarningAsSent(String category, int percentage) {
    _warningsSent[category] ??= <int>{};
    _warningsSent[category]!.add(percentage);
  }

  bool _hasMilestoneBeenReached(String goalId, int milestone) {
    return _milestonesReached[goalId]?.contains(milestone) ?? false;
  }

  void _markMilestoneAsReached(String goalId, int milestone) {
    _milestonesReached[goalId] ??= <int>{};
    _milestonesReached[goalId]!.add(milestone);
  }

  // Validate notification data before sending
  bool _shouldSendNotification(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'budget_alert':
        return data['budgetAmount'] != null && 
               data['spentAmount'] != null &&
               data['category'] != null &&
               data['budgetAmount'] > 0;
      
      case 'goal_progress':
        return data['goalName'] != null &&
               data['targetAmount'] != null &&
               data['currentAmount'] != null &&
               data['targetAmount'] > 0;
      
      case 'large_expense':
        return data['amount'] != null &&
               data['category'] != null &&
               data['monthlyAverage'] != null &&
               data['amount'] > 0;
      
      default:
        return true; // Allow other types by default
    }
  }

  // Reset cache mỗi tháng
  static void resetMonthlyCache() {
    _warningsSent.clear();
    // Không reset milestones vì chỉ gửi 1 lần cho mỗi goal
  }

  // Method to manually trigger notifications for testing
  Future<void> triggerTestNotification() async {
    try {
      await NotificationService.showNotification(
        title: 'Test Notification',
        message: 'Hệ thống thông báo hoạt động bình thường',
        type: NotificationType.general,
      );
    } catch (e) {
      print('Error triggering test notification: $e');
    }
  }
}

// Provider cho ActivityMonitorService
final activityMonitorProvider = Provider<ActivityMonitorService>((ref) {
  return ActivityMonitorService(ref);
});