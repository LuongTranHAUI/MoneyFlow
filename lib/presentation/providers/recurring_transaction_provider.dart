import 'package:drift/drift.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// Recurring Transaction State
class RecurringTransactionState {
  final List<RecurringTransactionEntity> recurringTransactions;
  final List<RecurringExecutionEntity> pendingExecutions;
  final bool isLoading;
  final String? error;

  const RecurringTransactionState({
    this.recurringTransactions = const [],
    this.pendingExecutions = const [],
    this.isLoading = false,
    this.error,
  });

  RecurringTransactionState copyWith({
    List<RecurringTransactionEntity>? recurringTransactions,
    List<RecurringExecutionEntity>? pendingExecutions,
    bool? isLoading,
    String? error,
  }) {
    return RecurringTransactionState(
      recurringTransactions: recurringTransactions ?? this.recurringTransactions,
      pendingExecutions: pendingExecutions ?? this.pendingExecutions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RecurringTransactionNotifier extends StateNotifier<RecurringTransactionState> {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  RecurringTransactionNotifier(this._database) : super(const RecurringTransactionState()) {
    loadRecurringTransactions();
    _checkAndCreatePendingExecutions();
  }

  // Load all recurring transactions
  Future<void> loadRecurringTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recurringTransactions = await _database.select(_database.recurringTransactions).get();
      final pendingExecutions = await (_database.select(_database.recurringExecutions)
            ..where((e) => e.status.equals('pending'))
            ..orderBy([(e) => OrderingTerm(expression: e.scheduledDate)]))
          .get();
      
      state = state.copyWith(
        recurringTransactions: recurringTransactions,
        pendingExecutions: pendingExecutions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tải giao dịch định kỳ: $e',
      );
    }
  }

  // Add new recurring transaction
  Future<void> addRecurringTransaction({
    required String name,
    required double amount,
    required String type, // income, expense
    required String category,
    required String frequency, // daily, weekly, monthly, yearly
    required int interval,
    required DateTime startDate,
    DateTime? endDate,
    String? description,
    bool autoExecute = false,
  }) async {
    try {
      final nextDueDate = _calculateNextDueDate(startDate, frequency, interval);
      
      final recurringTransaction = RecurringTransactionsCompanion.insert(
        name: name,
        amount: amount,
        type: type,
        category: category,
        description: description != null ? Value(description) : const Value.absent(),
        frequency: frequency,
        interval: Value(interval),
        startDate: startDate,
        endDate: endDate != null ? Value(endDate) : const Value.absent(),
        nextDueDate: nextDueDate,
        autoExecute: Value(autoExecute),
      );

      final recurringId = await _database.into(_database.recurringTransactions).insert(recurringTransaction);
      
      // Create first execution
      await _createExecution(recurringId, nextDueDate);
      
      await loadRecurringTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi thêm giao dịch định kỳ: $e');
    }
  }

  // Calculate next due date based on frequency
  DateTime _calculateNextDueDate(DateTime startDate, String frequency, int interval) {
    switch (frequency) {
      case 'daily':
        return startDate.add(Duration(days: interval));
      case 'weekly':
        return startDate.add(Duration(days: 7 * interval));
      case 'monthly':
        return DateTime(
          startDate.year,
          startDate.month + interval,
          startDate.day,
        );
      case 'yearly':
        return DateTime(
          startDate.year + interval,
          startDate.month,
          startDate.day,
        );
      default:
        return startDate.add(Duration(days: interval));
    }
  }

  // Create execution record
  Future<void> _createExecution(int recurringId, DateTime scheduledDate) async {
    final execution = RecurringExecutionsCompanion.insert(
      recurringTransactionId: recurringId,
      scheduledDate: scheduledDate,
      status: 'pending',
    );

    await _database.into(_database.recurringExecutions).insert(execution);
  }

  // Execute pending transaction
  Future<void> executePendingTransaction(int executionId) async {
    try {
      // Get execution details
      final execution = await (_database.select(_database.recurringExecutions)
            ..where((e) => e.id.equals(executionId)))
          .getSingle();

      // Get recurring transaction details
      final recurringTransaction = await (_database.select(_database.recurringTransactions)
            ..where((r) => r.id.equals(execution.recurringTransactionId)))
          .getSingle();

      // Create actual transaction
      final transaction = TransactionsCompanion.insert(
        uuid: _uuid.v4(),
        amount: recurringTransaction.amount,
        type: recurringTransaction.type,
        category: recurringTransaction.category,
        description: Value('${recurringTransaction.name} (Tự động)'),
        date: DateTime.now(),
      );

      final transactionId = await _database.into(_database.transactions).insert(transaction);

      // Mark execution as executed
      await (_database.update(_database.recurringExecutions)
            ..where((e) => e.id.equals(executionId)))
          .write(RecurringExecutionsCompanion(
            status: const Value('executed'),
            executedDate: Value(DateTime.now()),
            transactionId: Value(transactionId),
          ));

      // Update recurring transaction
      await (_database.update(_database.recurringTransactions)
            ..where((r) => r.id.equals(recurringTransaction.id)))
          .write(RecurringTransactionsCompanion(
            executedCount: Value(recurringTransaction.executedCount + 1),
            nextDueDate: Value(_calculateNextDueDate(
              execution.scheduledDate, 
              recurringTransaction.frequency, 
              recurringTransaction.interval,
            )),
            updatedAt: Value(DateTime.now()),
          ));

      // Create next execution
      final nextDueDate = _calculateNextDueDate(
        execution.scheduledDate, 
        recurringTransaction.frequency, 
        recurringTransaction.interval,
      );

      // Check if should create next execution (within end date if set)
      if (recurringTransaction.endDate == null || 
          nextDueDate.isBefore(recurringTransaction.endDate!)) {
        await _createExecution(recurringTransaction.id, nextDueDate);
      }

      await loadRecurringTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi thực hiện giao dịch: $e');
    }
  }

  // Skip pending transaction
  Future<void> skipPendingTransaction(int executionId, {String? reason}) async {
    try {
      await (_database.update(_database.recurringExecutions)
            ..where((e) => e.id.equals(executionId)))
          .write(RecurringExecutionsCompanion(
            status: const Value('skipped'),
            notes: reason != null ? Value(reason) : const Value.absent(),
          ));

      await loadRecurringTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi bỏ qua giao dịch: $e');
    }
  }

  // Check and create pending executions for all active recurring transactions
  Future<void> _checkAndCreatePendingExecutions() async {
    try {
      final activeRecurring = await (_database.select(_database.recurringTransactions)
            ..where((r) => r.isActive.equals(true)))
          .get();

      for (final recurring in activeRecurring) {
        // Check if there's already a pending execution
        final existingPending = await (_database.select(_database.recurringExecutions)
              ..where((e) => 
                e.recurringTransactionId.equals(recurring.id) & 
                e.status.equals('pending')))
            .getSingleOrNull();

        // If no pending execution and next due date is in the future
        if (existingPending == null && recurring.nextDueDate.isAfter(DateTime.now())) {
          await _createExecution(recurring.id, recurring.nextDueDate);
        }
      }
    } catch (e) {
      print('Error checking pending executions: $e');
    }
  }

  // Toggle recurring transaction active status
  Future<void> toggleRecurringTransaction(int recurringId, bool isActive) async {
    try {
      await (_database.update(_database.recurringTransactions)
            ..where((r) => r.id.equals(recurringId)))
          .write(RecurringTransactionsCompanion(
            isActive: Value(isActive),
            updatedAt: Value(DateTime.now()),
          ));

      await loadRecurringTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi cập nhật trạng thái: $e');
    }
  }

  // Delete recurring transaction
  Future<void> deleteRecurringTransaction(int recurringId) async {
    try {
      // Delete all executions first
      await (_database.delete(_database.recurringExecutions)
            ..where((e) => e.recurringTransactionId.equals(recurringId)))
          .go();
      
      // Delete recurring transaction
      await (_database.delete(_database.recurringTransactions)
            ..where((r) => r.id.equals(recurringId)))
          .go();
      
      await loadRecurringTransactions();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi xóa giao dịch định kỳ: $e');
    }
  }

  // Get executions history for a recurring transaction
  Future<List<RecurringExecutionEntity>> getExecutionsHistory(int recurringId) async {
    try {
      return await (_database.select(_database.recurringExecutions)
            ..where((e) => e.recurringTransactionId.equals(recurringId))
            ..orderBy([(e) => OrderingTerm(expression: e.scheduledDate, mode: OrderingMode.desc)]))
          .get();
    } catch (e) {
      return [];
    }
  }

  // Check for due executions (for background processing)
  Future<List<RecurringExecutionEntity>> getDueExecutions() async {
    try {
      final now = DateTime.now();
      return await (_database.select(_database.recurringExecutions)
            ..where((e) => 
              e.status.equals('pending') & 
              e.scheduledDate.isSmallerOrEqualValue(now)))
          .get();
    } catch (e) {
      return [];
    }
  }

  // Auto-execute due transactions
  Future<void> processAutoExecutions() async {
    try {
      final dueExecutions = await getDueExecutions();
      
      for (final execution in dueExecutions) {
        // Get recurring transaction to check if auto-execute is enabled
        final recurringTransaction = await (_database.select(_database.recurringTransactions)
              ..where((r) => r.id.equals(execution.recurringTransactionId)))
            .getSingle();

        if (recurringTransaction.autoExecute) {
          await executePendingTransaction(execution.id);
        }
      }
    } catch (e) {
      print('Error processing auto executions: $e');
    }
  }

  // Get frequency display text
  String getFrequencyText(String frequency, int interval) {
    switch (frequency) {
      case 'daily':
        return interval == 1 ? 'Hàng ngày' : 'Mỗi $interval ngày';
      case 'weekly':
        return interval == 1 ? 'Hàng tuần' : 'Mỗi $interval tuần';
      case 'monthly':
        return interval == 1 ? 'Hàng tháng' : 'Mỗi $interval tháng';
      case 'yearly':
        return interval == 1 ? 'Hàng năm' : 'Mỗi $interval năm';
      default:
        return 'Không xác định';
    }
  }
}

// Providers
final recurringTransactionProvider = StateNotifierProvider<RecurringTransactionNotifier, RecurringTransactionState>((ref) {
  final database = AppDatabase();
  return RecurringTransactionNotifier(database);
});

// Provider for execution history
final executionHistoryProvider = FutureProvider.family<List<RecurringExecutionEntity>, int>((ref, recurringId) {
  final notifier = ref.read(recurringTransactionProvider.notifier);
  return notifier.getExecutionsHistory(recurringId);
});