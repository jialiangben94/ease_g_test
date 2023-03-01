import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:ease/src/data/new_business_model/application_dao.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quotation_dao.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:intl/intl.dart';

final applicationDao = ApplicationDao();
final quotationDao = QuotationDao();

class ApplicationFormData {
  static dynamic data;
  static dynamic currentHome;
  static dynamic qIndex;
  static bool? callRead;
  static dynamic dynamicFields;
  static dynamic id;
  static dynamic isAmlaChecking = {};
  static dynamic amlaTimer = {};
  static dynamic isPaymentChecking = {};
  static dynamic paymentTimer = {};
  static dynamic tabList;
  static dynamic onTitleClicked;
  static dynamic optionList;
  static dynamic optionType;
  static dynamic translation;
  static int? languageId;
}

void checkEachRequiredAndComplete(tabList) {
  String? currentKey = "customer";
  for (var key in tabList.keys) {
    if (key.indexOf("progress") > -1) continue;
    if (tabList[key]["enable"] == false) continue;
    if (tabList[key]["completed"] == false) {
      if (key == "customer") {
        tabList["progress"] = tabList["defaultprogress"];
        break;
      }
      tabList["progress"] = tabList[currentKey]["progress"];
      break;
    }
    currentKey = key;
  }
}

//FOR NOT REPLACE WHOLE OBJECT
void removeOptionValue(key, o) {
  var obj = getGlobalInputJsonFormat();
  if (obj[o] != null &&
      obj[o]["type"] != null &&
      obj[o]["type"].indexOf("option") > -1) {
    for (var i = 0; i < obj[o]["options"].length; i++) {
      if (obj[o]["options"][i]["value"] == ApplicationFormData.data[key][o]) {
        continue;
      } else if (obj[o]["options"][i]["option_fields"] != null) {
        handleNestedOption(obj[o]["options"][i]["option_fields"], key);
      }
    }
  } else if (obj[o] != null && obj[o]["option_fields"] != null) {
    for (var i in obj[o]["option_fields"].keys) {
      ApplicationFormData.data[key].remove(i);
    }
  }
}

void handleNestedOption(obj, key2) {
  for (var key in obj.keys) {
    if (obj[key]["option_fields"] != null) {
      handleNestedOption(obj[key]["option_fields"], key2);
    } else {
      ApplicationFormData.data[key2].remove(key);
    }
  }
}

void saveFilterToMapCurrentFormat(data) {
  if (data != null && !data.isEmpty) {
    if (data["buyingFor"] == BuyingFor.self.toStr) {
      data["lifeInsured"] = data["policyOwner"];
    }
  }
}

