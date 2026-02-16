import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bgController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;

  late Animation<Alignment> _gradientAnimation;

  @override
  void initState() {
    super.initState();

    Get.find<SplashController>();

    /// LOGO — bouncy scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    /// TEXT — slide up + fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _titleFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    /// BACKGROUND — gentle gradient shift
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _gradientAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _logoController.forward();
    await _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientAnimation.value,
                end: Alignment.bottomCenter,
                colors: const [
                  Color(0xFF576045), // Dark Sage
                  Color(0xFF6A7554), // Sage
                  Color(0xFFD88B2F), // Gold/Orange
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                /// LOGO
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(scale: _logoScale, child: _logo()),
                ),

                const SizedBox(height: 40),

                /// TITLE + SLOGAN
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: _titleSection(),
                  ),
                ),

                const SizedBox(height: 40),

                /// Loading dots
                const _WaveDots(),

                const Spacer(flex: 4),

                const Text(
                  'Master Essential Life Skills',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(
        Icons.volunteer_activism,
        size: 60,
        color: Color(0xFF576045),
      ),
    );
  }

  Widget _titleSection() {
    return const Column(
      children: [
        Text(
          'Rise & Impact',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Rise to Your Potential,\nImpact Your Future',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────
// Animated wave-style loading dots
// ───────────────────────────────────────────────────────────
class _WaveDots extends StatefulWidget {
  const _WaveDots();

  @override
  State<_WaveDots> createState() => _WaveDotsState();
}

class _WaveDotsState extends State<_WaveDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Stagger each dot by 0.2 of the animation cycle
            final delay = index * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);

            // Bounce: go up in first half, come back down in second half
            final bounce = t < 0.5 ? t * 2.0 : 2.0 - t * 2.0;
            final opacity = 0.3 + 0.7 * bounce;
            final yOffset = -8.0 * bounce;

            return Transform.translate(
              offset: Offset(0, yOffset),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
