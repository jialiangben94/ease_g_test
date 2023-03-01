import 'dart:convert';

import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/application/questions/questionbloc/question_bloc.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String tsarKey(String key) {
  return "<$key>k__BackingField";
}

String convertTSARKey(String key) {
  return key.replaceAll("<", "").replaceAll(">k__BackingField", "");
}

dynamic filterTSARResponse(obj) {
  dynamic tsarRes = {};
  for (var key in obj.keys) {
    var newkey = convertTSARKey(key);
    tsarRes[newkey] = obj[key];
  }
  return tsarRes;
}

formatTSARInput(lstTsarVpms) {
  if (lstTsarVpms != null) {
    var vpmsin = [];
    lstTsarVpms.forEach((item) {
      item = filterTSARResponse(item);
      vpmsin.add(item);
    });
    ApplicationFormData.data["TSARVPMSInput"] = vpmsin;
  } else {
    ApplicationFormData.data["TSARVPMSInput"] = null;
  }
}

formatTSAROutput(lstTsarVpms) {
  if (lstTsarVpms != null) {
    var vpmsout = [];
    lstTsarVpms.forEach((item) {
      item = filterTSARResponse(item);
      var objResult = {
        "ClientType": item["ClientType"],
        "Version": item["VPMSOutput"]["P_UW_Version"],
        "Reason": item["VPMSOutput"]["P_L_UW_Reason"],
        "ReasonInd": item["VPMSOutput"]["P_L_UW_IND"]
      };
      vpmsout.add(objResult);
    });
    ApplicationFormData.data["TSARVPMSOutput"] = vpmsout;
  } else {
    ApplicationFormData.data["TSARVPMSOutput"] = null;
  }
}

dynamic getProductSpec(String prodCode) async {
  dynamic prodspec;
  String plan = await rootBundle.loadString('assets/files/lookupfixed.json');
  final dataPlan = jsonDecode(plan);
  if (dataPlan != null) {
    prodspec = dataPlan["ProductSpec"]
        .firstWhere((element) => element["ProdCode"] == prodCode);
  }
  return prodspec;
}

bool getProductCallOnlineVPMS(prodCode) {
  bool blnCallOnlineVPMS = false;
  switch (prodCode) {
    case "PCWI03": // Securelink
      blnCallOnlineVPMS = true;
      break;
    case "PCHI03": // Maxipro (IL Savings)
      blnCallOnlineVPMS = true;
      break;
    case "PCHI04": // Maxipro
      blnCallOnlineVPMS = true;
      break;
    case "PCJI02": // Megaplus
      blnCallOnlineVPMS = true;
      break;
    case "PTWI03": // Eliteplus
      blnCallOnlineVPMS = true;
      break;
    case "PCTA01": // Etiqa Life Secure
      blnCallOnlineVPMS = true;
      break;
    case "PCWA01": // Enrich Life Plan
      blnCallOnlineVPMS = true;
      break;
    default:
      blnCallOnlineVPMS = false;
  }
  return blnCallOnlineVPMS;
}

void setQtype(context) {
  if (ApplicationFormData.data["tsarqtype"] == null) {
    String? qtype;
    var p = ApplicationFormData.data["listOfQuotation"][0];
    String prodCode = p["productPlanCode"];
    dynamic qsetup =
        questionSetup.firstWhere((element) => element["ProdCode"] == prodCode);
    var riders = p["riderOutputDataList"]
        .where((element) => element["riderCode"] != prodCode)
        .toList();
    if (riders.length > 0) {
      qtype = qsetup["Type"][0]["riderQuest"];
    } else {
      qtype = qsetup["Type"][0]["gpQuest"];
    }
    ApplicationFormData.data["qtype"] = qtype;
    BlocProvider.of<QuestionBloc>(context).add(SetQuestionType(qtype!));
  } else {
    ApplicationFormData.data["qtype"] = ApplicationFormData.data["tsarqtype"];
    BlocProvider.of<QuestionBloc>(context)
        .add(SetQuestionType(ApplicationFormData.data["tsarqtype"]));
  }
}

