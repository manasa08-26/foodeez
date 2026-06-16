import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodeez_flutter/app.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FoodeezApp()),
    );
    // App should render something (login screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
