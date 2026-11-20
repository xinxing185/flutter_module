import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../bridge/network_bridge.dart';
import '../../core/app_navigator.dart';
import '../../core/device_page_params.dart';
import '../../core/device_page_scope.dart';

class DeviceApiTestPage extends StatefulWidget {
  const DeviceApiTestPage({super.key});

  @override
  State<DeviceApiTestPage> createState() => _DeviceApiTestPageState();
}

class _DeviceApiTestPageState extends State<DeviceApiTestPage> {
  final _methodController = TextEditingController(text: 'mesh.get_clients');
  DevicePageParams? _device;
  Future<String>? _response;

  @override
  void initState() {
    super.initState();
    NativeBridge.sendRouteReady(AppRoutes.deviceApiTest);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final device = DevicePageScope.maybeOf(context);
    if (identical(device, _device)) return;

    _device = device;
    final method = _methodController.text.trim();
    _response = device == null || method.isEmpty
        ? null
        : _request(device, method);
  }

  @override
  void dispose() {
    _methodController.dispose();
    super.dispose();
  }

  Future<String> _request(
    DevicePageParams device,
    String method, {
    bool manual = false,
  }) async {
    // 手动执行时保留短暂的加载反馈，便于区分本次调用与上一条结果。
    final feedback = manual
        ? Future<void>.delayed(const Duration(milliseconds: 350))
        : null;
    try {
      final result = await NetworkBridge.deviceRequest(
        device: device,
        method: method,
      );
      return const JsonEncoder.withIndent('  ').convert(result);
    } finally {
      await feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = _device;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => AppNavigator.pop(context)),
        centerTitle: true,
        title: const Text('Device API Test'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _methodController,
            enabled: device != null,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(labelText: 'Method'),
          ),
          const SizedBox(height: 12),
          if (device == null)
            const Text('Open this page with a device to run API requests.')
          else
            FutureBuilder<String>(
              key: ObjectKey(device),
              future: _response,
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState == ConnectionState.waiting;
                final error = snapshot.error;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _methodController,
                      builder: (context, input, child) {
                        final method = input.text.trim();
                        return FilledButton(
                          onPressed: loading || method.isEmpty
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    _response = _request(
                                      device,
                                      method,
                                      manual: true,
                                    );
                                  });
                                },
                          child: child,
                        );
                      },
                      child: const Text('Run'),
                    ),
                    if (loading) const LinearProgressIndicator(),
                    if (snapshot.hasData) SelectableText(snapshot.requireData),
                    if (!loading && error is PlatformException)
                      SelectableText(
                        '${error.code} (${error.details}): ${error.message}',
                      )
                    else if (!loading && error != null)
                      SelectableText(error.toString()),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
