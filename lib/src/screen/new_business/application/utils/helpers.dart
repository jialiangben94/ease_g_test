import 'dart:convert';
import 'dart:math';

import 'package:ease/src/data/new_business_model/master_lookup.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_mapping.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/application/utils/tsarvalidation.dart';
import 'package:ease/src/service/vpms_mapping_helper.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

var options = {};

String? getLabel(String type, String callValue) {
  String text = "";
  var translations = ApplicationFormData.translation;
  int languageId = ApplicationFormData.languageId ?? 1;

  if (callValue.isNotEmpty) {
    var translation = translations.firstWhere(
        (element) =>
            element.primaryKey == type &&
            element.field == callValue &&
            element.languageId == languageId,
        orElse: () => TranslationLookUp(text: ""));
    text = translation.text!;
  }
  return text;
}

dynamic getMasterlookup({type, value = "", remark}) {
  if (options.isEmpty && ApplicationFormData.optionList != null) {
    options["BankList"] = [];
    for (var i = 0; i < ApplicationFormData.optionList.length; i++) {
      if (ApplicationFormData.optionList[i]["BankCode"] != null) {
        options["BankList"].add({
          "id": ApplicationFormData.optionList[i]["Id"],
          "callValue": ApplicationFormData.optionList[i]["BankCode"],
          "label": ApplicationFormData.optionList[i]["Name"],
          "value": ApplicationFormData.optionList[i]["BankCode"],
          "AccountTypeCode": ApplicationFormData.optionList[i]
              ["AccountTypeCode"],
          "AccountNumLength": ApplicationFormData.optionList[i]
              ["AccountNumLength"],
          "remark": "",
          "active": true
        });
      }

      for (var e = 0; e < ApplicationFormData.optionType.length; e++) {
        if (ApplicationFormData.optionType[e]["Name"] == "Bank" &&
            ApplicationFormData.optionList[i]["TypeId"] == null) {
          options["Bank"].add({
            "id": ApplicationFormData.optionList[i]["Id"],
            "callValue": ApplicationFormData.optionList[i]["BankCode"],
            "label": ApplicationFormData.optionList[i]["Name"],
            "value": ApplicationFormData.optionList[i]["BankCode"],
            "AccountTypeCode": ApplicationFormData.optionList[i]
                ["AccountTypeCode"],
            "AccountNumLength": ApplicationFormData.optionList[i]
                ["AccountNumLength"],
            "remark": "",
            "active": true
          });
        }
        if (ApplicationFormData.optionList[i]["TypeId"] ==
            ApplicationFormData.optionType[e]["Id"]) {
          if (options[ApplicationFormData.optionType[e]["Name"]] == null) {
            options[ApplicationFormData.optionType[e]["Name"]] = [];
          }
          options[ApplicationFormData.optionType[e]["Name"]].add({
            "id": ApplicationFormData.optionList[i]["Id"],
            "callValue": ApplicationFormData.optionList[i]["CallValue"],
            "label": ApplicationFormData.optionList[i]["Name"],
            "value": ApplicationFormData.optionList[i]["CallValue"],
            "remark": ApplicationFormData.optionList[i]["Remark"],
            "active": ApplicationFormData.optionList[i]["IsActive"]
          });
        }
      }
    }
  }

  if (type != null && value != "") {
    Map<dynamic, dynamic>? obj = {};
    if (options[type] != null) {
      for (var i = 0; i < options[type].length; i++) {
        if (options[type][i]["value"] == value) {
          obj = options[type][i];
          break;
        }
      }
    }
    return obj;
  }

  if (remark != null && remark is List && type != null) {
    var array = [];
    if (options[type] != null) {
      for (var i = 0; i < options[type].length; i++) {
        if (remark.contains(options[type][i]["remark"])) {
          array.add(options[type][i]);
        }
      }
    }
    return array;
  }

  if (value == null) {
    return {};
  }

  if (type != null) {
    if (options[type] != null) {
      options[type].forEach((e) {
        String? label = getLabel(
            type == "BankList" ? "Bank" : type, e["callValue"] ?? "NULL");
        if (label != null && label != "") {
          e["label"] = label;
        }
      });
      return options[type];
    }
    return {};
  }

  return options;
}

bool checkQuesSatisfy() {
  var blnAnswer = true;

  var p = ApplicationFormData.data["listOfQuotation"][0];
  String prodCode = p["productPlanCode"];
  dynamic qsetup =
      questionSetup.firstWhere((element) => element["ProdCode"] == prodCode);

  var questRulesStr = qsetup["validateRules"];
  var questValStr = questRulesStr.split("|");

  questValStr.forEach((item) {
    var quesNoMother = item.split("*")[0];
    var quesNoCheck = item.split("*")[1];
    var liq = ApplicationFormData.data["liquestions"];
    var poq = ApplicationFormData.data["poquestion"];

    if (liq[quesNoMother] != null &&
        liq[quesNoMother]["AnswerValue"] == true &&
        liq[quesNoCheck] != null &&
        liq[quesNoMother]["AnswerValue"] == false) {
      blnAnswer = false;
    }

    if (blnAnswer && poq != null) {
      if (poq[quesNoMother] != null &&
          poq[quesNoMother]["AnswerValue"] == true &&
          poq[quesNoCheck] != null &&
          poq[quesNoMother]["AnswerValue"] == false) {
        blnAnswer = false;
      }
    }
  });

  return blnAnswer;
}

