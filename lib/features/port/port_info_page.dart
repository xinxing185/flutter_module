import 'package:flutter/material.dart';

import '../../app/app_router.dart';
import '../../bridge/native_bridge.dart';
import '../../core/app_navigator.dart';

class PortInfoPage extends StatefulWidget {
  const PortInfoPage({super.key, required this.source});

  final String source;

  @override
  State<PortInfoPage> createState() => _PortInfoPageState();
}

class _PortInfoPageState extends State<PortInfoPage> {
  Future<void> _handleBackPressed() async {
    await AppNavigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    NativeBridge.sendRouteReady(AppRoutes.portInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _handleBackPressed,
        ),
        title: const Text('Flutter Boost Module'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Source: ${widget.source}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AppNavigator.push(
                  AppRoutes.portSettings,
                  arguments: <String, dynamic>{'enableNotification': true},
                );
              },
              child: const Text('Open Port Settings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                AppNavigator.push(AppRoutes.unknown);
              },
              child: const Text('Open Unknown Flutter Page'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await NativeBridge.sendRouteReady(AppRoutes.portInfo);
              },
              child: const Text('Call Native MethodChannel'),
            ),
          ],
        ),
      ),
    );
  }
}
