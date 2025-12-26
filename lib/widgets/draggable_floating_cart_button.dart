import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../features/cart/app/bloc/cart_bloc.dart';
import '../features/cart/app/bloc/cart_state.dart';
import '../utils/constants/app_colors.dart';

class DraggableFloatingCartButton extends StatefulWidget {
  final VoidCallback onCartTap;

  const DraggableFloatingCartButton({super.key, required this.onCartTap});

  @override
  State<DraggableFloatingCartButton> createState() =>
      _DraggableFloatingCartButtonState();
}

class _DraggableFloatingCartButtonState
    extends State<DraggableFloatingCartButton> {
  Offset? _offset;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        bool show = false;
        if (state is CartLoaded && state.items.isNotEmpty) {
          show = true;
        }

        if (!show) return const SizedBox.shrink();

        // Use MediaQuery to get screen size for boundary checks if needed
        final size = MediaQuery.of(context).size;

        // Initialize position to bottom-right if not set
        // Shifted higher: size.height - 200
        _offset ??= Offset(size.width - 80, size.height - 200);

        return Stack(
          children: [
            Positioned(
              left: _offset!.dx,
              top: _offset!.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _isDragging = true;
                    double newX = _offset!.dx + details.delta.dx;
                    double newY = _offset!.dy + details.delta.dy;

                    // Simple boundary checks
                    // Button size approx 60x60
                    if (newX < 0) newX = 0;
                    if (newX > size.width - 60) newX = size.width - 60;
                    if (newY < 0) newY = 0;
                    if (newY > size.height - 60) newY = size.height - 60;

                    _offset = Offset(newX, newY);
                  });
                },
                onPanEnd: (_) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                onTap: () {
                  if (!_isDragging) {
                    widget.onCartTap();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/panier_reversed.svg',
                      width: 30,
                      height: 30,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
