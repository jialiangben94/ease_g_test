import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/dio_error_handler.dart';
import 'package:ease/src/util/string_util.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebasePerformance performance = FirebasePerformance.instance;

Future<dynamic> httpGet(Map obj,
    {Options? ops,
    token,
    bool decrypt = true,
    bool requireToken = true}) async {
  var pref = await SharedPreferences.getInstance();
  token ??= pref.getString(spkToken);
  // log("token >> $token");

  if (requireToken && token == null) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }
  if (obj["url"] is! String) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }
  if (obj["data"] == null || obj["data"] is! Map) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }

  Dio dio = Dio();
  var queryParameters = {};

  Map m = obj["data"];
  m.forEach((key, value) {
    var kkey = key.toString();
    var vvalue = value.toString();
    queryParameters.putIfAbsent(kkey, () => vvalue);
  });

  Map<String, String> qquery = Map<String, String>.from(queryParameters);

  String queryString = Uri(queryParameters: qquery).query;
  String requestUrl = obj["url"];
  if (queryString != "") {
    requestUrl = obj["url"] + '?' + queryString;
  }
  var options = defaultOptions(ops: ops);

  if (options.headers![apiHeaderAuth] == "") {
    options.headers![apiHeaderAuth] = "Bearer $token";
  }

  if (options.headers![apiHeaderLang] == "") {
    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');
    if (lang == 'ms') {
      options.headers![apiHeaderLang] = "ms, MY";
    } else {
      options.headers![apiHeaderLang] = "en, GB";
    }
  }

  try {
    HttpMetric metric = performance.newHttpMetric(requestUrl, HttpMethod.Get);
    await metric.start();
    metric.requestPayloadSize = 0;

    // log("Request >> $requestUrl");
    log("$requestUrl start >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");
    Response res = await dio.get(requestUrl, options: options);
    log("$requestUrl stop >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");

    metric.responseContentType = res.headers['content-type']!.join(",");
    metric.httpResponseCode = res.statusCode;
    metric.responsePayloadSize = utf8.encode(res.data.toString()).length;
    await metric.stop();

    if (res.data == null) {
      throw throwErrorFormat(false, AppErrorCode.resDataNull);
    }
    if (res.data is Map) {
      // log("resultString >> ${res.data}");
      return {"status": true, "data": res.data};
    } else if (!decrypt) {
      // log("resultString >> ${res.data}");
      return {"status": true, "data": jsonDecode(res.data)};
    }

    // log("resultString >> ${res.data}");
    String resultString = await decryptAES(res.data);
    if (resultString == "") {
      throw throwErrorFormat(false, AppErrorCode.decryptFailed);
    }

    // log("resultString >> $resultString");

    Map? resultMap = jsonDecode(resultString);
    return {"status": true, "data": resultMap};
  } on DioError catch (e) {
    throw (await errorHandler(e));
  } catch (e) {
    handleThrowError(e);
  }
}

Future<dynamic> httpPost(Map obj,
    {Options? ops, bool encrypt = true, bool requireToken = true}) async {
  var pref = await SharedPreferences.getInstance();
  String? token = pref.getString(spkToken);
  if (requireToken) {
    if (token == null) {
      throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
    }
  }
  if (obj["url"] is! String) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }
  if (encrypt && (obj["data"] == null || obj["data"] is! Map)) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }

  String encodeJson;
  if (obj["data"] is Map) {
    encodeJson = jsonEncode(obj["data"]);
  } else {
    encodeJson = obj["data"];
  }

  log("data >> $encodeJson");

  String encryptedData;
  if (!encrypt) {
    encryptedData = encodeJson;
  } else {
    encryptedData = await encryptAES(encodeJson);
  }

  var options = defaultOptions(ops: ops);

  if (requireToken && options.headers![apiHeaderAuth] == "") {
    options.headers![apiHeaderAuth] = "Bearer $token";
  }

  options.headers![apiHeaderHash] = encryptHash256(encodeJson + secretKey);

  if (options.headers![apiHeaderLang] == "") {
    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');
    if (lang == 'ms') {
      options.headers![apiHeaderLang] = "ms, MY";
    } else {
      options.headers![apiHeaderLang] = "en, GB";
    }
  }

  Dio dio = Dio();
  // throw throwErrorFormat(false, AppErrorCode.resDataNull);

  try {
    HttpMetric metric = performance.newHttpMetric(obj["url"], HttpMethod.Post);
    await metric.start();
    metric.requestPayloadSize = utf8.encode(encryptedData).length;

    log("${obj["url"]} start >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");
    Response res =
        await dio.post(obj["url"], data: encryptedData, options: options);
    log("${obj["url"]} stop >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");

    metric.responseContentType = res.headers['content-type']!.join(",");
    metric.httpResponseCode = res.statusCode;
    metric.responsePayloadSize = utf8.encode(res.data.toString()).length;
    await metric.stop();

    if (res.data == null) {
      throw throwErrorFormat(false, AppErrorCode.resDataNull);
    }
    if (res.data is Map) {
      return {"status": true, "data": res.data};
    }

    // log("result >> ${res.data}");
    String resultString = await decryptAES(res.data);

    log("resultString >> $resultString");

    if (resultString == "") {
      throw throwErrorFormat(false, AppErrorCode.decryptFailed);
    }
    Map? resultMap;
    try {
      resultMap = jsonDecode(resultString);
    } catch (e) {
      rethrow;
      // resultMap = resultString;
    }

    return {"status": true, "data": resultMap};
  } on DioError catch (e) {
    throw (await errorHandler(e));
  } catch (e) {
    handleThrowError(e);
    rethrow;
  }
}

