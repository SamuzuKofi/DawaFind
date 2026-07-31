import 'package:dawafind/features/drug_not_found/presentation/screens/drug_not_found_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('drug not found screen renders its title and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DrugNotFoundScreen()));

    expect(find.text('Medicine Not Found'), findsOneWidget);
    expect(find.text('Search Alternatives'), findsOneWidget);
    expect(find.text('Go Home'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });
}
