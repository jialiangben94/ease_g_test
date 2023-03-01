import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/notification.dart';
import 'package:ease/src/service/dio_util.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/setting/servicing_config.dart';
import 'package:ease/src/util/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class MedicalAppointmentServiceRepo {
  Future<dynamic> retrieveAllMedicalDocument(String id);
  Future<dynamic> fetchPanelList(
      {String? panelType, String? searchKeyword, String? facilityCode});
  Future<dynamic> fetchAppointmentListByStatus(
      {String? agentCode, String? appointmentStatus});
  Future<dynamic> submitAppointment(
      {required AppointmentDetails appointmentDetails, String? facilityCode});
  Future<dynamic> editAppointment(
      {required AppointmentDetails appointmentDetails, String? facilityCode});
  Future<dynamic> rescheduleAppointment(
      {required AppointmentDetails appointmentDetails, String? facilityCode});
  Future<dynamic> cancelAppointment({AppointmentRequest? appointmentRequest});
  Future<dynamic> getNotificationList();
  Future<dynamic> updateNotification(Notifications id);
  Future<dynamic> getStatusJourney(String proposalMEId);
  Future<dynamic> pushNotificationsRegister(
      String token, String agentCode, String firebaseKey);
  Future<dynamic> emailECRM(String propNo, String proposalMEId);
}

class MedicalAppointmentAPI implements MedicalAppointmentServiceRepo {
  static final MedicalAppointmentAPI _instance =
      MedicalAppointmentAPI.internal();
  MedicalAppointmentAPI.internal();
  factory MedicalAppointmentAPI() => _instance;
  bool haveConn = false;

  @override
  Future<dynamic> retrieveAllMedicalDocument(String? proposalMEId) async {
    var obj = {"url": apiMedicalGetAllDoc + proposalMEId!, "data": {}};

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
  Future<dynamic> fetchPanelList(
      {String? panelType, String? searchKeyword, String? facilityCode}) async {
    // Tidy up searchKeyword
    String searchLocation =
        searchKeyword!.replaceAll(RegExp(r"\s+\b|\b\s"), "%20").toUpperCase();
    String panelType2 = panelType!.replaceAll(RegExp(r"\s+\b|\b\s"), "%20");

    var obj = {
      "url": apiMedicalGetPanelList,
      "data": {
        "panelType": panelType2,
        "searchLocation": searchLocation,
        "facilityCode": facilityCode
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
  Future<dynamic> fetchAppointmentListByStatus(
      {String? agentCode, String? appointmentStatus}) async {
    var obj = {
      "url": apiMedicalGetAppointmentListByStatus,
      "data": {"AgentCode": agentCode, "AppointmentStatus": appointmentStatus}
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
  Future<dynamic> submitAppointment(
      {required AppointmentDetails appointmentDetails,
      String? facilityCode}) async {
    var obj = {
      "url": apiMedicalSubmitAppointment,
      "data": appointmentDetails.toJson(facilityCode)
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
  Future<dynamic> editAppointment(
      {required AppointmentDetails appointmentDetails,
      String? facilityCode}) async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);

    String encodeJson = jsonEncode(appointmentDetails.toJson(facilityCode));
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(encodeJson + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": apiMedicalEditAppointment,
      "data": appointmentDetails.toJson(facilityCode)
    };

    try {
      Map? resultMap;
      await httpPut(obj, ops: Options(headers: authenticateHeaderString))
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> rescheduleAppointment(
      {required AppointmentDetails appointmentDetails,
      String? facilityCode}) async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);

    String encodeJson = jsonEncode(appointmentDetails.toJson(facilityCode));
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(encodeJson + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": apiMedicalRescheduleAppointment,
      "data": appointmentDetails.toJson(facilityCode)
    };

    try {
      Map? resultMap;
      await httpPut(obj, ops: Options(headers: authenticateHeaderString))
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> cancelAppointment(
      {AppointmentRequest? appointmentRequest}) async {
    var pref = await SharedPreferences.getInstance();
    Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

    // Sort appointment history
    appointmentRequest!.appointmentHistory!.sort((a, b) {
      DateTime dateA =
          DateTime.parse(a.createdDateTime!); //before -> var dateA = a.expiry;
      DateTime dateB =
          DateTime.parse(b.createdDateTime!); //var dateB = b.expiry;
      return dateB.compareTo(dateA);
    });

    AppointmentDetails appointmentDetails = AppointmentDetails(
        agentCode: agent.accountCode,
        appointmentRequest: appointmentRequest,
        appointmentCode:
            appointmentRequest.appointmentHistory![0].mcsAppointmentCode);

    var obj = {
      "url": apiMedicalCancelAppointment,
      "data": appointmentDetails.toCancelJson()
    };

    try {
      Map? resultMap;
      await httpPut(obj).then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> getNotificationList() async {
    var obj = {"url": apiMedicalGetNotificationList, "data": {}};

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
  Future<dynamic> updateNotification(Notifications notifications) async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);

    String bodyString = jsonEncode({"id": notifications.id});
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(bodyString + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": "$apiMedicalUpdateNotification?id=${notifications.id}",
      "data": {"id": notifications.id}
    };

    try {
      Map? resultMap;
      await httpPut(obj, ops: Options(headers: authenticateHeaderString))
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> getStatusJourney(String? proposalMEId) async {
    var obj = {
      "url": apiMedicalGetStatusJourney,
      "data": {"proposalMEId": proposalMEId}
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
  Future<dynamic> pushNotificationsRegister(
      String? token, String? agentCode, String? firebaseKey) async {
    String bodyString =
        jsonEncode({"UserId": agentCode, "RegistrationToken": firebaseKey});
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(bodyString + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": apiRegisterPushNotification,
      "data": {"UserId": agentCode, "RegistrationToken": firebaseKey}
    };

    try {
      Map? resultMap;
      await httpPost(obj, ops: Options(headers: authenticateHeaderString))
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> emailECRM(String? propNo, String? proposalMEId) async {
    var pref = await SharedPreferences.getInstance();
    String? token = pref.getString(spkToken);
    String bodyString =
        jsonEncode({"PropNo": propNo, "ProposalMEId": proposalMEId});
    Map<String, String> authenticateHeaderString = Map.from(apiHeader);
    authenticateHeaderString.update(
        apiHeaderHash, (value) => encryptHash256(bodyString + secretKey));
    authenticateHeaderString.update(apiHeaderLang, (value) => "en, GB");
    authenticateHeaderString.update(apiHeaderAuth, (value) => "Bearer $token");

    var obj = {
      "url": apiMedicalEmailECRM,
      "data": {"PropNo": propNo, "ProposalMEId": proposalMEId}
    };

    try {
      Map? resultMap;
      await httpPost(obj, ops: Options(headers: authenticateHeaderString))
          .then((res) {
        resultMap = res["data"];
      });
      return resultMap;
    } catch (e) {
      rethrow;
    }
  }
}
