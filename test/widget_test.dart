import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aafiyah/core/state/app_state.dart';
import 'package:aafiyah/features/auth/auth_state.dart';
import 'package:aafiyah/features/splash/presentation/pages/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => AuthState()),
        ],
        child: MaterialApp(
          home: const SplashScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Target Screen')),
          ),
        ),
      ),
    );

    // Verify that Splash screen is shown.
    expect(find.text('AAFIYAH'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Pump 3 seconds so _navigateToNext completes and transitions to Target Screen
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify transition succeeded
    expect(find.text('Target Screen'), findsOneWidget);
  });
}
