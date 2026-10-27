import 'dart:ui';

/// Represents a single recorded touch point with position and timestamp for velocity calculation.
class SignaturePoint {
  const SignaturePoint({
    required this.offset,
    required this.time,
    this.pressure = 1.0,
  });

  final Offset offset;
  final int time;
  final double pressure;

  double distanceTo(SignaturePoint other) {
    return (offset - other.offset).distance;
  }

  double velocityTo(SignaturePoint other) {
    final timeDiff = (time - other.time).abs();
    if (timeDiff == 0) return 0.0;
    return distanceTo(other) / timeDiff;
  }
}

/// A smooth cubic Bézier curve segment between signature points.
class CubicCurve {
  const CubicCurve({
    required this.startPoint,
    required this.controlPoint1,
    required this.controlPoint2,
    required this.endPoint,
    required this.startWidth,
    required this.endWidth,
  });

  final Offset startPoint;
  final Offset controlPoint1;
  final Offset controlPoint2;
  final Offset endPoint;
  final double startWidth;
  final double endWidth;

  /// Approximate length of the cubic curve.
  double get length {
    final chord = (endPoint - startPoint).distance;
    final net = (controlPoint1 - startPoint).distance +
        (controlPoint2 - controlPoint1).distance +
        (endPoint - controlPoint2).distance;
    return (chord + net) / 2.0;
  }

  /// Calculates a point along the cubic curve at parameter [t] in [0..1].
  Offset point(double t) {
    final u = 1.0 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    var p = startPoint * uuu;
    p += controlPoint1 * (3.0 * uu * t);
    p += controlPoint2 * (3.0 * u * tt);
    p += endPoint * ttt;
    return p;
  }
}
