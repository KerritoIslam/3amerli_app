import 'dart:math';

import 'package:flutter/material.dart';

/// Failure page with animated X mark, similar to SuccessPage
class FailurePage extends StatefulWidget {
  final String? orderId;
  final String? date;
  final String? paymentMethod;
  final String? amount;
  final String? failureReason;
  final VoidCallback? onRetryTap;

  const FailurePage({
    super.key,
    this.orderId,
    this.date,
    this.paymentMethod,
    this.amount,
    this.failureReason,
    this.onRetryTap,
  });

  @override
  State<FailurePage> createState() => _FailurePageState();
}

class _FailurePageState extends State<FailurePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arc;
  late final Animation<double> _xMark;
  bool _done = false; // shows content after move completes
  bool _moved = false; // triggers moving the circle up
  final Duration _moveDuration = const Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    // make the arc draw a bit longer and then run a shorter elastic X mark scale
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1300));
    _arc = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut));
    _xMark = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.elasticOut));
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        // after arc+X mark finish, move the circle up, then reveal content
        setState(() => _moved = true);
        Future.delayed(_moveDuration, () => setState(() => _done = true));
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
    const errorColor = Color(0xFFE53935); // Red color for error

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              '/cart', (route) => route.settings.name == '/'),
        ),
        title: Text('Échec du paiement',
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
                      _summaryRow('Date', widget.date ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow(
                          'Méthode de paiement', widget.paymentMethod ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow('Commande', widget.orderId ?? '-'),
                      const SizedBox(height: 8),
                      _summaryRow('Montant', widget.amount ?? '-',
                          emphasize: true),
                      const SizedBox(height: 8),
                      _summaryRow(
                          'Raison', widget.failureReason ?? 'Erreur inconnue',
                          emphasize: true, isError: true),

                      const SizedBox(height: 12),

                      // Actions
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: widget.onRetryTap ??
                              () => Navigator.of(context)
                                  .pushNamedAndRemoveUntil('/cart',
                                      (route) => route.settings.name == '/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text('Réessayer le paiement',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil('/', (route) => false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: errorColor),
                            shape: const StadiumBorder(),
                            backgroundColor: Colors.transparent,
                          ),
                          child: const Text('Retour à l\'accueil',
                              style: TextStyle(
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
                            strokeColor: errorColor,
                            strokeWidth: 6,
                          ),
                        ),
                        Transform.scale(
                          scale: (_xMark.value).clamp(0.0, 1.0) * 1.25,
                          child: Opacity(
                            opacity: _xMark.value.clamp(0.0, 1.0),
                            child: const Icon(Icons.close,
                                size: 64, color: errorColor),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Message (shown after move completes)
            if (_done)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      'Désolé, votre paiement n\'a pas pu être traité.\nVeuillez vérifier vos informations de paiement et réessayer.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool emphasize = false, bool isError = false}) {
    final labelStyle = emphasize
        ? const TextStyle(fontWeight: FontWeight.w700)
        : const TextStyle(color: Colors.black54);
    final valueStyle = emphasize
        ? TextStyle(
            fontWeight: FontWeight.w800,
            color: isError ? const Color(0xFFE53935) : null)
        : const TextStyle(fontWeight: FontWeight.w600);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Flexible(
            child: Text(value, style: valueStyle, textAlign: TextAlign.end))
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
