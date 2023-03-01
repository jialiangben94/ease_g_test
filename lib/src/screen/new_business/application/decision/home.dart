import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/decision/decision.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class DecisionHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const DecisionHome({Key? key, required this.callback}) : super(key: key);

  @override
  DecisionHomeState createState() => DecisionHomeState();
}

class DecisionHomeState extends State<DecisionHome> {
  var data = ApplicationFormData.data;
  dynamic tabList;
  dynamic currentTab;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Assessment/Decision", "Assessment/Decision");
    tabList = {
      "decision": {
        "label": getLocale("Product Summary & Decision"),
        "route": Decision(
            info: data,
            callback: (value) {
              data["decision"] = value;
              checkCompleted(isSave: true);
            }),
        "active": true,
        "completed": true,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["decision"]["route"];
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

  void onTabClicked(obj) {
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
      Expanded(child: currentTab)
    ]);
  }
}
