import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_confetti/flutter_confetti.dart';

import '../constants/app_colors.dart';
import '../models/quiz_model.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/tts_service.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/quiz_card.dart';
import '../widgets/story_card.dart';
import '../widgets/success_widget.dart';

class StoryBuddyScreen extends ConsumerStatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  ConsumerState<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends ConsumerState<StoryBuddyScreen> {
  static const _storyText = sampleStoryText;

  static final _sampleQuiz = QuizModel(
    question: "What colour was Pip the Robot's lost gear?",
    options: ['Red', 'Green', 'Blue', 'Yellow'],
    answer: 'Blue',
  );

  Future<void> _readStory() async {
    final audioNotifier = ref.read(audioProvider.notifier);
    final quizNotifier = ref.read(quizProvider.notifier);
    final ttsService = ref.read(ttsServiceProvider);

    audioNotifier.setLoading();
    quizNotifier.hideQuiz();

    try {
      await ttsService.initialize(
        onComplete: () {
          if (!mounted) return;

          ref.read(audioProvider.notifier).setCompleted();
          ref.read(quizProvider.notifier).showQuiz(_sampleQuiz);
        },
        onError: (message) {
          if (!mounted) return;

          ref.read(audioProvider.notifier).setError(message);
        },
      );

      if (!mounted) return;

      audioNotifier.setPlaying();
      await ttsService.speak(_storyText);
    } on TtsServiceException catch (error) {
      if (!mounted) return;

      audioNotifier.setError(error.message);
    } catch (error) {
      if (!mounted) return;

      audioNotifier.setError('Something went wrong while reading the story.');
    }
  }

  void _launchConfetti() {
  Confetti.launch(
    context,
    options: const ConfettiOptions(
      particleCount: 200,
      spread: 360,
      startVelocity: 40,
      gravity: 0.25,
      scalar: 1.0,
      ticks: 250,
      x: 0.5,
      y: 0.5,
      colors: [
        AppColors.primary,
        AppColors.sunny,
        AppColors.coral,
        AppColors.mint,
        AppColors.sky,
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    ref.listen<QuizState>(quizProvider, (previous, next) {
      final hasNewWrongAnswer =
          next.status == QuizStatus.wrongAnswer &&
          previous?.selectedAnswer != next.selectedAnswer;
      final hasNewSuccess =
          next.status == QuizStatus.success &&
          previous?.status != QuizStatus.success;

      if (hasNewWrongAnswer) {
        HapticFeedback.mediumImpact();
      }

      if (hasNewSuccess && mounted) {
        HapticFeedback.lightImpact();
        _launchConfetti();
      }
    });

    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 420 ? 18.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu_rounded),
          color: AppColors.deepPurple,
          tooltip: 'Menu',
        ),
        titleSpacing: 0,
        title: const Text(
          'AI Story Buddy',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.primary,
            tooltip: 'Profile',
          ),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            22,
            horizontalPadding,
            30,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _HeaderIntro(),
                  const SizedBox(height: 18),
                  const Center(child: _BuddySection()),
                  const SizedBox(height: 22),
                  const StoryCard(storyText: _storyText),
                  const SizedBox(height: 16),
                  _ReadStoryButton(onPressed: _readStory),
                  const _AudioErrorMessage(),
                  const SizedBox(height: 24),
                  const RepaintBoundary(child: _QuizSection()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIntro extends StatelessWidget {
  const _HeaderIntro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, storyteller!',
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.deepPurple,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the button when you are ready for a tiny adventure.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.sunny,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.lightbulb_rounded,
            color: AppColors.deepPurple,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class _BuddySection extends ConsumerWidget {
  const _BuddySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHappy = ref.watch(
      quizProvider.select((state) => state.status == QuizStatus.success),
    );

    return BuddyWidget(isHappy: isHappy);
  }
}

class _ReadStoryButton extends StatelessWidget {
  const _ReadStoryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final status = ref.watch(audioStatusProvider);
        final isBusy =
            status == AudioStatus.loading || status == AudioStatus.playing;

        return SizedBox(
          height: 58,
          child: ElevatedButton.icon(
            onPressed: isBusy ? null : onPressed,
            icon: Icon(
              status == AudioStatus.loading
                  ? Icons.hourglass_top_rounded
                  : Icons.volume_up_rounded,
            ),
            label: Text(_buttonLabel(status)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              foregroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.mutedText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        );
      },
    );
  }

  String _buttonLabel(AudioStatus status) {
    return switch (status) {
      AudioStatus.loading => 'Getting Story Ready',
      AudioStatus.playing => 'Reading...',
      AudioStatus.completed => 'Read Again',
      AudioStatus.error => 'Try Again',
      AudioStatus.idle => 'Read Me a Story',
    };
  }
}

class _AudioErrorMessage extends ConsumerWidget {
  const _AudioErrorMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = ref.watch(audioErrorMessageProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: errorMessage == null
          ? const SizedBox.shrink()
          : Padding(
              key: const ValueKey('audio-error'),
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
    );
  }
}

class _QuizSection extends ConsumerWidget {
  const _QuizSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(quizStatusProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: switch (status) {
        QuizStatus.hidden => const SizedBox.shrink(
            key: ValueKey('quiz-hidden'),
          ),
        QuizStatus.active => const _ActiveQuizCard(
            key: ValueKey('quiz-active'),
          ),
        QuizStatus.wrongAnswer => const _ActiveQuizCard(
            key: ValueKey('quiz-wrong-answer'),
          ),
        QuizStatus.success => const SuccessWidget(
            key: ValueKey('quiz-success'),
          ),
      },
    );
  }
}

class _ActiveQuizCard extends ConsumerWidget {
  const _ActiveQuizCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(quizCardViewProvider);
    final quiz = viewState.quiz;

    if (quiz == null) return const SizedBox.shrink();

    final card = QuizCard(
      question: quiz.question,
      options: quiz.options,
      selectedAnswer: viewState.selectedAnswer,
      correctAnswer: quiz.answer,
      showWrongAnswer: viewState.status == QuizStatus.wrongAnswer,
      onOptionSelected: ref.read(quizProvider.notifier).submitAnswer,
    );

    if (viewState.status != QuizStatus.wrongAnswer) return card;

    return card
        .animate(key: ValueKey('wrong-${viewState.selectedAnswer}'))
        .shakeX(duration: 420.ms, hz: 8, amount: 10)
        .fadeIn(duration: 120.ms);
  }
}
