import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';

// Investment State
class InvestmentState {
  final List<InvestmentEntity> investments;
  final List<PortfolioEntity> portfolios;
  final bool isLoading;
  final String? error;

  const InvestmentState({
    this.investments = const [],
    this.portfolios = const [],
    this.isLoading = false,
    this.error,
  });

  InvestmentState copyWith({
    List<InvestmentEntity>? investments,
    List<PortfolioEntity>? portfolios,
    bool? isLoading,
    String? error,
  }) {
    return InvestmentState(
      investments: investments ?? this.investments,
      portfolios: portfolios ?? this.portfolios,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Investment Provider
class InvestmentNotifier extends StateNotifier<InvestmentState> {
  final AppDatabase _database;

  InvestmentNotifier(this._database) : super(const InvestmentState()) {
    loadInvestments();
  }

  // Load all investments and portfolios
  Future<void> loadInvestments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final investments = await _database.select(_database.investments).get();
      final portfolios = await _database.select(_database.portfolios).get();
      
      state = state.copyWith(
        investments: investments,
        portfolios: portfolios,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khi tải dữ liệu đầu tư: $e',
      );
    }
  }

  // Add new investment
  Future<void> addInvestment({
    required String name,
    required String symbol,
    required String type,
    required double initialPrice,
    required double quantity,
    String? description,
  }) async {
    try {
      final totalInvested = initialPrice * quantity;
      
      final investment = InvestmentsCompanion.insert(
        name: name,
        symbol: symbol,
        type: type,
        totalValue: totalInvested, // Initially same as invested
        totalInvested: totalInvested,
        currentPrice: initialPrice,
        quantity: quantity,
        description: description != null ? Value(description) : const Value.absent(),
      );

      await _database.into(_database.investments).insert(investment);
      
      // Add initial transaction
      await addInvestmentTransaction(
        investmentId: 0, // Will be updated after getting the actual ID
        type: 'buy',
        quantity: quantity,
        price: initialPrice,
        fee: 0,
      );
      
      await loadInvestments();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi thêm đầu tư: $e');
    }
  }

  // Add investment transaction
  Future<void> addInvestmentTransaction({
    required int investmentId,
    required String type, // buy, sell
    required double quantity,
    required double price,
    required double fee,
    String? notes,
  }) async {
    try {
      final totalAmount = (quantity * price) + fee;
      
      final transaction = InvestmentTransactionsCompanion.insert(
        investmentId: investmentId,
        type: type,
        quantity: quantity,
        price: price,
        fee: Value(fee),
        totalAmount: totalAmount,
        notes: notes != null ? Value(notes) : const Value.absent(),
        transactionDate: DateTime.now(),
      );

      await _database.into(_database.investmentTransactions).insert(transaction);
      
      // Update investment totals
      await _updateInvestmentTotals(investmentId);
      await loadInvestments();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi thêm giao dịch đầu tư: $e');
    }
  }

  // Update investment totals after transaction
  Future<void> _updateInvestmentTotals(int investmentId) async {
    try {
      // Get all transactions for this investment
      final transactions = await (_database.select(_database.investmentTransactions)
            ..where((t) => t.investmentId.equals(investmentId)))
          .get();

      double totalQuantity = 0;
      double totalInvested = 0;
      
      for (final transaction in transactions) {
        if (transaction.type == 'buy') {
          totalQuantity += transaction.quantity;
          totalInvested += transaction.totalAmount;
        } else if (transaction.type == 'sell') {
          totalQuantity -= transaction.quantity;
          totalInvested -= transaction.totalAmount; // Reduce invested amount
        }
      }

      // Get current price (for now, use the latest transaction price)
      final currentPrice = transactions.isNotEmpty ? transactions.last.price : 0.0;
      final totalValue = totalQuantity * currentPrice;

      // Update investment
      await (_database.update(_database.investments)
            ..where((i) => i.id.equals(investmentId)))
          .write(InvestmentsCompanion(
            totalValue: Value(totalValue),
            totalInvested: Value(totalInvested),
            currentPrice: Value(currentPrice),
            quantity: Value(totalQuantity),
            updatedAt: Value(DateTime.now()),
          ));
    } catch (e) {
      print('Error updating investment totals: $e');
    }
  }

  // Create portfolio
  Future<void> createPortfolio({
    required String name,
    String? description,
    required String riskLevel,
    double? targetAllocation,
  }) async {
    try {
      final portfolio = PortfoliosCompanion.insert(
        name: name,
        description: description != null ? Value(description) : const Value.absent(),
        totalValue: 0,
        totalInvested: 0,
        targetAllocation: targetAllocation != null ? Value(targetAllocation) : const Value.absent(),
        riskLevel: riskLevel,
      );

      await _database.into(_database.portfolios).insert(portfolio);
      await loadInvestments();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi tạo danh mục đầu tư: $e');
    }
  }

  // Update investment prices (would typically fetch from API)
  Future<void> updatePrices() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // For demo purposes, simulate price updates
      for (final investment in state.investments) {
        // Simulate price change ±5%
        final priceChange = (investment.currentPrice * 0.05) * (DateTime.now().millisecond % 200 - 100) / 100;
        final newPrice = investment.currentPrice + priceChange;
        final newTotalValue = investment.quantity * newPrice;
        
        await (_database.update(_database.investments)
              ..where((i) => i.id.equals(investment.id)))
            .write(InvestmentsCompanion(
              currentPrice: Value(newPrice),
              totalValue: Value(newTotalValue),
              updatedAt: Value(DateTime.now()),
            ));
      }
      
      await loadInvestments();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi cập nhật giá: $e', isLoading: false);
    }
  }

  // Get investment transactions
  Future<List<InvestmentTransactionEntity>> getInvestmentTransactions(int investmentId) async {
    try {
      return await (_database.select(_database.investmentTransactions)
            ..where((t) => t.investmentId.equals(investmentId))
            ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc)]))
          .get();
    } catch (e) {
      return [];
    }
  }

  // Calculate ROI for investment
  double calculateROI(InvestmentEntity investment) {
    if (investment.totalInvested <= 0) return 0.0;
    return ((investment.totalValue - investment.totalInvested) / investment.totalInvested) * 100;
  }

  // Calculate total portfolio value
  double get totalPortfolioValue {
    return state.investments.fold(0.0, (sum, investment) => sum + investment.totalValue);
  }

  // Calculate total invested amount
  double get totalInvestedAmount {
    return state.investments.fold(0.0, (sum, investment) => sum + investment.totalInvested);
  }

  // Calculate overall ROI
  double get overallROI {
    if (totalInvestedAmount <= 0) return 0.0;
    return ((totalPortfolioValue - totalInvestedAmount) / totalInvestedAmount) * 100;
  }

  // Delete investment
  Future<void> deleteInvestment(int investmentId) async {
    try {
      // Delete all transactions first
      await (_database.delete(_database.investmentTransactions)
            ..where((t) => t.investmentId.equals(investmentId)))
          .go();
      
      // Delete investment
      await (_database.delete(_database.investments)
            ..where((i) => i.id.equals(investmentId)))
          .go();
      
      await loadInvestments();
    } catch (e) {
      state = state.copyWith(error: 'Lỗi khi xóa đầu tư: $e');
    }
  }
}

// Providers
final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final investmentProvider = StateNotifierProvider<InvestmentNotifier, InvestmentState>((ref) {
  final database = ref.watch(databaseProvider);
  return InvestmentNotifier(database);
});

// Provider for specific investment transactions
final investmentTransactionsProvider = FutureProvider.family<List<InvestmentTransactionEntity>, int>((ref, investmentId) {
  final notifier = ref.read(investmentProvider.notifier);
  return notifier.getInvestmentTransactions(investmentId);
});