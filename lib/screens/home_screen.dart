import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../providers/quiz_provider.dart';
import '../widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('Buffed Quiz'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: AppStrings.history,
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: AppStrings.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          if (quizProvider.sections.isEmpty) {
            return _EmptyState(onCreateTap: () => context.push('/create'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Stats row
              _StatsRow(provider: quizProvider),
              const SizedBox(height: 20),

              // Section list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.yourQuizzes,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${quizProvider.sections.length} ${AppStrings.sections}',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...quizProvider.sections.map(
                (section) => SectionCard(
                  section: section,
                  onStart: () => context.push('/quiz/${section.id}'),
                  onEdit: () => context.push('/edit/${section.id}'),
                  onDelete: () => _confirmDelete(
                      context, quizProvider, section.id, section.name),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          return FloatingActionButton.extended(
            onPressed: () => context.push('/create'),
            icon: const Icon(Icons.add_rounded),
            label: Text(AppStrings.newQuiz),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, QuizProvider provider, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded,
            color: Colors.red, size: 32),
        title: Text(AppStrings.deleteQuiz),
        content: Text('${AppStrings.deleteQuizConfirm} "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteSection(id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Stats row shown above section list
// ──────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final QuizProvider provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final totalResults = provider.results.length;
    final avgScore = totalResults == 0
        ? 0.0
        : provider.results.map((r) => r.percentage).reduce((a, b) => a + b) /
            totalResults;
    final best = totalResults == 0
        ? 0.0
        : provider.results.map((r) => r.percentage).reduce(
            (a, b) => a > b ? a : b);

    return Row(
      children: [
        _StatCard(
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFFFC107),
          label: AppStrings.language == AppLanguage.cs ? 'Nejlepší' : 'Best',
          value: totalResults == 0 ? '—' : '${best.toInt()}%',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.bar_chart_rounded,
          iconColor: AppTheme.accent,
          label: AppStrings.language == AppLanguage.cs ? 'Průměr' : 'Average',
          value: totalResults == 0 ? '—' : '${avgScore.toInt()}%',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.history_edu_rounded,
          iconColor: AppTheme.primary,
          label: AppStrings.language == AppLanguage.cs ? 'Testů' : 'Tests',
          value: '$totalResults',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppTheme.primary.withValues(alpha: 0.12),
          ),
          boxShadow: AppTheme.isDark
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Empty state widget
// ──────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.quiz_rounded,
                size: 56,
                color: AppTheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.noQuizzesYet,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.noQuizzesDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add_rounded),
              label: Text(AppStrings.createQuiz),
            ),
          ],
        ),
      ),
    );
  }
}
