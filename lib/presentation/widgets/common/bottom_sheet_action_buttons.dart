import 'package:flutter/material.dart';

/// Standard action buttons for bottom sheets
class BottomSheetActionButtons extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final String? cancelText;
  final String? confirmText;
  final bool isLoading;
  final bool showDeleteButton;
  final VoidCallback? onDelete;
  final String? deleteText;
  final MainAxisAlignment alignment;

  const BottomSheetActionButtons({
    super.key,
    this.onCancel,
    required this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.isLoading = false,
    this.showDeleteButton = false,
    this.onDelete,
    this.deleteText,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
        if (showDeleteButton && onDelete != null) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              child: Text(deleteText ?? 'Xóa'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : (onCancel ?? () => Navigator.pop(context)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(cancelText ?? 'Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isLoading ? null : onConfirm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(confirmText ?? 'Xác nhận'),
          ),
        ),
      ],
    );
  }
}

/// Confirmation dialog buttons for delete operations
class ConfirmationButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final String? cancelText;
  final String? confirmText;
  final bool isDangerous;

  const ConfirmationButtons({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.cancelText,
    this.confirmText,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(cancelText ?? 'Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: isDangerous
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isDangerous
                  ? Theme.of(context).colorScheme.onError
                  : Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(confirmText ?? (isDangerous ? 'Xóa' : 'Xác nhận')),
          ),
        ),
      ],
    );
  }
}

/// Single action button (usually for closing)
class SingleActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isFullWidth;
  final ButtonStyle? style;

  const SingleActionButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isFullWidth = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      style: style ??
          FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      child: Text(text),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}

/// Floating action button for bottom sheets
class BottomSheetFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final bool extended;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const BottomSheetFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.extended = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: foregroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
      child: Icon(icon),
    );
  }
}