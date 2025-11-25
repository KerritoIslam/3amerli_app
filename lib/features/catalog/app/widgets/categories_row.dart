import 'dart:ui';
import 'dart:math';

import 'package:amerli_app/features/catalog/app/widgets/category_chip.dart';
import 'package:amerli_app/features/catalog/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoriesRow extends StatefulWidget {
  final List<Category> categories;
  // Optional callback when a category is tapped (passes the category)
  final ValueChanged<Category>? onTap;
  const CategoriesRow({super.key, required this.categories, this.onTap});

  @override
  State<CategoriesRow> createState() => _CategoriesRowState();
}

class _CategoriesRowState extends State<CategoriesRow> {
  final ScrollController _controller = ScrollController();
  late List<GlobalKey> _itemKeys = [];
  final Map<int, double> _visibility = {};
  final Map<int, double> _itemWidths = {};
  final Map<int, Offset> _itemViewportEdges = {};
  double? _viewportRight;
  // Define the fixed fade distance
  static const double _fadeDistance = 60.0;
  // Selected category names (used for selection state)
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _itemKeys = List.generate(widget.categories.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeVisibility());
  }

  @override
  void didUpdateWidget(covariant CategoriesRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_itemKeys.length != widget.categories.length) {
      _itemKeys = List.generate(widget.categories.length, (_) => GlobalKey());
      WidgetsBinding.instance.addPostFrameCallback((_) => _computeVisibility());
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    _computeVisibility();
  }

  void _computeVisibility() {
    final RenderBox? viewportBox = context.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;
    final vpTopLeft = viewportBox.localToGlobal(Offset.zero);
    final vpLeft = vpTopLeft.dx;
    final vpRight = vpLeft + viewportBox.size.width;
    _viewportRight = vpRight;

    _visibility.clear();
    _itemWidths.clear();
    _itemViewportEdges.clear();

    for (var i = 0; i < _itemKeys.length; i++) {
      final key = _itemKeys[i];
      final ctx = key.currentContext;
      if (ctx == null) continue;
      final RenderBox box = ctx.findRenderObject() as RenderBox;
      final itemTopLeft = box.localToGlobal(Offset.zero);
      final itemLeft = itemTopLeft.dx;
      final itemRight = itemLeft + box.size.width;

      final visible = (itemRight <= vpLeft || itemLeft >= vpRight)
          ? 0.0
          : (min(itemRight, vpRight) - max(itemLeft, vpLeft)) / box.size.width;

      _visibility[i] = visible.clamp(0.0, 1.0);
      _itemWidths[i] = box.size.width;
      _itemViewportEdges[i] = Offset(itemLeft, itemRight);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_itemKeys.length != widget.categories.length) {
      _itemKeys = List.generate(widget.categories.length, (_) => GlobalKey());
      WidgetsBinding.instance.addPostFrameCallback((_) => _computeVisibility());
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    // The main change: Wrap the entire SingleChildScrollView in a ShaderMask
    return ShaderMask(
      // BlendMode.dstIn makes the content transparent where the gradient is transparent
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        // Calculate stops for a 60px fade on the right edge (or left in RTL)
        final double width = bounds.width;
        // Start fade (fully opaque) at width - 60px
        final double startFade =
            (width - _fadeDistance).clamp(0.0, width) / width;
        // End fade (fully transparent) at width (1.0)
        final double endFade = 1.0;

        return LinearGradient(
          begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          stops: [0.0, startFade, endFade],
          colors: [
            Colors.white, // Fully opaque from 0.0 to startFade
            Colors.white,
            Colors.white.withValues(alpha: 0.0), // Fades to transparent
          ],
        ).createShader(bounds);
      },
      child: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.categories.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: KeyedSubtree(
                    key: _itemKeys[i],
                    child: Builder(builder: (context) {
                      final category = widget.categories[i];
                      final visible = _visibility[i] ?? 1.0;
                      final width = _itemWidths[i] ?? 0.0;
                      final edges = _itemViewportEdges[i];

                      // Check if the item is clipped on the right (LTR) or left (RTL).
                      var isClipped = false;
                      double hiddenFraction = 0.0;

                      if (edges != null &&
                          _viewportRight != null &&
                          width > 0) {
                        if (isRtl) {
                          // RTL logic: disable blur for now to avoid complexity/glitches
                          isClipped = false;
                        } else {
                          // LTR Logic
                          final itemRight = edges.dy;
                          isClipped =
                              (itemRight > _viewportRight!) && (visible < 1.0);
                          if (isClipped) {
                            final clippedWidthRight =
                                edges.dy - _viewportRight!;
                            hiddenFraction =
                                (clippedWidthRight / width).clamp(0.0, 1.0);
                          }
                        }
                      }

                      // Blur calculation: max blur is 4.0
                      final maxBlurSigma = 4.0;
                      final blurSigma = isClipped
                          ? hiddenFraction.clamp(0.0, 1.0) * maxBlurSigma
                          : 0.0;

                      // Chip widget with selection handling
                      final isSelected =
                          _selectedCategories.contains(category.name);
                      final chip = CategoryChip(
                        label: category.name,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCategories.remove(category.name);
                            } else {
                              _selectedCategories.add(category.name);
                            }
                          });
                          debugPrint(
                              'Selected categories: ${_selectedCategories.toString()}');
                          // Notify parent about the selection so pages can react (e.g. filter favorites)
                          widget.onTap?.call(category);
                        },
                        // ... (trailing widget implementation is unchanged)
                        trailing: (category.image != null &&
                                category.image!.isNotEmpty)
                            ? SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipOval(
                                  child: Image.network(
                                    category.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey.shade200,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 24,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 24,
                                child: Icon(
                                  Icons.category,
                                  size: 18,
                                ),
                              ),
                      );

                      // If not clipped or blur is negligible, return the chip directly.
                      if (!isClipped || blurSigma <= 0.01) return chip;

                      // Apply only the Blur (the fade is applied to the parent)
                      return ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: blurSigma, sigmaY: blurSigma),
                          child: chip);
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
