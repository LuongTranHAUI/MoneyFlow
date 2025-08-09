import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/investment_provider.dart';
import '../../core/utils/currency_formatter.dart';

class AddInvestmentBottomSheet extends ConsumerStatefulWidget {
  const AddInvestmentBottomSheet({super.key});

  @override
  ConsumerState<AddInvestmentBottomSheet> createState() => _AddInvestmentBottomSheetState();
}

class _AddInvestmentBottomSheetState extends ConsumerState<AddInvestmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = 'stock';
  bool _isLoading = false;

  final Map<String, String> _investmentTypes = {
    'stock': 'Cổ phiếu',
    'crypto': 'Tiền điện tử',
    'gold': 'Vàng',
    'bond': 'Trái phiếu',
    'fund': 'Quỹ đầu tư',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Thêm khoản đầu tư',
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
                      // Investment Type
                      const Text(
                        'Loại đầu tư',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _investmentTypes.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Row(
                              children: [
                                Icon(
                                  _getAssetTypeIcon(entry.key),
                                  size: 20,
                                  color: _getAssetTypeColor(entry.key),
                                ),
                                const SizedBox(width: 8),
                                Text(entry.value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên đầu tư',
                          hintText: 'VD: Apple Inc, Bitcoin, Vàng SJC...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên đầu tư';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Symbol
                      TextFormField(
                        controller: _symbolController,
                        decoration: InputDecoration(
                          labelText: 'Mã/Ký hiệu',
                          hintText: 'VD: AAPL, BTC, GOLD...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.code),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mã đầu tư';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price and Quantity Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Giá mua',
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
                                  return 'Nhập giá';
                                }
                                final price = double.tryParse(value.replaceAll(',', ''));
                                if (price == null || price <= 0) {
                                  return 'Giá không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Số lượng',
                                hintText: '0',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.numbers),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Nhập số lượng';
                                }
                                final quantity = double.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Số lượng không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Total Investment Display
                      if (_priceController.text.isNotEmpty && _quantityController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng đầu tư:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _calculateTotal(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú (tùy chọn)',
                          hintText: 'Thông tin bổ sung về khoản đầu tư...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
                // Bottom Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
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
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Thêm đầu tư',
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

  String _calculateTotal() {
    final priceText = _priceController.text.replaceAll(',', '');
    final quantityText = _quantityController.text;
    
    final price = double.tryParse(priceText);
    final quantity = double.tryParse(quantityText);
    
    if (price != null && quantity != null) {
      final total = price * quantity;
      return CurrencyFormatter.formatVND(total);
    }
    
    return '0 ₫';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final price = double.parse(_priceController.text.replaceAll(',', ''));
      final quantity = double.parse(_quantityController.text);
      
      await ref.read(investmentProvider.notifier).addInvestment(
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim().toUpperCase(),
        type: _selectedType,
        initialPrice: price,
        quantity: quantity,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm khoản đầu tư thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
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

  Color _getAssetTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return Colors.blue;
      case 'crypto':
        return Colors.orange;
      case 'gold':
        return Colors.amber;
      case 'bond':
        return Colors.green;
      case 'fund':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getAssetTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'stock':
        return Icons.trending_up;
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'gold':
        return Icons.star;
      case 'bond':
        return Icons.account_balance;
      case 'fund':
        return Icons.pie_chart;
      default:
        return Icons.attach_money;
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