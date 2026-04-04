import 'package:flutter/material.dart';
import 'pattern_background.dart';

/// Gradient banner with decorative pattern background + content slot.
/// Standardizes the look of the top banners across journey screens.
class GradientBanner extends StatelessWidget {
  final List<Color> colors;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final PatternStyle? patternStyle;
  final double? height;

  const GradientBanner({
    super.key,
    required this.colors,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(24),
    this.patternStyle = PatternStyle.circles,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            if (patternStyle != null)
              Positioned.fill(
                child: PatternBackground(
                  color: Colors.white,
                  opacity: 0.08,
                  style: patternStyle!,
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
