import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class NetworkUtil {
  // next three lines makes this class a Singleton
  static final NetworkUtil _instance = NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = const JsonDecoder();

  static final HttpClient httpClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
  static final IOClient ioClient = IOClient(httpClient);
  FirebasePerformance performance = FirebasePerformance.instance;

  Future<dynamic> get(String url, {Map? headers}) async {
    HttpMetric metric = performance.newHttpMetric(url, HttpMethod.Get);
    await metric.start();
    metric.requestPayloadSize = 0;

    return ioClient
        .get(Uri.parse(url), headers: headers as Map<String, String>?)
        .then((Response response) async {
      final String res = response.body;
      final int statusCode = response.statusCode;

      metric.responseContentType = response.headers['content-type'] ?? "";
      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.contentLength;
      await metric.stop();

      if (statusCode < 200 || statusCode > 400) {
        if (res.contains('<h2>') && res.contains('<//h2>')) {
          throw Exception(
              res.substring(res.indexOf('<h2>') - 1, res.indexOf('<//h2>')));
        }

        throw Exception();
      }
      return _decoder.convert(res);
    });
  }

  // Future<dynamic> get(String url) {
  //   return ioClient.get(url,).then((Response response) {
  //     final String res = response.body;
  //     final int statusCode = response.statusCode;

  //     if (statusCode < 200 || statusCode > 400 || response == null) {
  //       if (res.indexOf('<h2>') != -1 && res.indexOf('<//h2>') != -1)
  //         throw Exception(res.substring(res.indexOf('<h2>') - 1, res.indexOf('<//h2>')));
  //       else
  //         throw Exception();
  //     }
  //     return _decoder.convert(res);
  //   });
  // }

  Future<dynamic> post(String url, {Map? headers, body, encoding}) async {
    HttpMetric metric = performance.newHttpMetric(url, HttpMethod.Post);
    await metric.start();
    metric.requestPayloadSize = utf8.encode(body).length;

    return ioClient
        .post(Uri.parse(url),
            body: body,
            headers: headers as Map<String, String>?,
            encoding: encoding)
        .then((Response response) async {
      metric.responseContentType = response.headers['content-type'] ?? "";
      metric.httpResponseCode = response.statusCode;
      metric.responsePayloadSize = response.contentLength;
      await metric.stop();
      return response;
    }).timeout(const Duration(seconds: 300));
  }
}

Future<String> getDeviceUUiD() async {
  late String identifier;

  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  try {
    if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      identifier = data.identifierForVendor as String; //UUID for iOS
    }
  } on PlatformException {
    rethrow;
  }
  // remove "-"
  return identifier.replaceAll(RegExp('-'), "");
}

void saveToFlutterSecureStorage(String key, String loginDetails) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: key, value: loginDetails);
}
