import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/app_localization.dart';
import 'package:ease/main.dart';
import 'package:ease/src/bloc/network_error.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:safe_device/safe_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class UserProfileRepository {
  Future<dynamic> validateToken();
  Future<dynamic> refreshToken();
  Future<Agent> fetchUserProfile();
  Future<Agent?> fetchUserProfileAPI();
  void saveToken(String token, String refreshToken);
  void saveUserProfile(Agent agent);
  void removeUserProfile();
}

class AuthenticationRepository implements UserProfileRepository {
  static final AuthenticationRepository _instance =
      AuthenticationRepository.internal();
  AuthenticationRepository.internal();
  factory AuthenticationRepository() => _instance;

  @override
  Future<dynamic> validateToken() async {
    bool isJailBroken = false;
    dynamic result;

    isJailBroken = await SafeDevice.isJailBroken;

    if (isJailBroken) {
      result = {
        "isTokenValid": false,
        "message": "Jailbreak has been detected"
      };
    } else {
      var pref = await SharedPreferences.getInstance();
      String? token = pref.getString(spkToken);
      if (token != null) {
        try {
          ConnectivityResult conn = await (Connectivity().checkConnectivity());
          if (conn != ConnectivityResult.none) {
            await ServicingAPI().validateToken().then((res) async {
              if (res["Message"] == "Valid Token") {
                result = {"isTokenValid": true, "message": res["Message"]};
              } else {
                removeUserProfile();
                result = {"isTokenValid": false, "message": res["Message"]};
              }
            }).catchError((error) {
              result = {"isTokenValid": false, "message": error};
            });
          } else {
            // removeUserProfile();
            result = {
              "isTokenValid": true,
              "message":
                  "Connection Error: Please check your internet connection"
            };
          }
        } on NetworkError catch (e) {
          result = {"isTokenValid": false, "message": e};
        }
      } else {
        result = {"isTokenValid": false, "message": "No token found"};
      }
    }
    return result;
  }

  @override
  Future<dynamic> refreshToken() async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);
    String? refreshToken = pref.getString(spkRefreshToken);
    dynamic result;

    await ServicingAPI().refreshToken(token, refreshToken).then((data) async {
      if (data != null) {
        if (data["IsSuccess"]) {
          await pref.setString(spkToken, data["Token"]);
          await pref.setString(spkRefreshToken, data["RefreshToken"]);
          result = {
            "IsSuccess": data["IsSuccess"],
            "message": "Token refreshed"
          };
        } else {
          result = {"IsSuccess": data["IsSuccess"], "message": data["Message"]};
          removeUserProfile();
        }
      } else {
        result = {"IsSuccess": false, "message": "No response from server"};
        removeUserProfile();
      }
    });
    return result;
  }

  @override
  Future<Agent> fetchUserProfile() async {
    var pref = await SharedPreferences.getInstance();
    try {
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));
      return agent;
    } catch (e) {
      removeUserProfile();
      rethrow;
    }
  }

  @override
  Future<Agent?> fetchUserProfileAPI() async {
    var pref = await SharedPreferences.getInstance();
    try {
      Agent? agent;
      await ServicingAPI()
          .getAgentDetails(pref.getString(spkToken))
          .then((res) {
        if (res != null) {
          agent = Agent.fromJson(res["agentDetail"]);
        }
      });
      return agent;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void saveToken(String token, String refreshToken) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString(spkToken, token);
    await pref.setString(spkRefreshToken, refreshToken);
  }

  @override
  void saveUserProfile(Agent agent) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setString(spkAgent, json.encode(agent));

    String entity = "";
    if (agent.accountCode![2] == "I") {
      entity = "ELIB";
    } else if (agent.accountCode![2] == "T") {
      entity = "EFTB";
    }
    await pref.setString(spkEntity, entity);
    AppLocalizations.of(navigatorKey.currentContext!)!.updateEntity();
  }

  @override
  void removeUserProfile() async {
    var pref = await SharedPreferences.getInstance();
    await pref.remove(spkToken);
    await pref.remove(spkRefreshToken);
    await pref.remove(spkAgent);
    await pref.remove("resourcesdownloadedafterlogin");
    await pref.remove("vpmscheckafterlogin");
  }
}
