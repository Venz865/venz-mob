// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:vsoles/main.dart';

void main() {
  testWidgets('VSoles app opens on the login page and allows guest browsing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const VSolesApp());

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();
    expect(find.text('Find your next pair.'), findsOneWidget);
    expect(find.text('V SOLES'), findsOneWidget);
  });

  testWidgets('login form validates and switches to account creation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VSolesApp());

    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Use at least 6 characters'), findsOneWidget);

    await tester.tap(find.text('Create account').first);
    await tester.pumpAndSettle();
    expect(find.text('Full name'), findsOneWidget);
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.text('Enter your name'), findsOneWidget);
  });

  testWidgets('customer can search, add a selected size, and place an order', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VSolesApp());
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Kobe 5 X-ray'), findsOneWidget);
    expect(find.text('Kobe 8 What the'), findsOneWidget);
    expect(find.text('₱2,000'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField).first, 'Kobe 5');
    await tester.pumpAndSettle();
    expect(find.text('Kobe 5 X-ray'), findsOneWidget);
    expect(find.text('₱2,000'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kobe 5 X-ray'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('9').last);
    await tester.tap(find.textContaining('Add to bag'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Bag'));
    await tester.pumpAndSettle();
    expect(find.text('US size 9'), findsOneWidget);
    await tester.tap(find.text('Continue to checkout'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Place order'));
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a delivery address'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '12 Market Street');
    await tester.ensureVisible(find.text('Place order'));
    await tester.tap(find.text('Place order'));
    await tester.pumpAndSettle();
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.textContaining('12 Market Street'), findsOneWidget);
  });

  testWidgets('tapping a product card opens its details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(412, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const VSolesApp());
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Save pair').first);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unsave pair'), findsOneWidget);
    expect(find.text('Choose your size (US)'), findsNothing);

    await tester.tap(find.text('Kobe 5 X-ray'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your size (US)'), findsOneWidget);
  });
}
