import 'dart:convert';

export 'package:ease/src/screen/new_business/application/application_enum.dart';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/screen/new_business/application/application_main.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/data/new_business_model/application_dao.dart';
import 'package:ease/src/screen/new_business/application/application_summary/application_summary.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/row_container.dart';
import 'package:ease/src/widgets/popup_menu.dart';
import 'package:ease/src/util/function.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationListHome extends StatefulWidget {
  final AppStatus? appStatus;
  final int? dayValid;
  const ApplicationListHome({Key? key, this.appStatus, this.dayValid})
      : super(key: key);
  @override
  ApplicationListHomeState createState() => ApplicationListHomeState();
}

class ApplicationListHomeState extends State<ApplicationListHome> {
  final applicationDao = ApplicationDao();
  dynamic data;

  @override
  void initState() {
    super.initState();
    getData().then((record) {
      filterData(record);
    });
  }

  dynamic updateData(record) async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getString(spkAgent) != null) {
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      var item = json.decode(json.encode(record.value));
      var changed = false;
      if (item["agentCodes"] == null) {
        item["agentCodes"] = agent.accountCode;
        changed = true;
      }
      if (item["agentCodes"] == agent.accountCode) {
        DateTime now = DateTime.now();
        DateTime date = DateTime(now.year, now.month, now.day);
        // check if submitted
        if (item["remote"] != null &&
            item["remote"]["remoteStatus"] != null &&
            item["remote"]["remoteStatus"]["resSubmit"] != null) {
          item["application"] = item["remote"]["remoteStatus"]["resSubmit"];
        }
        if (item["application"] != null) {
          // check remote status
          // check if submitted
          if (item["remote"] != null &&
              item["remote"]["remoteStatus"] != null &&
              item["remote"]["remoteStatus"]["resSubmit"] != null) {
            bool remoteComplete = true;
            List<dynamic> verifyStatus = item["remote"]["listOfRecipient"]
                .map((value) => value["VerifyStatus"])
                .toList();
            if (verifyStatus.any((value) => value != "5")) {
              remoteComplete = false;
            }
            if (remoteComplete) {
              item["application"] = item["remote"]["remoteStatus"]["resSubmit"];
              var payor = item["remote"]["listOfRecipient"].firstWhere(
                  (remote) => remote["isPayor"] == true,
                  orElse: () => null);
              if (payor != null) {
                dynamic recipient = item["remote"]["remoteStatus"]
                        ["ClientRemoteList"]
                    .firstWhere(
                        (remote) => (remote["nric"] == payor["IDNum"] &&
                            remote["ClientName"] == payor["name"]),
                        orElse: () => null);
                if (item["payment"] != null &&
                    item["payment"]["payment"] != null &&
                    (item["payment"]["payment"] != "creditdebit" ||
                        item["payment"]["payment"] != "fpx") &&
                    recipient != null &&
                    recipient["VerifyStatus"] == "5") {
                  recipient["PaymentStatus"] = "3";
                  item["appStatus"] = AppStatus.completed.toString();
                  if (widget.appStatus == AppStatus.completed) {
                    item["application"]["ApplicationStatus"] =
                        await getAppStatus([item["application"]["ProposalNo"]]);
                  }
                  item["needReassessment"] = false;
                  changed = true;
                } else {
                  if (recipient != null &&
                      recipient["PaymentStatus"] == "9" &&
                      recipient["VerifyStatus"] == "5") {
                    item["appStatus"] = AppStatus.completed.toString();
                    if (widget.appStatus == AppStatus.completed) {
                      item["application"]["ApplicationStatus"] =
                          await getAppStatus(
                              [item["application"]["ProposalNo"]]);
                    }
                    item["needReassessment"] = false;
                    changed = true;
                  }
                }
              } else {
                if (item["payment"] != null &&
                    item["payment"]["paymentStatus"] == "0") {
                  item["appStatus"] = AppStatus.completed.toString();
                  if (widget.appStatus == AppStatus.completed) {
                    item["application"]["ApplicationStatus"] =
                        await getAppStatus([item["application"]["ProposalNo"]]);
                  }
                  item["needReassessment"] = false;
                  changed = true;
                }
              }
            }
          } else {
            if (item["payment"] != null &&
                item["payment"]["paymentStatus"] == "0") {
              item["appStatus"] = AppStatus.completed.toString();
              if (widget.appStatus == AppStatus.completed) {
                item["application"]["ApplicationStatus"] =
                    await getAppStatus([item["application"]["ProposalNo"]]);
              }
              item["needReassessment"] = false;
              changed = true;
            }
          }
        }

        if (!changed) {
          // if assessment expire
          if (item["assessmentDate"] != null &&
              item["assessmentDate"] < getTimestamp(date: date)) {
            // if not submitted/complete yet, reset assessment
            if (item["appStatus"] != AppStatus.completed) {
              item["appStatus"] = AppStatus.incomplete.toString();
              item["assessmentDate"] = null;
              item["tsarRes"] = null;
              item["decision"] = null;
              item["application"] = null;
              item["declaration"] = null;
              item["payment"] = null;
              item["SetID"] = null;
              item["tsarqtype"] = null;
              item["qtype"] = null;

              if (item["guardian"] != null) {
                item["guardiansign"] = null;
              }
              if (item["trusteesign"] != null) {
                item["trusteesign"] = null;
              }
              if (item["agent"] != null) {
                item["agent"] = null;
              }
              if (item["witness"] != null) {
                item["witness"]["signature"] = null;
              }
              item["needReassessment"] = true;
              changed = true;
            }
          } else {
            if (item["tsarRes"] != null && item["decision"] != null) {
              item["needReassessment"] = false;
              changed = true;
            }
          }
        }
      }

      return {"key": record.key, "value": item, "changed": changed};
    }
  }

  bool isExpired(dynamic dateTime) {
    if (widget.dayValid != null) {
      var age = getAgeInDays(DateTime.fromMicrosecondsSinceEpoch(dateTime));
      return age > widget.dayValid!;
    } else {
      return false;
    }
  }

  void filterData(record) async {
    var tempData = [];
    List<int> ids = [];
    List<Map<String, Object?>> items = [];
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

    for (var i = 0; i < record.length; i++) {
      var updated = await updateData(record[i]);
      if (updated["value"]["agentCodes"] == agent.accountCode) {
        if (updated != null &&
            isExpired(updated["value"]["createdTimestamp"])) {
          await applicationDao.delete(updated["key"]);
        } else {
          if (updated != null && updated["changed"] == true) {
            ids.add(updated["key"]);
            items.add(Map<String, Object?>.from(updated['value']));
          }
          if (updated != null && updated["value"] != null) {
            if (updated["value"]["appStatus"] == widget.appStatus.toString()) {
              tempData.add(updated);
            } else if (widget.appStatus == AppStatus.incomplete &&
                updated["value"]["appStatus"] !=
                    AppStatus.completed.toString()) {
              tempData.add(updated);
            }
          }
        }
      }
    }

    if (ids.isNotEmpty) {
      await applicationDao.bulkUpdate(ids, items);
    }

    if (mounted) {
      setState(() {
        data = tempData;
      });
    }
  }

  Future<dynamic> getData() async {
    var record = await applicationDao.getAllData();
    return record.reversed.toList();
  }

  void refreshData() async {
    var record = await getData();
    filterData(record);
  }

  Future<void> refreshData2() async {
    setState(() {
      refreshData();
    });
  }

  void onEditTap(id) {
    Navigator.of(context)
        .push(createRoute(ApplicationForm(appQuoId: id)))
        .then((_) {
      refreshData();
    });
  }

  void onViewTap(id) {
    Navigator.of(context)
        .push(createRoute(ApplicationSummary(appQuoId: id)))
        .then((_) {
      refreshData();
    });
  }

  void onDeleteTap(id, name) async {
    var result = await showConfirmDialog(context, getLocale("Delete"),
        "${getLocale("Are you sure you want to delete")} ${(name ?? "")}?");
    if (result != null && result) {
      await applicationDao.delete(id);
      refreshData();
    }
  }

  Future<dynamic> getAppStatus(List<String?> props) async {
    var value = await NewBusinessAPI().getApplicationStatus(props);
    return value["StatusList"][0];
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    var swd = screenWidth / dScreenWidth;
    var shd = screenHeight / dScreenHeight;
    gFontSize = ((dScreenWidth * swd) + (dScreenHeight * shd)) * 0.010051;

    Widget buildHeader() {
      int? cal = data.length;

      return Container(
          padding: EdgeInsets.only(top: gFontSize * 1.7, bottom: gFontSize),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${getLocale("We found a total of")} $cal ${getLocale("application(s)")}",
                    style: bFontWN().copyWith(color: greyTextColor)),
              ]));
    }

    Widget applicationStatus(bool? isVisible, String status) {
      isVisible = isVisible ?? false;
      Color bgColor = darkerCreamColor;
      Color titleColor = honeyColor;
      if (status == "paid") {
        bgColor = lightCyanColorThree;
        titleColor = tealGreenColor;
      } else if (status == "update") {
        bgColor = darkerCreamColor;
        titleColor = orangeColor;
      } else if (status == "reassess") {
        bgColor = lightPinkColor;
        titleColor = scarletRedColor;
      }
      return Visibility(
          visible: isVisible,
          child: Container(
              decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(20),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: status == "paid"
                            ? Icon(Icons.check, color: titleColor)
                            : Container()),
                    Expanded(
                        child: Text(
                            status == "reassess"
                                ? getLocale("Reassessment required")
                                : getLocale("Payment accepted"),
                            style: sFontW5().copyWith(color: titleColor)))
                  ])));
    }

    Widget buildTableItem(val) {
      var item = val["value"];
      if (item != null && item["policyOwner"] == null) {
        item["policyOwner"] = {};
      }
      if (item != null && item["lifeInsured"] == null) {
        item["lifeInsured"] = {};
      }
      if (item != null &&
          (item["listOfQuotation"] == null ||
              item["listOfQuotation"].length == 0)) {
        item["listOfQuotation"] = [];
        item["listOfQuotation"].add({"a": ""});
      }

      dynamic amount = "-";

      if (item["listOfQuotation"][0]["totalPremium"] != null) {
        amount = RichText(
            text: TextSpan(
                text:
                    toRM(item["listOfQuotation"][0]["totalPremium"], rm: true),
                style: bFontWN(),
                children: <TextSpan>[
              TextSpan(
                  text: getLocale('\nmonthly'),
                  style: ssFontWN()
                      .copyWith(color: Colors.black, fontFamily: "Meta"))
            ]));
      }
      var obj = [
        {
          "size": 5,
          "value": Row(children: [
            CircleAvatar(
                radius: gFontSize,
                backgroundColor: lightGreyColor2,
                child: Text(
                    (item["policyOwner"]["name"] != null
                        ? item["policyOwner"]["name"][0]
                        : "-"),
                    style: bFontW5().copyWith(color: greyTextColor))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text((item["policyOwner"]["name"] ?? "-"),
                        style: bFontWB())))
          ])
        },
        {"size": 4, "value": (item["lifeInsured"]["name"] ?? "-")}
      ];
      if (widget.appStatus == AppStatus.completed) {
        obj.add({"size": 4, "value": item["application"]["ProposalNo"] ?? "-"});
      }
      String? date;
      if (widget.appStatus == AppStatus.completed) {
        date = getStandardDateFormat(timestamp: item["applicationDate"]);
      } else if (item["listOfQuotation"][0]["dateTime"] != null) {
        date = item["listOfQuotation"][0]["dateTime"];
      }
      obj.addAll([
        {"size": 4, "value": date},
        {
          "size": widget.appStatus == AppStatus.completed ? 3 : 4,
          "value": item["listOfQuotation"][0]["productPlanName"] ?? "-"
        },
        {"size": 4, "value": amount}
      ]);
      String? appstatus;
      if (widget.appStatus == AppStatus.completed) {
        if (item["application"]["ApplicationStatus"] != null) {
          if (item["application"]["ApplicationStatus"]["LeaderAckStatus"] !=
                  null &&
              item["application"]["ApplicationStatus"]["LeaderAckStatus"] !=
                  "No Leader Acknowledgement") {
            if (item["application"]["ApplicationStatus"]["LeaderAckStatus"] ==
                "Pending") {
              appstatus = item["application"]["ApplicationStatus"]
                      ["LeaderAckStatus"] +
                  " Leader Approval";
            } else {
              appstatus =
                  item["application"]["ApplicationStatus"]["LeaderAckStatus"];
            }
          } else if (item["application"]["ApplicationStatus"]
                      ["FailSubmitReason"] !=
                  null &&
              (item["application"]["ApplicationStatus"]["FailSubmitReason"] ==
                      "Failed" ||
                  item["application"]["ApplicationStatus"]["LeaderAckStatus"] !=
                      "No Leader Acknowledgement")) {
            appstatus =
                item["application"]["ApplicationStatus"]["FailSubmitReason"];
          } else if (item["application"]["ApplicationStatus"]
                  ["ApplicationStatus"] !=
              null) {
            appstatus =
                item["application"]["ApplicationStatus"]["ApplicationStatus"];
          }
        }
        obj.add({
          "size": 3,
          "value": Text((appstatus ?? "-"),
              style: sFontWN().copyWith(color: greyTextColor))
        });
      }
      obj.addAll([
        {
          "size": widget.appStatus == AppStatus.incomplete ? 3 : 2,
          "value": GestureDetector(
              onTap: () {
                widget.appStatus == AppStatus.completed
                    ? onViewTap(val["key"])
                    : onEditTap(val["key"]);
              },
              child: Text(
                  widget.appStatus == AppStatus.completed
                      ? "${getLocale("View")} >"
                      : "${getLocale("Continue")} >",
                  style: TextStyle(color: cyanColor)))
        }
      ]);
      if (widget.appStatus == AppStatus.incomplete) {
        obj.add({
          "size": 1,
          "value": PopupMenu(
              items: [getLocale("Edit"), getLocale("Delete")],
              onSelected: (value) {
                if (value == 0) {
                  onEditTap(val["key"]);
                } else if (value == 1) {
                  onDeleteTap(val["key"], item["policyOwner"]["name"]);
                }
              })
        });
      }

      return Container(
          decoration: BoxDecoration(
              border:
                  Border.all(width: gFontSize * 0.08, color: greyBorderColor),
              borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.3))),
          child: Column(children: [
            RowContainer(
                arrayObj: obj,
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(
                    horizontal: gFontSize, vertical: gFontSize * 0.5)),
            applicationStatus(
                item["application"] != null &&
                        item["application"]["ApplicationStatus"] != null
                    ? item["application"]["ApplicationStatus"]["IsPaymentDone"]
                    : item["needReassessment"] ?? false,
                item["needReassessment"] != null && item["needReassessment"]
                    ? "reassess"
                    : "paid")
          ]));
    }

    Widget buildTableTitle() {
      //Size base on table item calculation
      var obj = [
        {
          "size": 5,
          "value": Text(getLocale("Policy Owner", entity: true),
              style: sFontWN().copyWith(color: greyTextColor))
        },
        {
          "size": 4,
          "value": Text(getLocale("Life Insured", entity: true),
              style: sFontWN().copyWith(color: greyTextColor))
        }
      ];
      if (widget.appStatus == AppStatus.completed) {
        obj.add({
          "size": 4,
          "value": Text(getLocale("Proposal No."),
              style: sFontWN().copyWith(color: greyTextColor))
        });
      }
      obj.addAll([
        {
          "size": 4,
          "value": Text(
              widget.appStatus == AppStatus.completed
                  ? getLocale("Submitted date")
                  : getLocale("Requested date"),
              style: sFontWN().copyWith(color: greyTextColor))
        },
        {
          "size": widget.appStatus == AppStatus.completed ? 3 : 4,
          "value": Text(
              widget.appStatus == AppStatus.completed
                  ? getLocale("Product")
                  : getLocale("Selected Product"),
              style: sFontWN().copyWith(color: greyTextColor))
        },
        {
          "size": 4,
          "value": Text(getLocale("Premium Amount"),
              style: sFontWN().copyWith(color: greyTextColor))
        }
      ]);
      if (widget.appStatus == AppStatus.completed) {
        obj.add({
          "size": 3,
          "value": Text(getLocale("Status"),
              style: sFontWN().copyWith(color: greyTextColor))
        });
      }
      obj.addAll([
        {
          "size": widget.appStatus == AppStatus.incomplete ? 3 : 2,
          "value": Text(getLocale("Action"),
              style: sFontWN().copyWith(color: greyTextColor))
        }
      ]);
      if (widget.appStatus == AppStatus.incomplete) {
        obj.add({"size": 1, "value": ""});
      }

      return RowContainer(
          arrayObj: obj,
          color: Colors.transparent,
          padding:
              EdgeInsets.symmetric(horizontal: gFontSize, vertical: gFontSize));
    }

    List<Widget> buildTableItems() {
      List<Widget> inWidList = [];

      data.sort((a, b) {
        if (widget.appStatus == AppStatus.completed) {
          DateTime asubmitted = DateTime.now();
          DateTime bsubmitted = DateTime.now();
          if (a["value"]["applicationDate"] != null) {
            asubmitted = DateTime.fromMicrosecondsSinceEpoch(
                a["value"]["applicationDate"]);
          }
          if (b["value"]["applicationDate"] != null) {
            bsubmitted = DateTime.fromMicrosecondsSinceEpoch(
                b["value"]["applicationDate"]);
          }
          return bsubmitted.compareTo(asubmitted);
        } else {
          DateTime acreate = DateTime.now();
          DateTime bcreate = DateTime.now();
          if (a["value"]["listOfQuotation"] != null &&
              a["value"]["listOfQuotation"][0]["dateTime"] != null) {
            acreate = DateFormat("dd MMM yyyy")
                .parse(a["value"]["listOfQuotation"][0]["dateTime"]);
          }
          if (b["value"]["listOfQuotation"] != null &&
              b["value"]["listOfQuotation"][0]["dateTime"] != null) {
            bcreate = DateFormat("dd MMM yyyy")
                .parse(b["value"]["listOfQuotation"][0]["dateTime"]);
          }
          return bcreate.compareTo(acreate);
        }
      });

      for (var i = 0; i < data.length; i++) {
        inWidList.add(buildTableItem(data[i]));
        inWidList.add(SizedBox(height: gFontSize * 0.3));
      }
      return inWidList;
    }

    Widget buildInitialInput() {
      return SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                    width: gFontSize * 7.5,
                    height: gFontSize * 8,
                    image: const AssetImage('assets/images/no_appt_icon.png')),
                Text(getLocale("No application found"),
                    style: sFontWN().copyWith(color: Colors.grey)),
                SizedBox(height: gFontSize * 2)
              ]));
    }

    Widget buildTable() {
      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 2.2),
          child: Column(children: [
            buildHeader(),
            buildTableTitle(),
            Expanded(
                child: RefreshIndicator(
                    color: honeyColor,
                    onRefresh: refreshData2,
                    child: ListView(children: buildTableItems())))
          ]));
    }

    Widget buildLoaded() {
      return data != null
          ? data.length != 0
              ? buildTable()
              : buildInitialInput()
          : buildLoading();
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700), child: buildLoaded()));
  }
}
