import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/thousand_separator_formatter.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_base.dart';
import 'package:finance_tracker/presentation/widgets/common/quick_amount_selector.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_action_buttons.dart';
import 'package:finance_tracker/domain/entities/transaction.dart' as trans;
import 'package:uuid/uuid.dart';

class AddMoneyToGoalBottomSheet extends ConsumerStatefulWidget {
  final GoalEntity goal;
  
  const AddMoneyToGoalBottomSheet({super.key, required this.goal});
  
  @override
  ConsumerState<AddMoneyToGoalBottomSheet> createState() => _AddMoneyToGoalBottomSheetState();
}

class _AddMoneyToGoalBottomSheetState extends ConsumerState<AddMoneyToGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    
    return BottomSheetBase(
      title: 'Thêm tiền vào mục tiêu',
      maxHeight: MediaQuery.of(context).size.height * 0.75,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoalInfoCard(context, remaining),
            const SizedBox(height: 24),
            _buildAmountInput(context),
            const SizedBox(height: 16),
            QuickAmountSelector(
              controller: _amountController,
              presetAmounts: const [100000, 500000, 1000000, 2000000],
              customAmount: remaining > 0 ? remaining : null,
              customLabel: remaining > 0 ? 'Hoàn thành' : null,
            ),
            const SizedBox(height: 32),
            BottomSheetActionButtons(
              onConfirm: _saveAmount,
              confirmText: 'Thêm tiền',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalInfoCard(BuildContext context, double remaining) {
    final progress = widget.goal.currentAmount / widget.goal.targetAmount;
    final goalColor = Color(int.parse(
      widget.goal.color?.replaceAll('#', '0xFF') ?? '0xFF2196F3'
    ));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            goalColor.withValues(alpha: 0.1),
            goalColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: goalColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: goalColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.goal.icon ?? '🎯',
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
                      widget.goal.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Còn lại: ${CurrencyFormatter.formatVND(remaining)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progress >= 1.0 
                      ? Colors.green.withValues(alpha: 0.2)
                      : goalColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: progress >= 1.0 ? Colors.green : goalColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressIndicator(context, progress, goalColor),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator(BuildContext context, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${CurrencyFormatter.formatCompact(widget.goal.currentAmount)} / ${CurrencyFormatter.formatCompact(widget.goal.targetAmount)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : color,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAmountInput(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandSeparatorInputFormatter(),
      ],
      autofocus: true,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: 'Số tiền thêm vào',
        hintText: '0',
        prefixIcon: const Icon(Icons.attach_money, size: 28),
        suffixText: '₫',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số tiền';
        }
        final amount = ThousandSeparatorParser.parse(value);
        if (amount == null || amount <= 0) {
          return 'Số tiền không hợp lệ';
        }
        return null;
      },
    );
  }
  
  void _saveAmount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final amount = ThousandSeparatorParser.parse(_amountController.text);
      if (amount != null) {
        final newAmount = widget.goal.currentAmount + amount;
        
        try {
          // Update goal amount
          await ref.read(goalProvider.notifier).updateGoal(
            id: widget.goal.id,
            name: widget.goal.name,
            description: widget.goal.description,
            targetAmount: widget.goal.targetAmount,
            currentAmount: newAmount,
            targetDate: widget.goal.targetDate,
            icon: widget.goal.icon,
            color: widget.goal.color,
          );
          
          // Create a transaction to deduct from balance
          const uuid = Uuid();
          final transaction = trans.Transaction(
            id: 0, // Will be set by database
            uuid: uuid.v4(),
            amount: amount,
            type: trans.TransactionType.expense,
            category: 'Tiết kiệm',
            description: 'Thêm vào mục tiêu: ${widget.goal.name}',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await ref.read(transactionProvider.notifier).addTransaction(transaction);
          
          if (mounted) {
            Navigator.pop(context);
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đã thêm ${CurrencyFormatter.formatVND(amount)} vào mục tiêu',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            
            // Show completion message if goal is completed
            if (newAmount >= widget.goal.targetAmount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Chúc mừng! Bạn đã hoàn thành mục tiêu!'),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }
  }
}