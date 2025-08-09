import 'package:drift/drift.dart';
import '../datasources/local/database.dart';
import '../models/budget_model.dart';
import '../../core/errors/app_exception.dart';

class BudgetService {
  final AppDatabase _database;

  BudgetService(this._database);

  Future<List<Budget>> getBudgets({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = _database.select(_database.budgets);
      
      if (startDate != null) {
        query.where((b) => b.startDate.isBiggerOrEqualValue(startDate));
      }
      
      if (endDate != null) {
        query.where((b) => b.endDate.isSmallerOrEqualValue(endDate));
      }

      final budgetEntries = await query.get();
      
      List<Budget> budgets = [];
      for (final entry in budgetEntries) {
        final spentAmount = await _getSpentAmountForBudget(entry.id, entry.category, entry.startDate, entry.endDate);
        
        budgets.add(Budget(
          id: entry.id,
          category: entry.category,
          icon: entry.icon,
          color: entry.color,
          budgetAmount: entry.budgetAmount,
          spentAmount: spentAmount,
          startDate: entry.startDate,
          endDate: entry.endDate,
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt,
        ));
      }
      
      return budgets;
    } catch (e) {
      throw AppException(message: 'Không thể tải danh sách ngân sách: $e');
    }
  }

  Future<Budget?> getBudgetById(int id) async {
    try {
      final budgetEntry = await (_database.select(_database.budgets)
            ..where((b) => b.id.equals(id)))
          .getSingleOrNull();

      if (budgetEntry == null) return null;

      final spentAmount = await _getSpentAmountForBudget(budgetEntry.id, budgetEntry.category, budgetEntry.startDate, budgetEntry.endDate);

      return Budget(
        id: budgetEntry.id,
        category: budgetEntry.category,
        icon: budgetEntry.icon,
        color: budgetEntry.color,
        budgetAmount: budgetEntry.budgetAmount,
        spentAmount: spentAmount,
        startDate: budgetEntry.startDate,
        endDate: budgetEntry.endDate,
        createdAt: budgetEntry.createdAt,
        updatedAt: budgetEntry.updatedAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tải ngân sách: $e');
    }
  }

  Future<Budget> createBudget({
    required String category,
    required String icon,
    required int color,
    required double budgetAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final budgetEntry = await _database.into(_database.budgets).insertReturning(
            BudgetsCompanion(
              category: Value(category),
              icon: Value(icon),
              color: Value(color),
              budgetAmount: Value(budgetAmount),
              startDate: Value(startDate),
              endDate: Value(endDate),
            ),
          );

      return Budget(
        id: budgetEntry.id,
        category: budgetEntry.category,
        icon: budgetEntry.icon,
        color: budgetEntry.color,
        budgetAmount: budgetEntry.budgetAmount,
        spentAmount: 0,
        startDate: budgetEntry.startDate,
        endDate: budgetEntry.endDate,
        createdAt: budgetEntry.createdAt,
        updatedAt: budgetEntry.updatedAt,
      );
    } catch (e) {
      throw AppException(message: 'Không thể tạo ngân sách mới: $e');
    }
  }

  Future<Budget> updateBudget({
    required int id,
    String? category,
    String? icon,
    int? color,
    double? budgetAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await (_database.update(_database.budgets)..where((b) => b.id.equals(id))).write(
        BudgetsCompanion(
          category: category != null ? Value(category) : const Value.absent(),
          icon: icon != null ? Value(icon) : const Value.absent(),
          color: color != null ? Value(color) : const Value.absent(),
          budgetAmount: budgetAmount != null ? Value(budgetAmount) : const Value.absent(),
          startDate: startDate != null ? Value(startDate) : const Value.absent(),
          endDate: endDate != null ? Value(endDate) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updatedBudget = await getBudgetById(id);
      if (updatedBudget == null) {
        throw const AppException(message: 'Không thể tìm thấy ngân sách sau khi cập nhật');
      }
      
      return updatedBudget;
    } catch (e) {
      throw AppException(message: 'Không thể cập nhật ngân sách: $e');
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await (_database.delete(_database.budgets)..where((b) => b.id.equals(id))).go();
    } catch (e) {
      throw AppException(message: 'Không thể xóa ngân sách: $e');
    }
  }

  Future<List<Budget>> getCurrentMonthBudgets() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return getBudgets(startDate: startOfMonth, endDate: endOfMonth);
  }

  Future<List<Budget>> getBudgetsByMonth(DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return getBudgets(startDate: startOfMonth, endDate: endOfMonth);
  }

  Future<double> getTotalBudgetAmount({DateTime? month}) async {
    return getTotalBudgetAmountByMonth(month ?? DateTime.now());
  }

  Future<double> getTotalBudgetAmountByMonth(DateTime month) async {
    try {
      final budgets = await getBudgetsByMonth(month);
      
      return budgets.fold<double>(0.0, (sum, budget) => sum + budget.budgetAmount);
    } catch (e) {
      throw AppException(message: 'Không thể tính tổng ngân sách: $e');
    }
  }

  Future<double> getTotalSpentAmount({DateTime? month}) async {
    return getTotalSpentAmountByMonth(month ?? DateTime.now());
  }

  Future<double> getTotalSpentAmountByMonth(DateTime month) async {
    try {
      final budgets = await getBudgetsByMonth(month);
      
      return budgets.fold<double>(0.0, (sum, budget) => sum + budget.spentAmount);
    } catch (e) {
      throw AppException(message: 'Không thể tính tổng số tiền đã chi: $e');
    }
  }

  Future<double> _getSpentAmountForBudget(int budgetId, String category, DateTime startDate, DateTime endDate) async {
    try {
      final query = _database.select(_database.transactions)
        ..where((t) => t.category.equals(category) & 
                       t.type.equals('expense') &
                       t.date.isBetweenValues(startDate, endDate));

      final transactions = await query.get();
      return transactions.fold<double>(0.0, (sum, transaction) => sum + transaction.amount);
    } catch (e) {
      // Nếu không có transaction nào, trả về 0
      return 0.0;
    }
  }

  Future<List<Budget>> getOverBudgetItems({DateTime? month}) async {
    final budgets = month != null 
        ? await getBudgets(
            startDate: DateTime(month.year, month.month, 1),
            endDate: DateTime(month.year, month.month + 1, 0),
          )
        : await getCurrentMonthBudgets();
    
    return budgets.where((budget) => budget.isOverBudget).toList();
  }

  Future<List<Budget>> getBudgetsNearLimit({double threshold = 0.8, DateTime? month}) async {
    final budgets = month != null 
        ? await getBudgets(
            startDate: DateTime(month.year, month.month, 1),
            endDate: DateTime(month.year, month.month + 1, 0),
          )
        : await getCurrentMonthBudgets();
    
    return budgets.where((budget) => 
        budget.percentageUsed >= (threshold * 100) && 
        !budget.isOverBudget
    ).toList();
  }
}