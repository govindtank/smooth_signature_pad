import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_signature_pad/smooth_signature_pad.dart';

void main() {
  group('SignatureController logic', () {
    test('captures strokes and manages undo/redo stack', () {
      final controller = SignatureController();
      expect(controller.isEmpty, isTrue);

      controller.startStroke(const Offset(10, 10));
      controller.addPoint(const Offset(20, 20));
      controller.addPoint(const Offset(30, 30));
      controller.endStroke();

      expect(controller.isNotEmpty, isTrue);
      expect(controller.strokes.length, equals(1));
      expect(controller.canUndo, isTrue);

      controller.undo();
      expect(controller.strokes.length, equals(0));
      expect(controller.canRedo, isTrue);

      controller.redo();
      expect(controller.strokes.length, equals(1));

      controller.clear();
      expect(controller.isEmpty, isTrue);
    });

    test('exports valid SVG markup with viewBox and paths', () {
      final controller = SignatureController();
      controller.startStroke(const Offset(50, 50));
      controller.addPoint(const Offset(80, 90));
      controller.addPoint(const Offset(120, 110));
      controller.addPoint(const Offset(160, 130));
      controller.endStroke();

      final svg = controller.toSvg(width: 300, height: 150);
      expect(svg, contains('<svg xmlns="http://www.w3.org/2000/svg"'));
      expect(svg, contains('viewBox="0 0 300 150"'));
      expect(svg, contains('</svg>'));
    });

    test('exports PNG image bytes', () async {
      final controller = SignatureController();
      controller.startStroke(const Offset(20, 20));
      controller.addPoint(const Offset(40, 40));
      controller.addPoint(const Offset(60, 60));
      controller.endStroke();

      final pngBytes = await controller.toPngBytes(width: 100, height: 50);
      expect(pngBytes, isNotNull);
      expect(pngBytes!.isNotEmpty, isTrue);
    });
  });

  group('SmoothSignaturePad Widget Tests', () {
    testWidgets('renders pad and handles gesture drag', (tester) async {
      final controller = SignatureController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: SmoothSignaturePad(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      );

      final padFinder = find.byType(SmoothSignaturePad);
      expect(padFinder, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(padFinder));
      await gesture.moveBy(const Offset(40, 20));
      await gesture.moveBy(const Offset(40, -10));
      await gesture.up();

      expect(controller.strokes.isNotEmpty, isTrue);
    });
  });
}
