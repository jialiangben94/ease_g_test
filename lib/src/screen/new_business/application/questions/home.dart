import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/questions/health_questions.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class QuestionsHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const QuestionsHome({Key? key, required this.callback}) : super(key: key);
  @override
  QuestionsHomeState createState() => QuestionsHomeState();
}

class QuestionsHomeState extends State<QuestionsHome> {
  var data = ApplicationFormData.data;
  dynamic tabList;
  dynamic currentTab;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Question Life Insured", "QuestionLifeInsured");
    tabList = {
      "liquestions": {
        "label": getLocale("Health Questions"),
        "route": HealthQuestions(
            clientType: data["buyingFor"] == "self" ? "3" : "2",
            obj: data["liquestions"],
            info: data["lifeInsured"],
            product: data["listOfQuotation"][0],
            title: getLocale("Life Insured", entity: true),
            onChanged: (value) {
              data["liquestions"] = value;
              checkCompleted(isSave: true);
            }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["liquestions"]["route"];
    checkCompleted(isSave: false, isInit: true);
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    String? qtype = data["qtype"];
    var p = data["listOfQuotation"][0];
    if (qtype == null || qtype.isEmpty) {
      dynamic qsetup = questionSetup
          .firstWhere((element) => element["ProdCode"] == p["productPlanCode"]);
      var riders = p["riderOutputDataList"];
      if (riders.length > 0) {
        qtype = qsetup["Type"][0]["riderQuest"];
      } else {
        qtype = qsetup["Type"][0]["gpQuest"];
      }
    }
    qtype = questionType.keys
        .firstWhere((k) => questionType[k] == int.parse(qtype!));

    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] = checkRequiredField(data[key]);
      }
      if (qtype == "IsFullQuest") {
        tabList[key]["completed"] =
            tabList[key]["completed"] && isHeightWeightValid(data[key]);
      }

      if (tabList[key]["required"] == true &&
          tabList[key]["completed"] == false) completed = false;

      setState(() {
        widget.callback(completed, isSave, isInit);
      });
    }
  }

  void onTabClicked(obj) {
    FocusScope.of(context).unfocus();
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
                    AppStatus.incomplete.toString() ||
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
