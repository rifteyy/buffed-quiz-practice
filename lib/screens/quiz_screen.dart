import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../models/question_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/timer_display.dart';

class QuizScreen extends StatefulWidget {
  final String sectionId;

  const QuizScreen({super.key, required this.sectionId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _openAnswerController = TextEditingController();
  bool _quizStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuizProvider>();
      provider.startQuiz(widget.sectionId);
      setState(() => _quizStarted = true);
    });
  }

  @override
  void dispose() {
    _openAnswerController.dispose();
    super.dispose();
  }

  void _selectOption(QuizProvider provider, String questionId, String answer) {
    provider.answerQuestion(questionId, answer);
  }

  void _submitOpenAnswer(QuizProvider provider, String questionId) {
    if (_openAnswerController.text.trim().isNotEmpty) {
      provider.answerQuestion(questionId, _openAnswerController.text.trim());
      _openAnswerController.clear();
    }
  }

  void _finishQuiz(QuizProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.finishQuiz),
        content: Text(
          '${provider.currentAnswers.length}/${provider.totalQuestions} - ${AppStrings.finishQuizConfirm}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.continueQuiz),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final result = provider.finishQuiz();
              context.go('/results/${result.id}');
            },
            child: Text(AppStrings.finish),
          ),
        ],
      ),
    );
  }

  void _requestHint(QuizProvider provider) {
    final question = provider.currentQuestion;
    if (question == null) return;

    if (question.hint != null && question.hint!.isNotEmpty) {
      provider.toggleHint();
    } else {
      final settings = context.read<SettingsProvider>();
      if (settings.hasApiKey) {
        final aiService = AIService(apiKey: settings.apiKey);
        provider.generateAIHint(aiService);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.apiKeyNeededForHint),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_quizStarted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final question = provider.currentQuestion;

        if (question == null || !provider.quizActive) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (question.type == QuestionType.openEnded) {
          final existing = provider.currentAnswers[question.id];
          if (existing != null && _openAnswerController.text != existing) {
            _openAnswerController.text = existing;
          }
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                provider.cancelQuiz();
                context.go('/');
              },
            ),
            title: QuizProgressBar(
              progress: provider.progress,
              current: provider.currentQuestionIndex,
              total: provider.totalQuestions,
            ),
            titleSpacing: 0,
            actions: [
              TimerDisplay(
                time: provider.timerDisplay,
                isWarning: provider.isTimerWarning,
              ),
              const SizedBox(width: 8),
            ],
            toolbarHeight: 70,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      question.type ==
                                              QuestionType.multipleChoice
                                          ? AppStrings.chooseFromAnswers
                                          : AppStrings.openEnded,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                question.questionText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (question.type == QuestionType.multipleChoice)
                        _buildMultipleChoice(provider, question)
                      else
                        _buildOpenAnswer(provider, question),
                      if (provider.showingHint &&
                          provider.currentHint != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: AppTheme.warning, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  provider.currentHint!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : () => _requestHint(provider),
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.lightbulb_outline, size: 20),
                        label: Text(AppStrings.hint),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                      const Spacer(),
                      if (provider.currentQuestionIndex > 0)
                        IconButton(
                          onPressed: () => provider.previousQuestion(),
                          icon: const Icon(Icons.arrow_back_ios, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.cardColor,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (provider.currentQuestionIndex <
                          provider.totalQuestions - 1)
                        ElevatedButton.icon(
                          onPressed: () => provider.nextQuestion(),
                          icon: Text(AppStrings.next),
                          label: const Icon(Icons.arrow_forward_ios, size: 16),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => _finishQuiz(provider),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(AppStrings.finish),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.success,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoice(QuizProvider provider, Question question) {
    final labels = ['A', 'B', 'C', 'D'];
    final options = question.options.isNotEmpty
        ? question.options
        : [question.correctAnswer];

    return Column(
      children: options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final label = idx < labels.length ? labels[idx] : '${idx + 1}';
        final isSelected = provider.currentAnswers[question.id] == option;

        return AnswerOptionTile(
          label: label,
          text: option,
          isSelected: isSelected,
          onTap: () => _selectOption(provider, question.id, option),
        );
      }).toList(),
    );
  }

  Widget _buildOpenAnswer(QuizProvider provider, Question question) {
    return Column(
      children: [
        TextField(
          controller: _openAnswerController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: AppStrings.writeYourAnswer,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _submitOpenAnswer(provider, question.id),
            icon: const Icon(Icons.check),
            label: Text(AppStrings.confirmAnswer),
          ),
        ),
      ],
    );
  }
}
