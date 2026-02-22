import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/question_model.dart';
import '../models/quiz_section_model.dart';
import '../models/quiz_result_model.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class QuizProvider extends ChangeNotifier {
  final StorageService _storage;
  final Uuid _uuid = const Uuid();

  List<QuizSection> _sections = [];
  List<QuizResult> _results = [];

  // Current quiz state
  QuizSection? _currentSection;
  int _currentQuestionIndex = 0;
  Map<String, String> _currentAnswers = {};
  Timer? _timer;
  int _timerSeconds = 0;
  bool _quizActive = false;
  bool _showingHint = false;
  String? _currentHint;
  bool _isLoading = false;

  QuizProvider(this._storage) {
    _loadData();
  }

  // Getters
  List<QuizSection> get sections => _sections;
  List<QuizResult> get results => _results;
  QuizSection? get currentSection => _currentSection;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get currentAnswers => _currentAnswers;
  bool get quizActive => _quizActive;
  bool get showingHint => _showingHint;
  String? get currentHint => _currentHint;
  bool get isLoading => _isLoading;
  int get timerSeconds => _timerSeconds;

  Question? get currentQuestion {
    if (_currentSection == null ||
        _currentQuestionIndex >= _currentSection!.questions.length) {
      return null;
    }
    return _currentSection!.questions[_currentQuestionIndex];
  }

  int get totalQuestions => _currentSection?.questions.length ?? 0;

  double get progress {
    if (totalQuestions == 0) return 0;
    return _currentAnswers.length / totalQuestions;
  }

  String get timerDisplay {
    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isTimerWarning => _timerSeconds <= 60 && _timerSeconds > 0;

  void _loadData() {
    _sections = _storage.getSections();
    _results = _storage.getResults();
    if (_sections.isEmpty) {
      _seedDemoQuiz();
    }
    notifyListeners();
  }

  void _seedDemoQuiz() {
    final demoQuestions = [
      Question(
        id: _uuid.v4(),
        questionText: 'Jaká je přibližná vzdálenost Země od Slunce?',
        correctAnswer: '150 milionů km',
        options: [
          '150 milionů km',
          '384 000 km',
          '1 milion km',
          '57 milionů km',
        ],
        hint: 'Tato vzdálenost se nazývá astronomická jednotka (AU).',
        type: QuestionType.multipleChoice,
      ),
      Question(
        id: _uuid.v4(),
        questionText: 'Který prvek má chemickou značku "Au"?',
        correctAnswer: 'Zlato',
        options: ['Zlato', 'Stříbro', 'Hliník', 'Měď'],
        hint: 'Z latinského slova "aurum".',
        type: QuestionType.multipleChoice,
      ),
      Question(
        id: _uuid.v4(),
        questionText: 'Ve kterém roce skončila druhá světová válka?',
        correctAnswer: '1945',
        options: ['1945', '1918', '1939', '1950'],
        hint: 'V Evropě v květnu, v Pacifiku v září.',
        type: QuestionType.multipleChoice,
      ),
      Question(
        id: _uuid.v4(),
        questionText: 'Jak se jmenuje nejdelší řeka světa?',
        correctAnswer: 'Nil',
        options: ['Nil', 'Amazonka', 'Jang-c\'-ťiang', 'Mississippi'],
        hint: 'Protéká Afrikou a vlévá se do Středozemního moře.',
        type: QuestionType.multipleChoice,
      ),
      Question(
        id: _uuid.v4(),
        questionText: 'Kolik kostí má lidské tělo dospělého člověka?',
        correctAnswer: '206',
        options: ['206', '312', '172', '248'],
        hint: 'Novorozenci mají více – některé kosti se později spojí.',
        type: QuestionType.multipleChoice,
      ),
      Question(
        id: _uuid.v4(),
        questionText:
            'Který planet sluneční soustavy je největší?',
        correctAnswer: 'Jupiter',
        options: ['Jupiter', 'Saturn', 'Uran', 'Neptun'],
        hint: 'Mohl by pojmout více než 1 300 planet velikosti Země.',
        type: QuestionType.multipleChoice,
      ),
    ];

    final demo = QuizSection(
      id: _uuid.v4(),
      name: '🌍 Demo kvíz – Obecné znalosti',
      description: 'Vyzkoušej si aplikaci na tomto ukázkovém kvízu',
      questions: demoQuestions,
      timerMinutes: 5,
    );

    _sections = [demo];
    _storage.saveSections(_sections);
  }

  // Section CRUD
  Future<void> addSection(QuizSection section) async {
    _sections.add(section);
    await _storage.saveSections(_sections);
    notifyListeners();
  }

  Future<void> updateSection(QuizSection section) async {
    final index = _sections.indexWhere((s) => s.id == section.id);
    if (index != -1) {
      _sections[index] = section;
      await _storage.saveSections(_sections);
      notifyListeners();
    }
  }

  Future<void> deleteSection(String sectionId) async {
    _sections.removeWhere((s) => s.id == sectionId);
    await _storage.saveSections(_sections);
    notifyListeners();
  }

  QuizSection? getSectionById(String id) {
    try {
      return _sections.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Create section helper
  QuizSection createSection({
    required String name,
    String? description,
    required List<Question> questions,
    int timerMinutes = 10,
    bool shuffleQuestions = false,
  }) {
    return QuizSection(
      id: _uuid.v4(),
      name: name,
      description: description,
      questions: questions,
      timerMinutes: timerMinutes,
      shuffleQuestions: shuffleQuestions,
    );
  }

  Question createQuestion({
    required String questionText,
    required String correctAnswer,
    List<String>? options,
    String? hint,
    QuestionType type = QuestionType.multipleChoice,
  }) {
    return Question(
      id: _uuid.v4(),
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options ?? [],
      hint: hint,
      type: type,
    );
  }

  // Quiz flow
  void startQuiz(String sectionId) {
    final section = getSectionById(sectionId);
    if (section == null || section.questions.isEmpty) return;

    // Apply shuffle if enabled
    final questions = section.shuffleQuestions
        ? (List.of(section.questions)..shuffle())
        : section.questions;
    _currentSection = section.copyWith(questions: questions);

    _currentQuestionIndex = 0;
    _currentAnswers = {};
    _quizActive = true;
    _showingHint = false;
    _currentHint = null;
    _timerSeconds = section.timerMinutes * 60;

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        finishQuiz();
      }
    });
  }

  void answerQuestion(String questionId, String answer) {
    _currentAnswers[questionId] = answer;
    _showingHint = false;
    _currentHint = null;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      _showingHint = false;
      _currentHint = null;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _showingHint = false;
      _currentHint = null;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      _showingHint = false;
      _currentHint = null;
      notifyListeners();
    }
  }

  void toggleHint() {
    if (currentQuestion?.hint != null && currentQuestion!.hint!.isNotEmpty) {
      _showingHint = !_showingHint;
      _currentHint = currentQuestion!.hint;
      notifyListeners();
    }
  }

  // AI hint generation
  Future<void> generateAIHint(AIService aiService) async {
    if (currentQuestion == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final hint = await aiService.generateHint(
        currentQuestion!.questionText,
        currentQuestion!.correctAnswer,
      );
      _currentHint = hint;
      _showingHint = true;
    } catch (e) {
      _currentHint = 'Nepodařilo se vygenerovat nápovědu: $e';
      _showingHint = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // AI option generation
  Future<Question> generateAIOptions(
      AIService aiService, Question question) async {
    try {
      final wrongOptions = await aiService.generateWrongOptions(
        question.questionText,
        question.correctAnswer,
      );

      final allOptions = [question.correctAnswer, ...wrongOptions]..shuffle();

      return question.copyWith(
        options: allOptions,
        aiGeneratedOptions: true,
      );
    } catch (e) {
      throw Exception('Nepodařilo se vygenerovat odpovědi: $e');
    }
  }

  // Finish quiz & evaluate
  QuizResult finishQuiz() {
    _timer?.cancel();
    _quizActive = false;

    final section = _currentSection!;
    int score = 0;
    final correctness = <String, bool>{};

    for (final question in section.questions) {
      final userAnswer = _currentAnswers[question.id];
      final isCorrect = userAnswer != null &&
          userAnswer.trim().toLowerCase() ==
              question.correctAnswer.trim().toLowerCase();
      correctness[question.id] = isCorrect;
      if (isCorrect) score++;
    }

    final totalTime = section.timerMinutes * 60;
    final timeSpent = totalTime - _timerSeconds;

    final result = QuizResult(
      id: _uuid.v4(),
      sectionId: section.id,
      sectionName: section.name,
      userAnswers: Map.from(_currentAnswers),
      correctness: correctness,
      score: score,
      totalQuestions: section.questions.length,
      percentage:
          section.questions.isEmpty ? 0 : (score / section.questions.length) * 100,
      timeSpentSeconds: timeSpent,
    );

    _results.insert(0, result);
    _storage.saveResults(_results);
    notifyListeners();

    return result;
  }

  // Update result with AI feedback
  Future<void> updateResultWithAIFeedback(
      String resultId, String feedback, String? grade) async {
    final index = _results.indexWhere((r) => r.id == resultId);
    if (index != -1) {
      _results[index] = _results[index].copyWith(
        aiFeedback: feedback,
        grade: grade,
      );
      await _storage.saveResults(_results);
      notifyListeners();
    }
  }

  QuizResult? getResultById(String id) {
    try {
      return _results.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  List<QuizResult> getResultsForSection(String sectionId) {
    return _results.where((r) => r.sectionId == sectionId).toList();
  }

  Future<void> deleteResult(String resultId) async {
    _results.removeWhere((r) => r.id == resultId);
    await _storage.saveResults(_results);
    notifyListeners();
  }

  void cancelQuiz() {
    _timer?.cancel();
    _quizActive = false;
    _currentSection = null;
    _currentAnswers = {};
    _showingHint = false;
    _currentHint = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