Future<dynamic> httpPut(Map obj, {Options? ops, bool? encrypt}) async {
  var pref = await SharedPreferences.getInstance();
  String? token = pref.getString(spkToken);

  if (token == null) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }
  if (obj["url"] is! String) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }
  if (obj["data"] == null || obj["data"] is! Map) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundApp);
  }

  String encodeJson = jsonEncode(obj["data"]);

  String encryptedData;
  if (encrypt != null && !encrypt) {
    encryptedData = encodeJson;
  } else {
    encryptedData = await encryptAES(encodeJson);
  }

  var options = defaultOptions(ops: ops);

  if (options.headers![apiHeaderAuth] == "") {
    options.headers![apiHeaderAuth] = "Bearer $token";
  }

  options.headers![apiHeaderHash] = encryptHash256(encodeJson + secretKey);

  if (options.headers![apiHeaderLang] == "") {
    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');
    if (lang == 'ms') {
      options.headers![apiHeaderLang] = "ms, MY";
    } else {
      options.headers![apiHeaderLang] = "en, GB";
    }
  }

  Dio dio = Dio();
  // throw throwErrorFormat(false, AppErrorCode.resDataNull);

  try {
    HttpMetric metric = performance.newHttpMetric(obj["url"], HttpMethod.Put);
    await metric.start();
    metric.requestPayloadSize = utf8.encode(encryptedData).length;

    log("${obj["url"]} start >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");
    Response res =
        await dio.put(obj["url"], data: encryptedData, options: options);
    log("${obj["url"]} stop >> ${DateFormat("HH:mm:ss").format(DateTime.now())}");

    metric.responseContentType = res.headers['content-type']!.join(",");
    metric.httpResponseCode = res.statusCode;
    metric.responsePayloadSize = utf8.encode(res.data.toString()).length;
    await metric.stop();

    if (res.data == null) {
      throw throwErrorFormat(false, AppErrorCode.resDataNull);
    }
    if (res.data is Map) {
      return {"status": true, "data": res.data};
    }

    String resultString = await decryptAES(res.data);
    // log("resultString >> $resultString");

    if (resultString == "") {
      throw throwErrorFormat(false, AppErrorCode.decryptFailed);
    }
    Map? resultMap;
    try {
      resultMap = jsonDecode(resultString);
    } catch (e) {
      rethrow;
      // resultMap = resultString;
    }

    return {"status": true, "data": resultMap};
  } on DioError catch (e) {
    throw (await errorHandler(e));
  } catch (e) {
    handleThrowError(e);
    rethrow;
  }
}

Options defaultOptions({Options? ops}) {
  Options options = ops ?? Options();
  options.followRedirects ??= false;
  options.receiveTimeout ??= 300000;
  options.sendTimeout ??= 10000;
  options.validateStatus ??= (status) {
    return status! < 500;
  };
  if (ops != null && ops.headers != null && ops.headers is Map) {
    options.headers = {}
      ..addAll(apiHeader)
      ..addAll(ops.headers!);
  } else {
    options.headers = {}..addAll(apiHeader);
  }

  return options;
}
