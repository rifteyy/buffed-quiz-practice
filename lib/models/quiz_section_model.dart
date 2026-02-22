import 'dart:convert';
import 'question_model.dart';

class QuizSection {
  final String id;
  final String name;
  final String? description;
  final List<Question> questions;
  final DateTime createdAt;
  final int timerMinutes;
  final bool shuffleQuestions;

  QuizSection({
    required this.id,
    required this.name,
    this.description,
    this.questions = const [],
    DateTime? createdAt,
    this.timerMinutes = 10,
    this.shuffleQuestions = false,
  }) : createdAt = createdAt ?? DateTime.now();

  QuizSection copyWith({
    String? id,
    String? name,
    String? description,
    List<Question>? questions,
    DateTime? createdAt,
    int? timerMinutes,
    bool? shuffleQuestions,
  }) {
    return QuizSection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      timerMinutes: timerMinutes ?? this.timerMinutes,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'timerMinutes': timerMinutes,
        'shuffleQuestions': shuffleQuestions,
      };

  factory QuizSection.fromJson(Map<String, dynamic> json) => QuizSection(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        questions: (json['questions'] as List?)
                ?.map((q) => Question.fromJson(q))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        timerMinutes: json['timerMinutes'] as int? ?? 10,
        shuffleQuestions: json['shuffleQuestions'] as bool? ?? false,
      );

  static String encode(List<QuizSection> sections) =>
      json.encode(sections.map((s) => s.toJson()).toList());

  static List<QuizSection> decode(String source) =>
      (json.decode(source) as List)
          .map((item) => QuizSection.fromJson(item))
          .toList();
}
