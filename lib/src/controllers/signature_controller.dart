import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/signature_point.dart';

/// Controller managing signature strokes, velocity-sensitive pressure calculations,
/// multi-pen styles, undo/redo history, and auto-trimmed vector SVG & PNG exports.
class SignatureController extends ChangeNotifier {
  SignatureController({
    this.penColor = Colors.black,
    this.penStyle = PenStyle.fountain,
    this.minStrokeWidth = 1.5,
    this.maxStrokeWidth = 4.5,
    this.velocityFilterWeight = 0.7,
  }) : assert(minStrokeWidth <= maxStrokeWidth,
            'minStrokeWidth cannot exceed maxStrokeWidth');

  final Color penColor;
  final PenStyle penStyle;
  final double minStrokeWidth;
  final double maxStrokeWidth;
  final double velocityFilterWeight;

  final List<List<SignaturePoint>> _strokes = [];
  final List<List<SignaturePoint>> _undoHistory = [];

  List<SignaturePoint>? _currentStroke;

  List<List<SignaturePoint>> get strokes => List.unmodifiable(_strokes);
  bool get isEmpty => _strokes.isEmpty && (_currentStroke?.isEmpty ?? true);
  bool get isNotEmpty => !isEmpty;
  bool get canUndo => _strokes.isNotEmpty;
  bool get canRedo => _undoHistory.isNotEmpty;

  /// Calculates the exact bounding box enclosing all recorded signature strokes.
  Rect? get bounds {
    final allStrokes = [..._strokes];
    if (_currentStroke != null) allStrokes.add(_currentStroke!);

    if (allStrokes.isEmpty || allStrokes.every((s) => s.isEmpty)) return null;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in allStrokes) {
      for (final pt in stroke) {
        minX = min(minX, pt.offset.dx);
        minY = min(minY, pt.offset.dy);
        maxX = max(maxX, pt.offset.dx);
        maxY = max(maxY, pt.offset.dy);
      }
    }

