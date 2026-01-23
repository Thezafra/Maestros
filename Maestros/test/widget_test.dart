import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestros_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Verify that our counter starts at 0.
    expect(find.text('Your Location'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
