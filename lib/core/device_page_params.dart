/// 原生通过路由传入的设备快照，字段名与 getNewIntent() 一致。
class DevicePageParams {
  DevicePageParams._(this._values);

  final Map<Object?, Object?> _values;

  Map<Object?, Object?> toMap() => _values;

  static DevicePageParams? fromRouteArguments(Object? arguments) {
    final device = arguments is Map ? arguments['device'] : null;
    return device is Map
        ? DevicePageParams._(Map<Object?, Object?>.unmodifiable(device))
        : null;
  }

  String? get deviceId => _values['device_id'] as String?;
  String? get cloudId => _values['device_cloud_id'] as String?;
  int? get cloudBindType => _values['device_cloud_bind_type'] as int?;
  String? get deviceName => _values['device_name'] as String?;
  String? get mac => _values['device_mac'] as String?;
  String? get host => _values['device_host'] as String?;
  int? get deviceMode => _values['device_mode'] as int?;
  String? get workMode => _values['device_workmode'] as String?;
  String? get model => _values['device_model'] as String?;
  String? get rom => _values['device_rom'] as String?;
  String? get hardware => _values['device_hardware'] as String?;
  String? get version => _values['device_version'] as String?;
  bool? get messageBySystem => _values['device_msg_though_by_sys'] as bool?;
  bool get isLocal => deviceMode == 0;
}
