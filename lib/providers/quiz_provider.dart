import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_model.dart';

enum QuizStatus {
  hidden,
  active,
  wrongAnswer,
  success,
}

class QuizState {
  const QuizState({
    this.status = QuizStatus.hidden,
    this.quiz,
    this.selectedAnswer,
  });

  final QuizStatus status;
  final QuizModel? quiz;
  final String? selectedAnswer;

  bool get isHidden => status == QuizStatus.hidden;
  bool get isActive => status == QuizStatus.active;
  bool get isWrongAnswer => status == QuizStatus.wrongAnswer;
  bool get isSuccess => status == QuizStatus.success;

  QuizState copyWith({
    QuizStatus? status,
    QuizModel? quiz,
    String? selectedAnswer,
    bool clearQuiz = false,
    bool clearSelectedAnswer = false,
  }) {
    return QuizState(
      status: status ?? this.status,
      quiz: clearQuiz ? null : quiz ?? this.quiz,
      selectedAnswer: clearSelectedAnswer
          ? null
          : selectedAnswer ?? this.selectedAnswer,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizState &&
            runtimeType == other.runtimeType &&
            status == other.status &&
            quiz == other.quiz &&
            selectedAnswer == other.selectedAnswer;
  }

  @override
  int get hashCode => Object.hash(status, quiz, selectedAnswer);
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(const QuizState());

  void showQuiz(QuizModel quiz) {
    state = QuizState(
      status: QuizStatus.active,
      quiz: quiz,
    );
  }

  void submitAnswer(String answer) {
    final quiz = state.quiz;

    if (quiz == null) return;

    final isCorrect = answer.trim().toLowerCase() ==
        quiz.answer.trim().toLowerCase();

    state = state.copyWith(
      status: isCorrect ? QuizStatus.success : QuizStatus.wrongAnswer,
      selectedAnswer: answer,
    );
  }

  void markSuccess() {
    state = state.copyWith(status: QuizStatus.success);
  }

  void retry() {
    state = state.copyWith(
      status: QuizStatus.active,
      clearSelectedAnswer: true,
    );
  }

  void hideQuiz() {
    state = const QuizState();
  }

  void resetSelection() {
    state = state.copyWith(clearSelectedAnswer: true);
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(),
);

final quizStatusProvider = Provider<QuizStatus>(
  (ref) => ref.watch(quizProvider.select((state) => state.status)),
);

final activeQuizProvider = Provider<QuizModel?>(
  (ref) => ref.watch(quizProvider.select((state) => state.quiz)),
);

final selectedQuizAnswerProvider = Provider<String?>(
  (ref) => ref.watch(quizProvider.select((state) => state.selectedAnswer)),
);

typedef QuizCardViewState = ({
  QuizModel? quiz,
  String? selectedAnswer,
  QuizStatus status,
});

final quizCardViewProvider = Provider<QuizCardViewState>(
  (ref) => ref.watch(
    quizProvider.select(
      (state) => (
        quiz: state.quiz,
        selectedAnswer: state.selectedAnswer,
        status: state.status,
      ),
    ),
  ),
);
