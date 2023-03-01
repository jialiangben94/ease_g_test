import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/service/dio_util.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/setting/servicing_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/string_util.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/setting/setting_bloc.dart'; */

abstract class NewBusinessServiceRepo {
  Future<dynamic> getConfig(String paramName);
  Future<dynamic> searchLead(String searchKeyword);
  Future<dynamic> getExistingCoverage(String clientId);
  Future<dynamic> remote(Map object);
  Future<dynamic> submitApp(Map object);
  Future<dynamic> getApplicationStatus(List<String?> proposalNos);
  Future<dynamic> masterData(Map object);
  Future<dynamic> payment(Map object);
  Future<dynamic> quotation(Map object);
  Future<dynamic> validation(Map object, {String setID});
}

class NewBusinessAPI implements NewBusinessServiceRepo {
  static final NewBusinessAPI _instance = NewBusinessAPI.internal();
  NewBusinessAPI.internal();
  factory NewBusinessAPI() => _instance;
  bool haveConn = false;

  @override
  Future<dynamic> getConfig(String paramName) async {
    var obj = {
      "url": apiNBGetConfig,
      "data": {"ParamName": paramName}
    };

    try {
      Map? resultMap;
      await httpGet(obj).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> searchLead(String? searchKeyword,
      {String? policyType}) async {
    var pref = await SharedPreferences.getInstance();
    Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    var obj = {
      "url": apiNBSearchLeadFFF,
      "data": {
        "searchContent": searchKeyword,
        "PolicyType": policyType,
        "agentCode": agent.accountCode
      }
    };

    try {
      Map? resultMap;
      await httpGet(obj).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> getExistingCoverage(String clientId) async {
    var obj = {
      "url": apiNBSearchLeadFFF,
      "data": {"searchContent": apiNBGetExistingCoverage, "cltId": clientId}
    };

    try {
      Map? resultMap;
      await httpGet(obj).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> remote(Map object) async {
    var obj = {};
    if (object["Method"] == "GET") {
      obj.addAll({"url": apiNBRemoteSubmission, "data": object["Param"]});
    } else {
      obj.addAll({"url": apiNBRemoteSubmission, "data": object["Body"]});
    }

    try {
      Map? data;
      if (object["Method"] == "GET") {
        data = await (httpGet(obj));
      } else if (object["Method"] == "POST") {
        data = await (httpPost(obj));
      } else if (object["Method"] == "PUT") {
        data = await (httpPut(obj));
      }
      data = checkRequiredData(data);
      return data;
    } catch (e) {
      if (e is AppCustomException) {
        log('the error master data ${e.message}');
      }
      // handleThrowError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> submitApp(Map object) async {
    object = {}
      ..addAll(object)
      ..addAll({"AppId": "my.com.etiqa.ease"});
    var obj = {"url": apiNBSubmitApplication, "data": object};

    try {
      Map? data = await (httpPost(obj));
      log("submit 1 ${jsonEncode(data)}");
      data = checkRequiredData(data);
      log("submit 2 ${jsonEncode(data)}");
      if (data!["Code"] != null) {
        return {"status": true, "data": data};
      } else {
        throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundServer);
      }
    } catch (e) {
      handleThrowError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> getApplicationStatus(List<String?> proposalNos) async {
    String encryptedData = await encryptAES(jsonEncode(proposalNos));
    var obj = {
      "url": apiNBGetApplicationStatus,
      "data": {"proposals": encryptedData}
    };

    try {
      Map? data = await (httpGet(obj));
      data = checkRequiredData(data);

      return data;
    } catch (e) {
      handleThrowError(e);
    }
  }

  @override
  Future<dynamic> masterData(Map object) async {
    var obj = {};
    if (object["Method"] == "GET") {
      obj.addAll({"url": apiNBMasterData, "data": object["Param"]});
      // obj.addAll({"url": apiNBMasterData, "data": object["Param"]});
    } else {
      obj.addAll(
          {"url": paramToURL(apiNBMasterData, object), "data": object["Body"]});
    }

    try {
      Map? data;
      if (object["Method"] == "GET") {
        data = await (httpGet(obj));
      } else {
        data = await (httpPost(obj));
      }
      data = checkRequiredData(data);
      return data;
    } catch (e) {
      if (e is AppCustomException) {
        log('the error master data ${e.message}');
      }
      // handleThrowError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> payment(Map object) async {
    var obj = {};
    if (object["Method"] == "GET") {
      obj.addAll({"url": apiNBOutboundPayment, "data": object["Param"]});
    } else {
      obj.addAll({
        "url": paramToURL(apiNBOutboundPayment, object),
        "data": object["Body"]
      });
    }

    try {
      Map? data;
      if (object["Method"] == "GET") {
        data = await (httpGet(obj));
      } else {
        data = await (httpPost(obj));
      }
      data = checkRequiredData(data);
      return data;
    } catch (e) {
      handleThrowError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> quotation(Map object) async {
    var obj = {};
    if (object["Method"] == "GET") {
      obj.addAll({"url": apiNBQuotation, "data": object["Param"]});
    } else {
      obj.addAll(
          {"url": paramToURL(apiNBQuotation, object), "data": object["Body"]});
    }

    try {
      Map? data;
      if (object["Method"] == "GET") {
        data = await (httpGet(obj));
      } else {
        data = await (httpPost(obj));
      }
      log("quotation ${json.encode(data)}");
      data = checkRequiredData(data);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> validation(Map object, {String? setID}) async {
    String url = apiNBValidation;
    var obj = {};
    if (object["Method"] == "GET") {
      if (object["Param"]["ProdCode"] != null) url = apiNBVPMS;
      obj.addAll({"url": url, "data": object["Param"]});
    } else {
      obj.addAll(
          {"url": paramToURL(apiNBValidation, object), "data": object["Body"]});
    }

    try {
      Map? data;
      if (object["Method"] == "GET") {
        data = await (httpGet(obj));
      } else {
        data = await (httpPost(obj));
      }
      data = checkRequiredData(data);
      if (data != null && setID != null) {
        data["SetID"] = setID;
      }
      log("validation ${jsonEncode(data)}");
      return data;
    } catch (e) {
      handleThrowError(e);
      rethrow;
    }
  }
}

Future<String> parseDecode(String encodeJson) async {
  String encryptedData = await encryptAES(encodeJson);
  return encryptedData;
}

Future<String> encrypt2(String encodeJson) async {
  return compute(parseDecode, encodeJson);
}

String paramToURL(String url, obj) {
  var queryParameters = {};
  Map m = obj["Param"];
  m.forEach((key, value) {
    var kkey = key.toString();
    var vvalue = value.toString();
    queryParameters.putIfAbsent(kkey, () => vvalue);
  });

  Map<String, String> query = Map<String, String>.from(queryParameters);

  String queryString = Uri(queryParameters: query).query;
  return '$url?$queryString';
}

Map? checkRequiredData(data) {
  if (data == null || data["data"] == null || data["status"] != true) {
    throw throwErrorFormat(false, AppErrorCode.requiredDataNotFoundServer);
  }

  data = data["data"];
  if (data["IsSuccess"] != true) {
    throw throwErrorFormat(false, AppErrorCode.isSuccessFalse, data["Message"]);
  }
  return data;
}
