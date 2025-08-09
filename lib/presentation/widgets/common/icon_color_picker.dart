import 'package:flutter/material.dart';

/// Widget for selecting icon and color
class IconColorPicker extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final List<String> availableIcons;
  final List<Color> availableColors;
  final Function(String) onIconSelected;
  final Function(Color) onColorSelected;
  final double iconSize;
  final double previewSize;

  const IconColorPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.availableIcons,
    required this.availableColors,
    required this.onIconSelected,
    required this.onColorSelected,
    this.iconSize = 20,
    this.previewSize = 60,
  });

  /// Default icons for common categories
  static const List<String> defaultIcons = [
    '💰', '🍔', '🚗', '🛍️', '🎮', '📄', '🏠', '💊', '✈️', '🎓',
    '💻', '📱', '🎯', '💍', '🏥', '🏍️', '📚', '🏖️', '💼', '🎁',
  ];

  /// Default colors for categories
  static const List<Color> defaultColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview
        Row(
          children: [
            Container(
              width: previewSize,
              height: previewSize,
              decoration: BoxDecoration(
                color: selectedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  selectedIcon,
                  style: TextStyle(fontSize: previewSize * 0.5),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIconSelector(context),
                  const SizedBox(height: 12),
                  _buildColorSelector(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biểu tượng',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final icon = availableIcons[index];
              final isSelected = selectedIcon == icon;
              
              return GestureDetector(
                onTap: () => onIconSelected(icon),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? selectedColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: TextStyle(fontSize: iconSize),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Màu sắc',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = selectedColor.value == color.value;
              
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Compact version for limited space
class CompactIconColorPicker extends StatelessWidget {
  final String selectedIcon;
  final Color selectedColor;
  final List<String> availableIcons;
  final List<Color> availableColors;
  final Function(String) onIconSelected;
  final Function(Color) onColorSelected;

  const CompactIconColorPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.availableIcons,
    required this.availableColors,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon Picker Button
        _buildPickerButton(
          context,
          label: 'Icon',
          child: Text(selectedIcon, style: const TextStyle(fontSize: 20)),
          onTap: () => _showIconPickerDialog(context),
        ),
        const SizedBox(width: 12),
        // Color Picker Button
        _buildPickerButton(
          context,
          label: 'Màu',
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
          ),
          onTap: () => _showColorPickerDialog(context),
        ),
      ],
    );
  }

  Widget _buildPickerButton(
    BuildContext context, {
    required String label,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showIconPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn biểu tượng'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final icon = availableIcons[index];
              return GestureDetector(
                onTap: () {
                  onIconSelected(icon);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedIcon == icon
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedIcon == icon
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn màu sắc'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: availableColors.length,
            itemBuilder: (context, index) {
              final color = availableColors[index];
              final isSelected = selectedColor.value == color.value;
              
              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}