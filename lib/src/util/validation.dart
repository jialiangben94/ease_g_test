import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> checkConnectivity() async {
  ConnectivityResult conn = await (Connectivity().checkConnectivity());
  return getHasConn(conn);
}

bool getHasConn(ConnectivityResult conn) {
  if (conn != ConnectivityResult.none) {
    return true;
  } else {
    return false;
  }
}

// For Authentication
String? validateUsername(String value) {
  if (value.isEmpty) {
    return getLocale('Please enter your username');
  } else if (value.length < 8) {
    return getLocale('Username must be at least 8 characters long');
  }
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) {
    return getLocale('Please enter your password');
  } else if (value.length < 8) {
    return getLocale('Password must be at least 8 characters long');
  }
  return null;
}

// Create New Quote
String? validateName(String value, {int? minLength}) {
  // String pattern = r"^[a-zA-Z @\'’.()&\-\/]+$";
  String pattern =
      r"^(?:(?!.*[ ]{2})(?!(?:.*[']){2})(?!(?:.*[-]){2})(?:[a-zA-Z @\'’.()&\-\/p{L}'-]*$))$";
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return getLocale("Full Name cannot be empty!");
  } else if (!regExp.hasMatch(value)) {
    return getLocale("Please enter a valid Full Name");
  } else if (minLength != null && value.length < minLength) {
    return getLocale("Full Name must contain at least 5 characters");
  }
  return null;
}

Future<bool?> loadTNC() async {
  bool? data = false;
  SharedPreferences pref = await SharedPreferences.getInstance();

  if (pref.getBool(spkTNC) != null) {
    data = pref.getBool(spkTNC);
  } else {
    data = false;
    await saveTNC(data);
  }
  return data;
}

Future<bool> saveTNC(bool data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setBool(spkTNC, data);
  return data;
}

