import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/nomination/benefit_owner.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class BenefitHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const BenefitHome({Key? key, required this.callback}) : super(key: key);
  @override
  BenefitHomeState createState() => BenefitHomeState();
}

class BenefitHomeState extends State<BenefitHome> {
  dynamic currentTab;
  dynamic tabList;
  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Beneficial Owner", "BeneficialOwner");
    tabList = {
      "benefitOwner": {
        "label": getLocale("Beneficial Owner"),
        "route": BenefitOwner(
            obj: data["benefitOwner"],
            onChanged: (value) {
              data["benefitOwner"] = value;
              checkCompleted(isSave: true);
            }),
        "active": false,
        "completed": false,
        "required": true,
        "size": 25
      }
    };
    currentTab = tabList["benefitOwner"]["route"];
    checkCompleted(isSave: true, isInit: true);
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] = checkRequiredField(data[key]);
        if (tabList[key]["completed"] &&
            data[key] != null &&
            data[key]["person"] != null) {
          bool validage = true;
          if (data[key]["person"] is List) {
            data[key]["person"].forEach((person) {
              DateTime date =
                  DateTime.fromMicrosecondsSinceEpoch(person["dob"]);
              var validDOB = validateAge(date, "99");
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
