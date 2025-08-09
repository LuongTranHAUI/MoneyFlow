import 'package:flutter/material.dart';

/// Base widget for all bottom sheets with consistent styling
class BottomSheetBase extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  final double? maxHeight;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? padding;
  final bool showDragHandle;
  final bool isScrollable;
  final bool useIntrinsicHeight;

  const BottomSheetBase({
    super.key,
    required this.title,
    required this.child,
    this.height,
    this.maxHeight,
    this.onClose,
    this.padding,
    this.showDragHandle = true,
    this.isScrollable = true,
    this.useIntrinsicHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.9;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle) _buildDragHandle(context),
        _buildHeader(context),
        if (isScrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          )
        else
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
      ],
    );

    // If height is specified, use fixed height container
    if (height != null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: content,
      );
    }

    // Otherwise use flexible sizing with constraints
    return Container(
      constraints: BoxConstraints(
        maxHeight: effectiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: useIntrinsicHeight
          ? IntrinsicHeight(child: content)
          : content,
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose ?? () => Navigator.pop(context),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact bottom sheet that wraps content
class CompactBottomSheet extends StatelessWidget {
  final Widget child;
  final bool showDragHandle;
  final EdgeInsetsGeometry? padding;
  final double? maxHeight;

  const CompactBottomSheet({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.padding,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.9;

    return Container(
      constraints: BoxConstraints(
        maxHeight: effectiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: IntrinsicHeight(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: padding ?? const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static method to show bottom sheet with base styling
class BottomSheetHelper {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: builder,
    );
  }

  /// Show compact bottom sheet that wraps content
  static Future<T?> showCompact<T>({
    required BuildContext context,
    required Widget child,
    bool showDragHandle = true,
    EdgeInsetsGeometry? padding,
    double? maxHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => CompactBottomSheet(
        showDragHandle: showDragHandle,
        padding: padding,
        maxHeight: maxHeight,
        child: child,
      ),
    );
  }
}