// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dawafind/app.dart';
import 'package:dawafind/features/drug_not_found/presentation/screens/drug_not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app builds smoke test', (WidgetTester tester) async {
    // The splash screen reads SharedPreferences before its 2s navigation
    // delay; without a mock backend that read never resolves and the
    // pending Timer trips the "still pending after dispose" test failure.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const DawaFindApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
