import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveWaveformPainter extends CustomPainter {
  final double progress;
  final List<double> barHeights;
  final bool isPaused;

  LiveWaveformPainter({
    required this.progress,
    required this.barHeights,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = barHeights.length;
    if (count == 0) return; // guards against a divide-by-zero on spacing below

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final spacing = size.width / count;
    final cx = size.width / 2;

    for (int i = 0; i < count; i++) {
      final x = i * spacing + spacing / 2;

      double animatedHeight;
      if (!isPaused) {
        final phase = (i / count) - progress;
        final wave = math.sin(phase * math.pi * 3);
        animatedHeight = size.height * barHeights[i] * (0.5 + 0.5 * wave.abs());
      } else {
        animatedHeight = size.height * barHeights[i] * 0.5;
      }

      final isRight = x > cx + 20;
      paint.color = isRight
          ? Colors.white.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.85);

      canvas.drawLine(
        Offset(x, size.height / 2 - animatedHeight / 2),
        Offset(x, size.height / 2 + animatedHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LiveWaveformPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isPaused != isPaused;
}
