import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/recommended_products.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class RecommendedProductsHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const RecommendedProductsHome({Key? key, required this.callback})
      : super(key: key);
  @override
  RecommendedProductsHomeState createState() => RecommendedProductsHomeState();
}

class RecommendedProductsHomeState extends State<RecommendedProductsHome> {
  dynamic currentTab;
  dynamic tabList;
  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Recommended Products", "RecommendedProducts");
    tabList = {
      "recommendedProducts": {
        "label": getLocale("Recommended Products"),
        "route": RecommendedProducts(
            obj: data["recommendedProducts"],
            info: data,
            onChanged: (value, quo) async {
              if (value != null) data["recommendedProducts"] = value;
              if (quo != null) {
                if (data["listOfQuotation"] == null) {
                  data["listOfQuotation"] = [{}];
                }

                data["listOfQuotation"][0] = quo;
                data["povpmsocc"] = data["policyOwner"]["occupation"];
                data["povpmsage"] = data["policyOwner"]["age"];
                data["povpmssmoke"] = data["policyOwner"]["smoking"];
                data["povpmsgender"] = data["policyOwner"]["gender"];
                data["livpmsocc"] = data["lifeInsured"]["occupation"];
                data["livpmsage"] = data["lifeInsured"]["age"];
                data["livpmssmoke"] = data["lifeInsured"]["smoking"];
                data["livpmsgender"] = data["lifeInsured"]["gender"];
                data["vpmsLastCalculated"] = getTimestamp();

                if (data["forceRequote"] != null && data["forceRequote"]) {
                  data["isRequote"] = true;
                  data["forceRequote"] = false;
                }
              }
              if (data["listOfQuotation"] != null &&
                  data["listOfQuotation"].length > 0) {
                checkCompleted(isSave: true);
              }
            }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["recommendedProducts"]["route"];
    if (data["listOfQuotation"] != null && data["listOfQuotation"].length > 0) {
      checkCompleted(isSave: false, isInit: true);
    }
  }

  void checkCompleted({isSave = true, isInit = false}) async {
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] != null && tabList[key]["required"]) {
        tabList[key]["completed"] = checkRequiredField(data[key]);
      }
      if (tabList[key]["completed"]) {
        tabList[key]["completed"] = !await needRecalculate(data);
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
          child: SingleChildScrollView(
              child: Stack(children: [
        currentTab,
        ApplicationFormData.data["appStatus"] !=
                    AppStatus.incomplete.toString() &&
                ApplicationFormData.data["appStatus"] != "AppStatus.Incomplete"
            ? Positioned.fill(
                child:
                    Container(color: const Color.fromRGBO(255, 255, 255, 0.5)))
            : const SizedBox()
      ])))
    ]);
  }
}
