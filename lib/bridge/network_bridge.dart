import 'dart:convert';

import 'package:flutter/services.dart';
import '../core/device_page_params.dart';

class NetworkBridge {
  NetworkBridge._();

  static const _channel = MethodChannel('cudy.network');

  static Future<Object?> deviceRequest({
    required DevicePageParams device,
    required String method,
    List<Object?>? params,
  }) {
    return _request('deviceRequest', {
      'device': device.toMap(),
      'method': method,
      if (params != null) 'params': params,
    });
  }

  static Future<Object?> cloudRequest({required String path, Object? body}) {
    return _request('cloudRequest', {
      'path': path,
      if (body != null) 'body': body,
    });
  }

  static Future<Object?> _request(
    String method,
    Map<String, Object?> args,
  ) async {
    final json = await _channel.invokeMethod<String>(method, args);
    if (json == null) throw const FormatException('Missing network response');
    return jsonDecode(json);
  }
}
