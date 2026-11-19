import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/bridge/network_bridge.dart';
import 'package:flutter_module/core/device_page_params.dart';
import 'package:flutter_module/features/port/port_settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_module/features/port/port_info_page.dart';

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
  testWidgets('Fast refresh shows progress and retains the previous response', (
    tester,
  ) async {
    const channel = MethodChannel('cudy.network');
    var calls = 0;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async => '${++calls}');
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(
      MaterialApp(
        home: PortSettingsPage(
          enableNotification: false,
          device: DevicePageParams.fromRouteArguments({
            'device': {'device_id': 'test', 'device_mode': 0},
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var previous = 1; previous <= 2; previous++) {
      await tester.tap(find.text('Refresh'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('$previous'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('${previous + 1}'), findsOneWidget);
    }
  });
  testWidgets('Port info page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PortInfoPage(source: 'native')),
    );

    expect(find.text('Flutter Boost Module'), findsOneWidget);
    expect(find.text('Source: native'), findsOneWidget);
    expect(find.text('Open Unknown Flutter Page'), findsOneWidget);
  });
}
