import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final String time;
  final bool isWarning;

  const TimerDisplay({
    super.key,
    required this.time,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isWarning
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWarning ? Colors.red.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color: isWarning ? Colors.red[300] : Colors.white70,
          ),
          const SizedBox(width: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isWarning ? Colors.red[300] : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
