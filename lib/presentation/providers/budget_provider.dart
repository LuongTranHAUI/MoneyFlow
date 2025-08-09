import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/budget_service.dart';
import '../../data/models/budget_model.dart';
import '../providers/database_provider.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetService(database);
});

final budgetsProvider = FutureProvider.autoDispose<List<Budget>>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return service.getCurrentMonthBudgets();
});

final budgetsByMonthProvider = FutureProvider.autoDispose.family<List<Budget>, DateTime>((ref, month) {
  final service = ref.watch(budgetServiceProvider);
  return service.getBudgetsByMonth(month);
});

final budgetProvider = FutureProvider.autoDispose.family<Budget?, int>((ref, id) {
  final service = ref.watch(budgetServiceProvider);
  return service.getBudgetById(id);
});

final totalBudgetAmountProvider = FutureProvider.autoDispose<double>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return service.getTotalBudgetAmount();
});

final totalBudgetAmountByMonthProvider = FutureProvider.autoDispose.family<double, DateTime>((ref, month) {
  final service = ref.watch(budgetServiceProvider);
  return service.getTotalBudgetAmountByMonth(month);
});

final totalSpentAmountProvider = FutureProvider.autoDispose<double>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return service.getTotalSpentAmount();
});

final totalSpentAmountByMonthProvider = FutureProvider.autoDispose.family<double, DateTime>((ref, month) {
  final service = ref.watch(budgetServiceProvider);
  return service.getTotalSpentAmountByMonth(month);
});

final overBudgetItemsProvider = FutureProvider.autoDispose<List<Budget>>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return service.getOverBudgetItems();
});

final budgetsNearLimitProvider = FutureProvider.autoDispose<List<Budget>>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return service.getBudgetsNearLimit();
});

class BudgetController extends StateNotifier<AsyncValue<void>> {
  final BudgetService _service;
  final Ref _ref;

  BudgetController(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> createBudget({
    required String category,
    required String icon,
    required int color,
    required double budgetAmount,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.createBudget(
        category: category,
        icon: icon,
        color: color,
        budgetAmount: budgetAmount,
        startDate: startDate,
        endDate: endDate,
      );
      
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(totalBudgetAmountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateBudget({
    required int id,
    String? category,
    String? icon,
    int? color,
    double? budgetAmount,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateBudget(
        id: id,
        category: category,
        icon: icon,
        color: color,
        budgetAmount: budgetAmount,
        startDate: startDate,
        endDate: endDate,
      );
      
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(budgetProvider(id));
      _ref.invalidate(totalBudgetAmountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteBudget(int id) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteBudget(id);
      
      _ref.invalidate(budgetsProvider);
      _ref.invalidate(totalBudgetAmountProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshBudgets() async {
    _ref.invalidate(budgetsProvider);
    _ref.invalidate(totalBudgetAmountProvider);
    _ref.invalidate(totalSpentAmountProvider);
    _ref.invalidate(overBudgetItemsProvider);
    _ref.invalidate(budgetsNearLimitProvider);
  }
}

final budgetControllerProvider = StateNotifierProvider<BudgetController, AsyncValue<void>>((ref) {
  final service = ref.watch(budgetServiceProvider);
  return BudgetController(service, ref);
});