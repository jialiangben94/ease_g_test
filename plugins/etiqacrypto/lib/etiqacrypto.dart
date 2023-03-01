import 'dart:async';
import 'package:flutter/services.dart';

class Etiqacrypto {
  static const MethodChannel _channel =
      MethodChannel('com.etiqa.flutter.crypto');

  static Future<String> decryptHttpData(Map<String, dynamic> args) async {
    final String decryptedData =
        await _channel.invokeMethod('decryptHttpData', args);

    return decryptedData;
  }

  static Future<String> encryptStringAsBase64(Map<String, dynamic> args) async {
    final String encryptedData =
        await _channel.invokeMethod('encryptStringAsBase64', args);

    return encryptedData;
  }
}
