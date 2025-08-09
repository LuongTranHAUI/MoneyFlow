import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_screen.dart';
import 'goal_screen.dart';
import 'investment_screen.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  const PlanningScreen({super.key});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch'),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.pie_chart_rounded, size: 20),
              text: 'Ngân sách',
            ),
            Tab(
              icon: Icon(Icons.savings_rounded, size: 20),
              text: 'Tiết kiệm',
            ),
            Tab(
              icon: Icon(Icons.trending_up_rounded, size: 20),
              text: 'Đầu tư',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BudgetScreen(),
          GoalScreen(),
          InvestmentScreen(),
        ],
      ),
    );
  }
}