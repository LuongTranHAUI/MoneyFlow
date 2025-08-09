import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/date_formatter.dart';
import 'package:finance_tracker/core/themes/app_theme.dart';
import 'package:finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:finance_tracker/presentation/widgets/notification_icon_with_badge.dart';
import 'package:finance_tracker/presentation/screens/main_screen.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);
    final transactionNotifier = ref.read(transactionProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          const NotificationIconWithBadge(),
        ],
      ),
      body: transactionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => transactionNotifier.loadTransactions(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context, transactionNotifier),
                    const SizedBox(height: 20),
                    _buildQuickStats(context, transactionState.transactions),
                    const SizedBox(height: 20),
                    _buildGoalsProgress(context, ref),
                    const SizedBox(height: 20),
                    _buildSpendingChart(context, transactionState.transactions),
                    const SizedBox(height: 20),
                    _buildRecentTransactions(context, ref, transactionState.transactions),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildBalanceCard(BuildContext context, TransactionNotifier notifier) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDarkMode 
          ? LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
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
            'Số dư hiện tại',
            style: TextStyle(
              color: isDarkMode 
                ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatVND(notifier.balance),
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
              _buildBalanceItem(
                context,
                icon: Icons.trending_up,
                label: 'Thu nhập',
                amount: notifier.totalIncome,
                color: AppTheme.incomeColor,
              ),
              _buildBalanceItem(
                context,
                icon: Icons.trending_down,
                label: 'Chi tiêu',
                amount: notifier.totalExpense,
                color: AppTheme.expenseColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
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
                  ? Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                  : Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
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
  
  Widget _buildQuickStats(BuildContext context, List<Transaction> transactions) {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final endOfMonth = DateTime(today.year, today.month + 1, 0);
    
    final monthTransactions = transactions.where((t) {
      return t.date.isAfter(startOfMonth) && t.date.isBefore(endOfMonth);
    }).toList();
    
    final monthIncome = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final monthExpense = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.account_balance_wallet,
            label: 'Thu nhập tháng',
            value: CurrencyFormatter.formatCompact(monthIncome),
            color: AppTheme.incomeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.credit_card,
            label: 'Chi tiêu tháng',
            value: CurrencyFormatter.formatCompact(monthExpense),
            color: AppTheme.expenseColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isDarkMode ? [] : [
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
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpendingChart(BuildContext context, List<Transaction> transactions) {
    // Group transactions by category for the current month
    final today = DateTime.now();
    final monthTransactions = transactions.where((t) {
      return t.date.month == today.month && 
             t.date.year == today.year &&
             t.type == TransactionType.expense;
    }).toList();
    
    final categoryTotals = <String, double>{};
    for (final transaction in monthTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories.take(5).toList();
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isDarkMode ? [] : [
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
            'Chi tiêu theo danh mục',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (topCategories.isEmpty)
            Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: topCategories.map((entry) {
                    final total = categoryTotals.values.reduce((a, b) => a + b);
                    final percentage = (entry.value / total * 100);
                    
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getCategoryColor(entry.key),
                      radius: 60,
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
          ...topCategories.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
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
  
  Color _getCategoryColor(String category) {
    final colors = [
      const Color(0xFF2E7D32),  // Green
      const Color(0xFF388E3C),  // Light Green
      const Color(0xFF00796B),  // Teal
      const Color(0xFF00897B),  // Cyan-Teal
      const Color(0xFF43A047),  // Green 600
      const Color(0xFF558B2F),  // Light Green 700
      const Color(0xFF6A4C93),  // Purple
      const Color(0xFF5E35B1),  // Deep Purple
    ];
    
    final index = category.hashCode % colors.length;
    return colors[index];
  }
  
  Widget _buildRecentTransactions(BuildContext context, WidgetRef ref, List<Transaction> transactions) {
    final recentTransactions = transactions.take(5).toList();
    
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
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Switch to transaction tab
                  ref.read(currentIndexProvider.notifier).state = 1;
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Chưa có giao dịch',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            )
          else
            ...recentTransactions.map((transaction) => _buildTransactionItem(context, transaction)),
        ],
      ),
    );
  }
  
  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
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
                    fontSize: 14,
                  ),
                ),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
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
                '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCompact(transaction.amount)}',
                style: TextStyle(
                  color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormatter.formatRelative(transaction.date),
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
  
  Widget _buildGoalsProgress(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(goalProvider);
    final activeGoals = goalState.goals.where((g) => !g.isCompleted).take(3).toList();
    
    if (activeGoals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: isDarkMode ? [] : [
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
                'Tiến độ mục tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Set planning tab to Goals (index 1)
                  ref.read(planningTabIndexProvider.notifier).state = 1;
                  // Navigate to Planning screen (index 2)
                  ref.read(currentIndexProvider.notifier).state = 2;
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activeGoals.map((goal) {
            final progress = goal.targetAmount > 0 ? goal.currentAmount / goal.targetAmount : 0.0;
            final progressPercent = (progress * 100).clamp(0, 100).toInt();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$progressPercent%',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.formatCompact(goal.currentAmount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatCompact(goal.targetAmount),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}