void updateRecipientList() {
  var data = ApplicationFormData.data;
  if (data["remote"] != null) {
    var listOfRecipient = [];
    var finalListOfRecipient = [];
    if ((data["consentMinor"] != null && data["consentMinor"]) &&
        (data["guardiansign"] != null && data["guardiansign"]["remote"])) {
      var parentGuardian = {
        "role": "Parent/Guardian (Consent For Minor)",
        "clientType": lookupClientType["guardian"],
        "name": data["guardian"]["name"],
        "identitytype": data["guardian"]["identitytype"],
        "nric": data["guardian"][data["guardian"]["identitytype"]],
        "method": "",
        "recipientMobile": "",
        "recipientEmail": "",
        "status": "",
        "datetime": "",
        "isPayor": false
      };
      listOfRecipient.add(parentGuardian);
    }

    if (data["trusteesign"] != null) {
      data["nomination"]["trustee"].forEach((element) {
        String key = "Identity-${element[element["identitytype"]]}";
        var tsign = data["trusteesign"][key];
        if (tsign != null && tsign["remote"]) {
          var trustee = {
            "role": "Trustee",
            "clientType": lookupClientType["trustee"],
            "name": element["name"],
            "identitytype": element["identitytype"],
            "nric": element[element["identitytype"]],
            "method": "",
            "recipientMobile": element["mobileno"],
            "recipientEmail": "",
            "status": "",
            "datetime": "",
            "isPayor": false
          };
          listOfRecipient.add(trustee);
        }
      });
    }

    // Add Witness
    if (data["witness"] != null &&
        data["witness"]["witness"] != "agent" &&
        data["witness"]["remote"]) {
      var witness = {
        "role": "Witness",
        "clientType": lookupClientType["witness"],
        "name": data["witness"]["name"],
        "identitytype": data["witness"]["identitytype"],
        "nric": data["witness"][data["witness"]["identitytype"]],
        "method": "",
        "status": "",
        "datetime": "",
        "recipientMobile": "",
        "recipientEmail": "",
        "isPayor": false
      };
      listOfRecipient.add(witness);
    }

    if (data["declaration"] != null &&
        data["declaration"]["ownerIdentity"] != null &&
        data["declaration"]["ownerIdentity"]["remote"] != null &&
        data["declaration"]["ownerIdentity"]["remote"]) {
      var policyOwner = {
        "role":
            "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
        "clientType": lookupClientType["poli"],
        "name": data["policyOwner"]["name"],
        "identitytype": data["policyOwner"]["identitytype"],
        "nric": data["policyOwner"][data["policyOwner"]["identitytype"]],
        "method": "",
        "recipientMobile": data["policyOwner"]["mobileno"] != ""
            ? data["policyOwner"]["mobileno"]
            : "",
        "recipientEmail": data["policyOwner"]["email"] != ""
            ? data["policyOwner"]["email"]
            : "",
        "status": "",
        "datetime": ""
      };

      if (data["buyingFor"] != BuyingFor.self.toStr) {
        policyOwner["clientType"] = lookupClientType["policyOwner"];
        policyOwner["role"] = getLocale("Policy Owner", entity: true);
      }

      if (data["buyingFor"] == BuyingFor.self.toStr &&
          (data["payor"] != null &&
              (data["payor"]["whopaying"] == "policyOwner" ||
                  data["payor"]["whopaying"] == "lifeInsured"))) {
        policyOwner["isPayor"] = true;
      } else if (data["buyingFor"] != BuyingFor.self.toStr &&
          (data["payor"] != null &&
              (data["payor"]["whopaying"] == "policyOwner"))) {
        policyOwner["isPayor"] = true;
      } else {
        policyOwner["isPayor"] = false;
      }
      listOfRecipient.add(policyOwner);
    }

    if (data["declaration"] != null &&
        data["declaration"]["insuredIdentity"] != null &&
        data["declaration"]["insuredIdentity"]["remote"]) {
      var lifeInsured = {
        "role": getLocale("Life Insured", entity: true),
        "clientType": lookupClientType["lifeInsured"],
        "name": data["lifeInsured"]["name"],
        "identitytype": data["lifeInsured"]["identitytype"],
        "nric": data["lifeInsured"][data["lifeInsured"]["identitytype"]],
        "method": "",
        "recipientMobile": data["lifeInsured"]["mobileno"] != ""
            ? data["lifeInsured"]["mobileno"]
            : "",
        "recipientEmail": data["lifeInsured"]["email"] != ""
            ? data["lifeInsured"]["email"]
            : "",
        "status": "",
        "datetime": ""
      };

      if (data["payor"] != null &&
          data["payor"]["whopaying"] == "lifeInsured") {
        lifeInsured["isPayor"] = true;
      } else {
        lifeInsured["isPayor"] = false;
      }
      listOfRecipient.add(lifeInsured);
    }

    // Add Payor
    if (data["declaration"] != null &&
        data["declaration"]["payorIdentity"] != null &&
        data["declaration"]["payorIdentity"]["remote"]) {
      var payor = {
        "role": "Payor",
        "clientType": lookupClientType["payor"],
        "name": data["payor"]["name"],
        "identitytype": data["payor"]["identitytype"],
        "nric": data["payor"][data["payor"]["identitytype"]],
        "method": "",
        "status": "",
        "datetime": "",
        "recipientMobile":
            data["payor"]["mobileno"] != "" ? data["payor"]["mobileno"] : "",
        "recipientEmail":
            data["payor"]["email"] != "" ? data["payor"]["email"] : "",
        "isPayor": true
      };
      listOfRecipient.add(payor);
    }

    // Sort and put payor at end
    listOfRecipient
        .sort((a, b) => (a["isPayor"] ? 1 : 0) - (b["isPayor"] ? 1 : 0));

    // update recipient status
    for (var element in listOfRecipient) {
      var recipient = data["remote"]["listOfRecipient"].firstWhere(
          (recipient) => recipient["nric"] == element["nric"],
          orElse: () => null);
      if (recipient != null) {
        finalListOfRecipient.add({
          "role": element["role"],
          "clientType": element["clientType"],
          "name": element["name"],
          "identitytype": element["identitytype"],
          "nric": element["nric"],
          "method": recipient["method"],
          "status": recipient["status"],
          "datetime": recipient["datetime"],
          "recipientMobile": recipient["recipientMobile"],
          "recipientEmail": recipient["recipientEmail"],
          "isPayor": element["isPayor"],
          "SetID": data["SetID"]
        });
      } else {
        finalListOfRecipient.add(element);
      }
    }
    if (finalListOfRecipient.isNotEmpty) {
      data["remote"]["listOfRecipient"] = finalListOfRecipient;
    } else {
      data["remote"] = {
        "paymentStatus": "",
        "enablePayor": false,
        "listOfRecipient": []
      };
    }
  } else {
    data["remote"] = {
      "paymentStatus": "",
      "enablePayor": false,
      "listOfRecipient": []
    };
  }
}

