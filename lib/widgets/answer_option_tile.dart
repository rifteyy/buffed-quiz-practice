import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/theme.dart';

class AnswerOptionTile extends StatefulWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final VoidCallback? onTap;

  const AnswerOptionTile({
    super.key,
    required this.label,
    required this.text,
    this.isSelected = false,
    this.isCorrect,
    this.showResult = false,
    this.onTap,
  });

  @override
  State<AnswerOptionTile> createState() => _AnswerOptionTileState();
}

class _AnswerOptionTileState extends State<AnswerOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap!();
  }

  Color get _bgColor {
    if (widget.showResult) {
      if (widget.isCorrect == true) {
        return AppTheme.success.withValues(alpha: 0.13);
      }
      if (widget.isSelected && widget.isCorrect == false) {
        return AppTheme.error.withValues(alpha: 0.13);
      }
    }
    if (widget.isSelected) return AppTheme.primary.withValues(alpha: 0.13);
    return AppTheme.surface;
  }

  Color get _borderColor {
    if (widget.showResult) {
      if (widget.isCorrect == true) return AppTheme.success;
      if (widget.isSelected && widget.isCorrect == false) return AppTheme.error;
    }
    if (widget.isSelected) return AppTheme.primary;
    return AppTheme.isDark
        ? Colors.white.withValues(alpha: 0.14)
        : AppTheme.primaryLight.withValues(alpha: 0.45);
  }

  Color get _badgeBg {
    if (widget.showResult && widget.isCorrect == true) return AppTheme.success;
    if (widget.showResult && widget.isSelected && widget.isCorrect == false) {
      return AppTheme.error;
    }
    if (widget.isSelected) return AppTheme.primary;
    return AppTheme.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : AppTheme.cardColor;
  }

  Color get _badgeFg {
    if (widget.isSelected ||
        (widget.showResult && widget.isCorrect == true) ||
        (widget.showResult && widget.isSelected)) {
      return Colors.white;
    }
    return AppTheme.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.showResult ? null : _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border.all(
                color: _borderColor,
                width: widget.isSelected ||
                        (widget.showResult && widget.isCorrect == true)
                    ? 2.0
                    : 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: widget.isSelected && !widget.showResult
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : widget.showResult && widget.isCorrect == true
                      ? [
                          BoxShadow(
                            color: AppTheme.success.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
            ),
            child: Row(
              children: [
                // Label badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: _badgeContent()),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _trailingWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeContent() {
    if (widget.showResult && widget.isCorrect == true) {
      return const Icon(Icons.check, color: Colors.white, size: 18);
    }
    if (widget.showResult && widget.isSelected && widget.isCorrect == false) {
      return const Icon(Icons.close, color: Colors.white, size: 18);
    }
    return Text(
      widget.label,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: _badgeFg,
      ),
    );
  }

  Widget _trailingWidget() {
    if (widget.showResult && widget.isCorrect == true) {
      return _ResultBadge(
        icon: Icons.check_circle_rounded,
        color: AppTheme.success,
        label: '✓',
      );
    }
    if (widget.showResult && widget.isSelected && widget.isCorrect == false) {
      return _ResultBadge(
        icon: Icons.cancel_rounded,
        color: AppTheme.error,
        label: '✗',
      );
    }
    if (widget.isSelected && !widget.showResult) {
      return Icon(Icons.radio_button_checked_rounded,
          color: AppTheme.primary, size: 22);
    }
    return Icon(Icons.radio_button_unchecked,
        color: AppTheme.isDark
            ? Colors.white.withValues(alpha: 0.25)
            : AppTheme.textSecondary.withValues(alpha: 0.4),
        size: 22);
  }
}

class _ResultBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ResultBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
