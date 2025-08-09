import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_base.dart';
import 'package:finance_tracker/presentation/widgets/common/icon_color_picker.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_action_buttons.dart';
import 'package:finance_tracker/core/utils/thousand_separator_formatter.dart';

class AddGoalBottomSheet extends ConsumerStatefulWidget {
  const AddGoalBottomSheet({super.key});

  @override
  ConsumerState<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends ConsumerState<AddGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _selectedIcon = '🎯';
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      title: 'Tạo mục tiêu mới',
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Color Picker
            IconColorPicker(
              selectedIcon: _selectedIcon,
              selectedColor: _selectedColor,
              availableIcons: IconColorPicker.defaultIcons,
              availableColors: IconColorPicker.defaultColors,
              onIconSelected: (icon) => setState(() => _selectedIcon = icon),
              onColorSelected: (color) =>
                  setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 20),

            // Name Input
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên mục tiêu',
                hintText: 'VD: Mua xe máy',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên mục tiêu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Input
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'VD: Tiết kiệm để mua xe đi làm',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Số tiền mục tiêu',
                hintText: '0',
                prefixIcon: const Icon(Icons.attach_money, size: 28),
                suffixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Số tiền hiện có',
                hintText: '0',
                prefixIcon: const Icon(Icons.savings),
                suffixText: 'VND',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Target Date Selection
            InkWell(
              onTap: _selectTargetDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày mục tiêu',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            BottomSheetActionButtons(
              onConfirm: _saveGoal,
              confirmText: 'Tạo mục tiêu',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _selectedColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }

  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final targetAmount =
          ThousandSeparatorParser.parse(_targetAmountController.text);
      final currentAmount =
          ThousandSeparatorParser.parse(_currentAmountController.text) ?? 0;

      if (targetAmount != null) {
        try {
          await ref.read(goalProvider.notifier).addGoal(
                name: _nameController.text,
                description: _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
                targetAmount: targetAmount,
                currentAmount: currentAmount,
                targetDate: _targetDate,
                icon: _selectedIcon,
                color:
                    '#${_selectedColor.value.toRadixString(16).substring(2)}',
              );

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text('Mục tiêu đã được tạo thành công'),
                  ],
                ),
                backgroundColor: Colors.green,
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
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }
  }
}
