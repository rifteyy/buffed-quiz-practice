import 'dart:convert';
import '../constants/strings.dart';

class QuizResult {
  final String id;
  final String sectionId;
  final String sectionName;
  final Map<String, String> userAnswers;
  final Map<String, bool> correctness;
  final int score;
  final int totalQuestions;
  final double percentage;
  final DateTime completedAt;
  final int timeSpentSeconds;
  final String? aiFeedback;
  final String? grade;

  QuizResult({
    required this.id,
    required this.sectionId,
    required this.sectionName,
    required this.userAnswers,
    required this.correctness,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    DateTime? completedAt,
    this.timeSpentSeconds = 0,
    this.aiFeedback,
    this.grade,
  }) : completedAt = completedAt ?? DateTime.now();

  QuizResult copyWith({
    String? aiFeedback,
    String? grade,
  }) {
    return QuizResult(
      id: id,
      sectionId: sectionId,
      sectionName: sectionName,
      userAnswers: userAnswers,
      correctness: correctness,
      score: score,
      totalQuestions: totalQuestions,
      percentage: percentage,
      completedAt: completedAt,
      timeSpentSeconds: timeSpentSeconds,
      aiFeedback: aiFeedback ?? this.aiFeedback,
      grade: grade ?? this.grade,
    );
  }

  String get formattedTime {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get gradeText {
    if (grade != null) return grade!;
    if (percentage >= 90) return AppStrings.gradeExcellent;
    if (percentage >= 75) return AppStrings.gradeVeryGood;
    if (percentage >= 60) return AppStrings.gradeGood;
    if (percentage >= 45) return AppStrings.gradeSufficient;
    return AppStrings.gradeInsufficient;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sectionId': sectionId,
        'sectionName': sectionName,
        'userAnswers': userAnswers,
        'correctness': correctness.map((k, v) => MapEntry(k, v)),
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'completedAt': completedAt.toIso8601String(),
        'timeSpentSeconds': timeSpentSeconds,
        'aiFeedback': aiFeedback,
        'grade': grade,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        id: json['id'] as String,
        sectionId: json['sectionId'] as String,
        sectionName: json['sectionName'] as String,
        userAnswers: Map<String, String>.from(json['userAnswers'] ?? {}),
        correctness: (json['correctness'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), v as bool)) ??
            {},
        score: json['score'] as int,
        totalQuestions: json['totalQuestions'] as int,
        percentage: (json['percentage'] as num).toDouble(),
        completedAt: DateTime.parse(json['completedAt'] as String),
        timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
        aiFeedback: json['aiFeedback'] as String?,
        grade: json['grade'] as String?,
      );

  static String encode(List<QuizResult> results) =>
      json.encode(results.map((r) => r.toJson()).toList());

  static List<QuizResult> decode(String source) =>
      (json.decode(source) as List)
          .map((item) => QuizResult.fromJson(item))
          .toList();
}
