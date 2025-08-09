import 'package:flutter/material.dart';
import 'package:finance_tracker/core/utils/currency_formatter.dart';
import 'package:finance_tracker/core/utils/thousand_separator_formatter.dart';

/// Widget for quick amount selection with preset values
class QuickAmountSelector extends StatelessWidget {
  final TextEditingController controller;
  final List<double>? presetAmounts;
  final double? customAmount;
  final String? customLabel;
  final Function(double)? onAmountSelected;
  final Color? chipColor;
  final Color? selectedChipColor;

  const QuickAmountSelector({
    super.key,
    required this.controller,
    this.presetAmounts,
    this.customAmount,
    this.customLabel,
    this.onAmountSelected,
    this.chipColor,
    this.selectedChipColor,
  });

  static const List<double> defaultAmounts = [
    50000,
    100000,
    200000,
    500000,
    1000000,
    2000000,
    5000000,
  ];

  @override
  Widget build(BuildContext context) {
    final amounts = presetAmounts ?? defaultAmounts;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn nhanh',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...amounts.take(4).map((amount) => _buildAmountChip(
              context,
              amount: amount,
              label: CurrencyFormatter.formatCompact(amount),
            )),
            if (customAmount != null)
              _buildAmountChip(
                context,
                amount: customAmount!,
                label: customLabel ?? CurrencyFormatter.formatCompact(customAmount!),
                isSpecial: true,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountChip(
    BuildContext context, {
    required double amount,
    required String label,
    bool isSpecial = false,
  }) {
    final isSelected = controller.text.replaceAll(',', '') == amount.toInt().toString();
    
    return ActionChip(
      label: Text(label),
      onPressed: () {
        controller.text = CurrencyFormatter.addThousandsSeparator(amount.toInt().toString());
        onAmountSelected?.call(amount);
      },
      backgroundColor: isSelected 
          ? (selectedChipColor ?? Theme.of(context).colorScheme.primaryContainer)
          : isSpecial 
              ? Theme.of(context).colorScheme.tertiaryContainer
              : (chipColor ?? Theme.of(context).colorScheme.secondaryContainer),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : isSpecial
                ? Theme.of(context).colorScheme.onTertiaryContainer
                : Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: isSelected
          ? BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            )
          : BorderSide.none,
    );
  }
}

/// Extended version with more options
class AdvancedAmountSelector extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final List<double>? presetAmounts;
  final bool showCalculator;
  final Function(double)? onAmountChanged;

  const AdvancedAmountSelector({
    super.key,
    required this.controller,
    this.label,
    this.presetAmounts,
    this.showCalculator = false,
    this.onAmountChanged,
  });

  @override
  State<AdvancedAmountSelector> createState() => _AdvancedAmountSelectorState();
}

class _AdvancedAmountSelectorState extends State<AdvancedAmountSelector> {
  late List<double> _amounts;
  
  @override
  void initState() {
    super.initState();
    _amounts = widget.presetAmounts ?? QuickAmountSelector.defaultAmounts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _amounts.length,
                itemBuilder: (context, index) {
                  final amount = _amounts[index];
                  return _buildGridAmountButton(context, amount);
                },
              ),
              if (widget.showCalculator) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _showCalculatorDialog,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Máy tính'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridAmountButton(BuildContext context, double amount) {
    final isSelected = widget.controller.text.replaceAll(',', '') == amount.toInt().toString();
    
    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          widget.controller.text = CurrencyFormatter.addThousandsSeparator(amount.toInt().toString());
          widget.onAmountChanged?.call(amount);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            CurrencyFormatter.formatCompact(amount),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  void _showCalculatorDialog() {
    // TODO: Implement calculator dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng máy tính sẽ được thêm sau')),
    );
  }
}