Future<bool?> tsarValidate(data, context) async {
  var p = data["listOfQuotation"][0];
  QuickQuotation quickqtn = QuickQuotation.fromMap(p);
  String prodCode = quickqtn.productPlanCode!;
  var objProdSpec = await getProductSpec(prodCode);
  String? qtype = data["qtype"];

  bool blnIsCallOnlineVpms = getProductCallOnlineVPMS(prodCode);

  var tsarResult = data["tsarRes"];
  var tsarWSResult = filterTSARResponse(tsarResult["TSARWSResult"]);

  // ElitePlus: blocking substandard case if ad hoc topup is available
  if (prodCode == "PTWI03" &&
      tsarResult["VPMSFailAA"] &&
      quickqtn.adhocAmt != null &&
      quickqtn.adhocAmt != "0") {
    showAlertDialog4(context, "This proposal require underwriting assessment",
        "Kindly remove Ad Hoc Top-up in order to proceed submission");
    return false;
  }

  if (objProdSpec["RuleSetup"]["IsEnabled"]) {
    if (objProdSpec["RuleSetup"]["IsGA"]) {
      if (tsarResult["Type"] == "1") {
        data["forceRequote"] = tsarWSResult["ReqRequote"];
        data["requoteAmt"] = tsarWSResult["RequoteAmt"];

        data["FailNation"] = tsarWSResult["GAFailNation"];
        dynamic failProductLimits;
        if (tsarWSResult["FailProductLimits"] != null &&
            tsarWSResult["FailProductLimits"].length > 0) {
          failProductLimits = tsarWSResult["FailProductLimits"][0];
        }

        if (tsarWSResult["ReqGA"]) {
          data["UWPropKIVStatus"] = uwPropKIVStatus["Standard"];

          //Mawaddah & Protect88
          if (prodCode == "PTWE04" ||
              prodCode == "PTWE05" ||
              prodCode == "PCWA02") {
            ApplicationFormData.data["caseindicator"] = "UWCaseStandard";
          } else {
            ApplicationFormData.data["caseindicator"] = "GIOCase";
          }
        } else {
          // Check ROP
          if (tsarWSResult["ReqROPQuestion"] == true) {
            if (qtype == questionType["IsFullQuest"].toString()) {
              data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
              if (blnIsCallOnlineVpms) {
                formatTSARInput(tsarResult["lstTsarVpmsField"]);
                formatTSAROutput(tsarResult["lstTsarVpmsField"]);
              }
              ApplicationFormData.data["caseindicator"] = "NonGIOCase";
            } else if (qtype == questionType["IsROPSimplified"].toString()) {
              if (data["forceRequote"]) {
                if (data["isFirstQuote"]) {
                  dynamic saLimit;
                  double? limit = 200000;
                  ProductPlan? productPlan = await ProductPlanRepositoryImpl()
                      .getProductPlanSetupByProdCode(
                          prodCode == "PCHI04" ? "PCHI03" : prodCode);
                  if (productPlan != null &&
                      productPlan.gaProductList!.isNotEmpty) {
                    limit = productPlan.gaProductList![0].prodLimit;
                  }

                  if (data["FailNation"]) {
                    var tempLimit = data["requoteAmt"] - limit;
                    if (tempLimit > limit) {
                      saLimit = 0;
                    } else {
                      saLimit = limit! - tempLimit;
                    }
                  } else {
                    if (data["requoteAmt"] > limit) {
                      saLimit = 0;
                    } else {
                      saLimit = limit! - data["requoteAmt"];
                    }
                  }

                  ApplicationFormData.data["tsarqtype"] =
                      questionType["IsROPSimplified"].toString();
                  BlocProvider.of<QuestionBloc>(context).add(SetQuestionType(
                      questionType["IsROPSimplified"].toString()));

                  data["prodLimit"] = saLimit;
                  data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                  showAlertDialog3(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      "${getLocale("requote_a")}${toRM(saLimit, rm: true)}${getLocale("requote_b")}");
                  return false;
                } else {
                  ApplicationFormData.data["tsarqtype"] =
                      questionType["IsFullQuest"].toString();
                  BlocProvider.of<QuestionBloc>(context).add(
                      SetQuestionType(questionType["IsFullQuest"].toString()));

                  data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                  data["qtype"] = questionType["IsFullQuest"].toString();

                  showAlertDialog3(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      getLocale("ropFullQuestionsNeeded").replaceAll(
                          "%s", getLocale('Life Insured', entity: true)));
                  return false;
                }
              } else {
                ApplicationFormData.data["tsarqtype"] =
                    questionType["IsFullQuest"].toString();
                BlocProvider.of<QuestionBloc>(context).add(
                    SetQuestionType(questionType["IsFullQuest"].toString()));

                data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                data["qtype"] = questionType["IsFullQuest"].toString();

                showAlertDialog2(
                    context,
                    getLocale("Oops, there seems to be an issue."),
                    getLocale("ropFullQuestionsNeeded").replaceAll(
                        "%s", getLocale('Life Insured', entity: true)));
                return false;
              }
            }
          } else {
            //START FTA UW rules
            if (tsarWSResult["ReqGAShowMsg"]) {
              var strMsgCompleteFailReason = "", strMsgFail = "";

              if (prodCode == "PTWE04") {
                //for mawaddah
                var minSA = quickqtn.minsa;
                if (failProductLimits["AvailLimit"] < minSA) {
                  //100000 is minimum for mawaddah SA
                  if (failProductLimits["AvailLimit"] != null &&
                      failProductLimits["AvailLimit"] != 0 &&
                      failProductLimits["AvailLimit"] != "") {
                    showAlertDialog3(
                        context,
                        getLocale("Oops, there seems to be an issue."),
                        getLocale("ftauw1").replaceAll("%s",
                            toRM(failProductLimits["AvailLimit"], rm: true)));
                    return false;
                  } else {
                    showAlertDialog3(
                        context,
                        getLocale("Oops, there seems to be an issue."),
                        getLocale("ftauw1").replaceAll("%s", "RM 0.00"));
                    return false;
                  }
                } else {
                  showAlertDialog3(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      getLocale("ftauw2").replaceAll("%s", "RM 0.00"));
                  return false;
                }
              } else {
                if (tsarResult != null) {
                  if (tsarWSResult["FailProductLimits"].length > 0) {
                    tsarWSResult["FailProductLimits"].forEach((item) {
                      strMsgFail = "";

                      var minSA = quickqtn.minsa;

                      if (failProductLimits["AvailLimit"] > 0) {
                        if (failProductLimits["AvailLimit"] < minSA) {
                          //50000 is minimum for protect88 SA
                          if (failProductLimits["AvailLimit"] != null &&
                              failProductLimits["AvailLimit"] != 0 &&
                              failProductLimits["AvailLimit"] != "") {
                            var msg = getLocale("pro88uw1");
                            strMsgCompleteFailReason = msg
                                .replaceAll("%a", toRM(minSA, rm: true))
                                .replaceAll(
                                    "%b",
                                    toRM(failProductLimits["AvailLimit"],
                                        rm: true));
                          } else {
                            var msg = getLocale("pro88uw1");
                            strMsgCompleteFailReason = msg
                                .replaceAll("%a", toRM(minSA, rm: true))
                                .replaceAll("%b", "RM 0.00");
                          }
                        } else {
                          var msg = getLocale("pro88uw1");
                          strMsgCompleteFailReason = msg
                              .replaceAll(
                                  "%a",
                                  toRM(failProductLimits["AvailLimit"],
                                      rm: true))
                              .replaceAll("%b", toRM(minSA, rm: true))
                              .replaceAll(
                                  "%c",
                                  toRM(failProductLimits["AvailLimit"],
                                      rm: true));
                        }
                      }

                      if (item["FailProdLimitMessage"] != null &&
                          item["FailProdLimitMessage"].toString() != "") {
                        strMsgFail = "";
                        switch (item["FailProdLimitMessage"].toString()) {
                          case "FAIL002":
                            strMsgFail = getLocale("uwFail002");
                            break;
                          case "FAIL005":
                            strMsgFail = getLocale("uwFail005");
                            break;
                          case "FAIL006":
                            strMsgFail = getLocale("uwFail006");
                            break;
                          default:
                            break;
                        }
                      }

                      if (strMsgCompleteFailReason == "") {
                        strMsgCompleteFailReason += strMsgFail;
                      } else {
                        strMsgCompleteFailReason += "\n";
                        strMsgCompleteFailReason += strMsgFail;
                      }
                    });
                  }
                }

                if (strMsgCompleteFailReason != "") {
                  showAlertDialog3(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      strMsgCompleteFailReason);
                  return false;
                } else {
                  showAlertDialog3(
                      context,
                      getLocale("Oops, there seems to be an issue."),
                      getLocale("failProductLimit"));
                  return false;
                }
              }
            }
          }
        }
      }
    } else if (objProdSpec["RuleSetup"]["IsProductLimit"]) {
      if (tsarResult["Type"] == "2") {
        if (!tsarWSResult["ReqProductLimit"]) {
          if (blnIsCallOnlineVpms) {
            formatTSARInput(tsarResult["lstTsarVpmsField"]);
            formatTSAROutput(tsarResult["lstTsarVpmsField"]);
          }

          if (tsarResult["VPMSFailAA"]) {
            data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
            //securelink
            if (prodCode == "PCWI03" || prodCode == "PTWI03") {
              ApplicationFormData.data["caseindicator"] = "UWCaseSubStandard";
            } else {
              ApplicationFormData.data["caseindicator"] = "subStandardCase";
            }
          } else {
            data["UWPropKIVStatus"] = uwPropKIVStatus["Standard"];
            if (prodCode == "PCWI03" || prodCode == "PTWI03") {
              ApplicationFormData.data["caseindicator"] = "UWCaseStandard";
            } else {
              ApplicationFormData.data["caseindicator"] = "entitledPurchase";
            }
          }
        } else {
          var strMsgFailReason = "",
              strMsgFail = "",
              strClientType = "",
              strFspName = "";

          if (tsarResult != null) {
            bool tsarMedicalFailed = false;
            if (tsarWSResult["FailProductLimits"].length > 0) {
              tsarWSResult["FailProductLimits"].forEach((item) {
                item = filterTSARResponse(item);

                if (item["FspName"].contains("Medical Plus")) {
                  tsarMedicalFailed = true;
                }

                strMsgFail = "";
                strClientType = "";
                strFspName = "";
                var strAvailLimit = "";

                if (item["ClientType"] == lookupClientType["poli"]) {
                  strClientType = getLocale("Life Insured", entity: true);
                } else if (item["ClientType"] ==
                    lookupClientType["policyOwner"]) {
                  strClientType = getLocale("Policy Owner", entity: true);
                } else if (item["ClientType"] ==
                    lookupClientType["lifeInsured"]) {
                  strClientType = getLocale("Life Insured", entity: true);
                }

                if (item["FailProdLimitMessage"].toString() == "") {
                  strFspName = item["FspName"].toUpperCase();
                  strAvailLimit = item["AvailLimit"].toString();

                  var msg = getLocale("uwFailLimit");
                  msg = msg
                      .replaceAll("%a", strFspName)
                      .replaceAll("%b", strAvailLimit);
                  strMsgFail = "($strClientType) $msg";

                  if (strMsgFailReason == "") {
                    strMsgFailReason += strMsgFail;
                  } else {
                    strMsgFailReason += "\n";
                    strMsgFailReason += strMsgFail;
                  }
                } else {
                  strMsgFailReason =
                      "($strClientType) ${item["FailProdLimitMessage"].toString()}";
                }
              });
            }
            if (tsarMedicalFailed) {
              showAlertDialog2(
                  context,
                  getLocale("Oops, there seems to be an issue."),
                  strMsgFailReason != ""
                      ? strMsgFailReason
                      : getLocale("failProductLimit"), () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (route) => false);
              });
            } else {
              if (tsarResult["VPMSFailAA"]) {
                data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                //securelink
                if (prodCode == "PCWI03" || prodCode == "PTWI03") {
                  ApplicationFormData.data["caseindicator"] =
                      "UWCaseSubStandard";
                } else {
                  ApplicationFormData.data["caseindicator"] = "subStandardCase";
                }
              } else {
                data["UWPropKIVStatus"] = uwPropKIVStatus["Standard"];
                if (prodCode == "PCWI03" || prodCode == "PTWI03") {
                  ApplicationFormData.data["caseindicator"] = "UWCaseStandard";
                } else {
                  ApplicationFormData.data["caseindicator"] =
                      "entitledPurchase";
                }
              }
            }
          } else {
            showAlertDialog3(
                context,
                getLocale("Oops, there seems to be an issue."),
                strMsgFailReason != ""
                    ? strMsgFailReason
                    : getLocale("failProductLimit"));
            return false;
          }
        }
      }
    }
  }

  if (prodCode == "PCWI03" || prodCode == "PTWI03") {
    var blnFailGA = checkFailGA(prodCode, tsarWSResult);

    if (blnFailGA) {
      switch (prodCode) {
        case "PCWI03":
        case "PTWI03":
          quickqtn.totalPremium = quickqtn.totalPremium;
          break;
      }
    }
  }

  data["listOfQuotation"] = [quickqtn.toMap()];
  ApplicationFormData.data = data;
  return null;
}

