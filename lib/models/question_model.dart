import 'dart:convert';

enum QuestionType { multipleChoice, openEnded }

class Question {
  final String id;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final String? hint;
  final QuestionType type;
  final bool aiGeneratedOptions;

  Question({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    this.options = const [],
    this.hint,
    this.type = QuestionType.multipleChoice,
    this.aiGeneratedOptions = false,
  });

  Question copyWith({
    String? id,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    String? hint,
    QuestionType? type,
    bool? aiGeneratedOptions,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      hint: hint ?? this.hint,
      type: type ?? this.type,
      aiGeneratedOptions: aiGeneratedOptions ?? this.aiGeneratedOptions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'correctAnswer': correctAnswer,
        'options': options,
        'hint': hint,
        'type': type.name,
        'aiGeneratedOptions': aiGeneratedOptions,
      };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        questionText: json['questionText'] as String,
        correctAnswer: json['correctAnswer'] as String,
        options: List<String>.from(json['options'] ?? []),
        hint: json['hint'] as String?,
        type: QuestionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => QuestionType.multipleChoice,
        ),
        aiGeneratedOptions: json['aiGeneratedOptions'] as bool? ?? false,
      );

  static String encode(List<Question> questions) =>
      json.encode(questions.map((q) => q.toJson()).toList());

  static List<Question> decode(String source) =>
      (json.decode(source) as List)
          .map((item) => Question.fromJson(item))
          .toList();
}
