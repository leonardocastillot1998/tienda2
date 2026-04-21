import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tienda/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders prestige login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // Inicia el frame
    await tester.pump(const Duration(milliseconds: 100)); // Espera un poco para Futures

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