dynamic submitUnderWritingWS(data, QuickQuotation quickQuotation,
    {String? totalPremium,
    bool getQuotationHistoryID = true,
    bool isCallVPMS = true}) async {
  ApplicationFormData.data["isFirstQuote"] =
      data["isRequote"] != null ? !data["isRequote"] : true;

  var apijson = await getTsarReqObj(quickQuotation,
      getQuotationHistoryID: getQuotationHistoryID, totalPremium: totalPremium);

  var tsarobj = {
    "Method": "POST",
    "Param": {"ValidateType": "TSAR"},
    "Body": {"Validate": apijson, "IsCallVPMS": isCallVPMS}
  };
  try {
    return await NewBusinessAPI().validation(tsarobj, setID: apijson["SetID"]);
  } catch (e) {
    rethrow;
  }
}

Future<bool> validateBeforeRoute(obj, context) async {
  var data = ApplicationFormData.data;

  if (obj["route"] == ApplicationFormData.tabList["questions"]["route"]) {
    if (!ApplicationFormData.tabList["customer"]["completed"] ||
        !ApplicationFormData.tabList["products"]["completed"] ||
        !ApplicationFormData.tabList["disclosure"]["completed"] ||        
        !ApplicationFormData.tabList["financial"]["completed"] || 
        !ApplicationFormData.tabList["nomination"]["completed"] ||
        !ApplicationFormData.tabList["benefitOwner"]["completed"]) {
      showAlertDialog2(
          context,
          getLocale("Questions not ready yet"),
          getLocale(
              'Please complete all the above tabs before continue to Questions.'));
      return false;
    } else {
      setQtype(context);
    }
  }

  if (obj["route"] == ApplicationFormData.tabList["decision"]["route"] &&
      (!ApplicationFormData.tabList["customer"]["completed"] ||
          !ApplicationFormData.tabList["products"]["completed"] ||
          !ApplicationFormData.tabList["disclosure"]["completed"] ||
          !ApplicationFormData.tabList["financial"]["completed"] ||
          !ApplicationFormData.tabList["questions"]["completed"] ||
          !ApplicationFormData.tabList["nomination"]["completed"] ||
          !ApplicationFormData.tabList["benefitOwner"]["completed"] ||
          (ApplicationFormData.tabList["questionsPolicyOwner"]["enable"] &&
              !ApplicationFormData.tabList["questionsPolicyOwner"]
                  ["completed"]))) {
    showAlertDialog2(
        context,
        getLocale("Assessment not yet ready"),
        getLocale(
            'Please complete all the above tabs before continue to Assessment.'));
    return false;
  } else if (obj["route"] == ApplicationFormData.tabList["decision"]["route"] &&
      (data["decision"] == null || data["caseindicator"] == null)) {
    try {
      startLoading(context);

      var p = data["listOfQuotation"][0];
      QuickQuotation quickqtn = QuickQuotation.fromMap(p);
      String prodCode = quickqtn.productPlanCode!;

      if (data["forceRequote"] != null && data["forceRequote"]) {
        stopLoading(context);
        showAlertDialog3(
            context,
            getLocale("Oops, there seems to be an issue."),
            "${getLocale("requote_a")}${toRM(data["prodLimit"], rm: true)}${getLocale("requote_b")}");
        return false;
      } else {
        var blnQuesSatisfy = false;

        if (prodCode.contains("PCHI") || prodCode == "PTWA03") {
          blnQuesSatisfy = checkQuesSatisfy();

          if (blnQuesSatisfy == true) {
            var res = await submitUnderWritingWS(data, quickqtn);
            ApplicationFormData.data["tsarRes"] = res;
            ApplicationFormData.data["SetID"] = res["SetID"];
            stopLoading(context);
          } else {
            stopLoading(context);
            showAlertDialog3(
                context,
                getLocale("Oops, there seems to be an issue."),
                getLocale("invalidQuestionnaire"));
            return false;
          }
        } else if (prodCode == "PCTA01" ||
            prodCode == "PCWA01" ||
            prodCode == "PCEL01" ||
            prodCode == "PCEE01" ||
            prodCode == "PTJI01" ||
            prodCode == "PTHI01" ||
            prodCode == "PTHI02") {
          ApplicationFormData.tabList["decision"]["completed"] = true;
          if (data != null && data["listOfQuotation"] != null) {
            ApplicationFormData.tabList["decision"]["payAmount"] =
                data["listOfQuotation"][0]["totalPremium"];
            Random random = Random();
            var now = DateTime.now();
            String formattedDate = DateFormat('yyMMdd').format(now);
            var pref = await SharedPreferences.getInstance();
            Agent nagent =
                Agent.fromJson(json.decode(pref.getString(spkAgent)!));
            String newSetID = nagent.accountCode! +
                formattedDate +
                random.nextInt(9999999).toString();
            ApplicationFormData.data["SetID"] = newSetID;
            ApplicationFormData.data["appStatus"] =
                AppStatus.assessed.toString();
            ApplicationFormData.data["assessmentDate"] = getTimestamp();
          }
          stopLoading(context);
        } else {
          var res = await submitUnderWritingWS(data, quickqtn);
          ApplicationFormData.data["tsarRes"] = res;
          ApplicationFormData.data["SetID"] = res["SetID"];
          stopLoading(context);
        }
      }

      if (ApplicationFormData.data["tsarRes"] != null) {
        bool? isValid =
            await tsarValidate(ApplicationFormData.data, context) ?? true;
        if (isValid) {
          var product = ApplicationFormData.data["listOfQuotation"][0];
          ApplicationFormData.data["decision"] = {
            "payAmount": product["premAmt"]
          };
          ApplicationFormData.data["appStatus"] = AppStatus.assessed.toString();
          ApplicationFormData.data["assessmentDate"] = getTimestamp();
        }
        return isValid;
      }
    } catch (e) {
      stopLoading(context);
      if (e is AppCustomException) {
        showAlertDialog(
            context, getLocale("Oops, there seems to be an issue."), e.message);
      } else {
        showAlertDialog(context, getLocale("Oops, there seems to be an issue."),
            e.toString());
      }
      return false;
    }
  } else {
    // log(jsonEncode(await getTsarReqObj(setID: data["SetID"])));
  }

  if (obj["route"] == ApplicationFormData.tabList["declaration"]["route"] &&
      (!ApplicationFormData.tabList["customer"]["completed"] ||
          !ApplicationFormData.tabList["products"]["completed"] ||
          !ApplicationFormData.tabList["questions"]["completed"] ||
          (ApplicationFormData.tabList["decision"]["enable"] &&
              !ApplicationFormData.tabList["decision"]["completed"]))) {
    showAlertDialog2(
        context,
        getLocale("Declaration not yet ready"),
        getLocale(
            "Please complete all the above tabs before continue to Declaration."));
    return false;
  }

  // log(jsonEncode(await clientjson()));
  var hideNominee = hideTrustee(data);
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

  if (obj["route"] == ApplicationFormData.tabList["payment"]["route"] &&
      ((ApplicationFormData.tabList["decision"]["enable"] &&
              !ApplicationFormData.tabList["decision"]["completed"]) ||
          !completeDeclaration)) {
    showAlertDialog2(
        context,
        getLocale("Payment not yet ready"),
        getLocale(
            "Please complete all the above tabs before continue to payment."));
    return false;
  }

  if (obj["route"] == ApplicationFormData.tabList["remote"]["route"] &&
      (data["decision"] == null ||
          data["declaration"] == null ||
          data["witness"] == null ||
          data["agent"] == null)) {
    showAlertDialog2(
        context,
        getLocale("Remote not yet ready"),
        getLocale(
            "Please complete all the above tabs before continue to Remote."));
    return false;
  }

  return true;
}

