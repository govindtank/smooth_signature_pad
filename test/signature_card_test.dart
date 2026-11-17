import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_signature_pad/smooth_signature_pad.dart';

void main() {
  group('SignatureAuditMetadata Tests', () {
    test('computes deterministic integrity hash for stroke points', () {
      final strokes = [
        [
          const SignaturePoint(offset: Offset(10, 10), time: 100),
          const SignaturePoint(offset: Offset(20, 20), time: 110),
        ],
      ];

      final hash1 = SignatureAuditMetadata.computeStrokesHash(strokes);
      final hash2 = SignatureAuditMetadata.computeStrokesHash(strokes);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(16));
    });

    test('audit line format contains legal signer, time, and hash', () {
      final audit = SignatureAuditMetadata(
        signerName: 'Govind Tank',
        signerId: 'USER-9921',
        documentId: 'DOC-AGREEMENT-2026',
        integrityHash: 'cbf29ce484222325',
      );

      expect(audit.auditLine, contains('Signer: Govind Tank'));
      expect(audit.auditLine, contains('Hash: cbf29ce484222325'));
    });
  });

  group('SignatureCaptureCard Widget Tests', () {
    testWidgets(
        'renders capture card with header, baseline, and action buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignatureCaptureCard(
              title: 'Executive Contract Sign-off',
              signerName: 'Govind Tank',
            ),
          ),
        ),
      );

      expect(find.text('Executive Contract Sign-off'), findsOneWidget);
      expect(find.byType(SmoothSignaturePad), findsOneWidget);
      expect(find.text('Legal Blue'), findsOneWidget);
      expect(find.text('Deep Black'), findsOneWidget);
      expect(find.text('Accept & Sign'), findsOneWidget);
    });

    testWidgets('prompts user when attempting to sign without drawing strokes',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignatureCaptureCard(
              title: 'Sign Agreement',
            ),
          ),
        ),
      );

      // Tap Accept & Sign when empty
      await tester.tap(find.text('Accept & Sign'));
      await tester.pump();

      expect(find.text('Please draw your signature before submitting.'),
          findsOneWidget);
    });
  });
}
