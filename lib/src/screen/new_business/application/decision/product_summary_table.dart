import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class ProductTable extends StatelessWidget {
  final dynamic data;
  final bool? tsar;
  const ProductTable({Key? key, this.data, this.tsar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var p = data["listOfQuotation"][0];
    var plans = [
      [
        {"label": getLocale("Basic and Supplementary Benefit"), "size": 5},
        {"label": getLocale("Sum Covered/Benefit (RM)"), "size": 5},
        {
          "label": getLocale("Premium/Contribution (RM)"),
          "size": 6,
          "span": [
            {"label": getLocale("Standard"), "size": 1},
            {"label": "-", "size": 1}
          ]
        }
      ]
    ];

    if (p["enricherPremiumAmount"] != null) {
      String stepprem =
          p["isSteppedPremium"] != null && p["isSteppedPremium"] ? "Yes" : "No";
      String enricherPrem = p["enricherPremiumAmount"] != null
          ? isNumeric(p["enricherPremiumAmount"])
              ? toRM(p["enricherPremiumAmount"])
              : p["enricherPremiumAmount"]
          : "";
      String premium = "${toRM(p["basicPlanPremiumAmount"])}\n$enricherPrem";
      plans.add([
        {
          "product": p["productPlanName"],
          "enricher": p["enricherPremiumAmount"] != null
              ? "Enricher\n(Stepped Premium = $stepprem)"
              : "",
          "size": 5
        },
        {"label": toRM(p["sumInsuredAmt"]), "size": 5},
        {"label": premium, "size": 3},
        {"label": "-", "size": 3}
      ]);
    } else {
      plans.add([
        {"product": p["productPlanName"], "size": 5},
        {"label": toRM(p["sumInsuredAmt"]), "size": 5},
        {"label": toRM(p["basicPlanPremiumAmount"]), "size": 3},
        {"label": "-", "size": 3}
      ]);
    }

    if (p["rtuPremiumAmount"] != null &&
        p["rtuPremiumAmount"] != 0 &&
        p["rtuPremiumAmount"] != "0") {
      plans.add([
        {"product": "Regular Top Up", "size": 5},
        {
          "label": isNumeric(p["rtuSumInsured"])
              ? toRM(p["rtuSumInsured"])
              : p["rtuSumInsured"] ?? "N/A",
          "size": 5
        },
        {
          "label": isNumeric(p["rtuPremiumAmount"])
              ? toRM(p["rtuPremiumAmount"])
              : p["rtuPremiumAmount"],
          "size": 3
        },
        {"label": "-", "size": 3}
      ]);
    }

    if (p["adhocAmt"] != null) {
      plans.add([
        {"product": "Ad Hoc Top Up", "size": 5},
        {"label": "N/A", "size": 5},
        {"label": "${p["adhocAmt"]}.00", "size": 3},
        {"label": "-", "size": 3}
      ]);
    }

    var riders = p["riderOutputDataList"];
    if (riders == null || riders.isEmpty) {
      riders = [{}];
    } else {
      riders.forEach((rider) {
        String riderSA;
        if (isNumeric(rider["riderSA"])) {
          riderSA = toRM(rider["riderSA"]);
        } else {
          riderSA = rider["riderSA"];
        }
        if (rider["riderCode"] == "PCHI03") {
          var ratescale = p["guaranteedCashPayment"] == "1"
              ? "Guaranteed Cash Payment(GCP) + Maturity Benefit"
              : "Lump Sum Payment At Maturity";
          plans.add([
            {"product": "IL Savings Growth\n- $ratescale", "size": 5},
            {"label": "N/A", "size": 5},
            {"label": toRM(p["gcpPremAmt"]), "size": 3},
            {"label": "-", "size": 3}
          ]);
        } else if (rider["riderCode"] == "PTHI01") {
          var ratescale = p["guaranteedCashPayment"] == "1"
              ? "To Receive GCP"
              : "Maturity Payments";
          plans.add([
            {"product": "Takafulink Saving Flexi\n- $ratescale", "size": 5},
            {"label": "N/A", "size": 5},
            {"label": toRM(p["gcpPremAmt"]), "size": 3},
            {"label": "-", "size": 3}
          ]);
        } else {
          plans.add([
            {"product": rider["riderName"], "size": 5},
            {"label": riderSA, "size": 5},
            {
              "label": rider["riderMonthlyPremium"] != null &&
                      rider["riderMonthlyPremium"] != "N/A"
                  ? toRM(rider["riderMonthlyPremium"])
                  : rider["riderType"] ?? "N/A",
              "size": 3
            },
            {"label": "-", "size": 3}
          ]);
        }
      });
    }

    var fundList = [];
    if (p["fundOutputDataList"].isNotEmpty) {
      fundList.add([
        {"label": getLocale("Funds"), "size": 5},
        {"label": getLocale("Investment Allocation"), "size": 3}
      ]);
      p["fundOutputDataList"].forEach((fund) {
        fundList.add([
          {"label": fund["fundName"], "size": 5},
          {"label": "${fund["fundAlloc"]}%", "size": 3}
        ]);
      });
    }

    Widget tableContainer(String? title,
        {bool? isTop,
        bool? isLeft,
        bool? isHeader,
        bool? isFooter,
        String? prod,
        String? enricher}) {
      return Container(
          height: isFooter != null ? gFontSize * 3 : null,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(
              vertical: 8, horizontal: isLeft != null && isLeft ? 18 : 8),
          decoration: BoxDecoration(
              color: isFooter != null ? cyanColor : Colors.white,
              border: Border(
                  top: isTop != null
                      ? BorderSide(color: tealGreenColor)
                      : BorderSide(width: 0, color: tealGreenColor),
                  bottom: BorderSide(color: tealGreenColor),
                  left: isLeft != null && isLeft
                      ? BorderSide(color: tealGreenColor)
                      : BorderSide(width: 0, color: tealGreenColor),
                  right: BorderSide(color: tealGreenColor))),
          child: Column(
              crossAxisAlignment: isLeft != null && isLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                prod != null
                    ? RichText(
                        text: TextSpan(
                            text: prod,
                            style: bFontWB(),
                            children: <TextSpan>[
                            TextSpan(
                                text: enricher != null ? "\n$enricher" : "",
                                style: sFontW5())
                          ]))
                    : Text(title ?? "N/A",
                        style: bFontW5().copyWith(
                            color: isFooter != null
                                ? Colors.white
                                : isHeader != null && isHeader
                                    ? greyTextColor
                                    : Colors.black))
              ]));
    }

    Widget tableFooter() {
      return IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Expanded(
                flex: 5,
                child: tableContainer(getLocale("Total Payable"),
                    isLeft: true, isFooter: true)),
            Expanded(
                flex: 3,
                child: tableContainer(
                    toRM(data["listOfQuotation"][0]["totalPremium"], rm: true),
                    isFooter: true))
          ]));
    }

    Widget prodTable(obj) {
      List<Widget> widList = [];
      int i = 0;
      obj.forEach((element) {
        List<Widget> rowWidList = [];
        int j = 0;
        element.forEach((element) {
          if (element["span"] != null) {
            List<Widget> widSpanList = [];
            element["span"].forEach((e) {
              widSpanList.add(Expanded(
                  flex: e["size"],
                  child: tableContainer(e["label"], isHeader: i == 0)));
            });
            rowWidList.add(Expanded(
                flex: element["size"],
                child: Column(children: [
                  tableContainer(element["label"], isHeader: i == 0),
                  Row(children: widSpanList)
                ])));
          } else {
            rowWidList.add(Expanded(
                flex: element["size"],
                child: tableContainer(element["label"],
                    prod: element["product"],
                    enricher: element["enricher"],
                    isHeader: i == 0,
                    isLeft: j == 0)));
          }
          j++;
        });
        i++;
        widList.add(IntrinsicHeight(child: Row(children: rowWidList)));
      });
      return Column(children: widList);
    }

    Widget tsarStatus() {
      String? casetype = getLocale(data["caseindicator"]);

      return Visibility(
          visible: tsar!,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: EdgeInsets.only(bottom: gFontSize * 0.8),
                child: Text(casetype,
                    style: t2FontW5().copyWith(color: tealGreenColor))),
            Padding(
                padding: EdgeInsets.only(bottom: gFontSize * 0.8),
                child: Text(getLocale("Your current proposal details"),
                    style: bFontW5()))
          ]));
    }

    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: gFontSize * 2, vertical: gFontSize * 2),
        margin: EdgeInsets.symmetric(vertical: gFontSize),
        decoration: BoxDecoration(
            color: lightCyanColorSix,
            borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.6))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          p["productPlanLOB"] == "ProductPlanType.traditional" ||
                  p["productPlanCode"] == "PTJI01" ||
                  p["productPlanCode"] == "PTHI01" ||
                  p["productPlanCode"] == "PTHI02"
              ? Container()
              : tsarStatus(),
          p["productPlanLOB"] == "ProductPlanType.traditional"
              ? Row(children: [
                  Expanded(
                      child: Text(getLocale("Entry Age"),
                          style: bFontW5().copyWith(color: greyTextColor))),
                  Expanded(
                      flex: 5,
                      child: Text(data["listOfQuotation"][0]["anb"],
                          style: bFontW5()))
                ])
              : Row(children: [
                  Expanded(
                      child: Text(getLocale("Maturity Age"),
                          style: bFontW5().copyWith(color: greyTextColor))),
                  Expanded(
                      flex: 5,
                      child: Text(data["listOfQuotation"][0]["maturityAge"],
                          style: bFontW5()))
                ]),
          SizedBox(height: gFontSize),
          prodTable(plans),
          tableFooter(),
          Visibility(
              visible: tsar! && p["fundOutputDataList"].isNotEmpty,
              child: Padding(
                  padding: EdgeInsets.only(top: gFontSize * 2),
                  child: prodTable(fundList)))
        ]));
  }
}
