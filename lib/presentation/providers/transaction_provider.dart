import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/data/models/transaction_model.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/presentation/providers/database_provider.dart';
import 'package:finance_tracker/core/services/activity_monitor_service.dart';

class TransactionState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;
  final DateTime? selectedDate;
  final TransactionType? filterType;
  
  const TransactionState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.selectedDate,
    this.filterType,
  });
  
  TransactionState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    TransactionType? filterType,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
      filterType: filterType ?? this.filterType,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  final AppDatabase _database;
  final Ref _ref;
  
  TransactionNotifier(this._database, this._ref) : super(const TransactionState()) {
    loadTransactions();
  }
  
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entities = await _database.getAllTransactions();
      final transactions = entities.map((e) => TransactionModel.fromEntity(e)).toList();
      
      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> loadTransactionsByDateRange(DateTime start, DateTime end) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entities = await _database.getTransactionsByDateRange(start, end);
      final transactions = entities.map((e) => TransactionModel.fromEntity(e)).toList();
      
      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final companion = TransactionModel.toCompanion(transaction);
      final id = await _database.insertTransaction(companion);
      
      final newTransaction = transaction.copyWith(id: id);
      final updatedList = [newTransaction, ...state.transactions];
      updatedList.sort((a, b) => b.date.compareTo(a.date));
      
      state = state.copyWith(transactions: updatedList);
      
      // Monitor hoạt động và tạo thông báo tự động
      final activityMonitor = _ref.read(activityMonitorProvider);
      await activityMonitor.onTransactionAdded(newTransaction);
      
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> updateTransaction(int id, Transaction transaction) async {
    try {
      final updatedTransaction = transaction.copyWith(id: id);
      final companion = TransactionModel.toCompanion(updatedTransaction);
      await _database.updateTransaction(companion);
      
      final updatedList = state.transactions.map((t) {
        return t.id == id ? updatedTransaction : t;
      }).toList();
      updatedList.sort((a, b) => b.date.compareTo(a.date));
      
      state = state.copyWith(transactions: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> deleteTransaction(int id) async {
    try {
      await _database.deleteTransaction(id);
      
      final updatedList = state.transactions.where((t) => t.id != id).toList();
      state = state.copyWith(transactions: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  void setFilterType(TransactionType? type) {
    state = state.copyWith(filterType: type);
  }
  
  void setSelectedDate(DateTime? date) {
    state = state.copyWith(selectedDate: date);
  }
  
  List<Transaction> get filteredTransactions {
    var filtered = state.transactions;
    
    if (state.filterType != null) {
      filtered = filtered.where((t) => t.type == state.filterType).toList();
    }
    
    if (state.selectedDate != null) {
      filtered = filtered.where((t) {
        return t.date.year == state.selectedDate!.year &&
            t.date.month == state.selectedDate!.month &&
            t.date.day == state.selectedDate!.day;
      }).toList();
    }
    
    return filtered;
  }
  
  double get totalIncome {
    return state.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  double get totalExpense {
    return state.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  double get balance => totalIncome - totalExpense;
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, TransactionState>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionNotifier(database, ref);
});