void saveData() {
  var data = json.decode(json.encode(ApplicationFormData.data));
  saveFilterToMapCurrentFormat(data);
  var date = DateTime.now().microsecondsSinceEpoch;

  if (ApplicationFormData.id != null) {
    data["lastUpdatedTimestamp"] = date;
    applicationDao.updateData(ApplicationFormData.id, data);
  } else if (data != null) {
    data["createdTimestamp"] = date;
    data["lastUpdatedTimestamp"] = date;
    data["appId"] = generateRandomId();
    applicationDao.insert(data).then((id) {
      ApplicationFormData.id = id;
    });
  }
}

void checkAllTabInput(data, tabList) async {
  tabList["customer"]["completed"] = checkRequiredField(data["policyOwner"]) &&
      checkRequiredField(data["lifeInsured"]) &&
      checkRequiredField(data["payor"]);

  if (tabList["customer"]["completed"] &&
      data["consentMinor"] != null &&
      data["consentMinor"]) {
    tabList["customer"]["completed"] = checkRequiredField(data["guardian"]);
  }

  tabList["disclosure"]["completed"] = checkRequiredField(data["disclosure"]);
  tabList["financial"]["completed"] =
      checkRequiredField(data["investmentPreference"]) &&
          checkRequiredField(data["priority"]) &&
          checkRequiredField(data["intermediary"]);

  tabList["products"]["completed"] = data["listOfQuotation"] != null
      ? checkRequiredField(data["recommendedProducts"]) &&
          !await needRecalculate(data)
      : false;

  // Since not so many validation in nominee
  // sometimes when user already update one field in customer
  // it auto pass the nomination

  // So we only run this validation once the customer section is passed

  var hideNominee = hideTrustee(data);
  if (tabList["customer"]["completed"]) {
    if (!hideNominee["hideNominee"]) {
      tabList["nomination"]["completed"] =
          checkRequiredField(data["nomination"]);
      if (tabList["nomination"]["completed"] &&
          data["nomination"]["nominee"] != null) {
        bool validage = true;
        if (data["nomination"]["nominee"] is List) {
          data["nomination"]["nominee"].forEach((nominee) {
            DateTime date = DateTime.fromMicrosecondsSinceEpoch(nominee["dob"]);
            var validDOB = validateAge(date, "4");
            validage = validage && validDOB["isValid"];
          });
        }
        if (validage &&
            data["nomination"]["trustee"] != null &&
            data["nomination"]["trustee"] is List) {
          data["nomination"]["trustee"].forEach((trustee) {
            DateTime date = DateTime.fromMicrosecondsSinceEpoch(trustee["dob"]);
            var validDOB = validateAge(date, "6");
            validage = validage && validDOB["isValid"];
          });
        }
        tabList["nomination"]["completed"] = validage;
      }
    } else {
      tabList["nomination"]["completed"] = true;
    }
  }

  if (tabList["customer"]["completed"]) {
    tabList["benefitOwner"]["completed"] =
        checkRequiredField(data["benefitOwner"]);
    if (tabList["benefitOwner"]["completed"] &&
        data["benefitOwner"]["person"] != null) {
      bool validage = true;
      if (data["benefitOwner"]["person"] is List) {
        data["benefitOwner"]["person"].forEach((person) {
          DateTime date = DateTime.fromMicrosecondsSinceEpoch(person["dob"]);
          var validDOB = validateAge(date, "99");
          validage = validage && validDOB["isValid"];
        });
      }
      tabList["benefitOwner"]["completed"] = validage;
    }
  }

  tabList["decision"]["completed"] = checkRequiredField(data["decision"]);

  // Only perform height and weight validation check on the following questionType codes
  if (data["qtype"] == 2 || data["qtype"] == 4 || data["qtype"] == 6) {
    tabList["questions"]["completed"] =
        checkRequiredField(data["liquestions"]) &&
            isHeightWeightValid(data["liquestions"]);
    tabList["questionsPolicyOwner"]["completed"] =
        checkRequiredField(data["poquestion"]) &&
            isHeightWeightValid(data["poquestion"]);
  } else {
    tabList["questions"]["completed"] = checkRequiredField(data["liquestions"]);
    tabList["questionsPolicyOwner"]["completed"] =
        checkRequiredField(data["poquestion"]);
  }

  bool completeDeclaration = true;
  if (data["declaration"] != null &&
      data["declaration"]["isSignRemote"] != null &&
      data["declaration"]["isSignRemote"]) {
    completeDeclaration = true;
  } else {
    completeDeclaration =
        completeDeclaration && checkRequiredField(data["declaration"]);
  }

  if (completeDeclaration &&
      data["consentMinor"] != null &&
      data["consentMinor"]) {
    if (data["guardiansign"] != null &&
        data["guardiansign"]["isSignRemote"] != null &&
        data["guardiansign"]["isSignRemote"]) {
      completeDeclaration = true;
    } else {
      completeDeclaration =
          completeDeclaration && checkRequiredField(data["guardiansign"]);
    }
  }

  if (completeDeclaration && !hideNominee["hideTrustee"]) {
    if (data["nomination"] != null &&
        data["nomination"]["trustee"] != null &&
        data["nomination"]["trustee"] is List) {
      if (data["trusteesign"] != null &&
          data["trusteesign"]["isSignRemote"] != null &&
          data["trusteesign"]["isSignRemote"]) {
        completeDeclaration = true;
      } else {
        completeDeclaration =
            completeDeclaration && checkRequiredField(data["trusteesign"]);
      }
    }
  }

  completeDeclaration = completeDeclaration &&
      checkRequiredField(data["witness"]) &&
      checkRequiredField(data["agent"]);

  tabList["declaration"]["completed"] = completeDeclaration;

  if (data["remote"] != null && data["remote"]["listOfRecipient"].length > 0) {
    bool isCompleted = true;
    data["remote"]["listOfRecipient"].forEach((remote) {
      if (data["remote"]["remoteStatus"] != null) {
        var recipient = data["remote"]["remoteStatus"]["ClientRemoteList"]
            .firstWhere(
                (rec) => (rec["IDNum"] == remote["nric"] &&
                    rec["ClientName"] == remote["name"]),
                orElse: () => null);
        if (recipient == null ||
            recipient != null && recipient["VerifyStatus"] != "5") {
          isCompleted = false;
        }
      } else {
        isCompleted = false;
      }
    });
    tabList["remote"]["completed"] = isCompleted;
  }

  if (data["payment"] != null &&
      data["payment"]["paymentStatus"] != null &&
      data["payment"]["paymentStatus"] == paymentStatus[PayS.pending]) {
    tabList["payment"]["completed"] = false;
  } else {
    tabList["payment"]["completed"] = checkRequiredField(data["payment"]);
  }

  checkEachRequiredAndComplete(tabList);
}

