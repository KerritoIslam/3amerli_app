import 'package:flutter/material.dart';

class CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Widget? trailing;
  const CategoryChip(
      {super.key,
      required this.label,
      required this.isSelected,
      this.onSelected,
      this.selectedColor,
      this.unselectedColor,
      this.trailing});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: widget.isSelected
                ? (widget.selectedColor ??
                    Theme.of(context).colorScheme.primary)
                : (widget.unselectedColor ??
                    Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1)),
            ]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.trailing != null) ...[
              SizedBox(
                  width: 24,
                  height: 24,
                  child: ClipOval(child: widget.trailing)),
              const SizedBox(width: 10),
            ],
            Text(widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
