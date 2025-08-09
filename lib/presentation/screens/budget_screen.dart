import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/presentation/providers/budget_provider.dart';
import 'package:finance_tracker/data/models/budget_model.dart';
import 'package:finance_tracker/presentation/widgets/budget_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int monthDelta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + monthDelta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsyncValue = ref.watch(budgetsByMonthProvider(_selectedMonth));
    final totalBudgetAsyncValue =
        ref.watch(totalBudgetAmountByMonthProvider(_selectedMonth));
    final totalSpentAsyncValue =
        ref.watch(totalSpentAmountByMonthProvider(_selectedMonth));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
      ),
      body: budgetsAsyncValue.when(
        data: (budgets) {
          return totalBudgetAsyncValue.when(
            data: (totalBudget) {
              return totalSpentAsyncValue.when(
                data: (totalSpent) {
                  final remaining = totalBudget - totalSpent;
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(budgetsByMonthProvider(_selectedMonth));
                      ref.invalidate(
                          totalBudgetAmountByMonthProvider(_selectedMonth));
                      ref.invalidate(
                          totalSpentAmountByMonthProvider(_selectedMonth));
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthSelector(_selectedMonth),
                          const SizedBox(height: 20),
                          _buildOverviewCard(
                              totalBudget, totalSpent, remaining),
                          const SizedBox(height: 20),
                          _buildBudgetProgress(totalBudget, totalSpent),
                          const SizedBox(height: 20),
                          const Text(
                            'Chi tiết ngân sách',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (budgets.isEmpty)
                            Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Chưa có ngân sách nào',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thêm ngân sách đầu tiên của bạn',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _showAddBudgetDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Thêm ngân sách'),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...budgets
                                .map((budget) => _buildBudgetItem(budget)),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 16),
                      Text('Lỗi: $error'),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Lỗi: $error'),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Lỗi: $error'),
              const SizedBox(height: 8),
              Text(
                'Kéo xuống để làm mới',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector(DateTime currentMonth) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            'Tháng ${currentMonth.month}/${currentMonth.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      double totalBudget, double totalSpent, double remaining) {
    final isOverBudget = totalSpent > totalBudget;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? (isDarkMode 
                  ? [Colors.red.shade900, Colors.red.shade800]
                  : [Colors.red.shade400, Colors.red.shade600])
              : (isDarkMode
                  ? [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8)
                    ]
                  : [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8)
                    ]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : Theme.of(context).primaryColor)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng ngân sách',
                style: TextStyle(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                      : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverBudget ? 'Vượt ngân sách!' : 'Trong ngân sách',
                  style: TextStyle(
                    color: isDarkMode
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatVND(totalBudget),
            style: TextStyle(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewItem(
                label: 'Đã chi',
                amount: totalSpent,
                icon: Icons.shopping_cart,
              ),
              _buildOverviewItem(
                label: 'Còn lại',
                amount: remaining.abs(),
                icon:
                    isOverBudget ? Icons.warning : Icons.account_balance_wallet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required String label,
    required double amount,
    required IconData icon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2)
                : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
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
                    ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                    : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            Text(
              CurrencyFormatter.formatCompact(amount),
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

  Widget _buildBudgetProgress(double totalBudget, double totalSpent) {
    final percentage = (totalSpent / totalBudget * 100).clamp(0, 100);
    final isOverBudget = totalSpent > totalBudget;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ tổng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isOverBudget
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red : Theme.of(context).primaryColor,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${CurrencyFormatter.formatCompact(totalSpent)} / ${CurrencyFormatter.formatCompact(totalBudget)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(Budget budget) {
    final percentage = budget.percentageUsed.clamp(0, 200);
    final isOverBudget = budget.isOverBudget;
    final remaining = budget.remainingAmount;

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Slidable(
            key: ValueKey(budget.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _editBudget(budget),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  icon: Icons.edit,
                  label: 'Sửa',
                ),
                SlidableAction(
                  onPressed: (context) => _deleteBudget(budget),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  icon: Icons.delete,
                  label: 'Xóa',
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: Theme.of(context).brightness == Brightness.dark ? [] : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _showBudgetDetails(budget),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(budget.color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                budget.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOverBudget
                                      ? 'Vượt ${CurrencyFormatter.formatCompact(remaining.abs())}'
                                      : 'Còn ${CurrencyFormatter.formatCompact(remaining)}',
                                  style: TextStyle(
                                    color: isOverBudget
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.formatCompact(
                                    budget.spentAmount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      isOverBudget ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '/ ${CurrencyFormatter.formatCompact(budget.budgetAmount)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (percentage / 100).clamp(0, 1),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget ? Theme.of(context).colorScheme.error : Color(budget.color),
                          ),
                          minHeight: 6,
                        ),
                      ),
                      if (percentage > 100)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${percentage.toStringAsFixed(0)}% đã sử dụng',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )));
  }

  void _showBudgetDetails(Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(budget.color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        budget.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ngân sách tháng này',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Add more details here like transaction list for this category
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailCard(
                      'Ngân sách',
                      CurrencyFormatter.formatVND(budget.budgetAmount),
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      'Đã chi',
                      CurrencyFormatter.formatVND(budget.spentAmount),
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      'Còn lại',
                      CurrencyFormatter.formatVND(
                          (budget.budgetAmount - budget.spentAmount).abs()),
                      budget.spentAmount > budget.budgetAmount
                          ? Colors.red
                          : Colors.green,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Giao dịch gần đây',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Chưa có giao dịch',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _editBudget(Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBudgetBottomSheet(budget: budget),
    );
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ngân sách'),
        content: Text(
          'Bạn có chắc chắn muốn xóa ngân sách "${budget.category}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final budgetController = ref.read(budgetControllerProvider.notifier);
      await budgetController.deleteBudget(budget.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ngân sách "${budget.category}"'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  void _showAddBudgetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBudgetBottomSheet(),
    );
  }

  void _showEditBudgetDialog(Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBudgetBottomSheet(budget: budget),
    );
  }
}
