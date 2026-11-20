import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../core/app_navigator.dart';
import '../../core/device_page_params.dart';
import '../../core/device_page_scope.dart';
import '../../l10n/generated/app_localizations.dart';

class FlutterDemoPage extends StatefulWidget {
  const FlutterDemoPage({super.key, required this.source});

  final String source;

  @override
  State<FlutterDemoPage> createState() => _FlutterDemoPageState();
}

class _FlutterDemoPageState extends State<FlutterDemoPage> {
  Future<void> _handleBackPressed() async {
    await AppNavigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    NativeBridge.sendRouteReady(AppRoutes.flutterDemo);
  }

  @override
  Widget build(BuildContext context) {
    final device = DevicePageScope.maybeOf(context);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: _handleBackPressed,
        ),
        centerTitle: true,
        title: const Text('Flutter Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source: ${widget.source}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AppNavigator.push(AppRoutes.deviceApiTest),
              child: const Text('Open Device API Test'),
            ),
            if (device != null &&
                (isAndroid || defaultTargetPlatform == TargetPlatform.iOS)) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  const modelWithVersionKey = 'device_model_with_version';
                  final deviceFields = device.toMap();
                  final model = device.model;
                  AppNavigator.openNative(
                    NativeRoutes.deviceDetail,
                    arguments: {
                      DevicePageParams.argumentKey: deviceFields,
                      if (isAndroid) ...{
                        // Android 详情页会以请求结果刷新在线接口。
                        'online_iface': const <String>['wan'],
                        'is_support_combo_call': true,
                      },
                      if (deviceFields[modelWithVersionKey] == null &&
                          model != null)
                        modelWithVersionKey: model,
                    },
                  );
                },
                child: const Text('Open Native Device Details'),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                AppNavigator.pushWithContainer(
                  AppRoutes.unknown,
                  inheritDevice: false,
                );
              },
              child: const Text('Open Unknown Flutter Page'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  AppNavigator.push(AppRoutes.feedback, inheritDevice: false),
              child: Text(
                AppLocalizations.of(context)?.feedbackTitle ??
                    'Suggestions & Feedback',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await NativeBridge.sendRouteReady(AppRoutes.flutterDemo);
              },
              child: const Text('Call Native MethodChannel'),
            ),
          ],
        ),
      ),
    );
  }
}
