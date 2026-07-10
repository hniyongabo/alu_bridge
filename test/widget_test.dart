import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alu_bridge/features/splash/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );

    expect(find.text('ALU Bridge'), findsOneWidget);
  });
}
