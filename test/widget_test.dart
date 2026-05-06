import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aafiyah/app.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AafiyahApp());

    // Verify that Splash screen is shown.
    expect(find.text('Aafiyah'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
