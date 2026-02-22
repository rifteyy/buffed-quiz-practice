import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../models/question_model.dart';
import '../providers/quiz_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String? editSectionId;

  const CreateQuizScreen({super.key, this.editSectionId});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timerController = TextEditingController(text: '10');
  List<_QuestionEntry> _questions = [];
  bool _isEditing = false;
  bool _shuffleQuestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.editSectionId != null) {
      _isEditing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingSection();
      });
    } else {
      _questions = [_QuestionEntry()];
    }
  }

  void _loadExistingSection() {
    final provider = context.read<QuizProvider>();
    final section = provider.getSectionById(widget.editSectionId!);
    if (section != null) {
      _nameController.text = section.name;
      _descriptionController.text = section.description ?? '';
      _timerController.text = section.timerMinutes.toString();
      setState(() {
        _shuffleQuestions = section.shuffleQuestions;
        _questions = section.questions.map((q) {
          final entry = _QuestionEntry();
          entry.questionController.text = q.questionText;
          entry.hintController.text = q.hint ?? '';
          entry.type = q.type;
          if (q.type == QuestionType.multipleChoice) {
            if (q.options.isNotEmpty) {
              for (int i = 0;
                  i < q.options.length && i < entry.optionControllers.length;
                  i++) {
                entry.optionControllers[i].text = q.options[i];
              }
              // Mark the correct answer index
              final idx = q.options.indexOf(q.correctAnswer);
              entry.correctOptionIndex = idx != -1 ? idx : 0;
            }
          } else {
            entry.answerController.text = q.correctAnswer;
          }
          return entry;
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timerController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(_QuestionEntry());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Future<void> _generateAIOptions(int index) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.hasApiKey) {
      _showSnackBar(AppStrings.setApiKeyFirst);
      return;
    }

    final entry = _questions[index];
    final correctText =
        entry.optionControllers[entry.correctOptionIndex].text.trim();

    if (entry.questionController.text.isEmpty || correctText.isEmpty) {
      _showSnackBar(AppStrings.fillQuestionAndAnswerFirst);
      return;
    }

    setState(() => entry.isGenerating = true);

    try {
      final aiService = AIService(apiKey: settings.apiKey);
      final wrongOptions = await aiService.generateWrongOptions(
        entry.questionController.text,
        correctText,
      );

      // Fill the OTHER 3 option slots (not the correct one)
      setState(() {
        int wrongIdx = 0;
        for (int i = 0; i < 4 && wrongIdx < wrongOptions.length; i++) {
          if (i != entry.correctOptionIndex) {
            entry.optionControllers[i].text = wrongOptions[wrongIdx++];
          }
        }
        entry.isGenerating = false;
      });

      _showSnackBar(AppStrings.optionsGenerated);
    } catch (e) {
      setState(() => entry.isGenerating = false);
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_questions.isEmpty) {
      _showSnackBar(AppStrings.addAtLeastOneQuestion);
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final questionEmpty = q.questionController.text.trim().isEmpty;
      final answerEmpty = q.type == QuestionType.multipleChoice
          ? q.optionControllers[q.correctOptionIndex].text.trim().isEmpty
          : q.answerController.text.trim().isEmpty;
      if (questionEmpty || answerEmpty) {
        _showSnackBar('${AppStrings.fillQuestionAndAnswer} ${i + 1}');
        return;
      }
    }

    final provider = context.read<QuizProvider>();
    final questions = _questions.map((entry) {
      final options = entry.type == QuestionType.multipleChoice
          ? entry.optionControllers
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList()
          : <String>[];

      final correctAnswer = entry.type == QuestionType.multipleChoice
          ? entry.optionControllers[entry.correctOptionIndex].text.trim()
          : entry.answerController.text.trim();

      if (entry.type == QuestionType.multipleChoice && options.isEmpty) {
        options.add(correctAnswer);
      }

      return provider.createQuestion(
        questionText: entry.questionController.text.trim(),
        correctAnswer: correctAnswer,
        options: options,
        hint: entry.hintController.text.trim().isNotEmpty
            ? entry.hintController.text.trim()
            : null,
        type: entry.type,
      );
    }).toList();

    if (_isEditing) {
      final existing = provider.getSectionById(widget.editSectionId!);
      if (existing != null) {
        final updated = existing.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          questions: questions,
          timerMinutes: int.tryParse(_timerController.text) ?? 10,
          shuffleQuestions: _shuffleQuestions,
        );
        await provider.updateSection(updated);
      }
    } else {
      final section = provider.createSection(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        questions: questions,
        timerMinutes: int.tryParse(_timerController.text) ?? 10,
        shuffleQuestions: _shuffleQuestions,
      );
      await provider.addSection(section);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? AppStrings.editQuiz : AppStrings.newQuiz),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveQuiz,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(AppStrings.save,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.quizInfo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.quizName,
                        hintText: AppStrings.quizNameHint,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? AppStrings.enterName
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: AppStrings.descriptionOptional,
                        hintText: AppStrings.descriptionHint,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _timerController,
                      decoration: InputDecoration(
                        labelText: AppStrings.timerMinutes,
                        suffixText: AppStrings.min,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final val = int.tryParse(v ?? '');
                        if (val == null || val < 1) {
                          return AppStrings.enterValidTime;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        AppStrings.shuffleQuestions,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        AppStrings.shuffleQuestionsDesc,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      value: _shuffleQuestions,
                      activeThumbColor: AppTheme.primary,
                      activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
                      onChanged: (v) => setState(() => _shuffleQuestions = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.question} (${_questions.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addQuestion,
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.addQuestion),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              return _buildQuestionCard(index, q);
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.addAnotherQuestion),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, _QuestionEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: number badge + type toggle + remove button
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                SegmentedButton<QuestionType>(
                  segments: [
                    ButtonSegment(
                      value: QuestionType.multipleChoice,
                      label: Text(AppStrings.multipleChoice,
                          style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.list, size: 16),
                    ),
                    ButtonSegment(
                      value: QuestionType.openEnded,
                      label: Text(AppStrings.openEnded,
                          style: const TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.edit_note, size: 16),
                    ),
                  ],
                  selected: {entry.type},
                  onSelectionChanged: (vals) {
                    setState(() => entry.type = vals.first);
                  },
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                    onPressed: () => _removeQuestion(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: entry.questionController,
              decoration: InputDecoration(
                labelText: AppStrings.questionText,
                hintText: AppStrings.questionTextHint,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),

            // Open-ended: show correct answer text field
            if (entry.type == QuestionType.openEnded) ...[
              TextFormField(
                controller: entry.answerController,
                decoration: InputDecoration(
                  labelText: AppStrings.correctAnswer,
                  hintText: AppStrings.correctAnswerHint,
                ),
              ),
              const SizedBox(height: 10),
            ],

            TextFormField(
              controller: entry.hintController,
              decoration: InputDecoration(
                labelText: AppStrings.hintOptional,
                hintText: AppStrings.hintForStudent,
              ),
            ),

            // Multiple choice: option tiles with click-to-mark-correct
            if (entry.type == QuestionType.multipleChoice) ...[
              const SizedBox(height: 12),
              const Divider(),
              Row(
                children: [
                  Text(
                    AppStrings.answerOptions,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      return TextButton.icon(
                        onPressed: entry.isGenerating
                            ? null
                            : () => _generateAIOptions(index),
                        icon: entry.isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          entry.isGenerating
                              ? AppStrings.generating
                              : AppStrings.aiGenerate,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppStrings.tapOptionToMarkCorrect,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              ...List.generate(4, (optIndex) {
                final labels = ['A', 'B', 'C', 'D'];
                final isCorrect = entry.correctOptionIndex == optIndex;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Clickable badge — tap to mark as correct
                      GestureDetector(
                        onTap: () =>
                            setState(() => entry.correctOptionIndex = optIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppTheme.success
                                : AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCorrect
                                  ? AppTheme.success
                                  : AppTheme.primary.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isCorrect
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : Text(
                                    labels[optIndex],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: entry.optionControllers[optIndex],
                          decoration: InputDecoration(
                            hintText: '${AppStrings.option} ${labels[optIndex]}',
                            filled: true,
                            fillColor: isCorrect
                                ? AppTheme.success.withValues(alpha: 0.07)
                                : null,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isCorrect
                                    ? AppTheme.success.withValues(alpha: 0.6)
                                    : AppTheme.primaryLight
                                        .withValues(alpha: 0.5),
                                width: isCorrect ? 1.5 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isCorrect
                                    ? AppTheme.success
                                    : AppTheme.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuestionEntry {
  final questionController = TextEditingController();
  final answerController = TextEditingController(); // open-ended only
  final hintController = TextEditingController();
  final optionControllers = List.generate(4, (_) => TextEditingController());
  QuestionType type = QuestionType.multipleChoice;
  int correctOptionIndex = 0; // which A-D option is correct (MC only)
  bool isGenerating = false;

  void dispose() {
    questionController.dispose();
    answerController.dispose();
    hintController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
  }
}
