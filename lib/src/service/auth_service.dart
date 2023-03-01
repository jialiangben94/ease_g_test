import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ease/src/service/dio_util.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/setting/servicing_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/network_util.dart';
import 'package:ease/src/util/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthService {
  Future<dynamic> validateToken();
  Future<dynamic> refreshToken(String token, String refreshToken);
  Future<dynamic> agentAuthentication(String username, String password);
  Future<dynamic> accessControl(String agentCode);
  Future<dynamic> changePassword(
      String username, String password, String newPassword);
  Future<dynamic> resetPassword(String username, String email);
  Future<dynamic> getAgentDetails(String token);
  Future<dynamic> logout();
  Future<dynamic> uploadPhoto(String base64);
  Future<dynamic> updateMobilePhone(String? username, String phoneNum);
  Future<dynamic> updateHomeAddress(String? username, String addressOne,
      String addressTwo, String addressThree);
  Future<dynamic> submitFeedback(String message);
}

class ServicingAPI implements AuthService {
  static final ServicingAPI _instance = ServicingAPI.internal();
  ServicingAPI.internal();
  factory ServicingAPI() => _instance;
  bool haveConn = false;

  Future<String?> encryptAES2(Map<String, Object?> body) async {
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(jsonEncode(body) + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    var obj = {"url": adhConvert, "data": body};

    try {
      String? resultMap;
      await httpPost(obj,
              ops: Options(headers: authenticateHeaderString),
              encrypt: false,
              requireToken: false)
          .then((res) {
        resultMap = jsonEncode(res["data"]);
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> validateToken() async {
    var obj = {"url": adhValidate, "data": {}};

    try {
      Map? resultMap;
      await httpGet(obj, decrypt: false).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> refreshToken(String? token, String? refreshToken) async {
    Map bodyString = {"AccessToken": token, "RefreshToken": refreshToken};

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(apiHeaderHash,
        (value) => encryptHash256(jsonEncode(bodyString) + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    var obj = {"url": adhTokenRenewal, "data": bodyString};

    try {
      Map? resultMap;
      await httpPost(obj,
              ops: Options(headers: authenticateHeaderString),
              encrypt: false,
              requireToken: false)
          .then((res) {
        if (res["status"]) {
          resultMap = {
            "IsSuccess": res["status"],
            "Token": res["data"]["Token"],
            "RefreshToken": res["data"]["RefreshToken"]
          };
        } else {
          resultMap = {
            "IsSuccess": res["status"],
            "Message": "Refresh token failed : ${res["data"]["Message"]}"
          };
        }
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> agentAuthentication(
      String? username, String? password) async {
    String uuid = await getDeviceUUiD();

    var bodyString = {
      "AccountCode": username,
      "Password": password,
      "AppCode": "EASE",
      "BusinessEntityID": 100,
      "UUiD": uuid
    };
    String? encryptedBodyString = await encryptAES2(bodyString);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(apiHeaderHash,
        (value) => encryptHash256(jsonEncode(bodyString) + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    var obj = {
      "url": nbLogin,
      "data": {"authRequest": encryptedBodyString}
    };

    try {
      Map? resultMap;
      await httpGet(obj,
              ops: Options(headers: authenticateHeaderString),
              requireToken: false)
          .then((res) {
        resultMap = res["data"];
        if (resultMap!["IsSuccess"]) {
          var message = jsonDecode(resultMap!["Message"]);
          if (message["Token"] != null && message["RefreshToken"] != null) {
            // if (resultMap!["BizSrc"] != "TA") {
            //   resultMap!["Message"] = message["Message"];
            //   resultMap!["IsSuccess"] = false;
            // } else {
            saveToFlutterSecureStorage(fssLoginDetail, jsonEncode(bodyString));
            resultMap!["Token"] = message["Token"];
            resultMap!["RefreshToken"] = message["RefreshToken"];
            // }
          } else {
            resultMap!["Message"] = message["Message"];
            resultMap!["IsSuccess"] = false;
          }
        }
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> accessControl(String accountCode) async {
    var obj = {
      "url": apiNBAccessControl,
      "data": {"AgentCode": accountCode}
    };
    try {
      return await (httpGet(obj));
    } catch (e) {
      handleThrowError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> changePassword(
      String? username, String password, String newPassword) async {
    Map<String, Object?> bodyString = {
      "AccountCode": username,
      "Password": password,
      "AppCode": "EASE",
      "BusinessEntityID": 100,
      "NewPassword": newPassword
    };
    String? encryptedBodyString = await encryptAES2(bodyString);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(apiHeaderHash,
        (value) => encryptHash256(jsonEncode(bodyString) + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    return NetworkUtil()
        .post(adhChangePassword,
            headers: authenticateHeaderString, body: encryptedBodyString)
        .then((res) async {
      if (res != null) {
        if (res.statusCode == 200) {
          return json.decode(res.body);
        } else if (res.statusCode == 460) {
          return {"IsSuccess": false, "Message": "Hash invalid"};
        } else {
          return {"IsSuccess": false, "Message": "Response timeout"};
        }
      } else {
        return {
          "IsSuccess": false,
          "Message": "NULL response returned from server"
        };
      }
    }).catchError((value) {
      return {
        "IsSuccess": false,
        "Message": "Agent Change Password Failed ${value.toString()}"
      };
    });
  }

  @override
  Future<dynamic> resetPassword(String username, String email) async {
    Map<String, Object> bodyString = {
      "AccountCode": username,
      "Password": "",
      "AppCode": "EASE",
      "BusinessEntityID": 100,
      "EmailAddress": email
    };
    String? encryptedBodyString = await encryptAES2(bodyString);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(apiHeaderHash,
        (value) => encryptHash256(jsonEncode(bodyString) + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    return NetworkUtil()
        .post(adhResetPassword,
            headers: authenticateHeaderString, body: encryptedBodyString)
        .then((res) async {
      if (res != null) {
        if (res.statusCode == 200) {
          return json.decode(res.body);
        } else if (res.statusCode == 460) {
          return {"IsSuccess": false, "Message": "Hash invalid"};
        } else {
          return {"IsSuccess": false, "Message": "Response timeout"};
        }
      } else {
        return {
          "IsSuccess": false,
          "Message": "NULL response returned from server"
        };
      }
    }).catchError((value) {
      return {
        "IsSuccess": false,
        "Message": "Agent Reset Password Failed ${value.toString()}"
      };
    });
  }

  @override
  Future<dynamic> getAgentDetails(String? token) async {
    var obj = {"url": adhAccount, "data": {}};

    try {
      Map? resultMap;
      await httpGet(obj, token: token).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> logout() async {
    var obj = {"url": adhLogout, "data": {}};

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
  Future<dynamic> uploadPhoto(String base64) async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderContentType, (value) => "application/json");
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": adhUploadPhoto,
      "data": {"ProfilePhoto": base64}
    };

    try {
      Map? resultMap;
      await httpPost(obj,
              ops: Options(headers: authenticateHeaderString), encrypt: false)
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> submitFeedback(String message) async {
    var obj = {
      "url": submitFeedbackUrl,
      "data": {"Feedback": message}
    };

    try {
      Map? resultMap;
      await httpPost(obj).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> updateMobilePhone(String? username, String mobileNum) async {
    String bodyString = jsonEncode({"UserId": username, "MobileNo": mobileNum});
    String encryptedBodyString = await encryptAES(bodyString);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(bodyString + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    return NetworkUtil()
        .post(accountUpdateMobile,
            headers: authenticateHeaderString, body: encryptedBodyString)
        .then((res) async {
      if (res != null) {
        if (res.statusCode == 200) {
          String resultString = await decryptAES(res.body);
          Map? resultMap = jsonDecode(resultString);
          return resultMap;
        } else if (res.statusCode == 460) {
          return {"IsSuccess": false, "Message": "Hash invalid"};
        } else {
          return {"IsSuccess": false, "Message": "Response timeout"};
        }
      } else {
        return {
          "IsSuccess": false,
          "Message": "NULL response returned from server"
        };
      }
    }).catchError((value) {
      return {
        "IsSuccess": false,
        "Message": "Update Mobile Failed ${value.toString()}"
      };
    });
  }

  @override
  Future<dynamic> updateHomeAddress(String? username, String addressOne,
      String addressTwo, String addressThree) async {
    String bodyString = jsonEncode({
      "UserId": username,
      "Address1": addressOne,
      "Address2": addressTwo,
      "Address3": addressThree
    });
    String encryptedBodyString = await encryptAES(bodyString);

    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(bodyString + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");

    return NetworkUtil()
        .post(accountUpdateAddress,
            headers: authenticateHeaderString, body: encryptedBodyString)
        .then((res) async {
      if (res != null) {
        if (res.statusCode == 200) {
          String resultString = await decryptAES(res.body);
          Map? resultMap = jsonDecode(resultString);

          return resultMap;
        } else if (res.statusCode == 460) {
          return {"IsSuccess": false, "Message": "Hash invalid"};
        } else {
          return {"IsSuccess": false, "Message": "Response timeout"};
        }
      } else {
        return {
          "IsSuccess": false,
          "Message": "NULL response returned from server"
        };
      }
    }).catchError((value) {
      return {
        "IsSuccess": false,
        "Message": "Update Address Failed ${value.toString()}"
      };
    });
  }
}
