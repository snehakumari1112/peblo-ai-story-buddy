class QuizModel {
  QuizModel({
    required this.question,
    required List<String> options,
    required this.answer,
  }) : options = List.unmodifiable(options);

  final String question;
  final List<String> options;
  final String answer;

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>? ?? const [])
              .map((option) => option.toString())
              .toList(),
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
    };
  }

  QuizModel copyWith({
    String? question,
    List<String>? options,
    String? answer,
  }) {
    return QuizModel(
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizModel &&
            runtimeType == other.runtimeType &&
            question == other.question &&
            answer == other.answer &&
            _listEquals(options, other.options);
  }

  @override
  int get hashCode => Object.hash(
    question,
    answer,
    Object.hashAll(options),
  );

  static bool _listEquals(List<String> first, List<String> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }
}

void quizModelExampleUsage() {
  final quiz = QuizModel.fromJson({
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  });

  final updatedQuiz = quiz.copyWith(
    options: [...quiz.options, 'Purple'],
  );

  final json = updatedQuiz.toJson();
  json;
}
