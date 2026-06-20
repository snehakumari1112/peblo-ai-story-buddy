import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum AnswerButtonState {
  idle,
  selected,
  correct,
  wrong,
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    required this.label,
    this.state = AnswerButtonState.idle,
    this.onTap,
  });

  final String label;
  final AnswerButtonState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMarked = state != AnswerButtonState.idle;
    final foregroundColor = switch (state) {
      AnswerButtonState.correct => const Color(0xFF16845A),
      AnswerButtonState.wrong => AppColors.coral,
      _ => AppColors.primary,
    };
    final backgroundColor = switch (state) {
      AnswerButtonState.correct => AppColors.mint,
      AnswerButtonState.wrong => const Color(0xFFFFEEEE),
      AnswerButtonState.selected => AppColors.lavender,
      AnswerButtonState.idle => AppColors.surface,
    };

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isMarked ? foregroundColor : AppColors.border,
              width: isMarked ? 2 : 1.4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A36165E),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMarked ? foregroundColor : AppColors.surface,
                  border: Border.all(
                    color: isMarked ? foregroundColor : AppColors.border,
                    width: 2.4,
                  ),
                ),
                child: isMarked
                    ? Icon(
                        state == AnswerButtonState.wrong
                            ? Icons.close_rounded
                            : Icons.check_rounded,
                        color: AppColors.surface,
                        size: 18,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
