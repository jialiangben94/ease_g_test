import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/financial_need/disclosure.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class DisclosureHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;
  const DisclosureHome({Key? key, required this.callback}) : super(key: key);

  @override
  DisclosureHomeState createState() => DisclosureHomeState();
}

class DisclosureHomeState extends State<DisclosureHome> {
  dynamic currentTab;
  dynamic tabList;

  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Financial Needs Analysis", "FNA");
    tabList = {
      "disclosure": {
        "label": getLocale("Existing Coverage Disclosure"),
        "route": Disclosure(callback: onDisclosureChanged),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["disclosure"]["route"];
    checkCompleted(isSave: false, isInit: true);
  }

  void onDisclosureChanged() {
    var rec = ApplicationFormData.data["recommendedProducts"];

    if (rec != null && rec["recommendreason"] != null) {
      String reason = rec["recommendreason"];

      if (needReason()) {
        ApplicationFormData.data["recommendedProducts"]["recommendreason"] =
            reason;
      } else {
        if (ApplicationFormData.data["recommendedProducts"] != null) {
          ApplicationFormData.data["recommendedProducts"]
              .remove("recommendreason");
        }
      }
    }

    checkCompleted();
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] =
            checkRequiredField(ApplicationFormData.data[key]);
      }
      if (tabList[key]["required"] == true &&
          tabList[key]["completed"] == false) completed = false;
    }
    setState(() {
      widget.callback(completed, isSave, isInit);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
          padding: EdgeInsets.only(top: gFontSize * 0.3, left: gFontSize * 3),
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
