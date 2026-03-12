import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_module/main.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter initialized'), findsOneWidget);
  });
}
