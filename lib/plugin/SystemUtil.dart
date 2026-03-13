import 'package:flutter/services.dart';

class SystemUtils {
  static MethodChannel get commonMethodChannel => MethodChannel('cudy.test');

  static Future<String> getTestData() async {
    return await commonMethodChannel.invokeMethod("get",
        // {"style": isBlack ? "1" : "0"}
    );
  }
}