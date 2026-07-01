import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:training_scheduler_cli/main.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const TrainingSchedulerApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}