dynamic tsarValidate2(data, quickqtn, tsarResult) async {
  String prodCode = quickqtn.productPlanCode!;
  var objProdSpec = await getProductSpec(prodCode);

  if (data["tsarqtype"] == null) {
    String? qtype;
    dynamic qsetup =
        questionSetup.firstWhere((element) => element["ProdCode"] == prodCode);
    var riderOutputDataList = quickqtn.riderOutputDataList != null
        ? quickqtn.riderOutputDataList!
            .map((data) => data.toMap())
            .toList(growable: false)
        : [];
    var riders = riderOutputDataList
        .where((element) => element["riderCode"] != prodCode)
        .toList();
    if (riders.length > 0) {
      qtype = qsetup["Type"][0]["riderQuest"];
    } else {
      qtype = qsetup["Type"][0]["gpQuest"];
    }
    data["qtype"] = qtype;
  } else {
    data["qtype"] = data["tsarqtype"];
  }

  String? qtype = data["qtype"];

  var tsarWSResult = filterTSARResponse(tsarResult["TSARWSResult"]);
  if (objProdSpec["RuleSetup"]["IsEnabled"]) {
    if (objProdSpec["RuleSetup"]["IsGA"]) {
      if (tsarResult["Type"] == "1") {
        data["forceRequote"] = tsarWSResult["ReqRequote"];
        data["requoteAmt"] = tsarWSResult["RequoteAmt"];

        data["FailNation"] = tsarWSResult["GAFailNation"];
        dynamic failProductLimits;
        if (tsarWSResult["FailProductLimits"] != null &&
            tsarWSResult["FailProductLimits"].length > 0) {
          failProductLimits = tsarWSResult["FailProductLimits"][0];
        }

        if (tsarWSResult["ReqGA"]) {
          data["UWPropKIVStatus"] = uwPropKIVStatus["Standard"];

          //Mawaddah & Protect88
          if (prodCode == "PTWE04" ||
              prodCode == "PTWE05" ||
              prodCode == "PCWA02") {
            data["caseindicator"] = "UWCaseStandard";
          } else {
            data["caseindicator"] = "GIOCase";
          }
        } else {
          // Check ROP
          if (tsarWSResult["ReqROPQuestion"] == true) {
            if (qtype == questionType["IsFullQuest"].toString()) {
              data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
              data["caseindicator"] = "NonGIOCase";
            } else if (qtype == questionType["IsROPSimplified"].toString()) {
              if (data["forceRequote"]) {
                if (data["isFirstQuote"]) {
                  double? limit = 200000;
                  ProductPlan? productPlan = await ProductPlanRepositoryImpl()
                      .getProductPlanSetupByProdCode(
                          prodCode == "PCHI04" ? "PCHI03" : prodCode);
                  if (productPlan != null &&
                      productPlan.gaProductList!.isNotEmpty) {
                    limit = productPlan.gaProductList![0].prodLimit;
                  }
                  dynamic saLimit;

                  if (data["FailNation"]) {
                    double tempLimit = data["requoteAmt"] - limit;
                    if (tempLimit > limit!) {
                      saLimit = 0;
                    } else {
                      saLimit = limit - tempLimit;
                    }
                  } else {
                    if (data["requoteAmt"] > limit) {
                      saLimit = 0;
                    } else {
                      saLimit = limit! - data["requoteAmt"];
                    }
                  }

                  data["tsarqtype"] =
                      questionType["IsROPSimplified"].toString();
                  data["prodLimit"] = saLimit;
                  data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];

                  data["saLimit"] = saLimit;
                  return {
                    "data": data,
                    "quickqtn": quickqtn,
                    "error":
                        "${getLocale("requote_a")}${toRM(saLimit, rm: true)}${getLocale("requote_b")}"
                  };
                } else {
                  data["tsarqtype"] = questionType["IsFullQuest"].toString();
                  data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                  data["qtype"] = questionType["IsFullQuest"].toString();

                  return {
                    "data": data,
                    "quickqtn": quickqtn,
                    "error": getLocale("ropFullQuestionsNeeded").replaceAll(
                        "%s", getLocale('Life Insured', entity: true))
                  };
                }
              } else {
                data["tsarqtype"] = questionType["IsFullQuest"].toString();
                data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
                data["qtype"] = questionType["IsFullQuest"].toString();

                return {
                  "data": data,
                  "quickqtn": quickqtn,
                  "error": getLocale("ropFullQuestionsNeeded")
                      .replaceAll("%s", getLocale('Life Insured', entity: true))
                };
              }
            }
          } else {
            //START FTA UW rules
            if (tsarWSResult["ReqGAShowMsg"]) {
              var strMsgCompleteFailReason = "", strMsgFail = "";

              if (prodCode == "PTWE04") {
                //for mawaddah
                var minSA = quickqtn.minsa;
                if (failProductLimits["AvailLimit"] < minSA) {
                  //100000 is minimum for mawaddah SA
                  if (failProductLimits["AvailLimit"] != null &&
                      failProductLimits["AvailLimit"] != 0 &&
                      failProductLimits["AvailLimit"] != "") {
                    data["AvailLimit"] = failProductLimits["AvailLimit"];

                    return {
                      "data": data,
                      "quickqtn": quickqtn,
                      "error": getLocale("ftauw1").replaceAll(
                          "%s", toRM(failProductLimits["AvailLimit"], rm: true))
                    };
                  } else {
                    data["AvailLimit"] = 0;
                    return {
                      "data": data,
                      "quickqtn": quickqtn,
                      "error": getLocale("ftauw1").replaceAll("%s", "RM 0.00")
                    };
                  }
                } else {
                  data["AvailLimit"] = 0;
                  return {
                    "data": data,
                    "quickqtn": quickqtn,
                    "error": getLocale("ftauw2").replaceAll("%s", "RM 0.00")
                  };
                }
              } else {
                if (tsarResult != null) {
                  if (tsarWSResult["FailProductLimits"].length > 0) {
                    tsarWSResult["FailProductLimits"].forEach((item) {
                      strMsgFail = "";

                      var minSA = quickqtn.minsa;

                      if (failProductLimits["AvailLimit"] > 0) {
                        if (failProductLimits["AvailLimit"] < minSA) {
                          //50000 is minimum for protect88 SA
                          if (failProductLimits["AvailLimit"] != null &&
                              failProductLimits["AvailLimit"] != 0 &&
                              failProductLimits["AvailLimit"] != "") {
                            data["AvailLimit"] =
                                failProductLimits["AvailLimit"];
                            var msg = getLocale("pro88uw1");
                            strMsgCompleteFailReason = msg
                                .replaceAll("%a", toRM(minSA, rm: true))
                                .replaceAll(
                                    "%b",
                                    toRM(failProductLimits["AvailLimit"],
                                        rm: true));
                          } else {
                            data["AvailLimit"] = 0;
                            var msg = getLocale("pro88uw1");
                            strMsgCompleteFailReason = msg
                                .replaceAll("%a", toRM(minSA, rm: true))
                                .replaceAll("%b", "RM 0.00");
                          }
                        } else {
                          data["AvailLimit"] = failProductLimits["AvailLimit"];
                          var msg = getLocale("pro88uw1");
                          strMsgCompleteFailReason = msg
                              .replaceAll(
                                  "%a",
                                  toRM(failProductLimits["AvailLimit"],
                                      rm: true))
                              .replaceAll("%b", toRM(minSA, rm: true))
                              .replaceAll(
                                  "%c",
                                  toRM(failProductLimits["AvailLimit"],
                                      rm: true));
                        }
                      }

                      if (item["FailProdLimitMessage"] != null &&
                          item["FailProdLimitMessage"].toString() != "") {
                        strMsgFail = "";
                        switch (item["FailProdLimitMessage"].toString()) {
                          case "FAIL002":
                            strMsgFail = getLocale("uwFail002");
                            break;
                          case "FAIL005":
                            strMsgFail = getLocale("uwFail005");
                            break;
                          case "FAIL006":
                            strMsgFail = getLocale("uwFail006");
                            break;
                          default:
                            break;
                        }
                      }

                      if (strMsgCompleteFailReason == "") {
                        strMsgCompleteFailReason += strMsgFail;
                      } else {
                        strMsgCompleteFailReason += "\n";
                        strMsgCompleteFailReason += strMsgFail;
                      }
                    });
                  }
                }

                if (strMsgCompleteFailReason != "") {
                  return {
                    "data": data,
                    "quickqtn": quickqtn,
                    "error": strMsgCompleteFailReason
                  };
                } else {
                  return {
                    "data": data,
                    "quickqtn": quickqtn,
                    "error": getLocale("failProductLimit")
                  };
                }
              }
            }
          }
        }
      }
    } else if (objProdSpec["RuleSetup"]["IsProductLimit"]) {
      if (tsarResult["Type"] == "2") {
        if (!tsarWSResult["ReqProductLimit"]) {
          if (tsarResult["VPMSFailAA"]) {
            data["UWPropKIVStatus"] = uwPropKIVStatus["PR"];
            //securelink
            if (prodCode == "PCWI03" || prodCode == "PTWI03") {
              data["caseindicator"] = "UWCaseSubStandard";
            } else {
              data["caseindicator"] = "subStandardCase";
            }
          } else {
            data["UWPropKIVStatus"] = uwPropKIVStatus["Standard"];
            if (prodCode == "PCWI03" || prodCode == "PTWI03") {
              data["caseindicator"] = "UWCaseStandard";
            } else {
              data["caseindicator"] = "entitledPurchase";
            }
          }
        } else {
          var strMsgFailReason = "",
              strMsgFail = "",
              strClientType = "",
              strFspName = "";

          if (tsarResult != null) {
            bool tsarMedicalFailed = false;
            if (tsarWSResult["FailProductLimits"].length > 0) {
              tsarWSResult["FailProductLimits"].forEach((item) {
                item = filterTSARResponse(item);

                if (item["FspName"].contains("Medical Plus")) {
                  tsarMedicalFailed = true;
                }

                strMsgFail = "";
                strClientType = "";
                strFspName = "";
                var strAvailLimit = "";

                if (item["ClientType"] == lookupClientType["poli"]) {
                  strClientType = getLocale("Life Insured", entity: true);
                } else if (item["ClientType"] ==
                    lookupClientType["policyOwner"]) {
                  strClientType = getLocale("Policy Owner", entity: true);
                } else if (item["ClientType"] ==
                    lookupClientType["lifeInsured"]) {
                  strClientType = getLocale("Life Insured", entity: true);
                }

                if (item["FailProdLimitMessage"].toString() == "") {
                  strFspName = item["FspName"].toUpperCase();
                  strAvailLimit = item["AvailLimit"].toString();
                  data["AvailLimit"] = item["AvailLimit"];

                  var msg = getLocale("uwFailLimit");
                  msg = msg
                      .replaceAll("%a", strFspName)
                      .replaceAll("%b", strAvailLimit);
                  strMsgFail = "($strClientType) $msg";

                  if (strMsgFailReason == "") {
                    strMsgFailReason += strMsgFail;
                  } else {
                    strMsgFailReason += "\n";
                    strMsgFailReason += strMsgFail;
                  }
                } else {
                  strMsgFailReason =
                      "($strClientType) ${item["FailProdLimitMessage"].toString()}";
                }
              });
            }

            if (tsarMedicalFailed) {
              return {
                "data": data,
                "quickqtn": quickqtn,
                "error": strMsgFailReason != ""
                    ? strMsgFailReason
                    : getLocale("failProductLimit")
              };
            } else {
              return {
                "data": data,
                "quickqtn": quickqtn,
                "error": strMsgFailReason != ""
                    ? strMsgFailReason
                    : getLocale("failProductLimit")
              };
            }
          } else {
            return {
              "data": data,
              "quickqtn": quickqtn,
              "error": getLocale("failProductLimit")
            };
          }
        }
      }
    }
  }

  if (prodCode == "PCWI03" || prodCode == "PTWI03") {
    var blnFailGA = checkFailGA(prodCode, tsarWSResult);

    if (blnFailGA) {
      switch (prodCode) {
        case "PCWI03":
        case "PTWI03":
          quickqtn.totalPremium = quickqtn.totalPremium;
          break;
      }
    }
  }

  return {"data": data, "quickqtn": quickqtn};
}

bool checkFailGA(prodCode, tsarWSResult) {
  bool blnFailGA = false;

  if (prodCode == "PCWI03" ||
      prodCode == "PTWI03" ||
      prodCode == "PCHI03" ||
      prodCode == "PCHI04") {
    if (tsarWSResult["ReqGA"] != null &&
        tsarWSResult["ReqProductLimit"] != null &&
        tsarWSResult["ReqROPQuestion"] != null &&
        tsarWSResult["ReqLoad"] != null) {
      if (tsarWSResult["ReqGA"] == false && tsarWSResult["ReqLoad"] == true) {
        blnFailGA = true;
      }
    }
  }

  return blnFailGA;
}
