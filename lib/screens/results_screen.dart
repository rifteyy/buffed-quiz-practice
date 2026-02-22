import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';

class ResultsScreen extends StatefulWidget {
  final String resultId;

  const ResultsScreen({super.key, required this.resultId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _loadingFeedback = false;

  Future<void> _requestAIFeedback() async {
    final settings = context.read<SettingsProvider>();
    if (!settings.hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.setApiKeyForFeedback),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<QuizProvider>();
    final result = provider.getResultById(widget.resultId);
    if (result == null) return;

    final section = provider.getSectionById(result.sectionId);
    if (section == null) return;

    setState(() => _loadingFeedback = true);

    try {
      final aiService = AIService(apiKey: settings.apiKey);
      final questionsAndAnswers = section.questions.map((q) {
        return {
          'question': q.questionText,
          'correct': q.correctAnswer,
          'answer': result.userAnswers[q.id] ?? AppStrings.noAnswer,
          'isCorrect': (result.correctness[q.id] ?? false).toString(),
        };
      }).toList();

      final feedback = await aiService.generateQuizFeedback(
        questionsAndAnswers,
        result.score,
        result.totalQuestions,
      );

      await provider.updateResultWithAIFeedback(
        widget.resultId,
        feedback,
        null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (mounted) setState(() => _loadingFeedback = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final result = provider.getResultById(widget.resultId);

        if (result == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.results)),
            body: Center(child: Text(AppStrings.resultNotFound)),
          );
        }

        final section = provider.getSectionById(result.sectionId);

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.results),
            leading: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/'),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        result.sectionName,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: result.percentage / 100,
                              strokeWidth: 10,
                              backgroundColor:
                                  AppTheme.primaryLight.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                result.percentage >= 60
                                    ? AppTheme.success
                                    : AppTheme.error,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${result.percentage.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: result.percentage >= 60
                                          ? AppTheme.success
                                          : AppTheme.error,
                                    ),
                                  ),
                                  Text(
                                    '${result.score}/${result.totalQuestions}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: result.percentage >= 60
                              ? AppTheme.success.withValues(alpha: 0.1)
                              : AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          result.gradeText,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: result.percentage >= 60
                                ? AppTheme.success
                                : AppTheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${AppStrings.time}: ${result.formattedTime}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (section != null) ...[
                Text(
                  AppStrings.answerOverview,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ...section.questions.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final q = entry.value;
                  final isCorrect = result.correctness[q.id] ?? false;
                  final userAnswer =
                      result.userAnswers[q.id] ?? AppStrings.noAnswer;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            isCorrect ? AppTheme.success : AppTheme.error,
                        child: Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        '${idx + 1}. ${q.questionText}',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.yours}: $userAnswer',
                            style: TextStyle(
                              fontSize: 13,
                              color: isCorrect
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                          ),
                          if (!isCorrect)
                            Text(
                              '${AppStrings.correct}: ${q.correctAnswer}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.success,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              if (result.aiFeedback != null) ...[
                Text(
                  AppStrings.aiFeedback,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: AppTheme.accent.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppTheme.accent, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.aiFeedback!,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadingFeedback ? null : _requestAIFeedback,
                    icon: _loadingFeedback
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _loadingFeedback
                          ? AppStrings.generatingFeedback
                          : AppStrings.getAiFeedback,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home),
                      label: Text(AppStrings.homeBtn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.go('/quiz/${result.sectionId}');
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(AppStrings.again),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
