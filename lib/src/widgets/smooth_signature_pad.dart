import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/signature_controller.dart';
import '../models/signature_point.dart';

/// Smooth, velocity-sensitive digital signature pad with Bézier curve smoothing,
/// optional baseline guideline, and real-time custom painting.
class SmoothSignaturePad extends StatefulWidget {
  const SmoothSignaturePad({
    super.key,
    required this.controller,
    this.backgroundColor = Colors.transparent,
    this.showGuideline = true,
    this.guidelineColor = const Color(0x33000000),
    this.guidelinePosition = 0.8,
    this.guidelineSignHereText = 'X',
  });

  final SignatureController controller;
  final Color backgroundColor;
  final bool showGuideline;
  final Color guidelineColor;
  final double guidelinePosition;
  final String? guidelineSignHereText;

  @override
  State<SmoothSignaturePad> createState() => _SmoothSignaturePadState();
}

class _SmoothSignaturePadState extends State<SmoothSignaturePad> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: GestureDetector(
        onPanStart: (details) {
          widget.controller.startStroke(details.localPosition);
        },
        onPanUpdate: (details) {
          widget.controller.addPoint(details.localPosition);
        },
        onPanEnd: (_) {
          widget.controller.endStroke();
        },
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SignaturePainter(
                controller: widget.controller,
                showGuideline: widget.showGuideline,
                guidelineColor: widget.guidelineColor,
                guidelinePosition: widget.guidelinePosition,
                guidelineSignHereText: widget.guidelineSignHereText,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.controller,
    required this.showGuideline,
    required this.guidelineColor,
    required this.guidelinePosition,
    required this.guidelineSignHereText,
  });

  final SignatureController controller;
  final bool showGuideline;
  final Color guidelineColor;
  final double guidelinePosition;
  final String? guidelineSignHereText;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Guideline if enabled
    if (showGuideline) {
      final y = size.height * guidelinePosition;
      final guidePaint = Paint()
        ..color = guidelineColor
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(24.0, y),
        Offset(size.width - 24.0, y),
        guidePaint,
      );

      if (guidelineSignHereText != null && guidelineSignHereText!.isNotEmpty) {
        final textSpan = TextSpan(
          text: guidelineSignHereText,
          style: TextStyle(
            color: guidelineColor,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(24.0, y - tp.height - 2.0));
      }
    }

    // 2. Draw Signature Strokes
    final allStrokes = [...controller.strokes];
    final paint = Paint()
      ..color = controller.penColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in allStrokes) {
      _drawStroke(canvas, stroke, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<SignaturePoint> stroke, Paint paint) {
    if (stroke.isEmpty) return;

    if (stroke.length == 1) {
      final dotPaint = Paint()
        ..color = controller.penColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          stroke.first.offset, controller.minStrokeWidth, dotPaint);
      return;
    }

    final curves = controller.computeCurves(stroke);
    if (curves.isEmpty) {
      final path = Path();
      path.moveTo(stroke.first.offset.dx, stroke.first.offset.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].offset.dx, stroke[i].offset.dy);
      }
      paint.strokeWidth = controller.minStrokeWidth;
      canvas.drawPath(path, paint);
    } else {
      for (final curve in curves) {
        final steps = max((curve.length / 2.0).ceil(), 2);
        for (int s = 0; s < steps; s++) {
          final t0 = s / steps;
          final t1 = (s + 1) / steps;
          final p0 = curve.point(t0);
          final p1 = curve.point(t1);
          final w = curve.startWidth + (curve.endWidth - curve.startWidth) * t0;

          paint.strokeWidth = w;
          canvas.drawLine(p0, p1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
