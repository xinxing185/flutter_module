import 'package:flutter/widgets.dart';

import 'device_page_params.dart';

/// 当前路由收到的设备快照。页面和子组件可按需读取。
class DevicePageScope extends InheritedWidget {
  const DevicePageScope({
    super.key,
    required this.device,
    required super.child,
  });

  final DevicePageParams device;

  static DevicePageParams? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DevicePageScope>()
        ?.device;
  }

  @override
  bool updateShouldNotify(DevicePageScope oldWidget) {
    return device != oldWidget.device;
  }
}
