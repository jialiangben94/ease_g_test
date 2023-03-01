import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/si_table.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_row_table.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';

class ProductTable extends StatelessWidget {
  final dynamic object;
  final dynamic info;
  final bool isSITable;

  const ProductTable({Key? key, this.object, this.info, this.isSITable = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic p;
    if (info != null &&
        info["listOfQuotation"] != null &&
        info["listOfQuotation"][0] != null) {
      p = info["listOfQuotation"][0];
    }

    Widget generateRecommended() {
      dynamic arr = {
        "header": {
          "plan": {"value": "(A) Basic plan", "size": 30},
          "sum": {"value": getLocale("Sum Insured"), "size": 20},
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

      return CustomRowTable(arrayObj: arr);
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
                getLocale("${convertPaymentMode(p['paymentMode'])} Premium"),
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
      if (p["productPlanLOB"] != "ProductPlanType.traditional") {
        return CustomRowTable(arrayObj: arr);
      } else {
        return Container();
      }
    }

    Widget generateUnitRider() {
      var riders = p["riderOutputDataList"];
      if (riders == null || riders.isEmpty) {
        riders = [{}];
      }
      List riderData = [{}];

      riders.forEach((rider) {
        String? riderSA;
        if (isNumeric(rider["riderSA"])) {
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
        arr["header"]["riderOutputTerm"] = {
          "value": "${getLocale("Term of Coverage")}\n(${getLocale("Years")})",
          "size": 15
        };
      }

      return CustomRowTable(arrayObj: arr);
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

    Widget totalAdhoc(text, amount) {
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: gFontSize, horizontal: gFontSize * 1.7),
          color: lightCyanColorFive,
          child: Row(children: [
            Expanded(flex: 80, child: Text(text, style: bFontWN())),
            Expanded(flex: 20, child: Text(amount, style: t2FontW5()))
          ]));
    }

    Widget generateFund() {
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
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Fund"), style: t2FontW5()),
        SizedBox(height: gFontSize),
        CustomRowTable(arrayObj: arr),
        SizedBox(height: gFontSize),
        totalSummary(getLocale("Total"), p["totalFundAlloc"] + "%"),
        SizedBox(height: gFontSize)
      ]);
    }

    Widget siTable() {
      List<List<String>> list = List<List<String>>.from(
          p["siTableData"].map((x) => List<String>.from(x.map((x) => x))));
      List<List<String>> listgsc = List<List<String>>.from(
          p["siTableGSC"].map((x) => List<String>.from(x.map((x) => x))));

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Illustration of Premium Benefits"), style: t2FontW5()),
        SizedBox(height: gFontSize),
        SITable(p["productPlanCode"], list),
        SizedBox(height: gFontSize),
        SITable(p["productPlanCode"], listgsc, isGSC: true),
        SizedBox(height: gFontSize),
        Text(
            '* ${getLocale("Take note that for details SI, please view our downloadable SI")}',
            style: sFontWN().copyWith(color: greyTextColor))
      ]);
    }

    String abc = "";
    String totalpremtext = "";
    if (p["eligibleRiders"] != null && p["eligibleRiders"]!.isNotEmpty) {
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

    return Column(children: [
      generateRecommended(),
      SizedBox(height: gFontSize),
      generateUnitRider(),
      SizedBox(height: gFontSize),
      generateRtu(),
      SizedBox(height: gFontSize),
      p["adhocAmt"] != null && p["adhocAmt"] != "0"
          ? Container(
              child: totalAdhoc(
                  getLocale("Ad Hoc Top-Up Contribution at Inception"),
                  toRM(p["adhocAmt"], rm: true)))
          : Container(),
      const SizedBox(height: 10),
      Container(
          child:
              totalSummary(totalpremtext, toRM(p["totalPremium"], rm: true))),
      const SizedBox(height: 10),
      Divider(thickness: gFontSize * 0.2),
      SizedBox(height: gFontSize * 2),
      if (p["productPlanLOB"] != "ProductPlanType.traditional") generateFund(),
      SizedBox(height: gFontSize),
      if (isSITable && p["productPlanLOB"] == "ProductPlanType.traditional"
          ? p["productPlanCode"] == "PCEL01"
          : true)
        siTable()
    ]);
  }
}
