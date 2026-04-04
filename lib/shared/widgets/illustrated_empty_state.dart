import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Friendly empty state with custom-painted illustration.
class IllustratedEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? action;

  const IllustratedEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = AppColors.primary,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _EmptyStatePainter(color: color),
                child: Center(
                  child: Icon(icon, size: 48, color: color),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyStatePainter extends CustomPainter {
  final Color color;

  _EmptyStatePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Large soft circle background
    canvas.drawCircle(
      center,
      size.width / 2,
      Paint()..color = color.withValues(alpha: 0.06),
    );

    // Medium circle
    canvas.drawCircle(
      center,
      size.width / 2 - 16,
      Paint()..color = color.withValues(alpha: 0.08),
    );

    // Decorative dots around the edge
    final paint = Paint()..color = color.withValues(alpha: 0.2);
    for (var angle = 0.0; angle < 360; angle += 45) {
      final rad = angle * math.pi / 180;
      final dx = center.dx + (size.width / 2 - 6) * 1.05 * math.cos(rad);
      final dy = center.dy + (size.width / 2 - 6) * 1.05 * math.sin(rad);
      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmptyStatePainter old) => old.color != color;
}
