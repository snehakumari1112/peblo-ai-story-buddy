import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';

class BuddyWidget extends StatelessWidget {
  const BuddyWidget({
    super.key,
    this.isHappy = false,
  });

  final bool isHappy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: isHappy
          ? 'Happy AI story buddy character'
          : 'AI story buddy character placeholder',
      child: RepaintBoundary(
        child: Container(
          width: 164,
          height: 164,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(34),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1836165E),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 18,
                child: Container(
                  width: 112,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.sky, AppColors.lavender],
                    ),
                    borderRadius: BorderRadius.circular(34),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 70,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.sunny,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 42,
                child: Container(
                  width: 104,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _BuddyEye(),
                          SizedBox(width: 22),
                          _BuddyEye(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _BuddySmile(isHappy: isHappy),
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 18,
                top: 82,
                child: _BuddyEar(color: AppColors.mint),
              ),
              const Positioned(
                right: 18,
                top: 82,
                child: _BuddyEar(color: AppColors.peach),
              ),
              Positioned(
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Buddy',
                    style: TextStyle(
                      color: AppColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(target: isHappy ? 1 : 0)
        .scaleXY(
          begin: 1,
          end: 1.05,
          duration: 260.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .scaleXY(
          begin: 1.05,
          end: 1,
          duration: 180.ms,
          curve: Curves.easeOut,
        );
  }
}

class _BuddyEye extends StatelessWidget {
  const _BuddyEye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: AppColors.deepPurple,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BuddySmile extends StatelessWidget {
  const _BuddySmile({required this.isHappy});

  final bool isHappy;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: isHappy ? 42 : 34,
      height: isHappy ? 18 : 14,
      decoration: BoxDecoration(
        color: isHappy ? AppColors.primary : AppColors.coral,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(18),
        ),
      ),
    );
  }
}

class _BuddyEar extends StatelessWidget {
  const _BuddyEar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}
