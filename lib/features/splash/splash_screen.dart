import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _smokeController;

  // Phase 1: Text Bounce
  late Animation<double> _textScaleAnimation;

  // Phase 2: Truck Enter
  late Animation<double> _truckEnterAnimation;

  // Phase 3: Lift
  late Animation<double> _textLiftAnimation;
  late Animation<double> _truckLiftAnimation;

  // Phase 4: Exit
  late Animation<double> _exitAnimation;

  // Curves
  late CurvedAnimation _bounceCurve;
  late CurvedAnimation _enterCurve;
  late CurvedAnimation _liftCurve;
  late CurvedAnimation _exitCurve;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7), // Slower duration
    );

    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Create Curves
      _bounceCurve = CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.15, curve: Curves.elasticOut),
      );
      _enterCurve = CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
      );
      _liftCurve = CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.65, curve: Curves.easeInOut),
      );
      _exitCurve = CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOutCubic),
      );

      // Phase 1: Text Bounces In (0.0 - 0.15)
      _textScaleAnimation =
          Tween<double>(begin: 0.0, end: 1.0).animate(_bounceCurve);

      // Phase 2: Truck Enters (0.15 - 0.5)
      // Truck comes from right (screen width) to center
      _truckEnterAnimation =
          Tween<double>(begin: 1.sw, end: 0.0).animate(_enterCurve);

      // Phase 3: Lift (0.5 - 0.65)
      // Text moves up slightly
      _textLiftAnimation =
          Tween<double>(begin: 0.0, end: -15.h).animate(_liftCurve);
      // Truck might tilt or move up slightly too
      _truckLiftAnimation =
          Tween<double>(begin: 0.0, end: -5.h).animate(_liftCurve);

      // Phase 4: Exit (0.6 - 1.0) - Slower exit (40% of 7s = 2.8s)
      _exitAnimation =
          Tween<double>(begin: 0.0, end: -1.sw).animate(_exitCurve);

      _mainController.forward().then((_) {
        if (mounted) {
          widget.onAnimationComplete();
        }
      });
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _mainController.stop();
    _smokeController.stop();

    // Dispose curves to remove listeners
    if (_isInitialized) {
      _bounceCurve.dispose();
      _enterCurve.dispose();
      _liftCurve.dispose();
      _exitCurve.dispose();
    }

    _mainController.dispose();
    _smokeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: 1.sw,
        height: 1.sh,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main Animation Stack
            AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                if (!_isInitialized) return const SizedBox.shrink();

                final exitOffset = _exitAnimation.value;
                final textY = _textLiftAnimation.value;
                final truckX = _truckEnterAnimation.value + exitOffset;
                final truckY = _truckLiftAnimation.value;

                // Centering adjustment:
                // Truck is offset by 80.w relative to text.
                // Shift both left by 40.w to center the group.
                final centerShift = -40.w;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Text
                    Transform.translate(
                      offset: Offset(exitOffset + centerShift,
                          textY - 30.h), // Raised text higher
                      child: Transform.scale(
                        scale: _textScaleAnimation.value,
                        child: SvgPicture.asset(
                          'assets/logo/log_text.svg',
                          height: 250.h,
                        ),
                      ),
                    ),

                    // Truck
                    Transform.translate(
                      offset: Offset(95.w + truckX + centerShift, truckY),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Only show smoke after truck entrance phase has started AND truck is visible
                            // Truck entrance starts at main animation progress 0.15
                            // Truck position goes from 1.sw to 0.0
                            // Show smoke only when: main animation > 0.2 AND truck position < 0.5.sw
                            if (_mainController.value > 0.2 &&
                                _truckEnterAnimation.value < 0.5.sw)
                              _buildSmokeEffect(),
                            Image.asset(
                              'assets/logo/logo_mix.png',
                              height: 200.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmokeEffect() {
    return AnimatedBuilder(
      animation: _smokeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(10.w,
              0), // Shift slightly right to connect better, or left if needed. User said left.
          // Wait, user said "shift them to the left to be connected".
          // If it's to the left of the truck, moving it left moves it AWAY.
          // Unless the truck image has empty space on the left?
          // I will try shifting it RIGHT (positive) to connect to the truck body.
          // But the user explicitly said "shift them to the left".
          // Maybe they mean the smoke is currently appearing ON the truck?
          // I'll stick to the user's "left" instruction: negative offset.
          child: Transform.translate(
            offset: Offset(
                -60.w, 0), // Closer to truck (assuming left shift connects it)
            child: SizedBox(
              width: 50.w,
              height: 50.h,
              child: CustomPaint(
                painter: SmokePainter(_smokeController.value),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SmokePainter extends CustomPainter {
  final double animationValue;

  SmokePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw a few circles that move right and fade
    for (int i = 0; i < 3; i++) {
      final offset = (animationValue + i * 0.33) % 1.0;
      final x = size.width * offset; // Move right (reversed)
      final y = size.height / 2 + math.sin(offset * math.pi * 2) * 5;
      final radius = 8.0 * offset; // Bigger radius
      final opacity = 1.0 - offset;

      paint.color =
          Colors.grey.withValues(alpha: 0.6 * opacity); // More visible
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SmokePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
