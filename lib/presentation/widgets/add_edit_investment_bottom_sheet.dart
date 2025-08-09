import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/investment_provider.dart';
import '../../data/datasources/local/database.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/thousand_separator_formatter.dart';
import 'common/bottom_sheet_base.dart';
import 'common/bottom_sheet_action_buttons.dart';

class AddEditInvestmentBottomSheet extends ConsumerStatefulWidget {
  final InvestmentEntity? investment;
  
  const AddEditInvestmentBottomSheet({
    super.key,
    this.investment,
  });

  @override
  ConsumerState<AddEditInvestmentBottomSheet> createState() => _AddEditInvestmentBottomSheetState();
}

class _AddEditInvestmentBottomSheetState extends ConsumerState<AddEditInvestmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _symbolController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _currentPriceController;
  late final TextEditingController _descriptionController;
  
  late String _selectedType;
  bool _isLoading = false;
  
  bool get isEditMode => widget.investment != null;

  final Map<String, String> _investmentTypes = {
    'stock': 'Cổ phiếu',
    'crypto': 'Tiền điện tử',
    'gold': 'Vàng',
    'bond': 'Trái phiếu',
    'fund': 'Quỹ đầu tư',
  };

  @override
  void initState() {
    super.initState();
    
    if (isEditMode) {
      _nameController = TextEditingController(text: widget.investment!.name);
      _symbolController = TextEditingController(text: widget.investment!.symbol);
      _priceController = TextEditingController(
        text: CurrencyFormatter.addThousandsSeparator(
          widget.investment!.purchasePrice.toStringAsFixed(0),
        ),
      );
      _quantityController = TextEditingController(
        text: widget.investment!.quantity.toString(),
      );
      _currentPriceController = TextEditingController(
        text: CurrencyFormatter.addThousandsSeparator(
          widget.investment!.currentPrice.toStringAsFixed(0),
        ),
      );
      _descriptionController = TextEditingController(text: widget.investment!.description ?? '');
      _selectedType = widget.investment!.type;
    } else {
      _nameController = TextEditingController();
      _symbolController = TextEditingController();
      _priceController = TextEditingController();
      _quantityController = TextEditingController();
      _currentPriceController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedType = 'stock';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _currentPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      title: isEditMode ? 'Sửa khoản đầu tư' : 'Thêm khoản đầu tư',
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Investment Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Loại đầu tư',
                prefixIcon: Icon(_getAssetTypeIcon(_selectedType)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Name and Symbol Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên đầu tư',
                      hintText: 'VD: Apple Inc',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _symbolController,
                    decoration: InputDecoration(
                      labelText: 'Mã',
                      hintText: 'AAPL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nhập mã';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Purchase Price and Quantity Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Giá mua',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffixText: '₫',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandSeparatorInputFormatter()],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhập giá mua';
                      }
                      final price = ThousandSeparatorParser.parse(value);
                      if (price == null || price <= 0) {
                        return 'Giá không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'SL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhập SL';
                      }
                      final qty = double.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'SL không hợp lệ';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current Price (for edit mode or optional)
            TextFormField(
              controller: _currentPriceController,
              decoration: InputDecoration(
                labelText: 'Giá hiện tại',
                prefixIcon: const Icon(Icons.trending_up),
                suffixText: '₫',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: isEditMode ? 'Cập nhật giá để tính lợi nhuận' : 'Tùy chọn',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandSeparatorInputFormatter()],
            ),
            
            // Total Investment Display
            if (_priceController.text.isNotEmpty && _quantityController.text.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng đầu tư:'),
                        Text(
                          _calculateTotal(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (_currentPriceController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Giá trị hiện tại:'),
                          Text(
                            _calculateCurrentValue(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lợi nhuận:'),
                          Text(
                            _calculateProfit(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _getProfitColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
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
              onConfirm: _submitForm,
              confirmText: isEditMode ? 'Cập nhật' : 'Thêm',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotal() {
    final price = ThousandSeparatorParser.parse(_priceController.text);
    final quantity = double.tryParse(_quantityController.text);
    
    if (price != null && quantity != null) {
      return CurrencyFormatter.formatVND(price * quantity);
    }
    return '0 ₫';
  }

  String _calculateCurrentValue() {
    final currentPrice = ThousandSeparatorParser.parse(_currentPriceController.text);
    final quantity = double.tryParse(_quantityController.text);
    
    if (currentPrice != null && quantity != null) {
      return CurrencyFormatter.formatVND(currentPrice * quantity);
    }
    return '0 ₫';
  }

  String _calculateProfit() {
    final purchasePrice = ThousandSeparatorParser.parse(_priceController.text);
    final currentPrice = ThousandSeparatorParser.parse(_currentPriceController.text);
    final quantity = double.tryParse(_quantityController.text);
    
    if (purchasePrice != null && currentPrice != null && quantity != null) {
      final profit = (currentPrice - purchasePrice) * quantity;
      final profitPercent = ((currentPrice - purchasePrice) / purchasePrice) * 100;
      return '${CurrencyFormatter.formatVND(profit)} (${profitPercent.toStringAsFixed(1)}%)';
    }
    return '0 ₫ (0%)';
  }

  Color _getProfitColor() {
    final purchasePrice = ThousandSeparatorParser.parse(_priceController.text);
    final currentPrice = ThousandSeparatorParser.parse(_currentPriceController.text);
    
    if (purchasePrice != null && currentPrice != null) {
      if (currentPrice > purchasePrice) return Colors.green;
      if (currentPrice < purchasePrice) return Colors.red;
    }
    return Colors.grey;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final purchasePrice = ThousandSeparatorParser.parse(_priceController.text)!;
      final quantity = double.parse(_quantityController.text);
      final currentPrice = ThousandSeparatorParser.parse(_currentPriceController.text) ?? purchasePrice;
      
      if (isEditMode) {
        // Create Investment object for update
        final updatedInvestment = Investment(
          id: widget.investment!.id,
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim().toUpperCase(),
          type: _selectedType,
          purchasePrice: purchasePrice,
          currentPrice: currentPrice,
          quantity: quantity,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
        
        await ref.read(investmentProvider.notifier).updateInvestment(
          widget.investment!.id,
          updatedInvestment,
        );
      } else {
        await ref.read(investmentProvider.notifier).addInvestment(
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim().toUpperCase(),
          type: _selectedType,
          initialPrice: purchasePrice,
          currentPrice: currentPrice,
          quantity: quantity,
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode ? 'Đã cập nhật khoản đầu tư' : 'Đã thêm khoản đầu tư'),
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
        setState(() => _isLoading = false);
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