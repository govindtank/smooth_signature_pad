import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('SmoothSignaturePadDemoApp smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmoothSignaturePadDemoApp());
    expect(find.text('smooth_signature_pad'), findsOneWidget);
    expect(find.text('v1.0.0'), findsOneWidget);
  });
}
