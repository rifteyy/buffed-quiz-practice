import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/strings.dart';
import '../constants/theme.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;

  static const List<String> _colorNames = [
    'colorSalmon', 'colorPurple', 'colorBlue', 'colorTeal',
    'colorOrange', 'colorPink', 'colorGreen', 'colorIndigo',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiKeyController.text = context.read<SettingsProvider>().apiKey;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    context.read<SettingsProvider>().saveApiKey(_apiKeyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(AppStrings.apiKeySaved),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppTheme.error, size: 36),
        title: Text(AppStrings.deleteAllData),
        content: Text(AppStrings.deleteAllDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<SettingsProvider>().clearAllData();
              _apiKeyController.clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.allDataDeleted),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(AppStrings.deleteAll),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── APPEARANCE ───────────────────────────────────────────
              _SectionHeader(
                icon: Icons.palette_outlined,
                title: AppStrings.appearance,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dark mode toggle
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.isDark
                                  ? Colors.indigo.withValues(alpha: 0.15)
                                  : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              AppTheme.isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppTheme.isDark
                                  ? Colors.indigoAccent
                                  : Colors.amber[700],
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.darkMode,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Switch(
                            value: settings.isDarkMode,
                            activeThumbColor: AppTheme.primary,
                            activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
                            onChanged: (v) => settings.setDarkMode(v),
                          ),
                        ],
                      ),
                      Divider(
                          height: 24,
                          color: AppTheme.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppTheme.primary.withValues(alpha: 0.1)),
                      // Color picker label
                      Row(
                        children: [
                          Icon(Icons.color_lens_outlined,
                              color: AppTheme.textSecondary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.themeColor,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Color swatches
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          AppTheme.presetColors.length,
                          (i) {
                            final color = AppTheme.presetColors[i];
                            final isSelected = settings.themeColorIndex == i;
                            final label = AppStrings.get(_colorNames[i]);
                            return Tooltip(
                              message: label,
                              child: GestureDetector(
                                onTap: () => settings.setThemeColorIndex(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: AppTheme.isDark
                                                ? Colors.white
                                                : Colors.black,
                                            width: 3)
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(
                                                  alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 22)
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── LANGUAGE ─────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.language_rounded,
                title: AppStrings.languageSetting,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.cs,
                        label: Text(AppStrings.czech),
                        icon: const Text('🇨🇿',
                            style: TextStyle(fontSize: 18)),
                      ),
                      ButtonSegment(
                        value: AppLanguage.en,
                        label: Text(AppStrings.english),
                        icon: const Text('🇬🇧',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ],
                    selected: {settings.language},
                    onSelectionChanged: (vals) {
                      settings.setLanguage(vals.first);
                      setState(() {});
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── API KEY ──────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.key_rounded,
                title: AppStrings.openaiApiKey,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: settings.hasApiKey
                                  ? AppTheme.success.withValues(alpha: 0.12)
                                  : AppTheme.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              settings.hasApiKey
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              color: settings.hasApiKey
                                  ? AppTheme.success
                                  : AppTheme.warning,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              settings.hasApiKey
                                  ? (AppStrings.language == AppLanguage.cs
                                      ? 'API klíč je nastaven'
                                      : 'API key is set')
                                  : (AppStrings.language == AppLanguage.cs
                                      ? 'API klíč není nastaven'
                                      : 'No API key set'),
                              style: TextStyle(
                                fontSize: 13,
                                color: settings.hasApiKey
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.apiKeyDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureApiKey,
                        decoration: InputDecoration(
                          hintText: 'sk-...',
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscureApiKey
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () => setState(
                                    () => _obscureApiKey = !_obscureApiKey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveApiKey,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: Text(AppStrings.saveKey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── ABOUT ────────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.info_outline_rounded,
                title: AppStrings.aboutApp,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                          icon: Icons.tag_rounded,
                          label: AppStrings.version,
                          value: '1.0.0'),
                      _InfoRow(
                          icon: Icons.smart_toy_outlined,
                          label: AppStrings.aiModel,
                          value: 'GPT-4o-mini'),
                      _InfoRow(
                          icon: Icons.storage_rounded,
                          label: AppStrings.dataStorage,
                          value: AppStrings.localOnDevice),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── DANGER ZONE ──────────────────────────────────────────
              _SectionHeader(
                icon: Icons.warning_amber_rounded,
                title: AppStrings.dangerZone,
                color: AppTheme.error,
              ),
              Card(
                color: AppTheme.error.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side:
                      BorderSide(color: AppTheme.error.withValues(alpha: 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _confirmClearData,
                      icon: const Icon(Icons.delete_forever_rounded,
                          color: AppTheme.error),
                      label: Text(AppStrings.deleteAllData,
                          style: const TextStyle(color: AppTheme.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primary;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style:
                  TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
