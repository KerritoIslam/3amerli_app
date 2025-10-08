

import 'package:flutter/material.dart';
// inset shadow removed — no external dependency

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

/// A simple animated bottom navigation bar.
///
/// Each item renders a circular red background (brand color) with a white
/// icon centered. When the item is selected the label expands next to the
/// icon using an [AnimatedSize]. The outer pill also animates its background
/// to indicate selection.
class AnimatedBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AnimatedBottomNavBar({
    Key? key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => NavBarItem(
            item: items[index],
            isSelected: selectedIndex == index,
            onTap: () => onItemSelected(index),
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavBarItem({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        
        height: 40,
        padding: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
        
          boxShadow: [
           if (isSelected) BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 0.5,
                
                offset: Offset(0.5,-0.5),
              )
          ],
          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular red background with white icon (always red per request)
            _IconCircle(icon: item.icon, isSelected: isSelected),

            // Animated label that appears when selected. The label's
            // container height is fixed to the circle diameter so the
            // item doesn't grow taller; only width changes.
            AnimatedSize(
              duration:  Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 0, height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

// Small private widget to keep the circular icon consistent and const-friendly.
class _IconCircle extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  const _IconCircle({required this.icon, required this.isSelected});

  @override
  State<_IconCircle> createState() => _IconCircleState();
}

class _IconCircleState extends State<_IconCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration:  BoxDecoration(
        boxShadow: [
           BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 0.5,
                
                offset: Offset(0.5,-0.5),
              )
        ],
        color: widget.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: widget.isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
    );
  }
}