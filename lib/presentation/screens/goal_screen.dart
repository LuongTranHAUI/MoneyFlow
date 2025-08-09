import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/date_formatter.dart';
import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:finance_tracker/presentation/widgets/add_goal_bottom_sheet.dart';
import 'package:finance_tracker/presentation/widgets/add_money_to_goal_bottom_sheet.dart';
import 'package:finance_tracker/presentation/widgets/withdraw_money_from_goal_bottom_sheet.dart';
import 'package:finance_tracker/presentation/screens/edit_goal_screen.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';

class GoalScreen extends ConsumerStatefulWidget {
  const GoalScreen({super.key});

  @override
  ConsumerState<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends ConsumerState<GoalScreen> {
  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalProvider);
    final goalNotifier = ref.read(goalProvider.notifier);

    if (goalState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeGoals = goalNotifier.activeGoals;
    final completedGoals = goalNotifier.completedGoals;
    final totalSaved = goalNotifier.totalSaved;
    final totalTarget = goalNotifier.totalTarget;

    // Separate emergency fund from regular goals
    final emergencyFund =
        activeGoals.where((g) => g.category == 'emergency_fund').firstOrNull;
    final regularActiveGoals =
        activeGoals.where((g) => g.category != 'emergency_fund').toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => goalNotifier.loadGoals(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCard(totalSaved, totalTarget),
              const SizedBox(height: 20),
              _buildQuickStats(activeGoals, completedGoals),
              const SizedBox(height: 20),
              // Emergency Fund Section
              if (emergencyFund != null) ...[
                _buildEmergencyFundCard(emergencyFund),
                const SizedBox(height: 20),
              ] else ...[
                _buildCreateEmergencyFundCard(),
                const SizedBox(height: 20),
              ],
              if (regularActiveGoals.isNotEmpty) ...[
                const Text(
                  'Mục tiêu đang thực hiện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...regularActiveGoals.map((goal) => _buildGoalCard(goal)),
                const SizedBox(height: 20),
              ],
              if (completedGoals.isNotEmpty) ...[
                const Text(
                  'Mục tiêu đã hoàn thành',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedGoals.map((goal) => _buildGoalCard(goal)),
              ],
              if (goalState.goals.isEmpty) _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(double totalSaved, double totalTarget) {
    final percentage = totalTarget > 0 ? (totalSaved / totalTarget * 100) : 0;
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
            'Tổng tiết kiệm',
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
            CurrencyFormatter.formatVND(totalSaved),
            style: TextStyle(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0, 1),
            backgroundColor: isDarkMode
                ? Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.3)
                : Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(isDarkMode
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onPrimary),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}% của mục tiêu',
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
                CurrencyFormatter.formatCompact(totalTarget),
                style: TextStyle(
                  color: isDarkMode
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      List<GoalEntity> activeGoals, List<GoalEntity> completedGoals) {
    final almostComplete = activeGoals.where((g) {
      final percentage = g.currentAmount / g.targetAmount * 100;
      return percentage >= 80;
    }).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.flag,
            label: 'Đang thực hiện',
            value: activeGoals.length.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            label: 'Sắp hoàn thành',
            value: almostComplete.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Đã đạt',
            value: completedGoals.length.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blue;
    try {
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildGoalCard(GoalEntity goal) {
    final percentage =
        (goal.currentAmount / goal.targetAmount * 100).clamp(0, 100);
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final monthlyRequired =
        daysLeft > 0 && !goal.isCompleted ? remaining / (daysLeft / 30) : 0;

    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Slidable(
            key: ValueKey(goal.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                if (!goal.isCompleted)
                  SlidableAction(
                    onPressed: (context) =>
                        _handleGoalAction('add_money', goal),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    icon: Icons.add_circle,
                    label: 'Thêm',
                  ),
                if (goal.currentAmount > 0)
                  SlidableAction(
                    onPressed: (context) =>
                        _handleGoalAction('withdraw_money', goal),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    icon: Icons.remove_circle,
                    label: 'Rút',
                  ),
                SlidableAction(
                  onPressed: (context) => _handleGoalAction('delete', goal),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  icon: Icons.delete,
                  label: 'Xóa',
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _showGoalDetails(goal),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(goal.color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                goal.icon ?? '🎯',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        goal.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    if (goal.isCompleted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Hoàn thành',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.isCompleted
                                      ? 'Đã đạt mục tiêu!'
                                      : daysLeft > 0
                                          ? 'Còn $daysLeft ngày'
                                          : 'Quá hạn',
                                  style: TextStyle(
                                    color: goal.isCompleted
                                        ? Colors.green
                                        : daysLeft > 30
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant
                                            : Colors.orange,
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
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: goal.isCompleted
                                      ? Colors.green
                                      : _getColorFromHex(goal.color),
                                ),
                              ),
                              Text(
                                DateFormatter.formatDayMonth(goal.targetDate),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: goal.isCompleted
                                    ? Colors.green
                                    : _getColorFromHex(goal.color),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatCompact(goal.currentAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (!goal.isCompleted && monthlyRequired > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${CurrencyFormatter.formatCompact(monthlyRequired.toDouble())}/tháng',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Text(
                            CurrencyFormatter.formatCompact(goal.targetAmount),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  // End of _buildGoalCard

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có mục tiêu nào',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo mục tiêu tiết kiệm để theo dõi tiến độ',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddGoalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tạo mục tiêu'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(GoalEntity goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(goal.color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                goal.icon ?? '🎯',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Mục tiêu đến ${DateFormatter.formatFullDate(goal.targetDate)}',
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
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditGoalScreen(goal: goal),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildProgressSection(goal),
                      const SizedBox(height: 24),
                      _buildStatisticsSection(goal),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(GoalEntity goal) {
    final percentage =
        (goal.currentAmount / goal.targetAmount * 100).clamp(0, 100);
    final remaining = goal.targetAmount - goal.currentAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến độ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 4,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.isCompleted
                              ? Colors.green
                              : _getColorFromHex(goal.color),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: goal.isCompleted
                                ? Colors.green
                                : _getColorFromHex(goal.color),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.isCompleted ? 'Hoàn thành' : 'Đã đạt',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã tiết kiệm',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.formatVND(goal.currentAmount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: goal.isCompleted
                              ? Colors.green
                              : _getColorFromHex(goal.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Còn lại',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.formatVND(
                            goal.isCompleted ? 0 : remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color:
                              goal.isCompleted ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(GoalEntity goal) {
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final remaining = goal.targetAmount - goal.currentAmount;
    final dailyRequired =
        daysLeft > 0 && !goal.isCompleted ? remaining / daysLeft : 0;
    final monthlyRequired =
        daysLeft > 0 && !goal.isCompleted ? remaining / (daysLeft / 30) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thống kê',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          'Thời gian còn lại',
          daysLeft > 0 ? '$daysLeft ngày' : 'Đã quá hạn',
          Icons.calendar_today,
          daysLeft > 30 ? Colors.blue : Colors.orange,
        ),
        _buildStatRow(
          'Cần tiết kiệm mỗi ngày',
          CurrencyFormatter.formatCompact(dailyRequired.toDouble()),
          Icons.today,
          Colors.purple,
        ),
        _buildStatRow(
          'Cần tiết kiệm mỗi tháng',
          CurrencyFormatter.formatCompact(monthlyRequired.toDouble()),
          Icons.calendar_month,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalBottomSheet(),
    );
  }

  Widget _buildEmergencyFundCard(GoalEntity emergencyFund) {
    final progress = emergencyFund.targetAmount > 0
        ? emergencyFund.currentAmount / emergencyFund.targetAmount
        : 0.0;
    final progressPercent = (progress * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade600,
            Colors.orange.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quỹ Khẩn cấp',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  if (emergencyFund.currentAmount > 0)
                    IconButton(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => WithdrawMoneyFromGoalBottomSheet(
                            goal: emergencyFund),
                      ),
                      icon: Icon(
                        Icons.remove_circle,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'Rút tiền',
                    ),
                  IconButton(
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) =>
                          AddMoneyToGoalBottomSheet(goal: emergencyFund),
                    ),
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    tooltip: 'Thêm tiền',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.formatVND(emergencyFund.currentAmount),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'của ${CurrencyFormatter.formatVND(emergencyFund.targetAmount)}',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progressPercent.toStringAsFixed(1)}% hoàn thành',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                _getEmergencyFundStatus(progress),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateEmergencyFundCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade200, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.orange.shade50,
      ),
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: 48,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'Tạo Quỹ Khẩn cấp',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quỹ khẩn cấp giúp bạn đối phó với những chi phí bất ngờ.\nNên có ít nhất 3-6 tháng chi tiêu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange.shade600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createEmergencyFund,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tạo quỹ khẩn cấp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmergencyFundStatus(double progress) {
    if (progress >= 1.0) {
      return '🛡️ An toàn';
    } else if (progress >= 0.75) {
      return '🟢 Tốt';
    } else if (progress >= 0.5) {
      return '🟡 Khá';
    } else if (progress >= 0.25) {
      return '🟠 Cần cải thiện';
    } else {
      return '🔴 Rủi ro cao';
    }
  }

  void _createEmergencyFund() {
    showDialog(
      context: context,
      builder: (context) => _EmergencyFundCreationDialog(
        onConfirm: (targetAmount) {
          ref.read(goalProvider.notifier).addGoal(
                name: 'Quỹ Khẩn cấp',
                targetAmount: targetAmount,
                targetDate: DateTime.now().add(const Duration(days: 365)),
                description: 'Quỹ dự phòng cho các trường hợp khẩn cấp',
                category: 'emergency_fund',
                priority: 1,
              );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _handleGoalAction(String action, GoalEntity goal) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditGoalScreen(goal: goal),
          ),
        );
        break;
      case 'add_money':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddMoneyToGoalBottomSheet(goal: goal),
        );
        break;
      case 'withdraw_money':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WithdrawMoneyFromGoalBottomSheet(goal: goal),
        );
        break;
      case 'delete':
        _confirmDeleteGoal(goal);
        break;
    }
  }

  void _showGoalOptionsMenu(BuildContext context, GoalEntity goal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              goal.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Chỉnh sửa mục tiêu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGoalScreen(goal: goal),
                  ),
                );
              },
            ),
            if (!goal.isCompleted)
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Thêm tiền vào mục tiêu'),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddMoneyToGoalBottomSheet(goal: goal),
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Xóa mục tiêu',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteGoal(goal);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGoal(GoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text(
          'Bạn có chắc chắn muốn xóa mục tiêu "${goal.name}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteGoal(goal);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGoal(GoalEntity goal) async {
    try {
      final goalNotifier = ref.read(goalProvider.notifier);
      await goalNotifier.deleteGoal(goal.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa mục tiêu "${goal.name}"'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'Hoàn tác',
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa mục tiêu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// Emergency Fund Creation Dialog
class _EmergencyFundCreationDialog extends StatefulWidget {
  final Function(double) onConfirm;

  const _EmergencyFundCreationDialog({required this.onConfirm});

  @override
  State<_EmergencyFundCreationDialog> createState() =>
      __EmergencyFundCreationDialogState();
}

class __EmergencyFundCreationDialogState
    extends State<_EmergencyFundCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _monthlyExpenses = 10000000; // Default 10M VND

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo Quỹ Khẩn cấp'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quỹ khẩn cấp nên bằng 3-6 tháng chi phí sinh hoạt của bạn.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Mục tiêu quỹ khẩn cấp',
                hintText: '30,000,000',
                prefixIcon: Icon(Icons.attach_money),
                suffixText: '₫',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null || amount <= 0) {
                  return 'Số tiền không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _amountController.text =
                          CurrencyFormatter.addThousandsSeparator(
                        (_monthlyExpenses * 3).toInt().toString(),
                      );
                    },
                    child: const Text('3 tháng'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _amountController.text =
                          CurrencyFormatter.addThousandsSeparator(
                        (_monthlyExpenses * 6).toInt().toString(),
                      );
                    },
                    child: const Text('6 tháng'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final amount =
                  double.parse(_amountController.text.replaceAll(',', ''));
              widget.onConfirm(amount);
            }
          },
          child: const Text('Tạo quỹ'),
        ),
      ],
    );
  }
}