bool checkRequiredField(obj, {emptyable = false}) {
  var completed = true;
  if (!emptyable &&
      (obj == null ||
          (obj is! int &&
              obj is! double &&
              obj is! bool &&
              obj is! String &&
              obj.isEmpty))) {
    return false;
  } else if (obj == null) {
    return true;
  } else if (obj is! Map) {
    return false;
  }

  for (var key in obj.keys) {
    if (obj[key] == null ||
        (obj[key] is! int &&
            obj[key] is! double &&
            obj[key] is! bool &&
            obj[key] is! String &&
            obj[key].isEmpty)) {
      completed = false;
      break;
    } else if (obj[key] != null && obj[key] is Map && obj[key].keys != null) {
      if (!checkRequiredField(obj[key])) {
        completed = false;
        break;
      }
    }
  }
  return completed;
}

bool isHeightWeightValid(data) {
  bool isValid = false;
  if (data != null && data["1078h"] != null && data["1078w"] != null) {
    var height = data["1078h"]["AnswerValue"].toString();
    var weight = data["1078w"]["AnswerValue"].toString();

    double doubleHeight;
    double doubleWeight;

    doubleHeight = double.parse(height);
    doubleWeight = double.parse(weight);

    if (doubleHeight >= heightMin &&
        doubleHeight <= heightMax &&
        doubleWeight >= weightMin &&
        doubleWeight <= weightMax) {
      isValid = true;
    } else {
      isValid = false;
    }
  }
  return isValid;
}

Future<dynamic> getByID(int id) {
  return applicationDao.getDataByID(id).then((data) {
    if (data == null) {
      return {"status": false, "data": data};
    }

    data = json.decode(json.encode(data));
    return {"status": true, "data": data};
  }).catchError((err) {
    return {"status": false, "error": err};
  });
}

