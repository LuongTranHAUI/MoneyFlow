import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:finance_tracker/data/datasources/local/database.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';

class AddMoneyToGoalDialog extends ConsumerStatefulWidget {
  final GoalEntity goal;
  
  const AddMoneyToGoalDialog({super.key, required this.goal});
  
  @override
  ConsumerState<AddMoneyToGoalDialog> createState() => _AddMoneyToGoalDialogState();
}

class _AddMoneyToGoalDialogState extends ConsumerState<AddMoneyToGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm tiền vào mục tiêu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Goal Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.goal.icon ?? '🎯',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.goal.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Còn lại: ${CurrencyFormatter.formatVND(remaining)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Số tiền',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'VND',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Số tiền không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Quick amount buttons
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickAmountChip('100K', 100000),
                  _buildQuickAmountChip('500K', 500000),
                  _buildQuickAmountChip('1M', 1000000),
                  _buildQuickAmountChip('5M', 5000000),
                  if (remaining > 0)
                    _buildQuickAmountChip('Còn lại', remaining),
                ],
              ),
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addMoney,
                    child: const Text('Thêm tiền'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickAmountChip(String label, double amount) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _amountController.text = amount.toStringAsFixed(0);
      },
    );
  }
  
  void _addMoney() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        await ref.read(goalProvider.notifier).addMoneyToGoal(
          widget.goal.id,
          amount,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${CurrencyFormatter.formatVND(amount)} vào mục tiêu'),
            ),
          );
        }
      }
    }
  }
}