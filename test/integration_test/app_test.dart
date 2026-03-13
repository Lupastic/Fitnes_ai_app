import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:finallapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full App Smoke Test', (WidgetTester tester) async {
    app.main(); // Launch your app
    await tester.pumpAndSettle(); // Wait for animations and data

    // Check for login or home screen
    expect(find.textContaining('Welcome'), findsOneWidget); // Change this based on your actual UI
  });
}
