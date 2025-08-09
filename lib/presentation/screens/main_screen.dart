import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/presentation/screens/dashboard_screen.dart';
import 'package:finance_tracker/presentation/screens/transaction_screen.dart';
import 'package:finance_tracker/presentation/screens/planning_screen.dart';
import 'package:finance_tracker/presentation/screens/more_screen.dart';
import 'package:finance_tracker/presentation/widgets/add_transaction_bottom_sheet.dart';
import '../../core/utils/auth_debug.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    
    // Debug auth state when MainScreen builds
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AuthDebug.logAuthState();
      });
    }
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: _getScreenForIndex(currentIndex),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => ref.read(currentIndexProvider.notifier).state = index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.attach_money_outlined),
            selectedIcon: Icon(Icons.attach_money),
            label: 'Giao dịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.savings_outlined),
            selectedIcon: Icon(Icons.savings),
            label: 'Kế hoạch',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_outlined),
            selectedIcon: Icon(Icons.menu),
            label: 'Khác',
          ),
        ],
      ),
      floatingActionButton: currentIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                _showAddTransactionSheet(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _getScreenForIndex(int index) {
    // Add key to ensure AnimatedSwitcher recognizes different screens
    switch (index) {
      case 0:
        return const DashboardScreen(key: ValueKey('dashboard'));
      case 1:
        return const TransactionScreen(key: ValueKey('transaction'));
      case 2:
        return const PlanningScreen(key: ValueKey('planning'));
      case 3:
        return const MoreScreen(key: ValueKey('more'));
      default:
        return const DashboardScreen(key: ValueKey('dashboard'));
    }
  }
  
  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }
}