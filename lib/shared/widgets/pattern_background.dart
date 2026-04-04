import 'dart:math';
import 'package:flutter/material.dart';

/// Decorative floating-circles pattern used as a subtle backdrop on banners.
/// Purely visual — no image files needed.
class PatternBackground extends StatelessWidget {
  final Color color;
  final double opacity;
  final PatternStyle style;

  const PatternBackground({
    super.key,
    required this.color,
    this.opacity = 0.15,
    this.style = PatternStyle.circles,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PatternPainter(
        color: color.withValues(alpha: opacity),
        style: style,
      ),
      size: Size.infinite,
    );
  }
}

enum PatternStyle { circles, dots, waves, hearts }

class _PatternPainter extends CustomPainter {
  final Color color;
  final PatternStyle style;

  _PatternPainter({required this.color, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Seed random so pattern is stable across rebuilds.
    final rand = Random(42);

    switch (style) {
      case PatternStyle.circles:
        _paintCircles(canvas, size, paint, rand);
      case PatternStyle.dots:
        _paintDots(canvas, size, paint);
      case PatternStyle.waves:
        _paintWaves(canvas, size, paint);
      case PatternStyle.hearts:
        _paintHearts(canvas, size, paint, rand);
    }
  }

  void _paintCircles(Canvas canvas, Size size, Paint paint, Random rand) {
    // 6-8 floating circles of various sizes
    const count = 7;
    for (var i = 0; i < count; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = 20 + rand.nextDouble() * 60;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 24.0;
    const radius = 2.0;
    for (var y = 0.0; y < size.height; y += spacing) {
      for (var x = 0.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _paintWaves(Canvas canvas, Size size, Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var y = 20.0; y < size.height; y += 30) {
      final path = Path();
      path.moveTo(0, y);
      for (var x = 0.0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10, y - 5,
          x + 20, y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _paintHearts(Canvas canvas, Size size, Paint paint, Random rand) {
    const count = 6;
    for (var i = 0; i < count; i++) {
      final cx = rand.nextDouble() * size.width;
      final cy = rand.nextDouble() * size.height;
      final scale = 8.0 + rand.nextDouble() * 16;
      _drawHeart(canvas, paint, Offset(cx, cy), scale);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double s) {
    final path = Path();
    path.moveTo(center.dx, center.dy + s * 0.3);
    path.cubicTo(
      center.dx - s * 1.2, center.dy - s * 0.5,
      center.dx - s * 0.6, center.dy - s * 1.3,
      center.dx, center.dy - s * 0.4,
    );
    path.cubicTo(
      center.dx + s * 0.6, center.dy - s * 1.3,
      center.dx + s * 1.2, center.dy - s * 0.5,
      center.dx, center.dy + s * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PatternPainter old) =>
      old.color != color || old.style != style;
}