Future<dynamic> getByQuoID(int? id, String? qquoId) {
  return quotationDao.getDataByID(id).then((data) {
    if (data == null) {
      return {"status": false, "data": data};
    }

    data = json.decode(json.encode(data));
    if (data["listOfQuotation"] != null && data["listOfQuotation"] is List) {
      int index = data["listOfQuotation"]
          .indexWhere((option) => option["quickQuoteId"] == qquoId);
      if (index > -1) {
        data["listOfQuotation"] = [data["listOfQuotation"][index]];
      } else {
        return {"status": false, "error": "Data not matching"};
      }
    }
    if (data["lifeInsured"] is String) {
      data["lifeInsured"] = json.decode(data["lifeInsured"]);
      if (data["lifeInsured"]["dob"] != null &&
          data["lifeInsured"]["dob"].indexOf(".") > -1) {
        data["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy', 'en_US')
            .parse(data["lifeInsured"]["dob"])
            .microsecondsSinceEpoch;
      }
    }
    if (data["policyOwner"] is String) {
      data["policyOwner"] = json.decode(data["policyOwner"]);
      if (data["policyOwner"]["dob"] != null &&
          data["policyOwner"]["dob"].indexOf(".") > -1) {
        data["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy', 'en_US')
            .parse(data["policyOwner"]["dob"])
            .microsecondsSinceEpoch;
      }
    }

    // print(data.keys);

    for (var key in data["lifeInsured"].keys) {
      // print(key);
      if (data["lifeInsured"][key] == null ||
          (data["lifeInsured"][key] is List &&
              data["lifeInsured"][key].isEmpty)) {
        data["lifeInsured"][key] = "";
      }
    }

    for (var key in data["policyOwner"].keys) {
      // print(key);
      if (data["policyOwner"][key] == null ||
          (data["policyOwner"][key] is List &&
              data["policyOwner"][key].isEmpty)) {
        data["policyOwner"][key] = "";
      }
    }

    if (data["occupation"] != null) {
      dynamic occJson = json.decode(data["occupation"]);
      data["occupationDisplay"] = occJson["OccupationName"];
    }

    //for first time generate data to disable the tab checked
    if (data["policyOwner"]["identitytype"] == null) {
      data["policyOwner"]["identitytype"] = null;
    }

    //for first time generate data to disable the tab checked
    if (data["lifeInsured"]["identitytype"] == null) {
      data["lifeInsured"]["identitytype"] = null;
    }

    data["povpmsocc"] = data["policyOwner"]["occupation"];
    data["povpmsage"] = data["policyOwner"]["age"];
    data["povpmssmoke"] = data["policyOwner"]["smoking"];
    data["povpmsgender"] = data["policyOwner"]["gender"];
    data["livpmsocc"] = data["lifeInsured"]["occupation"];
    data["livpmsage"] = data["lifeInsured"]["age"];
    data["livpmssmoke"] = data["lifeInsured"]["smoking"];
    data["livpmsgender"] = data["lifeInsured"]["gender"];
    return {"status": true, "data": data};
  }).catchError((err) {
    return {"status": false, "error": err};
  });

  // return data;
}

bool needReason({tempQuo}) {
  bool isRequired = false;
  var d = ApplicationFormData.data["disclosure"];

  var q = {};
  if (tempQuo != null) {
    q = tempQuo;
  } else if (ApplicationFormData.data["listOfQuotation"] != null &&
      ApplicationFormData.data["listOfQuotation"].length != 0) {
    q = ApplicationFormData.data["listOfQuotation"][0];
  }

  if (d != null && q.isNotEmpty) {
    if (d["currentOption"] == "Option 3") {
      isRequired = true;
    } else {
      if (d["discussion"] == null) {
        isRequired = true;
      } else {
        bool isDiscussed = false;
        if (q["productPlanCode"] == "PCWI03") {
          var discussion = [
            "saving",
            "childreneducation",
            "protection",
            "medical"
          ];
          d["discussion"].forEach((key, value) {
            if (discussion.contains(key)) {
              isDiscussed = true;
            }
          });
        } else if (q["productPlanCode"] == "PCJI01" ||
            q["productPlanCode"] == "PCJI02") {
          var discussion = ["retirement", "childreneducation", "protection"];
          d["discussion"].forEach((key, value) {
            if (discussion.contains(key)) {
              isDiscussed = true;
            }
          });
        } else if (q["productPlanCode"] == "PCHI03" ||
            q["productPlanCode"] == "PCHI04") {
          var discussion = ["saving", "childreneducation"];
          d["discussion"].forEach((key, value) {
            if (discussion.contains(key)) {
              isDiscussed = true;
            }
          });
        }
        isRequired = !isDiscussed;
      }
    }
  }
  return isRequired;
}

int checkFundRisk({tempQuo}) {
  int risk = 0;
  dynamic product;
  if (tempQuo != null) {
    product = tempQuo;
  } else {
    product = ApplicationFormData.data["listOfQuotation"];
  }
  if (product is List && product[0] != null) product = product[0];
  if (product != null &&
      product["fundOutputDataList"] != null &&
      product["fundOutputDataList"] is List) {
    var list = product["fundOutputDataList"];
    for (var i = 0; i < list.length; i++) {
      if (list[i]["fundRiskLevel"] != null) {
        var risk2 = int.parse(list[i]["fundRiskLevel"]);
        if (risk2 > risk) {
          risk = risk2;
        }
      }
    }
  }
  return risk;
}

Future<dynamic> initData(int id, tabList) {
  return getByID(id).then((status) {
    if (status != null && status["data"] != null) {
      checkAllTabInput(status["data"], tabList);
      var amla = checkAmlaPass(status["data"]);
      var data = status["data"];
      if (amla == false) {
        return {
          "status": false,
          "msg": getLocale("This record is not allow to continue."),
          "error": ""
        };
      } else if (data["recommendedProducts"] != null &&
          data["recommendedProducts"]["TSARMedicalPassed"] != null &&
          !data["recommendedProducts"]["TSARMedicalPassed"]) {
        return {
          "status": false,
          "msg":
              "${getLocale("This record is not allow to continue.")} ${data["recommendedProducts"]["TSARMedicalErrorMsg"]}",
          "error": ""
        };
      } else if (data["TSARMedicalPassed"] != null &&
          !data["TSARMedicalPassed"]) {
        return {
          "status": false,
          "msg":
              "${getLocale("This record is not allow to continue.")} ${data["TSARMedicalErrorMsg"]}",
          "error": ""
        };
      }
      return status;
    } else {
      return {
        "status": false,
        "msg": getLocale("Status missing"),
        "error": status
      };
    }
  }).catchError((err) {
    return err;
  });
}

Future<dynamic> initDataWithQuoId(int? id, String? qquoId, tabList) {
  return getByQuoID(id, qquoId).then((status) {
    if (status != null && status["data"] != null) {
      checkAllTabInput(status["data"], tabList);
      return status;
    } else {
      return {
        "status": false,
        "msg": getLocale("Status missing"),
        "error": status
      };
    }
  }).catchError((err) {
    return {"status": false, "err": err};
  });
}

Future<dynamic> initDataSummary(int id) {
  return getByID(id).then((status) {
    if (status != null && status["data"] != null) {
      return status;
    } else {
      return {
        "status": false,
        "msg": getLocale("Status missing"),
        "error": status
      };
    }
  }).catchError((err) {
    return err;
  });
}

bool checkAmlaPass(data) {
  if (data != null && data is Map) {
    var amlaPo = data["policyOwner"];
    var amlaLi = data["lifeInsured"];
    if (amlaPo != null && amlaPo["amlaPass"] == false) {
      return false;
    }
    if (amlaLi != null && amlaLi["amlaPass"] == false) {
      return false;
    }
    return true;
  } else {
    throw "Unhandle";
  }
}

//for dynamic function usage for server control not yet in use
// Function.apply(printKwargs, [], symbolizeKeys({"a": "cc"}));
Map<Symbol, dynamic> symbolizeKeys(Map<String, dynamic> map) =>
    map.map((key, value) => MapEntry(Symbol(key), value));

void startCheckAmla(data, checking, callback) {
  if (ApplicationFormData.isAmlaChecking[checking] == true) {
    return;
  }
  if (data != null && data["amlaChecked"] == null ||
      data["amlaChecked"] == false) {
    if (data["name"] != null &&
        data["countryofbirth"] != null &&
        data["nationality"] != null) {
      if (data["identitytype"] != null && data[data["identitytype"]] != null) {
        var obj = {
          "FullName": data["name"],
          "CountryAlpha3": getMasterlookup(
              type: "Country", value: data["countryofbirth"])["callValue"],
          "Nationality": getMasterlookup(
              type: "Nationality", value: data["nationality"])["callValue"],
          "IdType": identityTypeMap[data["identitytype"]],
          "IdNo": data[data["identitytype"]],
          "AppId": "my.com.etiqa.ease"
        };
        if (obj["CountryAlpha3"] == null) {
          startAmlaTimer(data, checking, callback);
          return;
        }
        ApplicationFormData.isAmlaChecking[checking] = true;
        var amlaobj = {
          "Method": "POST",
          "Param": {"ValidateType": "AMLA"},
          "Body": {"Validate": obj}
        };
        NewBusinessAPI().validation(amlaobj).then((res) {
          ApplicationFormData.isAmlaChecking[checking] = false;
          ApplicationFormData.amlaTimer[checking]?.cancel();
          if (res != null && res["Code"] == "00") {
            data["amlaPass"] = true;
            data["amlaChecked"] = true;
            if (callback != null) {
              callback(data, null);
            }
          } else if (res != null && res["Message"] != null) {
            data["amlaPass"] = false;
            data["amlaChecked"] = true;
            if (callback != null) {
              callback(data, res["Message"]);
            }
          } else {
            data["amlaPass"] = false;
            data["amlaChecked"] = true;
            if (callback != null) {
              callback(data);
            }
          }
        }).catchError((error) {
          ApplicationFormData.isAmlaChecking[checking] = false;
          startAmlaTimer(data, checking, callback);
        });
      }
    }
  }
}

void startAmlaTimer(data, checking, callback) {
  if (ApplicationFormData.amlaTimer[checking] == null ||
      ApplicationFormData.amlaTimer[checking].isActive == false) {
    ApplicationFormData.amlaTimer[checking] =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      startCheckAmla(data, checking, callback);
    });
  }
}

