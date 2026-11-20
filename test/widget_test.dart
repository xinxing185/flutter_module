import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/bridge/network_bridge.dart';
import 'package:flutter_module/core/device_page_params.dart';
import 'package:flutter_module/core/device_page_scope.dart';
import 'package:flutter_module/features/demo/device_api_test_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_module/features/demo/flutter_demo_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'cloud calls carry the device snapshot or account path respectively',
    () async {
      const channel = MethodChannel('cudy.network');
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return '[1]';
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final fields = {
        'device_mode': 1,
        'device_model': 'test',
        'device_cloud_id': 'cloud',
        'device_msg_though_by_sys': true,
      };
      final device = DevicePageParams.fromRouteArguments({'device': fields})!;
      expect(
        await NetworkBridge.deviceRequest(
          device: device,
          method: 'system.info',
        ),
        [1],
      );
      expect(calls.first.arguments, {
        'device': fields,
        'method': 'system.info',
      });
      expect(await NetworkBridge.cloudRequest(path: 'device/list', body: {}), [
        1,
      ]);
      expect(calls.last.method, 'cloudRequest');
      expect(calls.last.arguments, {'path': 'device/list', 'body': {}});
    },
  );
  testWidgets('Device API page runs the entered method without params', (
    tester,
  ) async {
    const channel = MethodChannel('cudy.network');
    final arguments = <Map<Object?, Object?>>[];
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      arguments.add(call.arguments as Map<Object?, Object?>);
      return '${arguments.length}';
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: DevicePageScope(
          device: DevicePageParams.fromRouteArguments({
            'device': {'device_id': 'test', 'device_mode': 0},
          })!,
          child: const DeviceApiTestPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(arguments.single['method'], 'mesh.get_clients');
    final methodField = find.byType(TextField);
    final runButton = find.widgetWithText(FilledButton, 'Run');
    await tester.enterText(methodField, '  ');
    await tester.pump();
    expect(tester.widget<FilledButton>(runButton).onPressed, isNull);
    await tester.enterText(methodField, '  system.info  ');
    await tester.pump();
    expect(arguments, hasLength(1));
    for (var previous = 1; previous <= 2; previous++) {
      await tester.tap(runButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('$previous'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('${previous + 1}'), findsOneWidget);
      expect(arguments.last['method'], 'system.info');
      expect(arguments.last, isNot(contains('params')));
    }
  });
  testWidgets('Flutter demo page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FlutterDemoPage(source: 'native')),
    );

    expect(find.text('Flutter Demo'), findsOneWidget);
    expect(find.text('Source: native'), findsOneWidget);
    expect(find.text('Open Unknown Flutter Page'), findsOneWidget);
  });
}
