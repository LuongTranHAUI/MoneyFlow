import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/investment_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../widgets/add_edit_investment_bottom_sheet.dart';

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investmentState = ref.watch(investmentProvider);

    return Scaffold(
      body: investmentState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                final notifier = ref.read(investmentProvider.notifier);
                await notifier.loadInvestments();
                await notifier.updatePrices();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (investmentState.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                investmentState.error!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildPortfolioOverview(context, ref, investmentState),
                    const SizedBox(height: 20),
                    _buildAssetAllocation(context, investmentState),
                    const SizedBox(height: 20),
                    _buildInvestmentList(context, ref, investmentState),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddInvestmentSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPortfolioOverview(
      BuildContext context, WidgetRef ref, InvestmentState state) {
    final notifier = ref.read(investmentProvider.notifier);
    final totalValue = notifier.totalPortfolioValue;
    final totalInvested = notifier.totalInvestedAmount;
    final overallROI = notifier.overallROI;
    final profitLoss = totalValue - totalInvested;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.8),
                ]
              : [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng giá trị danh mục',
            style: TextStyle(
              color: isDarkMode
                  ? Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.8)
                  : Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatVND(totalValue),
            style: TextStyle(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPortfolioStat(
                context,
                icon: Icons.trending_up,
                label: 'Lợi nhuận',
                amount: profitLoss,
                color: profitLoss >= 0 ? Colors.green : Colors.red,
              ),
              _buildPortfolioStat(
                context,
                icon: Icons.percent,
                label: 'ROI',
                amount: overallROI,
                color: overallROI >= 0 ? Colors.green : Colors.red,
                isPercentage: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    bool isPercentage = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.2)
                : Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDarkMode
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDarkMode
                    ? Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer
                        .withValues(alpha: 0.8)
                    : Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            Text(
              isPercentage
                  ? '${amount.toStringAsFixed(1)}%'
                  : CurrencyFormatter.formatCompact(amount),
              style: TextStyle(
                color: isDarkMode
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssetAllocation(BuildContext context, InvestmentState state) {
    final investments = state.investments;

    if (investments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by type
    final Map<String, double> allocation = {};
    for (final investment in investments) {
      allocation[investment.type] =
          (allocation[investment.type] ?? 0) + investment.totalValue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân bổ tài sản',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (allocation.isEmpty)
            Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: allocation.entries.map((entry) {
                    final total = allocation.values.reduce((a, b) => a + b);
                    final percentage = (entry.value / total * 100);

                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getAssetTypeColor(context, entry.key),
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ...allocation.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getAssetTypeColor(context, entry.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getAssetTypeName(entry.key),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(entry.value),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInvestmentList(
      BuildContext context, WidgetRef ref, InvestmentState state) {
    final investments = state.investments;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách đầu tư',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (investments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Chưa có khoản đầu tư nào',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...investments.map(
                (investment) => _buildInvestmentItem(context, ref, investment)),
        ],
      ),
    );
  }

  Widget _buildInvestmentItem(BuildContext context, WidgetRef ref, investment) {
    final notifier = ref.read(investmentProvider.notifier);
    final roi = notifier.calculateROI(investment);
    final profitLoss = investment.totalValue - investment.totalInvested;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Slidable(
        key: Key(investment.id.toString()),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editInvestment(context, ref, investment),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Sửa',
            ),
            SlidableAction(
              onPressed: (context) =>
                  _deleteInvestment(context, ref, investment),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Xóa',
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            _showInvestmentDetails(context, ref, investment);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getAssetTypeColor(context, investment.type)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAssetTypeIcon(investment.type),
                    color: _getAssetTypeColor(context, investment.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${investment.symbol} • ${_getAssetTypeName(investment.type)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${investment.quantity.toStringAsFixed(2)} @ ${CurrencyFormatter.formatCompact(investment.currentPrice)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatCompact(investment.totalValue),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: roi >= 0 ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${profitLoss >= 0 ? '+' : ''}${CurrencyFormatter.formatCompact(profitLoss)}',
                      style: TextStyle(
                        color: profitLoss >= 0 ? Colors.green : Colors.red,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getAssetTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return Colors.blue;
      case 'crypto':
        return Colors.orange;
      case 'gold':
        return Colors.amber;
      case 'bond':
        return Colors.green;
      case 'fund':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _getAssetTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return 'Cổ phiếu';
      case 'crypto':
        return 'Tiền điện tử';
      case 'gold':
        return 'Vàng';
      case 'bond':
        return 'Trái phiếu';
      case 'fund':
        return 'Quỹ đầu tư';
      default:
        return 'Khác';
    }
  }

  IconData _getAssetTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return Icons.trending_up;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'gold':
        return Icons.star;
      case 'bond':
        return Icons.account_balance;
      case 'fund':
        return Icons.pie_chart;
      default:
        return Icons.attach_money;
    }
  }

  void _showAddInvestmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddEditInvestmentBottomSheet(),
    );
  }

  void _editInvestment(BuildContext context, WidgetRef ref, investment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditInvestmentBottomSheet(
        investment: investment,
      ),
    );
  }

  Future<void> _deleteInvestment(BuildContext context, WidgetRef ref, investment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline, size: 48, color: Colors.red),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa khoản đầu tư "${investment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(investmentProvider.notifier).deleteInvestment(investment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khoản đầu tư'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showInvestmentDetails(BuildContext context, WidgetRef ref, investment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InvestmentDetailsSheet(investment: investment),
    );
  }
}

class _InvestmentDetailsSheet extends ConsumerWidget {
  final investment;

  const _InvestmentDetailsSheet({required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync =
        ref.watch(investmentTransactionsProvider(investment.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investment.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            investment.symbol,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInvestmentStats(context, ref),
                    const SizedBox(height: 20),
                    const Text(
                      'Lịch sử giao dịch',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    transactionsAsync.when(
                      data: (transactions) {
                        if (transactions.isEmpty) {
                          return const Center(
                            child: Text('Chưa có giao dịch nào'),
                          );
                        }
                        return Column(
                          children: transactions.map((transaction) {
                            return _buildTransactionItem(context, transaction);
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Lỗi: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvestmentStats(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(investmentProvider.notifier);
    final roi = notifier.calculateROI(investment);
    final profitLoss = investment.totalValue - investment.totalInvested;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(context, 'Giá hiện tại',
                  CurrencyFormatter.formatVND(investment.currentPrice)),
              _buildStatItem(
                  context, 'Số lượng', investment.quantity.toStringAsFixed(2)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(context, 'Tổng đầu tư',
                  CurrencyFormatter.formatVND(investment.totalInvested)),
              _buildStatItem(context, 'Giá trị hiện tại',
                  CurrencyFormatter.formatVND(investment.totalValue)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                  context, 'Lợi nhuận', CurrencyFormatter.formatVND(profitLoss),
                  color: profitLoss >= 0 ? Colors.green : Colors.red),
              _buildStatItem(context, 'ROI', '${roi.toStringAsFixed(1)}%',
                  color: roi >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, transaction) {
    final isBuy = transaction.type == 'buy';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isBuy ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.trending_up : Icons.trending_down,
              color: isBuy ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBuy ? 'Mua' : 'Bán',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${transaction.quantity} @ ${CurrencyFormatter.formatCompact(transaction.price)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(transaction.totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${transaction.transactionDate.day}/${transaction.transactionDate.month}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