void startCheckPayment(data, checking, callback) {
  if (ApplicationFormData.isPaymentChecking != null &&
      ApplicationFormData.isPaymentChecking[checking] == true) {
    return;
  }
  ApplicationFormData.isPaymentChecking[checking] = true;
  if (data["proposalNo"] != null && data["proposalNo"] != "") {
    var obj = {
      "Method": "GET",
      "Param": {"Type": "MPAYTRXQUERY", "ProposalNo": data["proposalNo"]}
    };
    NewBusinessAPI().payment(obj).then((status) {
      log(jsonEncode(obj));
      log(jsonEncode(status));

      ApplicationFormData.isPaymentChecking[checking] = false;
      if (status != null) {
        if (status["ResponseCode"] == paymentStatus[PayS.success] ||
            status["ResponseCode"] == paymentStatus[PayS.failed]) {
          if (status["ResponseCode"] == paymentStatus[PayS.success]) {
            var product = ApplicationFormData.data["listOfQuotation"][0];
            FirebaseAnalytics.instance.logPurchase(
                items: [
                  AnalyticsEventItem(
                      itemName: product["productPlanName"],
                      itemId: product["productPlanCode"],
                      price: double.tryParse(product["totalPremium"]))
                ],
                value: double.tryParse(product["totalPremium"]),
                currency: "MYR",
                transactionId: ApplicationFormData.data["application"]
                    ["ProposalNo"]);
          }
          ApplicationFormData.paymentTimer[checking]?.cancel();
          callback(status);
        }
      }
    }).catchError((err) {
      ApplicationFormData.isPaymentChecking[checking] = false;
    });
  }
}

