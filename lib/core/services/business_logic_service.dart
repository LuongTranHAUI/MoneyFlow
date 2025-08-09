import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/database.dart';
import '../../presentation/providers/database_provider.dart';

class BusinessLogicService {
  final AppDatabase _database;
  final Ref _ref;

  BusinessLogicService(this._database, this._ref);

  /// Kiểm tra ngân sách khi thêm giao dịch chi tiêu
  Future<BudgetCheckResult> checkBudgetOverspend({
    required String category,
    required double amount,
    required DateTime date,
  }) async {
    try {
      // Lấy ngân sách cho category và tháng hiện tại
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      // Tìm budget cho category trong tháng này
      final budgets = await _database.select(_database.budgets).get();
      final budget = budgets.where((b) => 
        b.category == category &&
        b.startDate.isBefore(endOfMonth) &&
        b.endDate.isAfter(startOfMonth)
      ).firstOrNull;

      if (budget == null) {
        return BudgetCheckResult(
          hasWarning: false,
          message: 'Không có ngân sách được thiết lập cho danh mục này',
          budgetAmount: 0,
          currentSpent: 0,
          remainingAmount: 0,
          overspendAmount: 0,
        );
      }

      // Tính tổng chi tiêu hiện tại cho category trong tháng
      final transactions = await (_database.select(_database.transactions)
        ..where((t) => 
          t.category.equals(category) &
          t.type.equals('expense') &
          t.date.isBiggerOrEqualValue(startOfMonth) &
          t.date.isSmallerOrEqualValue(endOfMonth)
        )).get();

      final currentSpent = transactions.fold(0.0, (sum, t) => sum + t.amount.toDouble());
      final projectedSpent = currentSpent + amount;
      final remainingAmount = budget.budgetAmount.toDouble() - currentSpent;
      final overspendAmount = projectedSpent > budget.budgetAmount.toDouble()
          ? projectedSpent - budget.budgetAmount.toDouble()
          : 0.0;

      bool hasWarning = false;
      String message = '';

      if (overspendAmount > 0) {
        hasWarning = true;
        message = 'Vượt ngân sách ${_formatCurrency(overspendAmount)}! '
                 'Ngân sách: ${_formatCurrency(budget.budgetAmount.toDouble())}, '
                 'Đã chi: ${_formatCurrency(currentSpent)}';
      } else if (remainingAmount < budget.budgetAmount.toDouble() * 0.1) {
        hasWarning = true;
        message = 'Gần hết ngân sách! Còn lại: ${_formatCurrency(remainingAmount)}';
      } else if (projectedSpent > budget.budgetAmount.toDouble() * 0.8) {
        hasWarning = true;
        message = 'Đã chi 80% ngân sách. Còn lại: ${_formatCurrency(remainingAmount)}';
      }

      return BudgetCheckResult(
        hasWarning: hasWarning,
        message: message,
        budgetAmount: budget.budgetAmount.toDouble(),
        currentSpent: currentSpent,
        remainingAmount: remainingAmount,
        overspendAmount: overspendAmount,
      );
    } catch (e) {
      return BudgetCheckResult(
        hasWarning: false,
        message: 'Lỗi kiểm tra ngân sách: $e',
        budgetAmount: 0,
        currentSpent: 0,
        remainingAmount: 0,
        overspendAmount: 0,
      );
    }
  }

