import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'answer_button.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.question,
    required this.options,
    this.selectedAnswer,
    this.correctAnswer,
    this.showWrongAnswer = false,
    this.onOptionSelected,
  });

  final String question;
  final List<String> options;
  final String? selectedAnswer;
  final String? correctAnswer;
  final bool showWrongAnswer;
  final ValueChanged<String>? onOptionSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.softLavender,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.deepPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Little Quiz',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 18),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnswerButton(
                label: option,
                state: _buttonStateFor(option),
                onTap: onOptionSelected == null
                    ? null
                    : () => onOptionSelected?.call(option),
              ),
            ),
          ),
          if (showWrongAnswer) ...[
            const SizedBox(height: 2),
            Text(
              'Not quite. Try another answer!',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.coral,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  AnswerButtonState _buttonStateFor(String option) {
    if (selectedAnswer == null) return AnswerButtonState.idle;

    final isSelected = selectedAnswer == option;
    final isCorrect = correctAnswer != null && correctAnswer == option;

    if (isCorrect && showWrongAnswer) return AnswerButtonState.correct;
    if (isSelected && showWrongAnswer) return AnswerButtonState.wrong;
    if (isSelected) return AnswerButtonState.selected;

    return AnswerButtonState.idle;
  }
}