void startPaymentTimer(data, checking, callback) {
  if (ApplicationFormData.paymentTimer == null ||
      ApplicationFormData.paymentTimer[checking] == null ||
      ApplicationFormData.paymentTimer[checking].isActive == false) {
    ApplicationFormData.paymentTimer[checking] =
        Timer.periodic(const Duration(seconds: 3), (timer) {
      startCheckPayment(data, checking, callback);
    });
  }
}

void filterEmptyValue(item) {
  if (item == null || item is! Map) {
    return;
  }

  if (item["policyOwner"] == null) item["policyOwner"] = {};
  if (item["lifeInsured"] == null) item["lifeInsured"] = {};
  if (item["guardian"] == null) item["guardian"] = {};
  if (item["listOfQuotation"] == null || item["listOfQuotation"].length == 0) {
    item["listOfQuotation"] = [];
    item["listOfQuotation"].add({"a": ""});
  }
}

dynamic filterNominee(data) {
  var nomineeRelationship = {
    "isSpouse": false,
    "isChild": false,
    "isParent": false,
    "isOther": false
  };

  if (data["nomination"] != null &&
      data["nomination"]["nominee"] != null &&
      data["nomination"]["nominee"].length > 0) {
    data["nomination"]["nominee"].forEach((element) {
      var relationship = lookupRelationship.keys.firstWhereOrNull(
          (k) => lookupRelationship[k] == element["relationship"]);
      if (relationship == "wife" ||
          relationship == "husband" ||
          relationship == "spouse") {
        nomineeRelationship["isSpouse"] = true;
      } else if (relationship == "son" ||
          relationship == "daughter" ||
          relationship == "stepson" ||
          relationship == "stepdaughter" ||
          relationship == "adoptedson" ||
          relationship == "adopteddaughter" ||
          relationship == "child") {
        nomineeRelationship["isChild"] = true;
      } else if (relationship == "father" ||
          relationship == "mother" ||
          relationship == "parent") {
        nomineeRelationship["isParent"] = true;
      } else {
        nomineeRelationship["isOther"] = true;
      }
    });
  }
  return nomineeRelationship;
}

