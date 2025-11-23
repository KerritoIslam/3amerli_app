import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Phase 1: Hole
  late Animation<double> _holeScaleAnimation;
  late Animation<double> _holeFadeOutAnimation;

  // Phase 2: Logo Mix Movement
  late Animation<double> _logoMixScaleAnimation;
  late Animation<double> _logoMixJumpUpAnimation;
  late Animation<double> _logoMixDropAnimation;
  late Animation<double> _logoHorizontalMoveAnimation;

  // Phase 3: Transition to Full Logo
  late Animation<double> _fullLogoRevealAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // 1. Hole opens (0.0 - 0.1) - Faster
    _holeScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOutBack),
      ),
    );

    // Hole fades out quickly as icon goes up (0.15 - 0.25)
    _holeFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.25, curve: Curves.easeIn),
      ),
    );

    // 2. Logo Mix pops up (0.05 - 0.2) - Faster & Smoother growth
    _logoMixScaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.2, curve: Curves.easeOut),
      ),
    );

    // Jump UP (0.05 - 0.25) - Faster
    // Start from 80.0 (deeper) to emphasize emerging from hole
    _logoMixJumpUpAnimation = Tween<double>(begin: 80.0, end: -120.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.25, curve: Curves.easeOut),
      ),
    );

    // Drop Down to Center (0.25 - 0.45) - Returns to 0 with bounce
    _logoMixDropAnimation = Tween<double>(begin: -120.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.45, curve: Curves.bounceOut),
      ),
    );

    // Move to Right (0.5 - 0.65)
    // Shifts the logo to the right before the full logo reveals
    _logoHorizontalMoveAnimation = Tween<double>(begin: 0.0, end: 78.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.65, curve: Curves.easeInOut),
      ),
    );

    // Final Logo Animations
    // Full Logo reveals from Right to Left (0.65 - 0.9)
    _fullLogoRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.9, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        widget.onAnimationComplete();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate current Y position for Logo Mix
            double currentY = 0;
            if (_controller.value < 0.3) {
              currentY = _logoMixJumpUpAnimation.value;
            } else {
              currentY = _logoMixDropAnimation.value;
            }

            // Calculate current X position for Logo Mix
            // Only apply horizontal move after drop (0.5)
            double currentX = 0;
            if (_controller.value >= 0.5) {
              currentX = _logoHorizontalMoveAnimation.value;
            }

            return Stack(
              alignment: Alignment.center,
              children: [
                // Phase 1: Hole (Fades out quickly)
                Opacity(
                  opacity: _holeFadeOutAnimation.value,
                  child: Transform.scale(
                    scale: _holeScaleAnimation.value,
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(100, 30)),
                      ),
                    ),
                  ),
                ),

                // Phase 2: First Logo (Icon)
                // Jumps, Drops, then Moves Right
                // Phase 2: First Logo (Icon)
                // Jumps, Drops, then Moves Right
                Transform.translate(
                  offset: Offset(currentX, currentY),
                  child: Transform.scale(
                    scale: _logoMixScaleAnimation.value,
                    child: SvgPicture.asset(
                      'assets/logo/logo_mix.svg',
                      width: 220,
                      height: 220,
                    ),
                  ),
                ),

                // Phase 3: Second Logo (Full Logo)
                // Reveals from Right to Left, covering the First Logo
                if (_controller.value > 0.6)
                  SizedBox(
                    width: 300, // Fixed width container
                    height: 150,
                    child: Align(
                      alignment: Alignment.centerRight, // Anchor to the right
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerRight, // Reveal from right
                          widthFactor: _fullLogoRevealAnimation.value,
                          child: Image.asset(
                            'assets/logo/full_logo.png',
                            width: 300, // Match container width
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
