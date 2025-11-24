// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Welcome screen shows and Client button navigates to Sign In', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NyaynetraApp());

    // Verify the app title is shown on the Welcome screen.
    expect(find.text('Nyaynetra'), findsWidgets);
    expect(find.text('Welcome to Nyaynetra'), findsOneWidget);

    // Find the Client button and tap it.
    final clientButton = find.widgetWithText(ElevatedButton, 'Client').at(0);
    final outlinedClient = find.widgetWithText(OutlinedButton, 'Client');
    // Some copies use OutlinedButton for Client — try both fallbacks.
    if (tester.any(clientButton)) {
      await tester.tap(clientButton);
    } else if (tester.any(outlinedClient)) {
      await tester.tap(outlinedClient);
    } else {
      // Fallback: find by text only
      await tester.tap(find.text('Client'));
    }

    // Wait for navigation animation to complete.
    await tester.pumpAndSettle();

    // Verify we navigated to the Sign In screen by checking for heading text.
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to your account to continue.'), findsOneWidget);
  });

  testWidgets('Sign In button navigates to Home', (WidgetTester tester) async {
    await tester.pumpWidget(const NyaynetraApp());

    // Navigate to Sign In first
    await tester.tap(find.text('Client'));
    await tester.pumpAndSettle();

    // Ensure Sign In screen visible
    expect(find.text('Welcome Back'), findsOneWidget);

    // Tap Sign In button (the ElevatedButton with text 'Sign In')
    final signInBtn = find.widgetWithText(ElevatedButton, 'Sign In');
    expect(signInBtn, findsOneWidget);

    await tester.tap(signInBtn);
    await tester.pumpAndSettle();

    // Now we should be on the Home page
    expect(find.text('Hello, User'), findsOneWidget);
    expect(find.text('Trending Topics'), findsOneWidget);
  });
}