dynamic hideTrustee(data) {
  var nomineeRelationship = filterNominee(data);
  bool hideNominee = false;
  bool hideTrustee = false;
  if (data["policyOwner"] != null &&
      (data["policyOwner"]["clientType"] == 3 ||
          data["buyingFor"] == BuyingFor.self.toStr)) {
    // if less than 17 years old ANB, nomination not allowed
    if (data["policyOwner"]["age"] != null && data["policyOwner"]["age"] < 17) {
      hideNominee = true;
      hideTrustee = true;
    } else {
      // If policy owner is muslim or malay hide trustee
      if ((data["policyOwner"]["muslim"] != null &&
              data["policyOwner"]["muslim"] ||
          data["policyOwner"]["race"] != null &&
              data["policyOwner"]["race"] == "CCM1")) {
        hideTrustee = true;
      } else {
        if (data["nomination"] != null &&
            data["nomination"]["nominee"] != null &&
            data["nomination"]["nominee"].length > 0) {
          // If policy owner is single
          if (data["policyOwner"]["maritalstatus"] != null &&
              data["policyOwner"]["maritalstatus"] == "2") {
            // If policy owner is single with child, if nominee is child, can appoint trustee
            if (data["policyOwner"]["numberofchildren"] != null &&
                int.parse(data["policyOwner"]["numberofchildren"]) > 0) {
              hideTrustee = !nomineeRelationship["isChild"] ||
                  nomineeRelationship["isOther"];
            } else {
              hideTrustee = !nomineeRelationship["isParent"] ||
                  nomineeRelationship["isOther"];
            }
          }
          // If policy owner is married
          else if (data["policyOwner"]["maritalstatus"] != null &&
              data["policyOwner"]["maritalstatus"] == "1") {
            // If nominee is either their children/spouse, can appoint trustee
            if (data["policyOwner"]["numberofchildren"] != null &&
                int.parse(data["policyOwner"]["numberofchildren"]) > 0) {
              hideTrustee = !(nomineeRelationship["isSpouse"] ||
                  nomineeRelationship["isChild"] ||
                  nomineeRelationship["isOther"]);
            } else {
              hideTrustee = !nomineeRelationship["isSpouse"] ||
                  nomineeRelationship["isOther"];
            }
          }
          // If policy owner is divorce/widow
          else if (data["policyOwner"]["maritalstatus"] != null &&
                  data["policyOwner"]["maritalstatus"] == "3" ||
              data["policyOwner"]["maritalstatus"] == "4") {
            // If policy owner is divorce/widow with child, if nominee is child, can appoint trustee
            if (data["policyOwner"]["numberofchildren"] != null &&
                int.parse(data["policyOwner"]["numberofchildren"]) > 0) {
              hideTrustee = !nomineeRelationship["isChild"] ||
                  nomineeRelationship["isOther"];
            } else {
              hideTrustee = !nomineeRelationship["isParent"] ||
                  nomineeRelationship["isOther"];
            }
          }
        }
      }
    }
  } else {
    if (data["policyOwner"] != null) {
      hideNominee = true;
      hideTrustee = true;
    }
  }
  return {"hideNominee": hideNominee, "hideTrustee": hideTrustee};
}

Future<bool> checkIfCountryBlock(String selectionNationality) async {
  var isBlock = false;

  if (ApplicationFormData.data['listOfQuotation'] == null ||
      ApplicationFormData.data['listOfQuotation'].isEmpty) {
    return false;
  }

  var qtn = ApplicationFormData.data['listOfQuotation'][0];
  String productPlanType = qtn['productPlanLOB'];
  ProductPlanType? type;
  if (productPlanType.contains('investmentLink')) {
    type = ProductPlanType.investmentLink;
  } else {
    type = ProductPlanType.traditional;
  }

  List<ProductPlan> productSetup =
      await ProductPlanRepositoryImpl().getProductPlanSetup(type: type);

  // // We need to check what if the block country for this plan (if any)
  // // The data is based on product, but currently it is same for all (IL / Traditional)
  // // So we just check for the first data, and use the block country.
  ProductPlan plan = productSetup[0];

  // String blockCountry = plan.productSetup.blockedCountry;
  String? blockCountry = plan.productSetup?.blockedCountry;
  List<String> blockedCountries = [];

  if (blockCountry != null && blockCountry != "") {
    blockedCountries = blockCountry.split(',');
  }

  isBlock = blockedCountries.contains(selectionNationality);

  return isBlock;
}