    if (minX == double.infinity) return null;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void startStroke(Offset point) {
    _undoHistory.clear();

    _currentStroke = [
      SignaturePoint(
        offset: point,
        time: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
    notifyListeners();
  }

  void addPoint(Offset point) {
    if (_currentStroke == null) {
      startStroke(point);
      return;
    }

    final newPoint = SignaturePoint(
      offset: point,
      time: DateTime.now().millisecondsSinceEpoch,
    );

    _currentStroke!.add(newPoint);
    notifyListeners();
  }

  void endStroke() {
    if (_currentStroke != null && _currentStroke!.isNotEmpty) {
      _strokes.add(List.from(_currentStroke!));
      _currentStroke = null;
      notifyListeners();
    }
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      _undoHistory.add(_strokes.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_undoHistory.isNotEmpty) {
      _strokes.add(_undoHistory.removeLast());
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    _undoHistory.clear();
    _currentStroke = null;
    notifyListeners();
  }

  double _strokeWidth(double velocity) {
    switch (penStyle) {
      case PenStyle.ballpoint:
        return (minStrokeWidth + maxStrokeWidth) / 2.0;
      case PenStyle.fountain:
      case PenStyle.calligraphy:
        const maxVelocity = 2.5;
        final clampedVelocity = velocity.clamp(0.0, maxVelocity);
        final ratio = 1.0 - (clampedVelocity / maxVelocity);
        return minStrokeWidth + (maxStrokeWidth - minStrokeWidth) * ratio;
    }
  }

  List<CubicCurve> computeCurves(List<SignaturePoint> points) {
    if (points.length < 3) return [];

    final curves = <CubicCurve>[];
    double lastWidth = (minStrokeWidth + maxStrokeWidth) / 2.0;
    double lastVelocity = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = (i + 2 < points.length) ? points[i + 2] : p2;

      // Catmull-Rom to Cubic Bézier control points
      final cp1 = p1.offset + (p2.offset - p0.offset) / 6.0;
      final cp2 = p2.offset - (p3.offset - p1.offset) / 6.0;

      final velocity = p1.velocityTo(p2);
      final filteredVelocity = velocityFilterWeight * velocity +
          (1 - velocityFilterWeight) * lastVelocity;
      final width = _strokeWidth(filteredVelocity);

      curves.add(CubicCurve(
        startPoint: p1.offset,
        controlPoint1: cp1,
        controlPoint2: cp2,
        endPoint: p2.offset,
        startWidth: lastWidth,
        endWidth: width,
      ));

      lastVelocity = filteredVelocity;
      lastWidth = width;
    }

    return curves;
  }

  /// Exports the recorded signature as clean vector SVG path markup.
  /// If [trim] is true, tightly crops the SVG viewBox around signature bounds.
  String toSvg({
    int width = 400,
    int height = 200,
    Color? strokeColor,
    bool trim = false,
    double trimPadding = 12.0,
  }) {
    final color = strokeColor ?? penColor;
    final hexColor =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';

    final signBounds = bounds;
    String viewBox = '0 0 $width $height';
    int outWidth = width;
    int outHeight = height;

    if (trim && signBounds != null) {
      final minX = max(0.0, signBounds.left - trimPadding);
      final minY = max(0.0, signBounds.top - trimPadding);
      final cropW = signBounds.width + 2 * trimPadding;
      final cropH = signBounds.height + 2 * trimPadding;

      viewBox =
          '${minX.toStringAsFixed(1)} ${minY.toStringAsFixed(1)} ${cropW.toStringAsFixed(1)} ${cropH.toStringAsFixed(1)}';
      outWidth = cropW.ceil();
      outHeight = cropH.ceil();
    }

    final sb = StringBuffer();
    sb.writeln(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$viewBox" width="$outWidth" height="$outHeight">');
    sb.writeln('  <!-- Generated by smooth_signature_pad (Govind Tank) -->');

    final allStrokes = [..._strokes];
    if (_currentStroke != null) allStrokes.add(_currentStroke!);

    for (final stroke in allStrokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        final p = stroke.first.offset;
        sb.writeln(
            '  <circle cx="${p.dx.toStringAsFixed(1)}" cy="${p.dy.toStringAsFixed(1)}" r="${minStrokeWidth.toStringAsFixed(1)}" fill="$hexColor" />');
        continue;
      }

      final curves = computeCurves(stroke);
      if (curves.isEmpty) {
        sb.write(
            '  <polyline fill="none" stroke="$hexColor" stroke-width="${minStrokeWidth.toStringAsFixed(1)}" stroke-linecap="round" stroke-linejoin="round" points="');
        for (final pt in stroke) {
          sb.write(
              '${pt.offset.dx.toStringAsFixed(1)},${pt.offset.dy.toStringAsFixed(1)} ');
        }
        sb.writeln('" />');
      } else {
        sb.write(
            '  <path fill="none" stroke="$hexColor" stroke-width="${maxStrokeWidth.toStringAsFixed(1)}" stroke-linecap="round" stroke-linejoin="round" d="');
        sb.write(
            'M ${curves.first.startPoint.dx.toStringAsFixed(1)} ${curves.first.startPoint.dy.toStringAsFixed(1)} ');
        for (final c in curves) {
          sb.write(
              'C ${c.controlPoint1.dx.toStringAsFixed(1)} ${c.controlPoint1.dy.toStringAsFixed(1)}, ');
          sb.write(
              '${c.controlPoint2.dx.toStringAsFixed(1)} ${c.controlPoint2.dy.toStringAsFixed(1)}, ');
          sb.write(
              '${c.endPoint.dx.toStringAsFixed(1)} ${c.endPoint.dy.toStringAsFixed(1)} ');
        }
        sb.writeln('" />');
      }
    }

    sb.writeln('</svg>');
    return sb.toString();
  }

  /// Exports signature as high-DPI raster PNG bytes.
  /// If [trim] is true, tightly crops whitespace around the signature.
  Future<Uint8List?> toPngBytes({
    double width = 400.0,
    double height = 200.0,
    double pixelRatio = 3.0,
    Color? backgroundColor,
    bool trim = false,
    double trimPadding = 12.0,
  }) async {
    final signBounds = bounds;
    double renderWidth = width;
    double renderHeight = height;
    double translateX = 0.0;
    double translateY = 0.0;

    if (trim && signBounds != null) {
      renderWidth = signBounds.width + 2 * trimPadding;
      renderHeight = signBounds.height + 2 * trimPadding;
      translateX = -signBounds.left + trimPadding;
      translateY = -signBounds.top + trimPadding;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, renderWidth * pixelRatio, renderHeight * pixelRatio),
    );

    canvas.scale(pixelRatio, pixelRatio);

    if (backgroundColor != null) {
      final bgPaint = Paint()..color = backgroundColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, renderWidth, renderHeight), bgPaint);
    }

    if (trim) {
      canvas.translate(translateX, translateY);
    }

    final allStrokes = [..._strokes];
    if (_currentStroke != null) allStrokes.add(_currentStroke!);

    final paint = Paint()
      ..color = penColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in allStrokes) {
      final curves = computeCurves(stroke);
      if (curves.isEmpty) {
        if (stroke.length == 1) {
          final dotPaint = Paint()..color = penColor;
          canvas.drawCircle(stroke.first.offset, minStrokeWidth, dotPaint);
        } else {
          final path = Path();
          path.moveTo(stroke.first.offset.dx, stroke.first.offset.dy);
          for (int i = 1; i < stroke.length; i++) {
            path.lineTo(stroke[i].offset.dx, stroke[i].offset.dy);
          }
          paint.strokeWidth = minStrokeWidth;
          canvas.drawPath(path, paint);
        }
      } else {
        for (final curve in curves) {
          final steps = max((curve.length / 2.0).ceil(), 2);
          for (int s = 0; s < steps; s++) {
            final t0 = s / steps;
            final t1 = (s + 1) / steps;
            final p0 = curve.point(t0);
            final p1 = curve.point(t1);
            final w =
                curve.startWidth + (curve.endWidth - curve.startWidth) * t0;

            paint.strokeWidth = w;
            canvas.drawLine(p0, p1, paint);
          }
        }
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (renderWidth * pixelRatio).round(),
      (renderHeight * pixelRatio).round(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}
