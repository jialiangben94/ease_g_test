import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/nomination/nomination.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class NominationHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const NominationHome({Key? key, required this.callback}) : super(key: key);
  @override
  NominationHomeState createState() => NominationHomeState();
}

class NominationHomeState extends State<NominationHome> {
  dynamic currentTab;
  dynamic tabList;
  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Nomination and Trustee", "NominationAndTrustee");
    tabList = {
      "nomination": {
        "label": getLocale("Nomination & Trust"),
        "route": Nomination(
            info: data,
            obj: data["nomination"],
            onChanged: (value) {
              data["nomination"] = value;
              checkCompleted(isSave: true);
            }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 25
      }
    };
    currentTab = tabList["nomination"]["route"];
    checkCompleted(isSave: false, isInit: true);
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] = checkRequiredField(data[key]);

        if (tabList[key]["completed"] &&
            data["nomination"] != null &&
            data["nomination"]["nominee"] != null) {
          bool validage = true;
          if (data["nomination"]["nominee"] is List) {
            data["nomination"]["nominee"].forEach((nominee) {
              DateTime date =
                  DateTime.fromMicrosecondsSinceEpoch(nominee["dob"]);
              var validDOB = validateAge(date, "4");
              validage = validage && validDOB["isValid"];
            });
          }
          if (validage &&
              data["nomination"]["trustee"] != null &&
              data["nomination"]["trustee"] is List) {
            data["nomination"]["trustee"].forEach((trustee) {
              DateTime date =
                  DateTime.fromMicrosecondsSinceEpoch(trustee["dob"]);
              var validDOB = validateAge(date, "6");
              validage = validage && validDOB["isValid"];
            });
          }
          tabList[key]["completed"] = validage;
        }
      }
      if (tabList[key]["required"] == true &&
          tabList[key]["completed"] == false) completed = false;
    }

    setState(() {
      widget.callback(completed, isSave, isInit);
    });
  }

  void onTabClicked(obj) {
    FocusScope.of(context).unfocus();
    checkCompleted(isSave: true);
    setState(() {
      for (var key in tabList.keys) {
        tabList[key]["active"] = false;
      }
      obj["active"] = true;
      currentTab = obj["route"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          padding: EdgeInsets.only(
              top: gFontSize * 0.3, left: gFontSize * 3, bottom: 0),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: greyTextColor, width: gFontSize * 0.01))),
          child: ApplicationTabBar(
              tabList: tabList,
              onTap: (tab) {
                onTabClicked(tab);
              })),
      Expanded(
          child: SingleChildScrollView(
              child: Stack(children: [
        currentTab,
        ApplicationFormData.data["appStatus"] !=
                        AppStatus.incomplete.toString() &&
                    ApplicationFormData.data["appStatus"] !=
                        "AppStatus.Incomplete" ||
                (data["tsarRes"] != null &&
                    data["tsarRes"]["VPMSFailAA"] &&
                    data["listOfQuotation"][0]["adhocAmt"] != null)
            ? Positioned.fill(
                child:
                    Container(color: const Color.fromRGBO(255, 255, 255, 0.5)))
            : const SizedBox()
      ])))
    ]);
  }
}
