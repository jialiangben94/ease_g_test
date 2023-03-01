import 'dart:convert';

import 'package:ease/src/bloc/new_business/existing_customer_bloc/existing_customer_bloc.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/product_details.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecommendedProducts extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj, dynamic tempQuo) onChanged;

  const RecommendedProducts(
      {Key? key, this.obj, this.info, required this.onChanged})
      : super(key: key);
  @override
  RecommendedProductsState createState() => RecommendedProductsState();
}

class RecommendedProductsState extends State<RecommendedProducts>
    with SingleTickerProviderStateMixin {
  dynamic info;
  dynamic obj;
  dynamic summary;
  dynamic inputList;
  dynamic mapInfo;
  dynamic tempQuo;

  @override
  void initState() {
    super.initState();
    obj = widget.obj;
    info = widget.info;
    if (info["policyOwner"] == null) {
      info["policyOwner"] = {};
    }
    if (info["payor"] == null) {
      info["payor"] = {};
    }
    if (info["lifeInsured"] == null) {
      info["lifeInsured"] = {};
    }

    mapInfo = json.decode(json.encode(info));

    BlocProvider.of<ProductPlanBloc>(context)
        .add(const FilterProductPlanList(type: ProductPlanType.investmentLink));

    inputList = {
      "recommendreason": {
        "type": "text",
        "label": getLocale("State reason here"),
        "value": "",
        "enabled": false,
        "column": true,
        "size": {"textWidth": 85, "fieldWidth": 95, "emptyWidth": 5},
        "required": true,
        "sentence": true
      },
      "riskjustify": {
        "label": getLocale("Justification"),
        "type": "text",
        "value": "",
        "enabled": false,
        "column": true,
        "size": {"textWidth": 85, "fieldWidth": 95, "emptyWidth": 5},
        "required": true,
        "sentence": true
      },
      "purposeOfTrans": {
        "label": getLocale("Please choose where applicable"),
        "type": "optionList",
        "options": [
          {
            "label": getLocale("Education"),
            "active": true,
            "value": "education"
          },
          {
            "label": getLocale("Investment"),
            "active": true,
            "value": "investment"
          },
          {
            "label": getLocale("Protection"),
            "active": true,
            "value": "protection"
          },
          {
            "label": getLocale("Retirement"),
            "active": true,
            "value": "retirement"
          },
          {"label": getLocale("Saving"), "active": true, "value": "saving"},
          {"label": getLocale("Others"), "active": true, "value": "others"}
        ],
        "enabled": true,
        "value": [],
        "size": {"textWidth": 80, "fieldWidth": 90, "emptyWidth": 10},
        "required": true,
        "column": true
      },
      "otherPurposeOfTrans": {
        "label": getLocale("Other Purpose of Transaction"),
        "maxLines": 3,
        "type": "text",
        "enabled": true,
        "value": "",
        "size": {"textWidth": 80, "fieldWidth": 120, "emptyWidth": 0},
        "required": true,
        "column": true,
        "sentence": true,
        "maxLength": 100
      }
    };
    inputList["recommendreason"]["enabled"] = needReason();
    inputList["riskjustify"]["enabled"] = justifyRisk();
    generateDataToObjectValue(obj, inputList);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (info["listOfQuotation"] != null) save();
    });
  }

  bool justifyRisk({tempQuo}) {
    var p = info["investmentPreference"];
    var risk = checkFundRisk(tempQuo: tempQuo);
    if (p != null &&
        p["investmentpreference"] != null &&
        risk > p["investmentpreference"]) return true;
    return false;
  }

  void checkMedicalCard(obj) async {
    if (ApplicationFormData.data["listOfQuotation"] != null &&
        ApplicationFormData.data["listOfQuotation"].isNotEmpty) {
      bool haveMedicalCard = false;
      var qq = ApplicationFormData.data["listOfQuotation"][0];
      if (qq["riderOutputDataList"] != null &&
          qq["riderOutputDataList"].isNotEmpty) {
        List<dynamic> ridersCode = qq["riderOutputDataList"]
            .map((value) => value["riderCode"])
            .toList();
        if (ridersCode.any((value) => value.contains("RCIMP"))) {
          haveMedicalCard = true;
        }
      }
      if (haveMedicalCard) {
        String? errorMsg;
        String idnum = "";
        if (ApplicationFormData.data["buyingFor"] == BuyingFor.self.toStr) {
          idnum =
              mapInfo["policyOwner"][mapInfo["policyOwner"]["identitytype"]];
        } else {
          idnum =
              mapInfo["lifeInsured"][mapInfo["lifeInsured"]["identitytype"]];
        }

        await searchExistingCustomerList(idnum, policyType: "Rider")
            .then((data) {
          if (data.isNotEmpty) {
            for (var element in data) {
              if (element.existingMedicalPlan!.isNotEmpty) {
                element.existingMedicalPlan?.forEach((element) {
                  if (element.policyName != null &&
                      element.policyName!.contains("Medical Plus")) {
                    errorMsg =
                        getLocale("Client has existing Basic Medical Rider");
                  }
                });
              }
              if (element.existingCoverage!.isNotEmpty) {
                element.existingCoverage?.forEach((element) {
                  if (element.policyName != null &&
                      element.policyName!.contains("Medical Plus")) {
                    errorMsg =
                        getLocale("Client has existing Basic Medical Rider");
                  }
                });
              }
              if (element.existingCoverageDisclosure!.isNotEmpty) {
                element.existingCoverageDisclosure?.forEach((element) {
                  if (element.policyName != null &&
                      element.policyName!.contains("Medical Plus")) {
                    errorMsg =
                        getLocale("Client has existing Basic Medical Rider");
                  }
                });
              }
            }
          }

          if (errorMsg != null) {
            obj["TSARMedicalPassed"] = false;
            obj["TSARMedicalErrorMsg"] = errorMsg;
            widget.onChanged(obj, tempQuo);
            if (!mounted) {}
            showAlertDialog2(context,
                getLocale("Oops, there seems to be an issue."), errorMsg, () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (route) => false);
            });
          }
        }).catchError((onError) {});
      }
    }
  }

  void save({bool? fromQuote}) {
    inputList["recommendreason"]["enabled"] =
        needReason(tempQuo: fromQuote != null && fromQuote ? tempQuo : null);
    inputList["riskjustify"]["enabled"] =
        justifyRisk(tempQuo: fromQuote != null && fromQuote ? tempQuo : null);
    if (inputList["purposeOfTrans"]["value"].contains("others") ||
        inputList["purposeOfTrans"]["value"].contains("lain-lain")) {
      inputList["otherPurposeOfTrans"]["enabled"] = true;
    } else {
      inputList["otherPurposeOfTrans"]["enabled"] = false;
    }
    obj = getInputedData(inputList);
    checkMedicalCard(obj);
    widget.onChanged(obj, tempQuo);
  }

  Widget purposeOfTransInfo() {
    if (info["recommendedProducts"] != null &&
        inputList["purposeOfTrans"]["value"] != null &&
        inputList["purposeOfTrans"]["value"] != "" &&
        inputList["purposeOfTrans"]["value"].isNotEmpty) {
      inputList["purposeOfTrans"]["value"] =
          info["recommendedProducts"]["purposeOfTrans"];
    } else {
      inputList["purposeOfTrans"]["value"] = [];
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Purpose of Transaction"), style: t2FontW5()),
          customMultipleSelection(inputList["purposeOfTrans"], (value) {
            setState(() {
              inputList["purposeOfTrans"]["value"] = value;

              save();
            });
          }, context),
          Visibility(
              visible: (inputList["purposeOfTrans"]["value"] == null) ||
                  (inputList["purposeOfTrans"]["value"].isEmpty),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                      "${getLocale("Please select at least one")} ${getLocale("Purpose of Transaction")}",
                      style: ssFontWN().copyWith(color: scarletRedColor)))),
          SizedBox(height: gFontSize * 1.6),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.66,
              child: AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  child: inputList["purposeOfTrans"]["value"] != null
                      ? inputList["purposeOfTrans"]["value"]
                                  .contains("others") ||
                              inputList["purposeOfTrans"]["value"]
                                  .contains("lain-lain")
                          ? Padding(
                              padding: EdgeInsets.only(bottom: gFontSize * 2.4),
                              child: EaseAppTextField(
                                  obj: inputList["otherPurposeOfTrans"],
                                  onChanged: (val) {
                                    if (val !=
                                        inputList["otherPurposeOfTrans"]
                                            ["value"]) {
                                      inputList["otherPurposeOfTrans"]
                                          ["value"] = val;
                                    }
                                    save();
                                  }))
                          : Container()
                      : Container()))
        ]));
  }

  Widget generateProfileInfo() {
    var p = mapInfo;
    var p2 = mapInfo["policyOwner"];
    var p3 = mapInfo["lifeInsured"];
    String? p3dob;
    String? p2dob;
    if (p3 != null && p3["dob"] != null) {
      p3dob = DateFormat('dd MMM yyyy')
          .format(DateTime.fromMicrosecondsSinceEpoch(p3["dob"]));
    }
    if (p2 != null && p2["dob"] != null) {
      p2dob = DateFormat('dd MMM yyyy')
          .format(DateTime.fromMicrosecondsSinceEpoch(p2["dob"]));
    }

    List<Map<String, dynamic>> obj = [
      {
        "buyingfor": {
          "label": getLocale("Buying For"),
          "value": getLocale(p["buyingFor"])
        }
      },
      {
        "empty": {} // for spacing
      }
    ];
    if (p["buyingFor"] == BuyingFor.self.toStr) {
      obj.add({
        "title":
            "${getLocale("Special Translation 1 for Details")} ${getLocale('Life Insured', entity: true)} ${getLocale("Special Translation 2 for Details")}",
        "name": {"label": getLocale("Name"), "value": p3["name"]},
        "gender": {
          "label": getLocale("Gender"),
          "value": p3["gender"] == null ? p3["gender"] : getLocale(p3["gender"])
        },
        "dob": {"label": getLocale("Date of Birth"), "value": p3dob},
        "occupation": {
          "label": getLocale("Occupation"),
          "value": p3["occupationDisplay"]
        },
        "smoking": {
          "label": getLocale("Smoking"),
          "value": p3["smoking"] != null && p3["smoking"]
              ? getLocale("Yes")
              : getLocale("No")
        }
      });
    } else {
      obj.add({
        "title":
            "${getLocale("Special Translation 1 for Details")} ${getLocale("Policy Owner", entity: true)} ${getLocale("Special Translation 2 for Details")}",
        "name": {"label": getLocale("Name"), "value": p2["name"]},
        "gender": {
          "label": getLocale("Gender"),
          "value": getLocale(p2["gender"])
        },
        "dob": {"label": getLocale("Date of Birth"), "value": p2dob},
        "occupation": {
          "label": getLocale("Occupation"),
          "value": p2["occupationDisplay"]
        },
        "smoking": {
          "label": getLocale("Smoking"),
          "value": p2["smoking"] != null && p2["smoking"]
              ? getLocale("Yes")
              : getLocale("No")
        }
      });
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Profile Details"), style: t2FontW5()),
          SizedBox(height: gFontSize * 0.8),
          Container(
              padding: EdgeInsets.only(
                  top: gFontSize,
                  bottom: gFontSize,
                  left: gFontSize * 1.5,
                  right: gFontSize),
              decoration: BoxDecoration(
                  color: lightGreyColor2,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: CustomColumnTable(arrayObj: obj))
        ]));
  }

  Widget generateNeeds() {
    var priority = {
      "protection": getLocale("Family Protection"),
      "retirement": getLocale("Retirement Plan"),
      "education": getLocale("Children's Education"),
      "saving": getLocale("Savings & Invesment"),
      "investment": getLocale("Lump Sum Investment"),
      "medical": getLocale("Medical")
    };
    String? firstPriorKey, secondPrioKey;
    int? riskPref;
    var coverage = "";
    if (mapInfo["priority"] != null && mapInfo["priority"].isNotEmpty) {
      firstPriorKey = mapInfo["priority"]
          .keys
          .firstWhere((k) => mapInfo["priority"][k]["priority"] == 1);
      secondPrioKey = mapInfo["priority"]
          .keys
          .firstWhere((k) => mapInfo["priority"][k]["priority"] == 2);
    }

    if (mapInfo["investmentPreference"] != null &&
        mapInfo["investmentPreference"]["investmentpreference"] != null) {
      riskPref = mapInfo["investmentPreference"]["investmentpreference"];
    }

    if (mapInfo["disclosure"] != null &&
        mapInfo["disclosure"]["coverage"] != null) {
      for (var key in priority.keys) {
        if (mapInfo["disclosure"]["coverage"][key] != null &&
            !mapInfo["disclosure"]["coverage"][key].isEmpty) {
          coverage = "$coverage- ${priority[key]!}\n";
        }
      }
      coverage = coverage.trim();
    }
    var obj = [
      {
        "size": {"labelWidth": 35, "valueWidth": 65},
        "priority1": {
          "label": getLocale("Top Priority"),
          "value": priority[firstPriorKey]
        },
        "priority2": {
          "label": getLocale("Second Priority"),
          "value": priority[secondPrioKey]
        },
        "riskPref": {
          "label": getLocale("Investment Risk Preference"),
          "value": riskPref.toString()
        },
        "existingCoverage": {
          "label": getLocale("Existing Plan/Coverage"),
          "value": coverage
        }
      }
    ];
    return Container(
        padding: EdgeInsets.all(gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Needs Conclusion"), style: t2FontW5()),
          SizedBox(height: gFontSize * 0.8),
          Container(
              padding: EdgeInsets.only(
                  top: gFontSize,
                  bottom: gFontSize,
                  left: gFontSize * 1.5,
                  right: gFontSize),
              color: const Color.fromRGBO(227, 244, 242, 1),
              child: CustomColumnTable(arrayObj: obj))
        ]));
  }

  Widget editButton(onPressed) {
    return CustomButton(
        label: getLocale("Edit"),
        image:
            Image.asset('assets/images/edit_cyan.png', width: gFontSize * 0.9),
        fontSize: gFontSize * 0.9,
        labelColor: cyanColor,
        secondary: true,
        onPressed: onPressed);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: gFontSize * 2.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          purposeOfTransInfo(),
          generateProfileInfo(),
          generateNeeds(),
          ProductInfo(
            inputList: inputList,
            info: info,
            onChanged: (value, quo) {
              tempQuo = quo;
              if (quo != null) {
                setState(() {});
              }
              save(fromQuote: true);
            },
          ),
        ],
      ),
    );
  }
}
