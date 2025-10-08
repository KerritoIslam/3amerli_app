import 'package:flutter/material.dart';

/// A rounded card-like list with dividers between items.
///
/// Each item is described by a [CardsListItem] which contains
/// - leading: Widget shown at start
/// - title: Widget shown as title (can be Text or any widget)
/// - trailing: Widget at end (optional)
/// - onTap: tap handler
class CardsListItem {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final VoidCallback? onTap;

  CardsListItem({this.leading, required this.title, this.trailing, this.onTap});
}

class CardsList extends StatelessWidget {
  final List<CardsListItem> items;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final bool scrollable;

  const CardsList({
    Key? key,
    required this.items,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = 12.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.backgroundColor,
    this.scrollable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;

    Widget buildItem(BuildContext ctx, int index) {
      final item = items[index];
      return Container(
        
       
        child: Material(
        
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  if (item.leading != null) ...[
                    item.leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: item.title),
                  if (item.trailing != null) ...[
                    const SizedBox(width: 12),
                    item.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

  final defaultBorder = const Color(0xFFEBECEF);
  final resolvedBorderColor = borderColor ?? defaultBorder;
  final separator = Divider(height: 1, thickness: 1, color: resolvedBorderColor);

    Widget listChild;

    if (scrollable) {
      listChild = ListView.separated(
        padding: padding,
        itemBuilder: buildItem,
        separatorBuilder: (_, __) => separator,
        itemCount: items.length,
      );
    } else {
      // Non-scrollable: shrink-wrapped column
      final children = <Widget>[];
      for (var i = 0; i < items.length; i++) {
        children.add(buildItem(context, i));
        if (i != items.length - 1) children.add(separator);
      }
      listChild = Padding(padding: padding, child: Column(mainAxisSize: MainAxisSize.min, children: children));
    }

  // resolvedBorderColor already defined above to ensure divider and border match

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: resolvedBorderColor, width: borderWidth),
        ),
        child: listChild,
      ),
    );
  }
}
