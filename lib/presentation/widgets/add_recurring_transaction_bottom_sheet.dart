import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recurring_transaction_provider.dart';
import '../providers/category_provider.dart';
import '../../core/utils/currency_formatter.dart';

class AddRecurringTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddRecurringTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddRecurringTransactionBottomSheet> createState() => _AddRecurringTransactionBottomSheetState();
}

class _AddRecurringTransactionBottomSheetState extends ConsumerState<AddRecurringTransactionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'expense';
  String _selectedCategory = 'Ăn uống';
  String _selectedFrequency = 'monthly';
  int _interval = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoExecute = false;
  bool _isLoading = false;

  final Map<String, String> _frequencies = {
    'daily': 'Ngày',
    'weekly': 'Tuần', 
    'monthly': 'Tháng',
    'yearly': 'Năm',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final availableCategories = categories
        .where((cat) => cat.type == _selectedType || cat.type == 'both')
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Thêm giao dịch định kỳ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                
                // Form Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Transaction Type Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedType = 'income';
                                    _selectedCategory = availableCategories.isNotEmpty 
                                        ? availableCategories.first.name 
                                        : 'Thu nhập';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedType == 'income' 
                                        ? Theme.of(context).colorScheme.primary 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Thu nhập',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _selectedType == 'income' 
                                          ? Theme.of(context).colorScheme.onPrimary 
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedType = 'expense';
                                    _selectedCategory = availableCategories.isNotEmpty 
                                        ? availableCategories.first.name 
                                        : 'Ăn uống';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedType == 'expense' 
                                        ? Theme.of(context).colorScheme.error 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Chi tiêu',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _selectedType == 'expense' 
                                          ? Theme.of(context).colorScheme.onError 
                                          : Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên giao dịch',
                          hintText: 'VD: Lương hàng tháng, Tiền nhà...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên giao dịch';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money),
                          suffixText: '₫',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ThousandsSeparatorInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                      
                      // Category
                      DropdownButtonFormField<String>(
                        value: availableCategories.any((cat) => cat.name == _selectedCategory) 
                            ? _selectedCategory 
                            : (availableCategories.isNotEmpty ? availableCategories.first.name : null),
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Row(
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn danh mục';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Frequency and Interval
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              value: _selectedFrequency,
                              decoration: InputDecoration(
                                labelText: 'Tần suất',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.repeat),
                              ),
                              items: _frequencies.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFrequency = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _interval.toString(),
                              decoration: InputDecoration(
                                labelText: 'Mỗi',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixText: _frequencies[_selectedFrequency],
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                _interval = int.tryParse(value) ?? 1;
                              },
                              validator: (value) {
                                final interval = int.tryParse(value ?? '');
                                if (interval == null || interval < 1) {
                                  return 'Không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Start Date
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Ngày bắt đầu'),
                        subtitle: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // End Date (Optional)
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Ngày kết thúc (tùy chọn)'),
                        subtitle: Text(
                          _endDate != null 
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Không giới hạn',
                        ),
                        trailing: _endDate != null 
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _endDate = null;
                                  });
                                },
                              )
                            : null,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                            firstDate: _startDate,
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Auto Execute Toggle
                      SwitchListTile(
                        title: const Text('Tự động thực hiện'),
                        subtitle: const Text('Tự động tạo giao dịch khi đến hạn'),
                        value: _autoExecute,
                        onChanged: (value) {
                          setState(() {
                            _autoExecute = value;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú (tùy chọn)',
                          hintText: 'Thông tin bổ sung...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Bottom Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                              ),
                            )
                          : const Text(
                              'Tạo giao dịch định kỳ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      
      await ref.read(recurringTransactionProvider.notifier).addRecurringTransaction(
        name: _nameController.text.trim(),
        amount: amount,
        type: _selectedType,
        category: _selectedCategory,
        frequency: _selectedFrequency,
        interval: _interval,
        startDate: _startDate,
        endDate: _endDate,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        autoExecute: _autoExecute,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã tạo giao dịch định kỳ thành công'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Custom input formatter for thousands separator
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = CurrencyFormatter.addThousandsSeparator(numericOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}