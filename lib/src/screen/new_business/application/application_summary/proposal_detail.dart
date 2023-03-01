import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class ProposalDetails extends StatefulWidget {
  final dynamic applicationData;
  final dynamic applicationStatus;
  const ProposalDetails(this.applicationData, this.applicationStatus,
      {Key? key})
      : super(key: key);
  @override
  ProposalDetailsState createState() => ProposalDetailsState();
}

class ProposalDetailsState extends State<ProposalDetails> {
  List<Map<String, dynamic>> firstCol = [];
  List<Map<String, dynamic>> secondCol = [];
  dynamic appStatus;
  dynamic data;

  late bool hide;
  final GlobalKey _key = GlobalKey();
  RenderBox? renderBox;

  @override
  void initState() {
    data = widget.applicationData;
    appStatus = widget.applicationStatus;
    setPropData();
    hide = false;
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _getSizes());
  }

  void _getSizes() {
    setState(() {
      if (_key.currentContext != null) {
        renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
      }
    });
  }

  void setPropData() {
    String? applicationStatus = "-";
    String? paymentStatus = "-";

    if (appStatus != null && appStatus["ApplicationStatus"] != null) {
      applicationStatus = appStatus["ApplicationStatus"];
      if (appStatus != null && appStatus["PropStatus"] != null) {
        applicationStatus = "${applicationStatus!}. ${appStatus["PropStatus"]}";
      }
    }
    if (appStatus != null && appStatus["PaymentStatus"] != null) {
      if (appStatus["PaymentStatus"]) {
        paymentStatus = "Paid";
      } else {
        paymentStatus = "Pending Payment";
      }
    }

    setState(() {
      firstCol = [
        {
          "title": getLocale("Policy Owner", entity: true),
          "desc": data["policyOwner"]["name"]
        }
      ];
      secondCol = [
        {
          "title": getLocale("Proposal No."),
          "desc": data["application"]["ProposalNo"]
        }
      ];
      if (data["buyingFor"] != BuyingFor.self.toStr) {
        firstCol.add({
          "title": getLocale("Life Insured", entity: true),
          "desc": data["lifeInsured"]["name"]
        });
      }
      firstCol.addAll([
        {
          "title": getLocale("Selected Product"),
          "desc": data["listOfQuotation"][0]["productPlanName"]
        },
        {
          "title": getLocale("Payment Status"),
          "desc": paymentStatus != "Paid" ? paymentStatus : null,
          "status": paymentStatus != "Pending Payment" ? paymentStatus : null
        }
      ]);
      if (paymentStatus != "Pending Payment") {
        firstCol.add({
          "title": getLocale("Payment Date"),
          "desc": paymentStatus != "Pending Payment"
              ? data["applicationDate"] != null
                  ? DateFormat('dd MMM yyyy').format(
                      DateTime.fromMicrosecondsSinceEpoch(
                          data["applicationDate"]))
                  : "-"
              : "-"
        });
      }

      secondCol.add({
        "title": getLocale("Proposal Status"),
        "desc": appStatus != null && appStatus["PropStatus"] != null
            ? appStatus["PropStatus"]
            : "-"
      });
      if (appStatus != null &&
          appStatus["LeaderAckStatus"] != null &&
          appStatus["LeaderAckStatus"] != "No Leader Acknowledgement") {
        secondCol.addAll([
          {
            "title": getLocale("Leader Approval Status"),
            "desc": appStatus != null && appStatus["LeaderAckStatus"] != null
                ? appStatus["LeaderAckStatus"]
                : "-"
          },
          {
            "title": getLocale("Leader Approval Date"),
            "desc": appStatus != null && appStatus["LeaderAckDatetime"] != null
                ? appStatus["LeaderAckDatetime"]
                : "-"
          }
        ]);
      }
      secondCol.add({
        "title": getLocale("Application Status"),
        "status": appStatus != null && appStatus["ApplicationStatus"] != null
            ? appStatus["ApplicationStatus"]
            : "-"
      });

      if (appStatus != null &&
          appStatus["ApplicationStatus"] != null &&
          appStatus["ApplicationStatus"] == "Submitted") {
        secondCol.add({
          "title": "Submitted Date",
          "desc": appStatus != null && appStatus["SubmittedDatetime"] != null
              ? DateFormat('dd MMM yyyy')
                  .format(DateTime.parse(appStatus["SubmittedDatetime"]))
              : DateFormat('dd MMM yyyy').format(
                  DateTime.fromMicrosecondsSinceEpoch(data["applicationDate"]))
        });
      }

      if ((appStatus != null && appStatus["FailSubmitReason"] != null) &&
          (appStatus["ApplicationStatus"] == "Failed" ||
              appStatus["LeaderAckStatus"] != "No Leader Acknowledgement")) {
        secondCol.add({
          "title": "Reason(s) of Failed Submission",
          "failed": appStatus != null && appStatus["FailSubmitReason"] != null
              ? appStatus["FailSubmitReason"]
              : "-"
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget customRow(String title, String? details,
        {String? status, String? failed}) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: Text(title, style: bFontWN())),
            Expanded(
                flex: 3,
                child: Text(status ?? failed ?? details!,
                    style: bFontW5().copyWith(
                        color: status != null
                            ? cyanColor
                            : failed != null
                                ? scarletRedColor
                                : Colors.black)))
          ]));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(
                child: Text(getLocale("Proposal Details"),
                    style: tFontW5().copyWith(color: Colors.black))),
            InkWell(
                onTap: () {
                  _getSizes();
                  setState(() {
                    hide = !hide;
                  });
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(hide ? getLocale("Show") : getLocale("Hide"),
                      style: bFontW5().copyWith(color: cyanColor)),
                  Icon(
                      hide
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: cyanColor)
                ]))
          ])),
      AnimatedContainer(
          height: hide
              ? 0
              : renderBox != null
                  ? renderBox!.size.height + 10
                  : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linearToEaseOut,
          child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(key: _key, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Column(
                          children: firstCol.map((element) {
                    return customRow(element["title"], element["desc"],
                        status: element["status"], failed: element["failed"]);
                  }).toList())),
                  Expanded(
                      child: Column(
                          children: secondCol.map((element) {
                    return customRow(element["title"], element["desc"],
                        status: element["status"], failed: element["failed"]);
                  }).toList()))
                ])
              ])))
    ]);
  }
}
