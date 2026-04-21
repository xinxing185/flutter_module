import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../core/app_navigator.dart';

class PortSettingsPage extends StatefulWidget {
  const PortSettingsPage({super.key, required this.enableNotification});

  final bool enableNotification;

  @override
  State<PortSettingsPage> createState() => _PortSettingsPageState();
}

class _PortSettingsPageState extends State<PortSettingsPage> {
  late bool _enableNotification;

  Future<void> _handleBackPressed() async {
    await AppNavigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _enableNotification = widget.enableNotification;
    NativeBridge.sendRouteReady(AppRoutes.portSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _handleBackPressed,
        ),
        title: const Text('Port Settings'),
      ),
      body: SwitchListTile(
        title: const Text('Enable Notification'),
        value: _enableNotification,
        onChanged: (value) {
          setState(() {
            _enableNotification = value;
          });
        },
      ),
    );
  }
}
