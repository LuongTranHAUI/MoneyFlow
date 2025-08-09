import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_provider.dart';
import '../../data/datasources/local/database.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/thousand_separator_formatter.dart';

class EditGoalScreen extends ConsumerStatefulWidget {
  final GoalEntity goal;
  
  const EditGoalScreen({
    super.key,
    required this.goal,
  });

  @override
  ConsumerState<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends ConsumerState<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currentAmountController;
  late DateTime _targetDate;
  late String _selectedIcon;
  late Color _selectedColor;
  bool _isLoading = false;

  final List<String> _availableIcons = [
    '🎯', '💰', '🏠', '🚗', '✈️', '📱', '💻', '🎓', 
    '💍', '🏥', '🏍️', '📚', '🎮', '🏖️', '💼', '🎁'
  ];

  final List<Color> _availableColors = [
    Colors.blue, Colors.green, Colors.red, Colors.purple,
    Colors.orange, Colors.teal, Colors.pink, Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController = TextEditingController(text: widget.goal.name);
    _descriptionController = TextEditingController(text: widget.goal.description ?? '');
    _targetAmountController = TextEditingController(text: widget.goal.targetAmount.toInt().toString());
    _currentAmountController = TextEditingController(text: widget.goal.currentAmount.toInt().toString());
    _targetDate = widget.goal.targetDate;
    _selectedIcon = widget.goal.icon ?? '🎯';
    _selectedColor = _getColorFromHex(widget.goal.color) ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Color? _getColorFromHex(String? hexColor) {
    if (hexColor == null) return null;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.blue;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  Future<void> _updateGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final goalNotifier = ref.read(goalProvider.notifier);
      
      await goalNotifier.updateGoal(
        id: widget.goal.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        targetAmount: double.parse(ThousandSeparatorParser.parseToString(_targetAmountController.text)),
        currentAmount: double.parse(_currentAmountController.text.replaceAll(',', '')),
        targetDate: _targetDate,
        icon: _selectedIcon,
        color: _colorToHex(_selectedColor),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Cập nhật mục tiêu thành công')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi cập nhật mục tiêu: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${widget.goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        final goalNotifier = ref.read(goalProvider.notifier);
        await goalNotifier.deleteGoal(widget.goal.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Xóa mục tiêu thành công')),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Lỗi xóa mục tiêu: $e')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa mục tiêu'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: _isLoading ? null : _deleteGoal,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal preview card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedColor.withValues(alpha: 0.2),
                      _selectedColor.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _selectedIcon,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty ? 'Tên mục tiêu' : _nameController.text,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _targetAmountController.text.isEmpty 
                                ? '0 ₫' 
                                : CurrencyFormatter.formatVND(double.tryParse(_targetAmountController.text.replaceAll(',', '')) ?? 0),
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form fields
              _buildTextField(
                controller: _nameController,
                label: 'Tên mục tiêu',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên mục tiêu';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả (tùy chọn)',
                maxLines: 3,
                validator: Validators.validateDescription,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _targetAmountController,
                      label: 'Mục tiêu (₫)',
                      keyboardType: TextInputType.number,
                      validator: Validators.validateGoalAmount,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _currentAmountController,
                      label: 'Đã tiết kiệm (₫)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                        final amount = double.tryParse(value.replaceAll(',', ''));
                        if (amount == null) return 'Số tiền không hợp lệ';
                        final targetAmount = double.tryParse(_targetAmountController.text.replaceAll(',', '')) ?? 0;
                        if (amount > targetAmount) return 'Không thể lớn hơn mục tiêu';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Target date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) {
                    setState(() => _targetDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Mục tiêu: ${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Icon selector
              Text(
                'Biểu tượng',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : isDarkMode
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Color selector
              Text(
                'Màu sắc',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _availableColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = color),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Update button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _updateGoal,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: keyboardType == TextInputType.number
          ? [
              FilteringTextInputFormatter.digitsOnly,
              ThousandSeparatorInputFormatter(),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
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
        filled: true,
        fillColor: isDarkMode
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.surface,
      ),
    );
  }
}