Future<bool> needRecalculate(data) async {
  if (data != null &&
      data["policyOwner"] != null &&
      data["lifeInsured"] != null &&
      data["povpmsocc"] != null) {
    if (data["povpmsocc"] != data["policyOwner"]["occupation"]) return true;
    if (data["povpmsage"] != data["policyOwner"]["age"]) return true;
    if (data["povpmssmoke"] != data["policyOwner"]["smoking"]) return true;
    if (data["povpmsgender"] != data["policyOwner"]["gender"]) return true;
    if (data["livpmsocc"] != data["lifeInsured"]["occupation"]) return true;
    if (data["livpmsage"] != data["lifeInsured"]["age"]) return true;
    if (data["livpmssmoke"] != data["lifeInsured"]["smoking"]) return true;
    if (data["livpmsgender"] != data["lifeInsured"]["gender"]) return true;
  }

  if (data != null && data["listOfQuotation"] != null) {
    var p = data["listOfQuotation"][0];
    var temp2 = json.decode(json.encode(p));
    temp2 = QuickQuotation.fromMap(temp2);
    VpmsMapping vpmsMappingFile = await getVPMSMappingData(
        temp2.productPlanCode == "PCHI04" ? "PCHI03" : temp2.productPlanCode);
    var vpmslanguage = vpmsMappingFile.basicInput!.language ?? "A_Language";

    var vpmsin = temp2.vpmsinput ?? [];
    var prefLang = "";

    for (var element in vpmsin) {
      if (element.isNotEmpty) {
        if (element[0] == vpmslanguage && element[1] != null) {
          prefLang = element[1];
        }
      }
    }

    prefLang = prefLang == "E"
        ? "ENG"
        : prefLang == "B"
            ? "BMY"
            : "ENG";

    if (data["lifeInsured"] != null &&
        data["lifeInsured"]["preferlanguage"] != null &&
        prefLang != data["lifeInsured"]["preferlanguage"]) {
      return true;
    }
  }
  return false;
}
