import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';

class AIService {
  final String apiKey;

  AIService({required this.apiKey});

  Future<Map<String, dynamic>> _callOpenAI(String systemPrompt, String userPrompt) async {
    final response = await http.post(
      Uri.parse(AppConstants.openAiBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'model': AppConstants.openAiModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      final error = json.decode(response.body);
      throw Exception(
          'API Error: ${error['error']?['message'] ?? 'Unknown error (${response.statusCode})'}');
    }
  }

  String _extractContent(Map<String, dynamic> response) {
    return response['choices'][0]['message']['content'] as String;
  }

  /// Vygeneruje 3 další (nesprávné) odpovědi pro multiple choice otázku
  Future<List<String>> generateWrongOptions(
      String question, String correctAnswer) async {
    final response = await _callOpenAI(
      'Jsi asistent pro tvorbu kvízových otázek. Odpovídej pouze v JSON formátu.',
      'Pro následující otázku a správnou odpověď vygeneruj přesně 3 další věrohodné, '
          'ale nesprávné odpovědi. Odpovědi by měly být podobně dlouhé jako správná odpověď '
          'a měly by znít věrohodně.\n\n'
          'Otázka: $question\n'
          'Správná odpověď: $correctAnswer\n\n'
          'Odpověz POUZE platným JSON polem se 3 řetězci, např: ["odpověď1", "odpověď2", "odpověď3"]',
    );

    final content = _extractContent(response);
    final cleanContent = content.replaceAll(RegExp(r'```json?\s*|\s*```'), '').trim();
    final List<dynamic> options = json.decode(cleanContent);
    return options.map((o) => o.toString()).toList();
  }

  /// Zhodnotí psanou odpověď uživatele
  Future<Map<String, dynamic>> evaluateOpenAnswer(
      String question, String correctAnswer, String userAnswer) async {
    final response = await _callOpenAI(
      'Jsi přísný ale spravedlivý učitel. Hodnotíš odpovědi studentů. Odpovídej v češtině a v JSON formátu.',
      'Zhodnoť následující odpověď studenta na otázku.\n\n'
          'Otázka: $question\n'
          'Správná odpověď: $correctAnswer\n'
          'Odpověď studenta: $userAnswer\n\n'
          'Odpověz POUZE platným JSON objektem v tomto formátu:\n'
          '{"isCorrect": true/false, "score": 0-100, "feedback": "vysvětlení hodnocení"}',
    );

    final content = _extractContent(response);
    final cleanContent = content.replaceAll(RegExp(r'```json?\s*|\s*```'), '').trim();
    return json.decode(cleanContent);
  }

  /// Vygeneruje celkovou zpětnou vazbu po dokončení kvízu
  Future<String> generateQuizFeedback(
      List<Map<String, String>> questionsAndAnswers, int score, int total) async {
    final questionsText = questionsAndAnswers.map((qa) {
      return 'Otázka: ${qa['question']}\n'
          'Správná odpověď: ${qa['correct']}\n'
          'Odpověď studenta: ${qa['answer']}\n'
          'Výsledek: ${qa['isCorrect'] == 'true' ? 'Správně' : 'Špatně'}';
    }).join('\n\n');

    final response = await _callOpenAI(
      'Jsi zkušený učitel, který dává konstruktivní zpětnou vazbu studentům. '
          'Odpovídej v češtině. Buď povzbuzující ale upřímný.',
      'Student dokončil test s výsledkem $score/$total.\n\n'
          'Zde jsou otázky a odpovědi:\n\n$questionsText\n\n'
          'Poskytni celkovou zpětnou vazbu zahrnující:\n'
          '1. Celkové zhodnocení výkonu\n'
          '2. Oblasti kde student vynikal\n'
          '3. Oblasti ke zlepšení\n'
          '4. Konkrétní tipy pro další studium\n'
          '5. Známku (1-5, česká klasifikace)',
    );

    return _extractContent(response);
  }

  /// Vygeneruje nápovědu pro otázku
  Future<String> generateHint(String question, String correctAnswer) async {
    final response = await _callOpenAI(
      'Jsi učitel, který dává nápovědy studentům. Odpovídej v češtině. '
          'Nápověda by neměla přímo prozradit odpověď, ale nasměrovat studenta správným směrem.',
      'Vygeneruj nápovědu pro následující otázku. '
          'Nápověda by měla být stručná (1-2 věty) a neměla by přímo prozradit odpověď.\n\n'
          'Otázka: $question\n'
          'Správná odpověď: $correctAnswer\n\n'
          'Poskytni pouze text nápovědy, nic jiného.',
    );

    return _extractContent(response);
  }
}
