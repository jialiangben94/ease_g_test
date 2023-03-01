import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/discussion/intermediary.dart';
import 'package:ease/src/screen/new_business/application/discussion/investment_preference.dart';
import 'package:ease/src/screen/new_business/application/discussion/priority.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class FinancialHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const FinancialHome({Key? key, required this.callback}) : super(key: key);
  @override
  FinancialHomeState createState() => FinancialHomeState();
}

class FinancialHomeState extends State<FinancialHome> {
  dynamic currentTab;
  dynamic tabList;
  dynamic fundRisk;

  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen(
        "Potential Area of Discussion", "PotentialAreaOfDiscussion");
    tabList = {
      "priority": {
        "label": getLocale("Needs & Priority"),
        "route": Priority(callback: checkCompleted),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      },
      "investmentPreference": {
        "label": getLocale("Investment Preference"),
        "route": InvestmentPreference(callback: onInvestmentChanged),
        "active": false,
        "completed": false,
        "required": true,
        "size": 30
      },
      "intermediary": {
        "label": getLocale("Intermediary Status"),
        "route": Intermediary(callback: checkCompleted),
        "active": false,
        "completed": false,
        "required": true,
        "size": 30
      }
    };

    currentTab = tabList["priority"]["route"];
    checkCompleted(isSave: false, isInit: true);
  }

  void onInvestmentChanged() {
    var data = ApplicationFormData.data;
    var risk = checkFundRisk();
    var o = data["recommendedProducts"];

    if (o != null && o["riskjustify"] != null) {
      fundRisk = o["riskjustify"].toString();
    }

    if (o != null &&
        risk > data["investmentPreference"]["investmentpreference"]) {
      o["riskjustify"] = fundRisk;
    } else if (risk <= data["investmentPreference"]["investmentpreference"] &&
        o != null &&
        o is Map) {
      o.remove("riskjustify");
    }

    checkCompleted();
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var data = ApplicationFormData.data;
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] = checkRequiredField(data[key]);
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
      ]))
    ]);
  }
}
