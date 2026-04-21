import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_module/features/port/port_info_page.dart';

void main() {
  testWidgets('Port info page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PortInfoPage(source: 'native')),
    );

    expect(find.text('Flutter Boost Module'), findsOneWidget);
    expect(find.text('Source: native'), findsOneWidget);
    expect(find.text('Open Unknown Flutter Page'), findsOneWidget);
  });
}