  /// Xử lý giao dịch thu nhập - tự động phân bổ vào mục tiêu
  Future<IncomeAllocationResult> processIncomeTransaction({
    required double amount,
    required DateTime date,
  }) async {
    try {
      final allocations = <GoalAllocation>[];
      
      // Lấy danh sách mục tiêu đang active
      final goals = await (_database.select(_database.goals)
        ..where((g) => g.isCompleted.equals(false))
        ..orderBy([(g) => OrderingTerm.desc(g.priority)])
      ).get();

      if (goals.isEmpty) {
        return IncomeAllocationResult(
          totalAllocated: 0,
          remainingAmount: amount,
          allocations: [],
          message: 'Không có mục tiêu nào để phân bổ',
        );
      }

      double remainingAmount = amount;
      double totalAllocated = 0;

      // Quy tắc phân bổ tự động:
      // 1. Emergency Fund trước (10% thu nhập)
      // 2. Các mục tiêu khác theo độ ưu tiên
      
      final emergencyGoal = goals.where((g) => g.category == 'emergency_fund').firstOrNull;
      if (emergencyGoal != null && !emergencyGoal.isCompleted) {
        final emergencyNeeded = emergencyGoal.targetAmount.toDouble() - emergencyGoal.currentAmount.toDouble();
        final emergencyAllocation = (amount * 0.1).clamp(0, emergencyNeeded.clamp(0, remainingAmount));
        
        if (emergencyAllocation > 0) {
          allocations.add(GoalAllocation(
            goalId: emergencyGoal.id,
            goalName: emergencyGoal.name,
            amount: emergencyAllocation.toDouble(),
            reason: 'Quỹ khẩn cấp (10% thu nhập)',
          ));
          totalAllocated += emergencyAllocation;
          remainingAmount -= emergencyAllocation;
          
          // Cập nhật goal
          await _updateGoalProgress(emergencyGoal.id, emergencyAllocation.toDouble());
        }
      }

      // Phân bổ phần còn lại cho các mục tiêu khác (20% thu nhập)
      final otherGoals = goals.where((g) => g.category != 'emergency_fund').toList();
      if (otherGoals.isNotEmpty && remainingAmount > 0) {
        final savingsAllocation = (amount * 0.2).clamp(0, remainingAmount);
        final allocationPerGoal = savingsAllocation / otherGoals.length;
        
        for (final goal in otherGoals) {
          if (remainingAmount <= 0) break;
          
          final goalNeeded = goal.targetAmount.toDouble() - goal.currentAmount.toDouble();
          final goalAllocation = allocationPerGoal.clamp(0, goalNeeded.clamp(0, remainingAmount));
          
          if (goalAllocation > 0) {
            allocations.add(GoalAllocation(
              goalId: goal.id,
              goalName: goal.name,
              amount: goalAllocation.toDouble(),
              reason: 'Tiết kiệm tự động (${(goalAllocation/amount*100).toStringAsFixed(1)}%)',
            ));
            totalAllocated += goalAllocation;
            remainingAmount -= goalAllocation;
            
            // Cập nhật goal
            await _updateGoalProgress(goal.id, goalAllocation.toDouble());
          }
        }
      }

      String message = '';
      if (totalAllocated > 0) {
        message = 'Đã phân bổ ${_formatCurrency(totalAllocated)} vào ${allocations.length} mục tiêu. ';
        message += 'Còn lại: ${_formatCurrency(remainingAmount)}';
      } else {
        message = 'Không phân bổ vào mục tiêu nào';
      }

      return IncomeAllocationResult(
        totalAllocated: totalAllocated,
        remainingAmount: remainingAmount,
        allocations: allocations,
        message: message,
      );
    } catch (e) {
      return IncomeAllocationResult(
        totalAllocated: 0,
        remainingAmount: amount,
        allocations: [],
        message: 'Lỗi phân bổ thu nhập: $e',
      );
    }
  }

  /// Cập nhật tiến độ mục tiêu
  Future<void> _updateGoalProgress(int goalId, double amount) async {
    final goal = await (_database.select(_database.goals)
      ..where((g) => g.id.equals(goalId))).getSingleOrNull();
    
    if (goal != null) {
      final newAmount = goal.currentAmount + amount;
      final isCompleted = newAmount >= goal.targetAmount;
      
      await (_database.update(_database.goals)
        ..where((g) => g.id.equals(goalId)))
        .write(GoalsCompanion(
          currentAmount: Value(newAmount),
          isCompleted: Value(isCompleted),
          updatedAt: Value(DateTime.now()),
        ));
    }
  }

  /// Tạo notification tự động
  Future<void> createTransactionNotification({
    required String type,
    required String category,
    required double amount,
    BudgetCheckResult? budgetResult,
    IncomeAllocationResult? incomeResult,
  }) async {
    String title = '';
    String message = '';
    String notificationType = 'transaction';

    if (type == 'expense') {
      title = 'Chi tiêu mới';
      message = 'Đã chi ${_formatCurrency(amount)} cho $category';
      
      if (budgetResult != null && budgetResult.hasWarning) {
        title = 'Cảnh báo ngân sách';
        message = budgetResult.message;
        notificationType = 'budget_warning';
      }
    } else {
      title = 'Thu nhập mới';
      message = 'Đã thêm ${_formatCurrency(amount)} thu nhập';
      
      if (incomeResult != null && incomeResult.totalAllocated > 0) {
        message += '. ${incomeResult.message}';
        notificationType = 'goal_progress';
      }
    }

    // Lưu notification vào database
    await _database.into(_database.notifications).insert(
      NotificationsCompanion.insert(
        title: title,
        message: message,
        type: notificationType,
        data: Value('{"amount": $amount, "category": "$category"}'),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} ₫';
  }
}

/// Kết quả kiểm tra ngân sách
class BudgetCheckResult {
  final bool hasWarning;
  final String message;
  final double budgetAmount;
  final double currentSpent;
  final double remainingAmount;
  final double overspendAmount;

  BudgetCheckResult({
    required this.hasWarning,
    required this.message,
    required this.budgetAmount,
    required this.currentSpent,
    required this.remainingAmount,
    required this.overspendAmount,
  });
}

/// Kết quả phân bổ thu nhập
class IncomeAllocationResult {
  final double totalAllocated;
  final double remainingAmount;
  final List<GoalAllocation> allocations;
  final String message;

  IncomeAllocationResult({
    required this.totalAllocated,
    required this.remainingAmount,
    required this.allocations,
    required this.message,
  });
}

/// Phân bổ cho một mục tiêu
class GoalAllocation {
  final int goalId;
  final String goalName;
  final double amount;
  final String reason;

  GoalAllocation({
    required this.goalId,
    required this.goalName,
    required this.amount,
    required this.reason,
  });
}

/// Provider cho Business Logic Service
final businessLogicServiceProvider = Provider<BusinessLogicService>((ref) {
  final database = ref.watch(databaseProvider);
  return BusinessLogicService(database, ref);
});