import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_module/main.dart';

void main() {
  testWidgets('Flutter boost module home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter Boost Module'), findsOneWidget);
    expect(find.textContaining('Source:'), findsOneWidget);
  });
}
