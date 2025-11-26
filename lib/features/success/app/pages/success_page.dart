import 'dart:math';

import 'package:flutter/material.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/features/orders/presentation/pages/order_tracking_page.dart';
import 'package:amerli_app/features/orders/domain/entities/order.dart';
import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_bloc.dart';
import 'package:amerli_app/features/cart/app/bloc/cart_event.dart';

/// Minimal, clean SuccessPage implementation.
class SuccessPage extends StatefulWidget {
  final String? orderId;
  final String? date;
  final String? paymentMethod;
  final String? amount;
  final String? invoiceUrl;
  final VoidCallback? onInvoiceTap;
  final Order? order;

  const SuccessPage({
    super.key,
    this.orderId,
    this.date,
    this.paymentMethod,
    this.amount,
    this.invoiceUrl,
    this.onInvoiceTap,
    this.order,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arc;
  late final Animation<double> _check;
  bool _done = false; // shows content after move completes
  bool _moved = false; // triggers moving the circle up
  final Duration _moveDuration = const Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    // make the arc draw a bit longer and then run a shorter elastic check scale
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _arc = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut));
    _check = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.elasticOut));
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        // after arc+check finish, move the circle up, then reveal content
        setState(() => _moved = true);
        Future.delayed(_moveDuration, () {
          if (mounted) {
            setState(() => _done = true);
            // Clear cart only after animation is done and content is revealed
            try {
              context.read<CartBloc>().add(CartClearEvent());
            } catch (e) {
              debugPrint('Could not clear cart: $e');
            }
          }
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLanguage.success,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // main content (container) — hidden until animation finishes
            if (_done)
              Positioned(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).size.height * 0.40,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Small drag handle similar to bottom summary
                      Center(
                        child: Container(
                          height: 4,
                          width: 112,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Summary rows
                      _summaryRow(AppLanguage.date, widget.date ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow(AppLanguage.paymentMethod,
                          widget.paymentMethod ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow(
                          AppLanguage.orderLabel, widget.orderId ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow(AppLanguage.amountPaid, widget.amount ?? '-',
                          emphasize: true),

                      const SizedBox(height: 12),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(AppLanguage.backToHome,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            if (widget.order != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderTrackingPage(order: widget.order!),
                                ),
                              );
                            } else {
                              TopToast.show(
                                  context, AppLanguage.orderNotAvailable);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Theme.of(context).colorScheme.primary),
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(AppLanguage.followMyOrder,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Animated circle — starts centered, moves up after controller completes
            AnimatedAlign(
              alignment: _moved ? const Alignment(0, -0.98) : Alignment.center,
              duration: _moveDuration,
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _CircleArcPainter(
                            progress: _arc.value,
                            strokeColor: primary,
                            strokeWidth: 6,
                          ),
                        ),
                        Transform.scale(
                          scale: (_check.value).clamp(0.0, 1.0) * 1.25,
                          child: Opacity(
                            opacity: _check.value.clamp(0.0, 1.0),
                            child: Icon(Icons.check, size: 64, color: primary),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Message & invoice (shown after move completes)
            if (_done)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      AppLanguage.thankYouPaymentMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        if (widget.onInvoiceTap != null) {
                          return widget.onInvoiceTap!.call();
                        }
                        if (widget.invoiceUrl != null) {
                          TopToast.show(context, AppLanguage.openingInvoice);
                        } else {
                          TopToast.show(
                              context, AppLanguage.invoiceNotAvailable);
                        }
                      },
                      child: Text(AppLanguage.downloadOrViewInvoice,
                          style: TextStyle(
                              color: primary,
                              decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    final labelStyle = emphasize
        ? const TextStyle(fontWeight: FontWeight.w700)
        : const TextStyle(color: Colors.black54);
    final valueStyle = emphasize
        ? const TextStyle(fontWeight: FontWeight.w800)
        : const TextStyle(fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle)
      ],
    );
  }
}

class _CircleArcPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final double strokeWidth;

  _CircleArcPainter(
      {required this.progress,
      required this.strokeColor,
      this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - strokeWidth;

    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor.withValues(alpha: 0.12)
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor
      ..strokeCap = StrokeCap.round;

    final start = -pi / 2;
    final sweep = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start,
        sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _CircleArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
