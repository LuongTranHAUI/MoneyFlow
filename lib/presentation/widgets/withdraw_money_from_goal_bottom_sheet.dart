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

class WithdrawMoneyFromGoalBottomSheet extends ConsumerStatefulWidget {
  final GoalEntity goal;
  
  const WithdrawMoneyFromGoalBottomSheet({super.key, required this.goal});
  
  @override
  ConsumerState<WithdrawMoneyFromGoalBottomSheet> createState() => _WithdrawMoneyFromGoalBottomSheetState();
}

class _WithdrawMoneyFromGoalBottomSheetState extends ConsumerState<WithdrawMoneyFromGoalBottomSheet> {
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
    final currentAmount = widget.goal.currentAmount;
    
    return BottomSheetBase(
      title: 'Rút tiền từ mục tiêu',
      maxHeight: MediaQuery.of(context).size.height * 0.75,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoalInfoCard(context, currentAmount),
            const SizedBox(height: 24),
            _buildAmountInput(context, currentAmount),
            const SizedBox(height: 16),
            QuickAmountSelector(
              controller: _amountController,
              presetAmounts: const [100000, 500000, 1000000, 2000000],
              customAmount: currentAmount > 0 ? currentAmount : null,
              customLabel: currentAmount > 0 ? 'Rút hết' : null,
            ),
            const SizedBox(height: 32),
            BottomSheetActionButtons(
              onConfirm: _withdrawAmount,
              confirmText: 'Rút tiền',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalInfoCard(BuildContext context, double currentAmount) {
    final progress = widget.goal.currentAmount / widget.goal.targetAmount;
    final goalColor = Color(int.parse(
      widget.goal.color?.replaceAll('#', '0xFF') ?? '0xFF2196F3'
    ));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
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
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.trending_down, color: Colors.orange),
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
                      'Số dư hiện tại: ${CurrencyFormatter.formatVND(currentAmount)}',
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
                  color: goalColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: goalColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountInput(BuildContext context, double maxAmount) {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.start,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        ThousandSeparatorInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: 'Số tiền rút',
        hintText: '0',
        prefixIcon: const Icon(Icons.attach_money, size: 28),
        suffixText: '₫',
        helperText: 'Tối đa: ${CurrencyFormatter.formatVND(maxAmount)}',
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
        if (amount > maxAmount) {
          return 'Vượt quá số dư hiện tại';
        }
        return null;
      },
    );
  }
  
  void _withdrawAmount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final amount = ThousandSeparatorParser.parse(_amountController.text);
      if (amount != null) {
        final newAmount = widget.goal.currentAmount - amount;
        
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
          
          // Create a transaction to add back to balance
          const uuid = Uuid();
          final transaction = trans.Transaction(
            id: 0, // Will be set by database
            uuid: uuid.v4(),
            amount: amount,
            type: trans.TransactionType.income,
            category: 'Rút tiền',
            description: 'Rút từ mục tiêu: ${widget.goal.name}',
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
                        'Đã rút ${CurrencyFormatter.formatVND(amount)} từ mục tiêu',
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}