String? validateID(key, obj, client) {
  String? errorMessage;
  var data = ApplicationFormData.data;

  if (key == "nric" || key == "mypr") {
    if (obj["value"].isEmpty) {
      if (obj["required"]) {
        errorMessage = "${obj['label']} ${getLocale("cannot be empty")}!";
      }
    } else if (obj["value"].length != 12) {
      errorMessage = "${getLocale("Please enter valid")} ${obj['label']}";
    }
  }

  if (data == null || client == null) {
    errorMessage = null;
  }

  var listOfClient = [];

  if (data["policyOwner"] != null) {
    listOfClient.add({
      "clientType": "1",
      "idtype": data["policyOwner"]["identitytype"],
      "id": data["policyOwner"][data["policyOwner"]["identitytype"]],
      "nric": data["policyOwner"]["nric"]
    });
  }

  if (data["buyingFor"] != "self" && data["lifeInsured"] != null) {
    listOfClient.add({
      "clientType": "2",
      "idtype": data["lifeInsured"]["identitytype"],
      "id": data["lifeInsured"][data["lifeInsured"]["identitytype"]],
      "nric": data["lifeInsured"]["nric"]
    });
  }

  if (data["nomination"] != null &&
      data["nomination"]["nominee"] != null &&
      data["nomination"]["nominee"] is List) {
    data["nomination"]["nominee"].forEach((nominee) {
      listOfClient.add({
        "clientType": "4",
        "idtype": nominee["identitytype"],
        "id": nominee[nominee["identitytype"]],
        "nric": nominee["nric"]
      });
    });
  }

  if (data["nomination"] != null &&
      data["nomination"]["trustee"] != null &&
      data["nomination"]["trustee"] is List) {
    data["nomination"]["trustee"].forEach((trustee) {
      listOfClient.add({
        "clientType": "6",
        "idtype": trustee["identitytype"],
        "id": trustee[trustee["identitytype"]],
        "nric": trustee["nric"]
      });
    });
  }

  if (data["payor"] != null && data["payor"]["whopaying"] == "othersrelation") {
    listOfClient.add({
      "clientType": "7",
      "idtype": data["payor"]["identitytype"],
      "id": data["payor"][data["payor"]["identitytype"]],
      "nric": data["payor"]["nric"]
    });
  }

  if (data["witness"] != null &&
      data["witness"]["witness"] == "othersrelation") {
    listOfClient.add({
      "clientType": "8",
      "idtype": data["witness"]["identitytype"],
      "id": data["witness"][data["witness"]["identitytype"]],
      "nric": data["witness"]["nric"]
    });
  }

  if (data["consentMinor"] != null &&
      data["consentMinor"] &&
      data["guardian"] != null) {
    listOfClient.add({
      "clientType": "11",
      "idtype": data["guardian"]["identitytype"],
      "id": data["guardian"][data["guardian"]["identitytype"]],
      "nric": data["guardian"]["nric"]
    });
  }

  if (data["benefitOwner"] != null &&
      data["benefitOwner"]["person"] != null &&
      data["benefitOwner"]["person"] is List) {
    data["benefitOwner"]["person"].forEach((person) {
      listOfClient.add({
        "clientType": "99",
        "idtype": person["identitytype"],
        "id": person[person["identitytype"]],
        "nric": person["nric"]
      });
    });
  }

  // For Payor, allow same IC as Nominee
  if (client == "7") {
    listOfClient = listOfClient.where((o) => o['clientType'] != '4').toList();
  }

  // For Nominee, allow same IC as Payor
  if (client == "4" ) {
    listOfClient = listOfClient.where((o) => o['clientType'] != '7').toList();
  }

  // For Witness, allow same IC as Benefit Owner
  if (client == "8" ) {
    listOfClient = listOfClient.where((o) => o['clientType'] != '99').toList();
  }

  Map<String, dynamic>? found;
  if (key == "nric") {
    if ((client == "4" || client == "6") &&
        obj["isEdit"] != null &&
        !obj["isEdit"]) {
      found = listOfClient.firstWhere(
          (element) => obj["value"] == element["nric"],
          orElse: () => null);
      if (found != null) {
        errorMessage =
            "${getLocale("Your already added this")} ${clientLabel[client]}. ${getLocale("Please use different")} ${obj['label']}";
      }
    } else {
      found = listOfClient.firstWhere(
          (element) =>
              client != element["clientType"] &&
              obj["value"] == element["nric"],
          orElse: () => null);
      if (found != null) {
        errorMessage =
            "${clientLabel[client]} ${getLocale("cannot be the same as")} ${clientLabel[found['clientType']]}";
      }
    }
  } else {
    if ((client == "4" || client == "6") &&
        obj["isEdit"] != null &&
        !obj["isEdit"]) {
      found = listOfClient.firstWhere(
          (element) =>
              key == element["idtype"] && obj["value"] == element["id"],
          orElse: () => null);
      if (found != null) {
        errorMessage =
            "${getLocale("Your already added this")} ${clientLabel[client]}. ${getLocale("Please use different")} ${obj['label']}";
      }
    } else {
      found = listOfClient.firstWhere(
          (element) =>
              client != element["clientType"] &&
              key == element["idtype"] &&
              obj["value"] == element["id"],
          orElse: () => null);
      if (found != null) {
        errorMessage =
            "${clientLabel[client]} ${getLocale("cannot be the same as")} ${clientLabel[found['clientType']]}";
      }
    }
  }
  return errorMessage;
}

dynamic validateAge(DateTime dob, String? clientType,
    {String? selectedBuyingFor}) {
  var validDOB = {"isValid": true, "message": ""};
  int age = getAge(dob);
  int dayage = getAgeInDays(dob);
  if (clientType == null) return validDOB;
  if (clientType != "1" && clientType != "2" && clientType != "4") {
    String? cclientLabel = clientLabel[clientType];
    if (age < 18) {
      validDOB["isValid"] = false;
      validDOB["message"] =
          "${getLocale("A")} $cclientLabel ${getLocale("must be at least 18 years old")}";
    } else if (age > 98) {
      validDOB["isValid"] = false;
      validDOB["message"] =
          getLocale("Maximum entry age is 99 age next birthday");
    }
  } else {
    if (clientType == "4") {
      if (age > 98) {
        validDOB["isValid"] = false;
        validDOB["message"] =
            getLocale("Maximum entry age is 99 age next birthday");
      }
    } else {
      if (age > 98) {
        validDOB["isValid"] = false;
        validDOB["message"] =
            getLocale("Maximum entry age is 99 age next birthday");
      } else {
        if (selectedBuyingFor == "self") {
          if (clientType == "1") {
            if (age < 10) {
              validDOB["isValid"] = false;
              validDOB["message"] =
                  "${getLocale("A")} ${getLocale("Policy Owner", entity: true)} ${getLocale("is required for this application as you have not attained the age of 10")}";
            }
          }
        } else {
          if (clientType == "1") {
            if (age < 16) {
              validDOB["isValid"] = false;
              validDOB["message"] =
                  "${getLocale("A")} ${getLocale("Policy Owner", entity: true)} ${getLocale("must be at least 17 age next birthday")}";
            }
          } else {
            if (selectedBuyingFor == "children") {
              if (age > 16) {
                validDOB["isValid"] = false;
                validDOB["message"] =
                    "${getLocale("Please submit the application with you as the")} ${getLocale("Policy Owner", entity: true)}";
              } else if (dayage < 14) {
                validDOB["isValid"] = false;
                validDOB["message"] =
                    getLocale("Minimum entry age is 14 days old");
              }
            } else if (selectedBuyingFor == "spouse") {
              if (age < 16) {
                validDOB["isValid"] = false;
                validDOB["message"] =
                    "${getLocale("A")} ${getLocale("Life Insured", entity: true)} ${getLocale("must be at least 17 age next birthday")}";
              }
            }
          }
        }
      }
    }
  }
  return validDOB;
}

