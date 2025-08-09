import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/presentation/providers/budget_provider.dart';
import 'package:finance_tracker/data/models/budget_model.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_base.dart';
import 'package:finance_tracker/presentation/widgets/common/icon_color_picker.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_action_buttons.dart';
import 'package:finance_tracker/core/utils/thousand_separator_formatter.dart';

class AddBudgetBottomSheet extends ConsumerStatefulWidget {
  const AddBudgetBottomSheet({super.key});
  
  @override
  ConsumerState<AddBudgetBottomSheet> createState() => _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends ConsumerState<AddBudgetBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedIcon = '💰';
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      title: 'Thêm ngân sách mới',
      maxHeight: MediaQuery.of(context).size.height * 0.75,
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
              availableIcons: const ['💰', '🍔', '🚗', '🛍️', '🎮', '📄', '🏠', '💊', '✈️', '🎓'],
              availableColors: const [
                Colors.blue, Colors.green, Colors.orange, Colors.purple,
                Colors.red, Colors.pink, Colors.teal, Colors.amber
              ],
              onIconSelected: (icon) => setState(() => _selectedIcon = icon),
              onColorSelected: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 20),
            
            // Category Input
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                hintText: 'VD: Ăn uống, Di chuyển...',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập danh mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Số tiền ngân sách',
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
            const SizedBox(height: 24),
            
            // Action Buttons
            BottomSheetActionButtons(
              onConfirm: _saveBudget,
              confirmText: 'Thêm',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final now = DateTime.now();
        await ref.read(budgetControllerProvider.notifier).createBudget(
          category: _categoryController.text,
          icon: _selectedIcon,
          color: _selectedColor.value,
          budgetAmount: double.parse(ThousandSeparatorParser.parseToString(_amountController.text)),
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, now.month + 1, 0),
        );
        
        if (mounted) {
          Navigator.pop(context);
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

class EditBudgetBottomSheet extends ConsumerStatefulWidget {
  final Budget budget;
  
  const EditBudgetBottomSheet({super.key, required this.budget});
  
  @override
  ConsumerState<EditBudgetBottomSheet> createState() => _EditBudgetBottomSheetState();
}

class _EditBudgetBottomSheetState extends ConsumerState<EditBudgetBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;
  late String _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.budget.category);
    // Format the amount with thousand separators when initializing
    _amountController = TextEditingController(
      text: CurrencyFormatter.addThousandsSeparator(widget.budget.budgetAmount.toStringAsFixed(0))
    );
    _selectedIcon = widget.budget.icon;
    _selectedColor = Color(widget.budget.color);
  }
  
  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      title: 'Chỉnh sửa ngân sách',
      maxHeight: MediaQuery.of(context).size.height * 0.75,
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
              availableIcons: const ['💰', '🍔', '🚗', '🛍️', '🎮', '📄', '🏠', '💊', '✈️', '🎓'],
              availableColors: const [
                Colors.blue, Colors.green, Colors.orange, Colors.purple,
                Colors.red, Colors.pink, Colors.teal, Colors.amber
              ],
              onIconSelected: (icon) => setState(() => _selectedIcon = icon),
              onColorSelected: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 20),
            
            // Category Input
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập danh mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Amount Input
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'Số tiền ngân sách',
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
            const SizedBox(height: 24),
            
            // Action Buttons
            BottomSheetActionButtons(
              onConfirm: _updateBudget,
              confirmText: 'Cập nhật',
              isLoading: _isLoading,
              showDeleteButton: true,
              onDelete: _deleteBudget,
            ),
          ],
        ),
      ),
    );
  }

  void _updateBudget() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(budgetControllerProvider.notifier).updateBudget(
          id: widget.budget.id,
          category: _categoryController.text,
          icon: _selectedIcon,
          color: _selectedColor.value,
          budgetAmount: double.parse(ThousandSeparatorParser.parseToString(_amountController.text)),
        );
        
        if (mounted) {
          Navigator.pop(context);
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

  void _deleteBudget() async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CompactBottomSheet(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Xóa ngân sách này?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hành động này không thể hoàn tác',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ConfirmationButtons(
                onCancel: () => Navigator.pop(context, false),
                onConfirm: () => Navigator.pop(context, true),
                confirmText: 'Xóa',
                isDangerous: true,
              ),
            ],
          ),
        ),
      ),
    );
    
    if (confirm == true) {
      await ref.read(budgetControllerProvider.notifier).deleteBudget(widget.budget.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}