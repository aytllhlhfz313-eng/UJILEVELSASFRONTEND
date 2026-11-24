import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contre_store/app/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ContreStoreApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}