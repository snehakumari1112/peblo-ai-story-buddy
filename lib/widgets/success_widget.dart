import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import 'buddy_widget.dart';

class SuccessWidget extends StatefulWidget {
  const SuccessWidget({super.key});

  @override
  State<SuccessWidget> createState() => _SuccessWidgetState();
}

class _SuccessWidgetState extends State<SuccessWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;
  bool _shown = false;

  static const int _particleCount = 28;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    final rnd = Random(42);
    for (var i = 0; i < _particleCount; i++) {
      _particles.add(
        _Particle(
          x: rnd.nextDouble(),
          size: 6.0 + rnd.nextDouble() * 10.0,
          color: _palette[rnd.nextInt(_palette.length)],
          rotation: rnd.nextDouble() * pi * 2,
          delay: rnd.nextDouble() * 0.6,
          drift: (rnd.nextDouble() - 0.5) * 0.6,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_shown) {
        _shown = true;
        _showCelebrationDialog();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showCelebrationDialog() {
    _confettiController.forward(from: 0);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (context, a1, a2) {
        return RepaintBoundary(
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: _CelebrationOverlay(
                controller: _confettiController,
                particles: _particles,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, a1, a2, child) {
        final curved = Curves.easeOutCubic.transform(a1.value);
        return Opacity(
          opacity: a1.value,
          child: Transform.scale(scale: 0.96 + 0.04 * curved, child: child),
        );
      },
    ).then((_) {
      // Ensure controller stops when dialog closes
      _confettiController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep a tiny, zero-space inline widget so external layout isn't affected.
    return const SizedBox.shrink();
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay({
    required this.controller,
    required this.particles,
  });

  final AnimationController controller;
  final List<_Particle> particles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final height = mq.size.height;

    return Stack(
      children: [
        // Full-screen confetti layer
        Positioned.fill(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final t = controller.value;
              return IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(particles, t, height),
                ),
              );
            },
          ),
        ),

        // Center card with playful styling
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.surface, AppColors.sky],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star reward
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [const SizedBox(width: 8), _StarReward()],
                    ),
                    const SizedBox(height: 12),
                    // Buddy + text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Buddy with bounce animation
                        Animate(child: const BuddyWidget(isHappy: true))
                            .then()
                            .moveY(begin: 16, end: 0, duration: 700.ms)
                            .then()
                            .scaleXY(begin: 0.96, end: 1.0, duration: 600.ms)
                            .shake(duration: 900.ms),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Text content
                    Column(
                      children: [
                        Text(
                              '🎉 Amazing!',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.deepPurple,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 420.ms)
                            .slideY(begin: 0.12, end: 0, duration: 420.ms),
                        const SizedBox(height: 8),
                        Text(
                              'You helped Pip find his blue gear!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 480.ms, delay: 120.ms)
                            .slideY(
                              begin: 0.14,
                              end: 0,
                              delay: 120.ms,
                              duration: 480.ms,
                            ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Action button
                    Animate(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surface,
                              textStyle: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Continue'),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 420.ms, delay: 360.ms)
                        .scaleXY(begin: 0.96, end: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Small animated star reward
class _StarReward extends StatefulWidget {
  @override
  State<_StarReward> createState() => _StarRewardState();
}

class _StarRewardState extends State<_StarReward>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
      child: const Icon(Icons.star_rounded, color: Color(0xFFFFD24C), size: 34),
    );
  }
}

// Confetti painter - lightweight, single repaint pass
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t, this.height);

  final List<_Particle> particles;
  final double t;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final progress = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (progress <= 0) continue;

      final x =
          (p.x * size.width) +
          sin(progress * pi * 2 + p.rotation) * p.drift * 40;
      final y = progress * (height + 80) - 40;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * 6);
      paint.color = p.color.withOpacity((1 - progress).clamp(0.0, 1.0));
      final s = p.size;
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: s,
        height: s * 0.6,
      );
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.18));
      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _Particle {
  _Particle({
    required this.x,
    required this.size,
    required this.color,
    required this.rotation,
    required this.delay,
    required this.drift,
  });

  final double x;
  final double size;
  final Color color;
  final double rotation;
  final double delay;
  final double drift;
}

final List<Color> _palette = [
  AppColors.primary,
  AppColors.sunny,
  AppColors.peach,
  AppColors.mint,
  Color(0xFF6CACE4),
  Color(0xFFC78AF2),
];
