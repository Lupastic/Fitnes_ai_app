import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/home_page.dart';
import '../../screens/home_page.dart'; // ✅ relative import

void main() {
  testWidgets('HomePage shows Water widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp( // ❌ no const here
        home: HomePage(active: true), // ✅ fixed constructor
      ),
    );

    expect(find.textContaining('Water'), findsOneWidget);
  });
}
