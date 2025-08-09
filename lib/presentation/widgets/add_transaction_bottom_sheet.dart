import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/presentation/providers/transaction_provider.dart';
import 'package:finance_tracker/presentation/providers/category_provider.dart';
import 'package:finance_tracker/domain/entities/transaction.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_base.dart';
import 'package:finance_tracker/presentation/widgets/common/quick_amount_selector.dart';
import 'package:finance_tracker/presentation/widgets/common/bottom_sheet_action_buttons.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/thousand_separator_formatter.dart';
import 'package:finance_tracker/core/services/business_logic_service.dart';
import 'package:uuid/uuid.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});
  
  @override
  ConsumerState<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends ConsumerState<AddTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'expense';
  String _selectedCategory = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final filteredCategories = categories.where((c) => 
      c.type == _selectedType || c.type == 'both'
    ).toList();
    
    return BottomSheetBase(
      title: 'Thêm giao dịch',
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      type: 'income',
                      label: 'Thu nhập',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildTypeButton(
                      context,
                      type: 'expense',
                      label: 'Chi tiêu',
                      icon: Icons.arrow_upward,
                      color: Colors.red,
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                ThousandSeparatorInputFormatter(),
              ],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'Số tiền',
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
            const SizedBox(height: 12),
            
            // Quick Amount Selector
            QuickAmountSelector(
              controller: _amountController,
              presetAmounts: const [50000, 100000, 200000, 500000],
            ),
            const SizedBox(height: 20),
            
            // Category Selector
            _buildCategorySelector(filteredCategories),
            const SizedBox(height: 16),
            
            // Date Selector
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ngày giao dịch',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Description Input (moved to bottom)
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Nhập ghi chú (tùy chọn)',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            BottomSheetActionButtons(
              onConfirm: _saveTransaction,
              confirmText: 'Lưu',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeButton(
    BuildContext context, {
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _selectedType = type),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector(List<dynamic> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category.name;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category.name),
                child: Container(
                  width: 75,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(int.parse(category.color.replaceAll('#', '0xFF')))
                                  .withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Color(int.parse(category.color.replaceAll('#', '0xFF')))
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
  
  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final amountText = ThousandSeparatorParser.parseToString(_amountController.text);
      final amount = double.parse(amountText);
      
      // Kiểm tra ngân sách trước khi thêm chi tiêu
      if (_selectedType == 'expense') {
        await _handleExpenseTransaction(amount);
      } else {
        await _handleIncomeTransaction(amount);
      }
    }
  }

  Future<void> _handleExpenseTransaction(double amount) async {
    setState(() => _isLoading = true);
    
    try {
      final businessLogic = ref.read(businessLogicServiceProvider);
      
      // Kiểm tra ngân sách
      final budgetResult = await businessLogic.checkBudgetOverspend(
        category: _selectedCategory,
        amount: amount,
        date: _selectedDate,
      );
      
      // Hiển thị cảnh báo ngân sách nếu cần
      if (budgetResult.hasWarning) {
        final shouldContinue = await _showBudgetWarningDialog(budgetResult);
        if (!shouldContinue) {
          setState(() => _isLoading = false);
          return;
        }
      }
      
      // Tạo và lưu transaction
      await _createAndSaveTransaction(amount, budgetResult: budgetResult);
      
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _handleIncomeTransaction(double amount) async {
    setState(() => _isLoading = true);
    
    try {
      final businessLogic = ref.read(businessLogicServiceProvider);
      
      // Xử lý phân bổ thu nhập
      final incomeResult = await businessLogic.processIncomeTransaction(
        amount: amount,
        date: _selectedDate,
      );
      
      // Tạo và lưu transaction
      await _createAndSaveTransaction(amount, incomeResult: incomeResult);
      
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _createAndSaveTransaction(
    double amount, {
    BudgetCheckResult? budgetResult,
    IncomeAllocationResult? incomeResult,
  }) async {
    final now = DateTime.now();
    final transaction = Transaction(
      uuid: const Uuid().v4(),
      amount: amount,
      type: _selectedType == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      category: _selectedCategory,
      description: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
      date: _selectedDate,
      createdAt: now,
      updatedAt: now,
    );
    
    // Lưu transaction
    await ref.read(transactionProvider.notifier).addTransaction(transaction);
    
    // Tạo notification
    final businessLogic = ref.read(businessLogicServiceProvider);
    await businessLogic.createTransactionNotification(
      type: _selectedType,
      category: _selectedCategory,
      amount: amount,
      budgetResult: budgetResult,
      incomeResult: incomeResult,
    );
    
    if (mounted) {
      Navigator.pop(context);
      _showSuccessMessage(amount, budgetResult, incomeResult);
    }
  }

  Future<bool> _showBudgetWarningDialog(BudgetCheckResult result) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          result.overspendAmount > 0 ? Icons.warning_amber : Icons.info,
          size: 48,
          color: result.overspendAmount > 0 ? Colors.orange : Colors.blue,
        ),
        title: Text(result.overspendAmount > 0 ? 'Cảnh báo vượt ngân sách!' : 'Thông báo ngân sách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildBudgetRow('Ngân sách:', result.budgetAmount),
                  _buildBudgetRow('Đã chi:', result.currentSpent),
                  if (result.overspendAmount > 0)
                    _buildBudgetRow('Vượt:', result.overspendAmount, isNegative: true),
                  if (result.remainingAmount > 0)
                    _buildBudgetRow('Còn lại:', result.remainingAmount, isPositive: true),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(result.overspendAmount > 0 ? 'Vẫn thêm' : 'Tiếp tục'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildBudgetRow(String label, double amount, {bool isNegative = false, bool isPositive = false}) {
    Color? color;
    if (isNegative) color = Colors.red;
    if (isPositive) color = Colors.green;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            CurrencyFormatter.formatVND(amount),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(
    double amount,
    BudgetCheckResult? budgetResult,
    IncomeAllocationResult? incomeResult,
  ) {
    String message = 'Đã thêm ${CurrencyFormatter.formatVND(amount)}';
    Color backgroundColor = Colors.green;
    IconData icon = Icons.check_circle;
    
    // Thêm thông tin phân bổ cho thu nhập
    if (_selectedType == 'income' && incomeResult != null && incomeResult.totalAllocated > 0) {
      message += '\n${incomeResult.message}';
    }
    
    // Thêm cảnh báo ngân sách cho chi tiêu
    if (_selectedType == 'expense' && budgetResult != null && budgetResult.hasWarning) {
      if (budgetResult.overspendAmount > 0) {
        backgroundColor = Colors.orange;
        icon = Icons.warning;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleError(dynamic error) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}