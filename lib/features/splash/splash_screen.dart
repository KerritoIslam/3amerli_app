import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({super.key, required this.onAnimationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showFullLogo = false;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller for smooth transitions
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade animation for smooth transition
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Scale animation for expansion effect
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Start the animation sequence
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Show logo_mix.svg first
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Start fade in animation
    _controller.forward();
    
    // Wait for initial animation
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Transition to full logo
    setState(() {
      _showFullLogo = true;
    });
    
    // Reset and replay animation for full logo
    _controller.reset();
    _controller.forward();
    
    // Wait before completing
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Call completion callback
    widget.onAnimationComplete();
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
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _showFullLogo
                      ? SvgPicture.asset(
                          'assets/logo/full_logo.svg',
                          key: const ValueKey('full_logo'),
                          width: MediaQuery.of(context).size.width * 0.7,
                        )
                      : SvgPicture.asset(
                          'assets/logo/logo_mix.svg',
                          key: const ValueKey('logo_mix'),
                          width: 120,
                          height: 120,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
