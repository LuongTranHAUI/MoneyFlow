import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/presentation/providers/database_provider.dart';
import 'package:finance_tracker/core/services/activity_monitor_service.dart';

class GoalState {
  final List<GoalEntity> goals;
  final bool isLoading;
  final String? error;
  
  const GoalState({
    this.goals = const [],
    this.isLoading = false,
    this.error,
  });
  
  GoalState copyWith({
    List<GoalEntity>? goals,
    bool? isLoading,
    String? error,
  }) {
    return GoalState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GoalNotifier extends StateNotifier<GoalState> {
  final AppDatabase _database;
  final Ref _ref;
  
  GoalNotifier(this._database, this._ref) : super(const GoalState()) {
    loadGoals();
  }
  
  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goals = await _database.select(_database.goals).get();
      state = state.copyWith(
        goals: goals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> addGoal({
    required String name,
    String? description,
    required double targetAmount,
    double currentAmount = 0,
    required DateTime targetDate,
    String? icon,
    String? color,
    String category = 'general',
    int priority = 0,
  }) async {
    try {
      final goal = GoalsCompanion(
        name: Value(name),
        description: Value(description),
        targetAmount: Value(targetAmount),
        currentAmount: Value(currentAmount),
        targetDate: Value(targetDate),
        category: Value(category),
        priority: Value(priority),
        icon: Value(icon),
        color: Value(color),
        isCompleted: const Value(false),
      );
      
      await _database.into(_database.goals).insert(goal);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> updateGoal({
    required int id,
    required String name,
    String? description,
    required double targetAmount,
    required double currentAmount,
    required DateTime targetDate,
    String? icon,
    String? color,
  }) async {
    try {
      final isCompleted = currentAmount >= targetAmount;
      
      await (_database.update(_database.goals)
        ..where((g) => g.id.equals(id)))
        .write(GoalsCompanion(
          name: Value(name),
          description: Value(description),
          targetAmount: Value(targetAmount),
          currentAmount: Value(currentAmount),
          targetDate: Value(targetDate),
          icon: Value(icon),
          color: Value(color),
          isCompleted: Value(isCompleted),
          updatedAt: Value(DateTime.now()),
        ));
        
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateGoalEntity(GoalEntity goal) async {
    try {
      await _database.update(_database.goals).replace(goal);
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> deleteGoal(int id) async {
    try {
      await (_database.delete(_database.goals)..where((g) => g.id.equals(id))).go();
      await loadGoals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> addMoneyToGoal(int goalId, double amount) async {
    try {
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
        
        await loadGoals();
        
        // Monitor hoạt động và tạo thông báo tự động
        final activityMonitor = _ref.read(activityMonitorProvider);
        await activityMonitor.onMoneyAddedToGoal(goalId.toString(), amount);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  List<GoalEntity> get activeGoals => 
      state.goals.where((g) => !g.isCompleted).toList();
  
  List<GoalEntity> get completedGoals => 
      state.goals.where((g) => g.isCompleted).toList();
  
  double get totalSaved => 
      state.goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  
  double get totalTarget => 
      state.goals.fold(0.0, (sum, g) => sum + g.targetAmount);
}

final goalProvider = StateNotifierProvider<GoalNotifier, GoalState>((ref) {
  final database = ref.watch(databaseProvider);
  return GoalNotifier(database, ref);
});