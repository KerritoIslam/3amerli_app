import 'package:amerli_app/features/catalog/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:amerli_app/core/ui/skeleton/skeleton.dart';
import 'category_chip.dart';

typedef CategoryTapCallback = void Function(Category category);
typedef CategorySelectionCallback = void Function(List<int> selectedIds);

class CategoryGrid extends StatefulWidget {
  final List<Category> categories;
  final CategoryTapCallback? onTap;
  final CategorySelectionCallback? onSelectionChanged;
  final int crossAxisCount;
  final double itemHeight;

  // crossAxisCount and itemHeight are kept for API compatibility but are
  // ignored in the wrap-based layout (chips size themselves).
  const CategoryGrid({super.key, required this.categories, this.onTap, this.onSelectionChanged, this.crossAxisCount = 3, this.itemHeight = 90});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  final Set<int> _selectedIds = <int>{};

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    // Use a Wrap so CategoryChip widgets auto-wrap to the next line when
    // they don't fit, avoiding overflow and keeping a responsive layout.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((cat) {
            final selected = _selectedIds.contains(cat.id);
            return CategoryChip(
              label: cat.name,
              isSelected: selected,
              onSelected: () {
                setState(() {
                  if (_selectedIds.contains(cat.id)) _selectedIds.remove(cat.id);
                  else _selectedIds.add(cat.id);
                });
                // Notify parent with the updated selection array
                if (widget.onSelectionChanged != null) {
                  // ignore: avoid_print
                  print('[CategoryGrid] Selection changed: ${_selectedIds.toList()}');
                  widget.onSelectionChanged!(_selectedIds.toList());
                }
                // Keep backward compatibility with single-tap callback
                if (widget.onTap != null) widget.onTap!(cat);
              },
              trailing: cat.image != null && cat.image!.isNotEmpty
                  ? Image.network(
                      cat.image!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(color: Colors.grey.shade200),
                    )
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
// Lightweight wrapper that sizes a CategoryChip consistently when used
// inside a Wrap. Keeps the image clipped and provides a stable tappable
// area.


// Simple skeleton grid helper (used by pages during loading)
Widget categoriesSkeletonGrid({int count = 6, int crossAxisCount = 3, double itemHeight = 90}) {
  // Use a wrap-based skeleton to match the new chip layout and avoid
  // introducing a scrollable grid inside pages that already manage scrolling.
  final widths = [80.0, 100.0, 120.0, 90.0, 70.0];
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(count, (i) {
          final w = widths[i % widths.length];
          return SkeletonBox(height: 36, width: w, borderRadius: BorderRadius.circular(100));
        }),
      ),
    ),
  );
}
