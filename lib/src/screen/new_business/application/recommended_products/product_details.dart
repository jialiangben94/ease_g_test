import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_mapping.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/view_full_si_pds/view_full.dart';
import 'package:ease/src/service/vpms_mapping_helper.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/widgets/custom_row_table.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/si_table.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/data/new_business_model/quotation_dao.dart';
import 'package:ease/src/widgets/main_widget.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductInfo extends StatelessWidget {
  final dynamic object;
  final dynamic info;
  final dynamic inputList;
  final bool? isSummary;
  final Function(dynamic obj, dynamic qquo)? onChanged;

  const ProductInfo(
      {Key? key,
      this.object,
      this.inputList,
      this.onChanged,
      this.info,
      this.isSummary})
      : super(key: key);

  bool get mounted => object != null;

  @override
  Widget build(BuildContext context) {
    dynamic obj = object ?? {};
    dynamic p;
    if (info != null &&
        info["listOfQuotation"] != null &&
        info["listOfQuotation"][0] != null) {
      p = info["listOfQuotation"][0];
    }
    void startRecommendProduct() async {
      obj["recommendedProducts"] = null;
      saveData();
      //USING OTHERS DEVELOPER CHOOSE PRODUCT PAGE, LONG DATA NEEDED, MAY OR MAY NOT REWRITE BASE ON TIME ALLOW
      var temp = json.decode(json.encode(info));
      temp["id"] = null;
      temp["progress"] = null;
      temp["listOfQuotation"] = [];
      temp["reminderDate"] = null;
      temp["isSetReminder"] = null;
      temp["uid"] = generateQuickQuotationId();
      temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));
      temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));
      temp["policyOwner"] = json.encode(temp["policyOwner"]);
      temp["lifeInsured"] = json.encode(temp["lifeInsured"]);
      temp = Quotation.fromMap(temp);
      if (temp.buyingFor == BuyingFor.self.toStr) {
        temp.lifeInsured.clientType = lookupClientType["poli"];
        temp.policyOwner.clientType = lookupClientType["poli"];
      } else {
        temp.policyOwner.clientType = lookupClientType["policyOwner"];
        temp.lifeInsured.clientType = lookupClientType["lifeInsured"];
      }

      final quotationDao = QuotationDao();
      int? id = await quotationDao.insert(temp);
      temp.id = id;

      if (!mounted) {}
      var qquo = await Navigator.of(context).push(createRoute(ChooseProducts(
          id, temp,
          status: Status.newFromApplication, data: info)));

      await quotationDao.delete(temp);
      temp = temp.toMap();

      if (qquo != null) {
        qquo = qquo.toMap();
        var found = false;
        for (var key in inputList.keys) {
          if (inputList[key]["enabled"] is bool && inputList[key]["enabled"]) {
            found = true;
          }
        }
        if (!found) {
          obj = {};
          obj["empty"] = "";
        }
        onChanged!(obj, qquo);
      }
    }

    void editProduct({autocalculate = false}) async {
      obj["recommendedProducts"] = null;
      saveData();

      //USING OTHERS DEVELOPER CHOOSE PRODUCT PAGE, LONG DATA NEEDED, MAY OR MAY NOT REWRITE BASE ON TIME ALLOW
      var temp = json.decode(json.encode(info));

      temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));

      temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));

      temp["policyOwner"] = json.encode(temp["policyOwner"]);
      temp["lifeInsured"] = json.encode(temp["lifeInsured"]);

      temp = Quotation.fromMap(temp);
      if (temp.buyingFor == BuyingFor.self.toStr) {
        temp.lifeInsured.clientType = lookupClientType["poli"];
        temp.policyOwner.clientType = lookupClientType["poli"];
      } else {
        temp.policyOwner.clientType = lookupClientType["policyOwner"];
        temp.lifeInsured.clientType = lookupClientType["lifeInsured"];
      }

      var temp2 = json.decode(json.encode(p));
      temp2 = QuickQuotation.fromMap(temp2);

      ProductPlanState data = BlocProvider.of<ProductPlanBloc>(context).state;
      if (data is ProductPlanLoaded) {
        Future.delayed(const Duration(milliseconds: 100), () {
          //EDIT QUOTE
          BlocProvider.of<ChooseProductBloc>(context)
              .add(EditQuotation(quotation: temp, quickQuotation: temp2));
        });
        dynamic qquo;
        if (autocalculate == true) {
          QuickQuotation qqdata = temp2;
          VpmsMapping? vpmsMappingFile = await getVPMSMappingData(
              qqdata.productPlanCode == "PCHI04"
                  ? "PCHI03"
                  : qqdata.productPlanCode);

          int mainAge = info["lifeInsured"]["age"];
          int? intANB;
          String? pANB = vpmsMappingFile.premiumSummary!.anb;
          String? aDOB = vpmsMappingFile.basicInput!.dateOfBirth;
          if (pANB != null) {
            // Get LI current age
            var vpmsOutput = qqdata.vpmsoutput ?? [];
            String? qqANB;
            // Check if P_ANB age is same or more or less
            for (var element in vpmsOutput) {
              if (element.isNotEmpty) {
                if (element[0] == pANB && element[1] != null) {
                  qqANB = element[1];
                  break;
                }
              }
            }
            if (qqANB != null && isNumeric(qqANB)) {
              intANB = int.parse(qqANB);
            }
          }

          if (intANB == null) {
            if (aDOB != null) {
              var vpmsInput = qqdata.vpmsinput ?? [];
              String? qqDOB;
              // Check if P_ANB age is same or more or less
              for (var element in vpmsInput) {
                if (element.isNotEmpty) {
                  if (element[0] == aDOB && element[1] != null) {
                    qqDOB = element[1];
                    break;
                  }
                }
              }
              if (qqDOB != null) {
                intANB = getAgeString(qqDOB, true);
              }
            }
          }

          int ageDiff = mainAge - intANB!;

          if (ageDiff.abs() >= 4) {
            if (!mounted) {}
            showAlertDialog2(
                context,
                getLocale("Failed to auto recalculate."),
                getLocale(
                    'ANB for LI is too different than the one in existing SI/MI. Please proceed to edit product instead.'),
                () {
              Navigator.pop(context);
            });
          } else {
            if (!mounted) {}
            qquo = await Navigator.of(context).push(createRoute(ChooseProducts(
                info["id"], temp,
                quickQtnId: p["quickQuoteId"],
                status: Status.editAgeFromApp,
                data: info)));
          }
        } else {
          qquo = await Navigator.of(context).push(createRoute(ChooseProducts(
              info["id"], temp,
              quickQtnId: p["quickQuoteId"],
              status: Status.editFromApp,
              data: info)));
        }

        if (qquo != null) {
          if (qquo is QuickQuotation) {
            qquo = qquo.toMap();

            if (qquo != null) {
              var found = false;
              for (var key in inputList.keys) {
                if (inputList[key]["enabled"] is bool &&
                    inputList[key]["enabled"]) {
                  found = true;
                }
              }
              if (!found) {
                obj = {};
                obj["empty"] = "";
              }
              onChanged!(obj, qquo);
            }
          } else if (qquo["isSuccess"] != null && !qquo["isSuccess"]) {
            if (!mounted) {}
            showAlertDialog(context, "Error", qquo["message"]);
          }
        }
      }
    }

    void viewSI() {
      var temp = json.decode(json.encode(info));

      temp["policyOwner"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["policyOwner"]["dob"]));

      temp["lifeInsured"]["dob"] = DateFormat('dd.MM.yyyy').format(
          DateTime.fromMicrosecondsSinceEpoch(temp["lifeInsured"]["dob"]));

      temp["policyOwner"] = json.encode(temp["policyOwner"]);
      temp["lifeInsured"] = json.encode(temp["lifeInsured"]);

      temp = Quotation.fromMap(temp);

      var temp2 = json.decode(json.encode(p));

      temp2 = QuickQuotation.fromMap(temp2);

      Navigator.of(context).push(createRoute(ViewFullDoc(temp, temp2)));
    }

    Widget inputContainer(text, field) {
      return Container(
          padding: EdgeInsets.only(
              top: gFontSize * 1.5,
              bottom: gFontSize * 0.5,
              left: gFontSize * 1.5,
              right: gFontSize * 1.5),
          color: const Color.fromRGBO(254, 237, 230, 1),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text, style: bFontWN().copyWith(color: Colors.red)),
            Container(height: screenHeight * 0.02),
            field
          ]));
    }

    Widget viewSIMIButton() {
      var temp2 = json.decode(json.encode(p));
      temp2 = QuickQuotation.fromMap(temp2);

      return CustomButton(
          label: getLocale("View Full SI/MI"),
          image: temp2!.quotationHistoryID != null
              ? Image.asset('assets/images/view_doc_cyan.png',
                  width: gFontSize * 0.9)
              : null,
          fontSize: gFontSize * 0.9,
          labelColor:
              temp2!.quotationHistoryID != null ? cyanColor : greyBorderTFColor,
          secondary: true,
          onPressed: () {
            if (temp2!.quotationHistoryID != null) {
              viewSI();
            }
          });
    }

    Widget editButton(onPressed) {
      return CustomButton(
          label: getLocale("Edit"),
          image: Image.asset('assets/images/edit_cyan.png',
              width: gFontSize * 0.9),
          fontSize: gFontSize * 0.9,
          labelColor: cyanColor,
          secondary: true,
          onPressed: onPressed);
    }

    Widget generateProfileInfo() {
      var p = info;
      var p2 = info["policyOwner"];
      var p3 = info["lifeInsured"];
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
            "value": getLocale(p3["gender"])
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
          margin: EdgeInsets.symmetric(vertical: gFontSize),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Profile Details"),
                style: t1FontW5().copyWith(color: cyanColor)),
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

    Widget generateSIMI() {
      // var p = info;
      var version = Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(gFontSize * 0.2),
                      color: lightCyanColorFive),
                  padding: EdgeInsets.all(gFontSize * 0.4),
                  child: Text(
                      "${getLocale("Version")} ${(p["version"] ?? "1")}",
                      style: bFontWN().copyWith(color: Colors.white)))));

      var lob = p["productPlanLOB"];
      String? lobstr;
      if (isNumeric(lob)) {
        lobstr = lookupProductLOB.keys
            .firstWhereOrNull((k) => lookupProductLOB[k] == lob);
      } else if (lob is String) {
        var llob = convertProductPlan(lob);
        lobstr = convertProductPlan(llob);
      }

      var arrayObj = [
        {
          "size": {"labelWidth": 30, "valueWidth": 70},
          "planType": {
            "label": getLocale("Plan Type"),
            "value": lookupProductType(p["productPlanCode"])
          },
          "productLOB": {"label": getLocale("Product LOB"), "value": lobstr},
          "steppedPremium": {
            "label": getLocale("Stepped Premium"),
            "value": p["isSteppedPremium"] != null && p["isSteppedPremium"]
                ? getLocale("Yes")
                : getLocale("No")
          },
          "paymentMode": {
            "label": getLocale("Payment Mode"),
            "value": getLocale(convertPaymentModeInt(p["paymentMode"]))
          },
          "maturityAge": p["productPlanLOB"] == "ProductPlanType.traditional"
              ? {"label": getLocale("Entry Age"), "value": p["anb"]}
              : {"label": getLocale("Maturity Age"), "value": p["maturityAge"]}
        }
      ];
      if (isSummary == null) {
        arrayObj[0]
            ["quotation"] = {"label": getLocale("Quotation"), "value": version};
      }
      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (isSummary != null && isSummary!) generateProfileInfo(),
            const Divider(thickness: 3),
            SizedBox(height: gFontSize),
            isSummary != null && isSummary!
                ? Row(children: [
                    Expanded(
                        child: Text(getLocale("Product Details"),
                            style: t1FontW5().copyWith(color: cyanColor))),
                    viewSIMIButton()
                  ])
                : Row(children: [
                    Expanded(
                        child: Text(getLocale("SI/MI Details"),
                            style: t2FontW5())),
                    viewSIMIButton(),
                    SizedBox(width: gFontSize),
                    editButton(editProduct)
                  ]),
            SizedBox(height: gFontSize),
            CustomColumnTable(arrayObj: arrayObj)
          ]));
    }

    Widget recommendedTextField() {
      if (isSummary != null && isSummary!) {
        return Container();
      }

      var p = info["recommendedProducts"];
      var initValue =
          p != null && p["recommendreason"] != null ? p["recommendreason"] : "";
      inputList["recommendreason"]["value"] = initValue;
      bool isVisible = inputList["recommendreason"]["enabled"];

      var textField = EaseAppTextField(
          obj: inputList["recommendreason"],
          callback: (_) {
            var result = getInputedData(inputList);
            obj = result;
            onChanged!(obj, null);
          },
          onChanged: (value) {
            inputList["recommendreason"]["value"] = value;
          });

      return Visibility(
          visible: isVisible,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
              child: inputContainer(
                  "* ${getLocale("The selected product is different from the FNA Recommendation")}.",
                  textField)));
    }

    Widget generateRecommended() {
      // var p = info;
      dynamic arr = {
        "header": {
          "plan": {"value": "(A) Basic plan", "size": 30},
          "sum": {
            "value": p["productPlanLOB"] == "ProductPlanType.traditional"
                ? getLocale("Initial Sum Insured")
                : getLocale("Sum Insured"),
            "size": 20
          },
          "premiumterm": {
            "value":
                "${getLocale("Payment Term", entity: true)}\n(${getLocale("Years")})",
            "size": 15
          },
          "policyterm": {
            "value": p["productPlanLOB"] == "ProductPlanType.traditional"
                ? "${getLocale("Term of Coverage")}\n(${getLocale("Years")})"
                : "${getLocale("Policy Term", entity: true)}\n(${getLocale("Years")})",
            "size": 15
          },
          "premium": {
            "value":
                getLocale("${convertPaymentModeInt(p['paymentMode'])} Premium"),
            "size": 20
          }
        },
        "value": [
          {
            "plan": p["productPlanName"],
            "sum": toRM(p["sumInsuredAmt"], rm: true),
            "premiumterm": p["basicPlanPaymentTerm"],
            "policyterm": p["basicPlanPolicyTerm"] ?? p["policyTerm"],
            "premium": toRM(p["basicPlanPremiumAmount"], rm: true)
          }
        ]
      };
      if (p["enricherPremiumAmount"] != null) {
        arr["value"].add({
          "plan": "Enricher",
          "sum": "N/A",
          "premiumterm": p["enricherPaymentTerm"],
          "policyterm": p["enricherPolicyTerm"],
          "premium": p["enricherPremiumAmount"] != null
              ? toRM(p["enricherPremiumAmount"], rm: true)
              : null
        });
      }

      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
          child: CustomRowTable(arrayObj: arr));
    }

    Widget generateRtu() {
      var arr = {
        "header": {
          "naText": "-",
          "name": {"value": "(C) Regular Top Up", "size": 50},
          "rtuPaymentTerm": {
            "value": getLocale("Payment Term", entity: true),
            "size": 15
          },
          "rtuPolicyTerm": {"value": getLocale("RTU Term"), "size": 15},
          "rtuPremiumAmount": {
            "value":
                getLocale("${convertPaymentModeInt(p['paymentMode'])} Premium"),
            "size": 20
          }
        },
        "value": [
          {
            "name": "Regular Top Up",
            "rtuPolicyTerm": p["rtuPolicyTerm"],
            "rtuPaymentTerm": p["rtuPaymentTerm"],
            "rtuPremiumAmount": toRM(p["rtuPremiumAmount"], rm: true)
          }
        ]
      };

      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
          child: CustomRowTable(arrayObj: arr));
    }

    Widget generateUnitRider() {
      var riders = p["riderOutputDataList"];
      if (riders == null || riders.isEmpty) {
        riders = [{}];
      }
      List riderData = [{}];

      riders.forEach((rider) {
        String? riderSA;
        if (rider["isUnitBasedProd"] != null && rider["isUnitBasedProd"]) {
          riderSA = rider["riderSA"];
        } else if (isNumeric(rider["riderSA"])) {
          riderSA = toRM(rider["riderSA"], rm: true);
        } else {
          riderSA = rider["riderSA"];
        }

        if (rider.isNotEmpty) {
          if (rider["riderCode"] == "PCHI03") {
            var ratescale = p["guaranteedCashPayment"] == "1"
                ? "Guaranteed Cash Payment(GCP) + Maturity Benefit"
                : "Lump Sum Payment At Maturity";
            riderData.add({
              "riderName": "IL Savings Growth\n- $ratescale",
              "riderSA": "N/A",
              "riderPaymentTerm": p["gcpPremTerm"],
              "riderOutputTerm": p["gcpTerm"],
              "riderType": toRM(p["gcpPremAmt"], rm: true),
              "riderMonthlyPremium": toRM(p["gcpPremAmt"], rm: true)
            });
          } else if (rider["riderCode"] == "PTHI01") {
            var ratescale = p["guaranteedCashPayment"] == "1"
                ? "To Receive GCP"
                : "Maturity Payments";
            riderData.add({
              "riderName": "Takafulink Saving Flexi\n- $ratescale",
              "riderSA": "N/A",
              "riderPaymentTerm": p["gcpPremTerm"],
              "riderOutputTerm": p["gcpTerm"],
              "riderType": toRM(p["gcpPremAmt"], rm: true),
              "riderMonthlyPremium": toRM(p["gcpPremAmt"], rm: true)
            });
          } else {
            if (p["productPlanCode"] == "PCJI02") {
              riderData.add({
                "riderName": rider["riderName"],
                "riderSA": rider["riderType"],
                "riderPaymentTerm": rider["riderOutputTerm"],
                "riderOutputTerm": riderSA,
                "riderType": rider["riderType"] == "Unit Deducting Rider"
                    ? "N/A"
                    : rider["riderMonthlyPremium"] != null &&
                            rider["riderMonthlyPremium"] != "N/A"
                        ? toRM(rider["riderMonthlyPremium"], rm: true)
                        : rider["riderType"] ?? "N/A"
              });
            } else {
              riderData.add({
                "riderName": rider["riderName"],
                "riderSA": riderSA,
                "riderPaymentTerm": rider["riderPaymentTerm"],
                "riderOutputTerm": rider["riderOutputTerm"],
                "riderType": rider["riderMonthlyPremium"] != null &&
                        rider["riderMonthlyPremium"] != "N/A"
                    ? toRM(rider["riderMonthlyPremium"], rm: true)
                    : rider["riderType"]
              });
            }
          }
        }
      });

      dynamic arr = {
        "header": {
          "emptyText": getLocale("- No Rider Selected -"),
          "naText": "-",
          "riderName": {"value": "(B) Riders", "size": 30},
          "riderSA": {"value": getLocale("Sum Insured"), "size": 20},
          "riderPaymentTerm": {
            "value": getLocale("Payment Term", entity: true),
            "size": 15
          },
          "riderOutputTerm": {
            "value": "${getLocale("Riders Term")}\n(${getLocale("Years")})",
            "size": 15
          },
          "riderType": {
            "value":
                getLocale("${convertPaymentModeInt(p['paymentMode'])} Premium"),
            "size": 20
          },
        },
        "value": riderData
      };

      if (p["productPlanCode"] == "PCJI02") {
        arr["header"]["riderSA"] = {"value": getLocale("Type"), "size": 20};
        arr["header"]["riderOutputTerm"] = {
          "value": getLocale("Sum Insured"),
          "size": 20
        };
        arr["header"]["riderPaymentTerm"] = {
          "value": "${getLocale("Riders Term")}\n(${getLocale("Years")})",
          "size": 15
        };
      }
      if (p["productPlanLOB"] == "ProductPlanType.traditional") {
        arr["header"]["riderSA"] = {
          "value": "${getLocale("Initial Sum Insured")}/${getLocale("Units")}",
          "size": 20
        };
        arr["header"]["riderOutputTerm"] = {
          "value": "${getLocale("Term of Coverage")}\n(${getLocale("Years")})",
          "size": 15
        };
      }

      return Column(children: [
        SizedBox(height: gFontSize),
        Container(
            padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
            child: CustomRowTable(arrayObj: arr))
      ]);
    }

    Widget totalSummary(text, amount) {
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: gFontSize, horizontal: gFontSize * 1.7),
          color: lightCyanColor,
          child: Row(children: [
            Expanded(flex: 80, child: Text(text, style: bFontWN())),
            Expanded(flex: 20, child: Text(amount, style: t2FontW5()))
          ]));
    }

    Widget totalAdhoc(adhocAmount) {
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: gFontSize, horizontal: gFontSize * 1.7),
          color: lightCyanColorFive,
          child: Row(children: [
            Expanded(
                flex: 80,
                child: Text(
                    getLocale("Ad Hoc Top-Up Contribution at Inception"),
                    style: bFontWN())),
            Expanded(flex: 20, child: Text(adhocAmount, style: t2FontW5()))
          ]));
    }

    Widget riskTextField() {
      if (isSummary != null && isSummary!) {
        return Container();
      }
      var p2 = info["recommendedProducts"];
      if (inputList["riskjustify"]["enabled"]) {
        var initValue =
            p2 != null && p2["riskjustify"] != null ? p2["riskjustify"] : "";
        inputList["riskjustify"]["value"] = initValue;
        var textField = EaseAppTextField(
            obj: inputList["riskjustify"],
            callback: (_) {
              var result = getInputedData(inputList);
              obj = result;
              onChanged!(obj, null);
            },
            onChanged: (value) {
              inputList["riskjustify"]["value"] = value;
            });

        return inputContainer(
            "* ${getLocale("The risk of the recommended fund is higher than the customer's risk preference. It is compulsory for customer to justify. Do customer want to proceed")}?",
            textField);
      } else {
        return Container();
      }
    }

    Widget generateFund() {
      if (p["totalFundAlloc"] != null) {
        var arr = {
          "header": {
            "fundName": {"value": getLocale("Fund Name"), "size": 80},
            "fundAlloc": {
              "value": getLocale("Investment Allocation"),
              "size": 20,
              "append": "%"
            }
          },
          "value": p["fundOutputDataList"]
        };
        return Column(children: [
          Divider(thickness: gFontSize * 0.2),
          Container(
              padding: EdgeInsets.symmetric(
                  vertical: gFontSize * 2, horizontal: gFontSize * 2.5),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getLocale("Fund"), style: t2FontW5()),
                    SizedBox(height: gFontSize),
                    CustomRowTable(arrayObj: arr),
                    SizedBox(height: gFontSize),
                    totalSummary(getLocale("Total"), p["totalFundAlloc"] + "%"),
                    SizedBox(height: gFontSize),
                    riskTextField()
                  ]))
        ]);
      } else {
        return Container();
      }
    }

    Widget siTable() {
      // var p = info;
      List<List<String>> list = List<List<String>>.from(
          p["siTableData"].map((x) => List<String>.from(x.map((x) => x))));
      List<List<String>> listgsc = p["siTableGSC"] != null
          ? List<List<String>>.from(
              p["siTableGSC"].map((x) => List<String>.from(x.map((x) => x))))
          : [];

      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Illustration of Premium Benefits"),
                style: t2FontW5()),
            SizedBox(height: gFontSize),
            SITable(p["productPlanCode"], list),
            SizedBox(height: gFontSize),
            SITable(p["productPlanCode"], listgsc, isGSC: true),
            SizedBox(height: gFontSize),
            Text(
                '* ${getLocale("Take note that for details SI, please view our downloadable SI")}',
                style: sFontWN().copyWith(color: greyTextColor))
          ]));
    }

    var padding = EdgeInsets.symmetric(horizontal: gFontSize * 2.5);
    return FutureBuilder<dynamic>(
        future: needRecalculate(info),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
                  width: double.infinity,
                  child: Row(children: [
                    Expanded(
                        flex: 47,
                        child: CustomButton(
                            label: getLocale("Recalculate product"),
                            onPressed: () {
                              editProduct(autocalculate: true);
                            })),
                    const Expanded(flex: 5, child: SizedBox()),
                    Expanded(
                        flex: 47,
                        child: CustomButton(
                            label: getLocale("Edit product"),
                            onPressed: () {
                              editProduct();
                            }))
                  ]));
            } else if (info == null ||
                info["listOfQuotation"] == null ||
                info["listOfQuotation"][0] == null) {
              var disable = true;
              if (info["lifeInsured"] != null &&
                  info["lifeInsured"]["occupation"] != null &&
                  info["lifeInsured"]["smoking"] != null &&
                  info["lifeInsured"]["name"] != null &&
                  info["lifeInsured"]["dob"] != null &&
                  info["lifeInsured"]["gender"] != null) {
                disable = false;
              }
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.5),
                  width: double.infinity,
                  child: CustomButton(
                      label: getLocale("Recommend product"),
                      onPressed: disable
                          ? null
                          : () {
                              startRecommendProduct();
                            }));
            } else {
              String abc = "";
              String totalpremtext = "";
              if (p["eligibleRiders"] != null &&
                  p["eligibleRiders"]!.isNotEmpty) {
                abc = " (A + B)";
                if (p["productPlanLOB"] != "ProductPlanType.traditional") {
                  abc = " (A + B + C)";
                }
              }
              if (p["paymentMode"] != null) {
                if (isNumeric(p["paymentMode"])) {
                  totalpremtext =
                      "${getLocale("Total")} ${getLocale(convertPaymentMode(p["paymentMode"]))} ${getLocale("Premium")} $abc";
                } else {
                  totalpremtext =
                      "${getLocale("Total")} ${getLocale(p["paymentMode"]!)} ${getLocale("Premium")} $abc";
                }
              }

              var premWithoutAdhoc = double.parse(p["totalPremium"]) -
                  double.parse(p["adhocAmt"] ?? "0.00");
              return Column(children: [
                generateSIMI(),
                SizedBox(height: gFontSize),
                generateRecommended(),
                if (p["eligibleRiders"] != null &&
                    p["eligibleRiders"].isNotEmpty)
                  generateUnitRider(),
                if (p["productPlanLOB"] != "ProductPlanType.traditional")
                  generateRtu(),
                Container(
                    padding: padding,
                    child: totalSummary(
                        totalpremtext,
                        toRM(
                            p["adhocAmt"] != null || p["adhocAmt"] != "0"
                                ? premWithoutAdhoc.toString()
                                : p["totalPremium"],
                            rm: true))),
                const SizedBox(height: 10),
                p["productPlanLOB"] != "ProductPlanType.traditional" &&
                        p["adhocAmt"] != "0" &&
                        p["adhocAmt"] != null
                    ? Container(
                        padding: padding,
                        child: totalAdhoc(toRM(p["adhocAmt"], rm: true)))
                    : Container(),
                const SizedBox(height: 10),
                recommendedTextField(),
                SizedBox(height: gFontSize * 2),
                generateFund(),
                if (p["productPlanLOB"] == "ProductPlanType.traditional"
                    ? p["productPlanCode"] == "PCEL01" ||
                        p["productPlanCode"] == "PCEE01"
                    : true) ...[
                  Divider(thickness: gFontSize * 0.2),
                  SizedBox(height: gFontSize * 2),
                  siTable(),
                  SizedBox(height: gFontSize)
                ]
              ]);
            }
          } else {
            return Container();
          }
        });
  }
}
