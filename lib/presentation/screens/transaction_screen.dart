import 'package:finance_tracker/core/animations/list_animations.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/date_formatter.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_base.dart';
import 'package:finance_tracker/presentation/widgets/add_edit_transaction_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedMonth;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedMonth = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Giao dịch'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
            tooltip: 'Chọn tháng',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildSearchBar(),
              ),
              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(25),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Thu nhập'),
                    Tab(text: 'Chi tiêu'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionTab(null, transactionState.transactions),
                _buildTransactionTab(
                    TransactionType.income, transactionState.transactions),
                _buildTransactionTab(
                    TransactionType.expense, transactionState.transactions),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm giao dịch...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _searchQuery = ''),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildTransactionTab(
      TransactionType? filterType, List<Transaction> allTransactions) {
    final transactions = _getFilteredTransactions(allTransactions, filterType);

    if (transactions.isEmpty) {
      return _buildEmptyState(filterType);
    }

    return _buildTransactionList(transactions);
  }

  Widget _buildEmptyState(TransactionType? filterType) {
    String title;
    String subtitle;
    IconData icon;

    switch (filterType) {
      case TransactionType.income:
        title = 'Chưa có thu nhập nào';
        subtitle = 'Thêm giao dịch thu nhập để theo dõi';
        icon = Icons.trending_up;
        break;
      case TransactionType.expense:
        title = 'Chưa có chi tiêu nào';
        subtitle = 'Thêm giao dịch chi tiêu để theo dõi';
        icon = Icons.trending_down;
        break;
      default:
        title = 'Chưa có giao dịch nào';
        subtitle = 'Nhấn nút + để thêm giao dịch mới';
        icon = Icons.receipt_long_outlined;
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(transactionProvider.notifier).loadTransactions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    // Group transactions by date
    final groupedTransactions = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      groupedTransactions[date] ??= [];
      groupedTransactions[date]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(transactionProvider.notifier).loadTransactions(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final dayTransactions = groupedTransactions[date]!;
          final dayTotal = _calculateDayTotal(dayTransactions);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCard(
                delay: Duration(milliseconds: 100 * index),
                child: _buildDateHeader(date, dayTotal),
              ),
              ...dayTransactions.asMap().entries.map((entry) {
                final transactionIndex = entry.key;
                final transaction = entry.value;
                return AnimatedListItem(
                  index: transactionIndex,
                  delay: Duration(
                      milliseconds:
                          50 + (100 * index) + (50 * transactionIndex)),
                  child: _buildTransactionItem(transaction),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, double total) {
    final isToday = DateFormatter.isSameDay(date, DateTime.now());
    final isYesterday = DateFormatter.isSameDay(
      date,
      DateTime.now().subtract(const Duration(days: 1)),
    );

    String dateText;
    if (isToday) {
      dateText = 'Hôm nay';
    } else if (isYesterday) {
      dateText = 'Hôm qua';
    } else {
      dateText = DateFormatter.formatFullDate(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            CurrencyFormatter.formatVND(total),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: total >= 0
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;

    return Slidable(
      key: Key(transaction.uuid),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editTransaction(transaction),
            backgroundColor: Colors.blue,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.edit,
            label: 'Sửa',
          ),
          SlidableAction(
            onPressed: (context) => _deleteTransaction(transaction),
            backgroundColor: Colors.red,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: Icons.delete,
            label: 'Xóa',
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isIncome
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome
                      ? Theme.of(context).colorScheme.onTertiaryContainer
                      : Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (transaction.description != null)
                      Text(
                        transaction.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.formatVND(transaction.amount)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isIncome
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormatter.formatTime(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Transaction> _getFilteredTransactions(
      List<Transaction> transactions, TransactionType? filterType) {
    var filtered = transactions;

    // Filter by type
    if (filterType != null) {
      filtered = filtered.where((t) => t.type == filterType).toList();
    }

    // Filter by month
    if (_selectedMonth != null) {
      filtered = filtered.where((t) {
        return t.date.year == _selectedMonth!.year &&
            t.date.month == _selectedMonth!.month;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final query = _searchQuery.toLowerCase();
        return t.category.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  double _calculateDayTotal(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  void _editTransaction(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditTransactionBottomSheet(
        transaction: transaction,
      ),
    );
  }

  Future<void> _deleteTransaction(Transaction transaction) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              Icons.delete_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Xác nhận xóa',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có chắc muốn xóa giao dịch này?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && transaction.id != null) {
      ref.read(transactionProvider.notifier).deleteTransaction(transaction.id!);
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetBase(
        title: 'Chi tiết giao dịch',
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Loại',
                transaction.type == TransactionType.income
                    ? 'Thu nhập'
                    : 'Chi tiêu'),
            _buildDetailRow('Danh mục', transaction.category),
            _buildDetailRow(
                'Số tiền', CurrencyFormatter.formatVND(transaction.amount)),
            _buildDetailRow(
                'Ngày', DateFormatter.formatFullDateTime(transaction.date)),
            if (transaction.description != null)
              _buildDetailRow('Ghi chú', transaction.description!),
            if (transaction.tags != null && transaction.tags!.isNotEmpty)
              _buildDetailRow('Tags', transaction.tags!.join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