String? validHomeTel(obj) {
  String value = obj["value"];
  List<String> validHomeTel = ["03", "04", "05", "06", "07", "08", "09"];
  if (value.isEmpty) {
    return null;
  } else if (value.length < 8 || value.length > 11) {
    return '${getLocale("Please enter a valid")} ${obj["label"]}';
  } else {
    if (!validHomeTel.contains(value.substring(0, 2))) {
      return '${getLocale("Please enter a valid")} ${obj["label"]}';
    } else {
      if (value.substring(0, 2) == "08" &&
          (value[2] == "1" || value[2] == "0")) {
        return '${getLocale("Please enter a valid")} ${obj["label"]}';
      }
      return null;
    }
  }
}

String? validPhoneNo(value) {
  String pattern = r"^(1)[02-46-9]-*[0-9]{7}$|^(1)[1]-*[0-9]{8}$";
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return getLocale('Mobile No. 1 cannot be empty!');
  } else if (!regExp.hasMatch(value)) {
    return getLocale('Please enter a valid Mobile No. 1');
  } else if (ApplicationFormData.data != null &&
      value == ApplicationFormData.data["agentMobilePhone"]) {
    return getLocale("Mobile No. 1 cannot same as Agent's mobile number");
  }
  return null;
}

String? validEmail(value, {bool checkAgentEmail = false}) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return getLocale('Email address cannot be empty!');
  } else if (!regExp.hasMatch(value)) {
    return getLocale('Please enter a valid Email');
  } else if (checkAgentEmail &&
      ApplicationFormData.data != null &&
      value == ApplicationFormData.data["agentEmail"]) {
    return getLocale("Email cannot be same as Agent's email");
  }
  return null;
}

dynamic validateOcc(int dob, value) {
  var validOcc = {"isValid": true, "message": ""};
  int age = getAge(DateTime.fromMicrosecondsSinceEpoch(dob));
  if (value == "JUVENILE Pre-school/primary/secondary school student" &&
      age >= 16) {
    validOcc["isValid"] = false;
    validOcc["message"] = getLocale(
        "Invalid age range for selected occupation. Please choose different occupation");
  }
  return validOcc;
}

dynamic validateAccNo(obj) {
  var validAccNo = {"isValid": true, "message": ""};
  if (obj["accountno"]["value"] == null || obj["accountno"]["value"] == "") {
    return validAccNo;
  }
  int? accLength;
  int minLength = 6;
  int maxLength = 17;
  if (obj["bankname"] != null &&
      obj["bankname"]["value"] != null &&
      obj["bankname"]["value"] != "" &&
      obj["bankaccounttype"] != null &&
      obj["bankaccounttype"]["value"] != "" &&
      obj["bankaccounttype"]["value"] != null) {
    var bankList = getBankList();
    var theBank = bankList.firstWhere(
        (element) => element["value"] == obj["bankname"]["value"],
        orElse: () => null);
    if (theBank != null) {
      if (theBank["AccountTypes"] != null &&
          theBank["AccountTypes"].length > 0) {
        var length = theBank["AccountTypes"].firstWhere((value) =>
            value["AccountTypeCode"] == obj["bankaccounttype"]["value"]);
        accLength = length["AccountNumLength"];
      }
    }
  }
  if (accLength != null && accLength > 0) {
    validAccNo["isValid"] = obj["accountno"]["value"].length == accLength;
    validAccNo["message"] =
        "Invalid account number. Account number length should be $accLength digits only";
  } else if (obj["accountno"]["required"]) {
    validAccNo["isValid"] = obj["accountno"]["value"].length >= minLength &&
        obj["accountno"]["value"].length <= maxLength;
    validAccNo["message"] = getLocale(
        "Invalid account number. Account number length should be 6 digits only");
  }
  return validAccNo;
}
