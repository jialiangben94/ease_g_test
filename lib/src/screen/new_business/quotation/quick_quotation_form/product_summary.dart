import 'package:collection/collection.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class ProductSummary extends StatelessWidget {
  final Quotation quotation;
  final QuickQuotation quickQtn;
  final String totalPremium;
  final String totalPremiumWithoutAdhoc;
  final bool reviewStatement;

  const ProductSummary(this.quotation, this.quickQtn, this.totalPremium,
      this.totalPremiumWithoutAdhoc, this.reviewStatement,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<RiderOutputData> riderOutputDataList = [];
    riderOutputDataList = quickQtn.riderOutputDataList ?? [];

    var enricher = [];

    if (quickQtn.enricherPremiumAmount != null &&
        quickQtn.enricherPremiumAmount != "0.00") {
      //This is just dummy list to render table view.
      enricher.add("A");
    }
    Widget proposalDetails(String col1, String col2) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Expanded(
                flex: 1,
                child: Text(col1,
                    style: t2FontW5().copyWith(color: greyTextColor))),
            Expanded(flex: 2, child: Text(col2, style: t2FontW5()))
          ]));
    }

    Widget th(String label) {
      return Container(
          constraints: const BoxConstraints(minHeight: 60),
          decoration: BoxDecoration(
              color: creamColor,
              border: const Border(bottom: BorderSide(width: 1.0))),
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(label, textAlign: TextAlign.left)]));
    }

    Widget td(String text) {
      if (text.contains("RM ")) {
        String total = text.replaceAll("RM ", "");
        return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("RM", style: t2FontWB()),
                  Text(total, style: t2FontWB())
                ]));
      }
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Text(text, style: t2FontWB()));
    }

    TableRow tableHeader(List<String> value) {
      List<Widget> children = [];
      for (var element in value) {
        children.add(th(element));
      }
      return TableRow(children: children);
    }

    TableRow tableContent(List<String> value) {
      List<Widget> children = [];
      for (var element in value) {
        children.add(td(element));
      }
      return TableRow(children: children);
    }

    Widget basicPlanTableSummary() {
      List<String> header = [
        "(A) Basic Plan",
        getLocale("Sum Insured"),
        "${getLocale("Payment Term", entity: true)}\n(${getLocale("Years")})",
        quickQtn.productPlanLOB == "ProductPlanType.traditional"
            ? "${getLocale("Term of Coverage")}\n(${getLocale("Years")})"
            : "${getLocale("Policy Term", entity: true)}\n(${getLocale("Years")})",
        isNumeric(quickQtn.paymentMode)
            ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
            : "${quickQtn.paymentMode} Premium"
      ];

      if (quickQtn.productPlanLOB == "ProductPlanType.traditional") {
        header = [
          "(A) Basic Plan",
          getLocale("Initial Sum Insured"),
          getLocale("Premium Term", entity: true),
          getLocale("Term of Coverage"),
          isNumeric(quickQtn.paymentMode)
              ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
              : "${quickQtn.paymentMode} Premium"
        ];
      }

      List<List<String>> basicplan = [
        [
          quickQtn.productPlanName ?? "-",
          quickQtn.basicPlanSumInsured != null
              ? toRM(quickQtn.basicPlanSumInsured, rm: true)
              : "-",
          quickQtn.basicPlanPaymentTerm ?? quickQtn.premiumTerm ?? "-",
          quickQtn.basicPlanPolicyTerm ?? quickQtn.policyTerm ?? "-",
          quickQtn.basicPlanPremiumAmount != null
              ? toRM(quickQtn.basicPlanPremiumAmount, rm: true)
              : "-"
        ]
      ];

      if (quickQtn.enricherPremiumAmount != null &&
          quickQtn.enricherPremiumAmount != "" &&
          quickQtn.enricherPremiumAmount != "0.00") {
        basicplan.add([
          "Enricher",
          "N/A",
          quickQtn.enricherPolicyTerm != null &&
                  quickQtn.enricherPolicyTerm != ""
              ? quickQtn.enricherPolicyTerm!
              : "-",
          quickQtn.enricherPaymentTerm != null &&
                  quickQtn.enricherPaymentTerm != ""
              ? quickQtn.enricherPaymentTerm!
              : "-",
          toRM(quickQtn.enricherPremiumAmount, rm: true)
        ]);
      }

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Table(
              border: TableBorder(
                  horizontalInside:
                      BorderSide(width: 1.4, color: greyDividerColor)),
              columnWidths: const {
                0: FlexColumnWidth(5),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(3),
                4: FlexColumnWidth(3)
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
              children: [
                tableHeader(header),
                for (int i = 0; i < basicplan.length; i++)
                  tableContent(basicplan[i])
              ]));
    }

    List<TableRow> riderList(riderOutputDataList) {
      List<RiderOutputData> riderOutput = riderOutputDataList;
      List<TableRow> tablerow = [];
      List<List<String>> plan = [];

      for (var rider in riderOutput) {
        // Traditional rider summary
        if (quickQtn.productPlanLOB == "ProductPlanType.traditional") {
          plan.add([
            rider.riderName ?? "-",
            (rider.isUnitBasedProd != null && rider.isUnitBasedProd!)
                ? rider.riderSA as String
                : isNumeric(rider.riderSA)
                    ? toRM(rider.riderSA, rm: true)
                    : rider.riderSA as String,
            rider.riderPaymentTerm ?? "-",
            rider.riderOutputTerm ?? "-",
            rider.riderMonthlyPremium != null &&
                    rider.riderMonthlyPremium != "N/A"
                ? toRM(rider.riderMonthlyPremium, rm: true)
                : rider.riderType ?? "N/A"
          ]);
        } else {
          if (rider.riderCode == "PCHI03") {
            var ratescale = quickQtn.guaranteedCashPayment == "1"
                ? "Guaranteed Cash Payment(GCP) + Maturity Benefit"
                : "Lump Sum Payment At Maturity";
            plan.add([
              "IL Savings Growth\n- $ratescale",
              "N/A",
              quickQtn.gcpPremTerm ?? "-",
              quickQtn.gcpTerm ?? "-",
              toRM(quickQtn.gcpPremAmt, rm: true)
            ]);
          } else if (rider.riderCode == "PTHI01") {
            var ratescale = quickQtn.guaranteedCashPayment == "1"
                ? "To Receive GCP"
                : "Maturity Payments";
            plan.add([
              "Takafulink Saving Flexi\n- $ratescale",
              "N/A",
              quickQtn.gcpPremTerm ?? "-",
              quickQtn.gcpTerm ?? "-",
              toRM(quickQtn.gcpPremAmt, rm: true)
            ]);
          } else if (quickQtn.productPlanCode == "PCJI02") {
            plan.add([
              rider.riderName ?? "-",
              rider.riderType ?? "-",
              isNumeric(rider.riderSA)
                  ? toRM(rider.riderSA, rm: true)
                  : rider.riderSA as String,
              rider.riderOutputTerm ?? "-",
              rider.riderType == "Unit Deducting Rider"
                  ? "N/A"
                  : rider.riderMonthlyPremium != null &&
                          rider.riderMonthlyPremium != "N/A"
                      ? toRM(rider.riderMonthlyPremium, rm: true)
                      : rider.riderType ?? "N/A"
            ]);
          } else {
            plan.add([
              rider.riderName ?? "-",
              isNumeric(rider.riderSA)
                  ? toRM(rider.riderSA, rm: true)
                  : rider.riderSA as String,
              rider.riderOutputTerm ?? "-",
              rider.riderPaymentTerm ?? "-",
              rider.riderMonthlyPremium != null &&
                      rider.riderMonthlyPremium != "N/A"
                  ? toRM(rider.riderMonthlyPremium, rm: true)
                  : rider.riderType ?? "N/A"
            ]);
          }
        }
      }
      for (var element in plan) {
        tablerow.add(tableContent(element));
      }
      return tablerow;
    }

    Widget riderTableSummary() {
      List<String> header = [
        "(B) ${getLocale("Riders")}",
        getLocale('Sum Insured'),
        getLocale('Payment Term', entity: true),
        getLocale('Riders Term'),
        isNumeric(quickQtn.paymentMode)
            ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
            : "${quickQtn.paymentMode} Premium"
      ];
      if (quickQtn.productPlanCode == "PCJI02") {
        header = [
          "(B) ${getLocale("Riders")}",
          getLocale("Type"),
          getLocale('Sum Insured'),
          getLocale("Riders Policy Term"),
          isNumeric(quickQtn.paymentMode)
              ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
              : "${quickQtn.paymentMode} Premium"
        ];
      }
      if (quickQtn.productPlanLOB == "ProductPlanType.traditional") {
        header = [
          "(B) ${getLocale("Riders")}",
          "${getLocale("Initial Sum Insured")} / ${getLocale("Units")}",
          getLocale("Premium Term", entity: true),
          getLocale("Term of Coverage"),
          isNumeric(quickQtn.paymentMode)
              ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
              : "${quickQtn.paymentMode} Premium"
        ];
      }
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(children: [
            Table(
                border: TableBorder(
                    horizontalInside:
                        BorderSide(width: 1.4, color: greyDividerColor)),
                columnWidths: const {
                  0: FlexColumnWidth(5),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                  3: FlexColumnWidth(3),
                  4: FlexColumnWidth(3)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  tableHeader(header),
                  ...riderList(riderOutputDataList)
                ]),
            Visibility(
                visible: quickQtn.productPlanCode != "PCHI03" &&
                    quickQtn.riderOutputDataList!.isEmpty,
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(getLocale("- No Rider Selected -")))))
          ]));
    }

    Widget rtuTableSummary() {
      List<String> header = [
        "(C) ${getLocale("Regular Top Up")}",
        getLocale('Payment Term', entity: true),
        getLocale('RTU Term'),
        isNumeric(quickQtn.paymentMode)
            ? getLocale("${convertPaymentMode(quickQtn.paymentMode)} Premium")
            : '${quickQtn.paymentMode} ${getLocale("Premium")}'
      ];

      List<String> rtu = [
        getLocale("Regular Top Up"),
        quickQtn.rtuPaymentTerm ?? "-",
        quickQtn.rtuPolicyTerm ?? "-",
        toRM(
            quickQtn.rtuAmt != null && quickQtn.rtuAmt != "-"
                ? quickQtn.rtuAmt
                : 0,
            rm: true)
      ];

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(children: [
            Table(
                border: TableBorder(
                    horizontalInside:
                        BorderSide(width: 1.4, color: greyDividerColor)),
                columnWidths: const {
                  0: FlexColumnWidth(8),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(3),
                  3: FlexColumnWidth(3),
                  4: FlexColumnWidth(3)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [tableHeader(header), tableContent(rtu)])
          ]));
    }

    Widget summaryTable() {
      String abc = "";
      String totalpremtext = "";
      if (quickQtn.eligibleRiders != null &&
          quickQtn.eligibleRiders!.isNotEmpty) {
        abc = " (A + B)";
        if (quickQtn.productPlanLOB != "ProductPlanType.traditional") {
          abc = " (A + B + C)";
        }
      }
      if (quickQtn.paymentMode != null) {
        if (isNumeric(quickQtn.paymentMode)) {
          totalpremtext =
              "${getLocale("Total")} ${getLocale(convertPaymentMode(quickQtn.paymentMode))} ${getLocale("Premium")} $abc";
        } else {
          totalpremtext =
              "${getLocale("Total")} ${getLocale(quickQtn.paymentMode!)} ${getLocale("Premium")} $abc";
        }
      }
      return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
              color: lightCyanColor,
              child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(14),
                    1: FlexColumnWidth(3)
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text(totalpremtext,
                              textAlign: TextAlign.left, style: t2FontWN())),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text(
                              toRM(
                                  // quickQtn.totalPremOccLoad ??
                                  quickQtn.adhocAmt != "0" ||
                                          quickQtn.adhocAmt != null
                                      ? totalPremiumWithoutAdhoc
                                      : totalPremium,
                                  rm: true),
                              textAlign: TextAlign.left,
                              style: t2FontWB())),
                    ])
                  ])));
    }

    Widget adhocSummaryTable() {
      String totaladhoctext = "";
      if (quickQtn.paymentMode != null) {
        if (isNumeric(quickQtn.paymentMode)) {
          totaladhoctext = getLocale("Ad Hoc Top-Up Contribution at Inception");
        }
      }

      return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
              color: lightCyanColorFive,
              child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(9),
                    1: FlexColumnWidth(2)
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text(totaladhoctext,
                              textAlign: TextAlign.left, style: t2FontWN())),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text(toRM(quickQtn.adhocAmt, rm: true),
                              textAlign: TextAlign.left, style: t2FontWB())),
                    ])
                  ])));
    }

    String? lobstr;
    var lob = quickQtn.productPlanLOB;
    if (isNumeric(lob)) {
      lobstr = lookupProductLOB.keys
          .firstWhereOrNull((k) => lookupProductLOB[k] == lob);
    } else if (lob is String) {
      var llob = convertProductPlan(lob);
      lobstr = convertProductPlan(llob);
    }
    Person? la = quotation.lifeInsured;

    String? brpstr;
    var campaign = quickQtn.campaign;
    if (campaign != null) {
      if (campaign.campaignName == "BRP Code") {
        brpstr = campaign.campaignRemarks;
      }
    }

    return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          proposalDetails(getLocale("Product LOB"), lobstr ?? ""),
          brpstr == null
              ? Container()
              : proposalDetails(getLocale("BRP Code"), brpstr),
          proposalDetails(
              getLocale("Occupation"), la!.occupation!.occupationName ?? "-"),
          proposalDetails(getLocale("Occupation Class"),
              la.occupation!.occupationClass ?? "-"),
          quickQtn.productPlanLOB == "ProductPlanType.traditional"
              ? Container()
              : proposalDetails(
                  getLocale("Stepped Premium"),
                  quickQtn.isSteppedPremium != null
                      ? quickQtn.isSteppedPremium!
                          ? getLocale("Yes")
                          : getLocale("No")
                      : getLocale("No")),
          proposalDetails(
              getLocale("Payment Mode"),
              quickQtn.paymentMode == null
                  ? "-"
                  : isNumeric(quickQtn.paymentMode)
                      ? getLocale(convertPaymentMode(quickQtn.paymentMode))
                      : quickQtn.paymentMode!),
          quickQtn.productPlanLOB == "ProductPlanType.traditional"
              ? proposalDetails(getLocale("Entry Age"), quickQtn.anb ?? "-")
              : proposalDetails(
                  getLocale("Maturity Age"), quickQtn.maturityAge ?? "-"),
          const SizedBox(height: 20),
          basicPlanTableSummary(),
          if (quickQtn.eligibleRiders != null &&
              quickQtn.eligibleRiders!.isNotEmpty)
            riderTableSummary(),
          quickQtn.productPlanLOB == "ProductPlanType.traditional" ||
                  quickQtn.rtuAmt == "0" ||
                  quickQtn.rtuAmt == null
              ? Container()
              : rtuTableSummary(),
          summaryTable(),
          quickQtn.adhocAmt == "0" || quickQtn.adhocAmt == null
              ? Container()
              : adhocSummaryTable(),
          const SizedBox(height: 10),
          Visibility(
              visible: reviewStatement,
              child: Center(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Icon(Icons.check, color: cyanColor),
                    const SizedBox(width: 10),
                    Text(
                        "${getLocale("Premium last reviewed on")} ${quickQtn.lastUpdatedTime}",
                        style: TextStyle(color: cyanColor))
                  ])))
        ]));
  }
}
