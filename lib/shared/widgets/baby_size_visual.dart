import 'dart:math';
import 'package:flutter/material.dart';

/// Visual comparison of baby's size vs the previous week.
/// Pure CustomPainter — scales cleanly, no image assets.
class BabySizeVisual extends StatelessWidget {
  final double currentLengthCm;
  final double previousLengthCm;
  final Color color;

  const BabySizeVisual({
    super.key,
    required this.currentLengthCm,
    required this.previousLengthCm,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _BabySizePainter(
          currentSize: currentLengthCm,
          previousSize: previousLengthCm,
          color: color,
        ),
      ),
    );
  }
}

class _BabySizePainter extends CustomPainter {
  final double currentSize;
  final double previousSize;
  final Color color;

  _BabySizePainter({
    required this.currentSize,
    required this.previousSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Normalize sizes — 52cm (full term) is max
    const maxPregnancyCm = 52.0;
    final currentRatio = (currentSize / maxPregnancyCm).clamp(0.15, 1.0);
    final previousRatio = (previousSize / maxPregnancyCm).clamp(0.15, 1.0);

    // Previous size — outline circle
    canvas.drawCircle(
      center,
      maxRadius * previousRatio,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Current size — filled circle
    canvas.drawCircle(
      center,
      maxRadius * currentRatio,
      Paint()
        ..color = color.withValues(alpha: 0.25),
    );

    // Inner baby silhouette
    _drawBabySilhouette(canvas, center, maxRadius * currentRatio * 0.7, color);
  }

  /// Simple curled baby silhouette — stylized, cute.
  void _drawBabySilhouette(Canvas canvas, Offset c, double r, Color col) {
    if (r < 6) {
      canvas.drawCircle(c, r, Paint()..color = col);
      return;
    }
    final paint = Paint()..color = col;

    // Head (top)
    canvas.drawCircle(
      Offset(c.dx, c.dy - r * 0.5),
      r * 0.4,
      paint,
    );

    // Body — curled curve
    final body = Path();
    body.moveTo(c.dx - r * 0.3, c.dy - r * 0.2);
    body.quadraticBezierTo(
      c.dx - r * 0.6, c.dy + r * 0.2,
      c.dx - r * 0.2, c.dy + r * 0.5,
    );
    body.quadraticBezierTo(
      c.dx + r * 0.3, c.dy + r * 0.6,
      c.dx + r * 0.5, c.dy + r * 0.1,
    );
    body.quadraticBezierTo(
      c.dx + r * 0.4, c.dy - r * 0.2,
      c.dx + r * 0.1, c.dy - r * 0.2,
    );
    body.close();
    canvas.drawPath(body, paint);
  }

  @override
  bool shouldRepaint(covariant _BabySizePainter old) =>
      old.currentSize != currentSize || old.previousSize != previousSize;
}

/// Horizontal size comparison — baby vs a fruit or familiar object.
class SizeComparisonBar extends StatelessWidget {
  final double lengthCm;
  final double weightG;
  final Color color;

  const SizeComparisonBar({
    super.key,
    required this.lengthCm,
    required this.weightG,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final weightDisplay = weightG >= 1000
        ? '${(weightG / 1000).toStringAsFixed(2)} kg'
        : '${weightG.round()} g';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SizeStat(
            label: 'Length',
            value: '${lengthCm.toStringAsFixed(1)} cm',
            icon: Icons.straighten,
          ),
          Container(
            width: 1,
            height: 32,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          _SizeStat(
            label: 'Weight',
            value: weightDisplay,
            icon: Icons.monitor_weight_outlined,
          ),
        ],
      ),
    );
  }
}

class _SizeStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SizeStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Progress ring showing pregnancy progress (weeks 1-40).
class PregnancyProgressRing extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final double size;
  final Color color;
  final Color trackColor;

  const PregnancyProgressRing({
    super.key,
    required this.currentWeek,
    this.totalWeeks = 40,
    this.size = 80,
    this.color = Colors.white,
    this.trackColor = Colors.white24,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentWeek / totalWeeks).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: color,
          trackColor: trackColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentWeek',
                style: TextStyle(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                'weeks',
                style: TextStyle(
                  fontSize: size * 0.13,
                  color: color.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 6.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}
