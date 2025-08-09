import 'package:finance_tracker/presentation/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});
  
  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _currentAmountController = TextEditingController(text: '0');
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90));
  String _selectedIcon = '🎯';
  Color _selectedColor = Colors.blue;
  
  final List<String> _availableIcons = [
    '🎯', '💰', '🏠', '🚗', '✈️', '📱', '💻', '🎓', 
    '💍', '🏥', '🏍️', '📚', '🎮', '🏖️', '💼', '🎁'
  ];
  
  final List<Color> _availableColors = [
    Colors.blue, Colors.green, Colors.red, Colors.purple,
    Colors.orange, Colors.teal, Colors.pink, Colors.indigo,
  ];
  
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
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
                        'Tạo mục tiêu mới',
                        style: TextStyle(
                          fontSize: 20,
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
                  
                  // Icon and Color Selection
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
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
                            const Text('Biểu tượng', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 32,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _availableIcons.length,
                                itemBuilder: (context, index) {
                                  final icon = _availableIcons[index];
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedIcon = icon),
                                    child: Container(
                                      width: 32,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: _selectedIcon == icon
                                            ? _selectedColor.withValues(alpha: 0.2)
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _selectedIcon == icon
                                              ? _selectedColor
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(icon, style: const TextStyle(fontSize: 16)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Color Selection
                  const Text('Màu sắc', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableColors.length,
                      itemBuilder: (context, index) {
                        final color = _availableColors[index];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Name Input
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên mục tiêu',
                      hintText: 'VD: Mua xe máy',
                      prefixIcon: Icon(Icons.flag),
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
                    decoration: const InputDecoration(
                      labelText: 'Mô tả (tùy chọn)',
                      hintText: 'VD: Tiết kiệm để mua xe đi làm',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Target Amount Input
                  TextFormField(
                    controller: _targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền mục tiêu',
                      hintText: '0',
                      prefixIcon: Icon(Icons.attach_money),
                      suffixText: 'VND',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền mục tiêu';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Số tiền không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Current Amount Input
                  TextFormField(
                    controller: _currentAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền hiện có',
                      hintText: '0',
                      prefixIcon: Icon(Icons.savings),
                      suffixText: 'VND',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Target Date Selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Ngày mục tiêu'),
                    subtitle: Text(
                      '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                    ),
                    onTap: _selectTargetDate,
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
                        onPressed: _saveGoal,
                        child: const Text('Tạo mục tiêu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
    );
    
    if (picked != null && picked != _targetDate) {
      setState(() => _targetDate = picked);
    }
  }
  
  void _saveGoal() async {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.tryParse(_targetAmountController.text);
      final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;
      
      if (targetAmount != null) {
        await ref.read(goalProvider.notifier).addGoal(
          name: _nameController.text,
          description: _descriptionController.text.isNotEmpty 
              ? _descriptionController.text 
              : null,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          targetDate: _targetDate,
          icon: _selectedIcon,
          color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        );
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mục tiêu đã được tạo')),
          );
        }
      }
    }
  }
}