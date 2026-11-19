import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../bridge/network_bridge.dart';
import '../../core/app_navigator.dart';
import '../../core/device_page_params.dart';

class PortSettingsPage extends StatefulWidget {
  const PortSettingsPage({
    super.key,
    required this.enableNotification,
    this.device,
  });

  final bool enableNotification;
  final DevicePageParams? device;

  @override
  State<PortSettingsPage> createState() => _PortSettingsPageState();
}

class _PortSettingsPageState extends State<PortSettingsPage> {
  late bool _enableNotification;
  late Future<String>? _systemInfo;

  Future<String>? _loadSystemInfo({bool refresh = false}) {
    final device = widget.device;
    if (device == null) return null;
    final response = NetworkBridge.deviceRequest(
      device: device,
      // method: 'system.info',
      method: 'mesh.get_clients',
    ).then(const JsonEncoder.withIndent('  ').convert);
    if (!refresh) return response;
    // 本地设备可能在一帧内返回；仅手动刷新时保留短暂的可见反馈。
    return Future.wait([
      response,
      Future<void>.delayed(const Duration(milliseconds: 350)),
    ]).then((values) => values.first as String);
  }

  Future<void> _handleBackPressed() async {
    await AppNavigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _enableNotification = widget.enableNotification;
    _systemInfo = _loadSystemInfo();
    NativeBridge.sendRouteReady(AppRoutes.portSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _handleBackPressed,
        ),
        centerTitle: true,
        title: const Text('Port Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notification'),
            value: _enableNotification,
            onChanged: (value) {
              setState(() {
                _enableNotification = value;
              });
            },
          ),
          if (widget.device != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<String>(
                future: _systemInfo,
                builder: (context, snapshot) {
                  final loading =
                      snapshot.connectionState != ConnectionState.done;
                  final error = snapshot.error;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('mesh.get_clients')),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => setState(() {
                                    _systemInfo = _loadSystemInfo(
                                      refresh: true,
                                    );
                                  }),
                            child: Text(
                              snapshot.hasError ? 'Retry' : 'Refresh',
                            ),
                          ),
                        ],
                      ),
                      if (loading) const LinearProgressIndicator(),
                      if (snapshot.hasData)
                        SelectableText(snapshot.requireData),
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
            ),
        ],
      ),
    );
  }
}
