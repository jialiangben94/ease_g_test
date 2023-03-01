import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/customer/child_insured.dart';
import 'package:ease/src/screen/new_business/application/customer/family_member.dart';
import 'package:ease/src/screen/new_business/application/customer/payor.dart';
import 'package:ease/src/screen/new_business/application/customer/policy_owner.dart';
import 'package:ease/src/screen/new_business/application/customer/guardian.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/expandable_container.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';

class AppCustomerHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const AppCustomerHome({Key? key, required this.callback}) : super(key: key);
  @override
  AppCustomerHomeState createState() => AppCustomerHomeState();
}

class AppCustomerHomeState extends State<AppCustomerHome>
    with SingleTickerProviderStateMixin {
  dynamic tabList;
  var data = ApplicationFormData.data;
  var showBuyingFor = true;
  var scrollController = ScrollController();

  late TabController tabController;
  late int currentIndex;

  var inputList = {
    "buyingFor": {
      "type": "option1",
      "options": [
        {
          "label": getLocale("Himself/herself"),
          "active": true,
          "value": BuyingFor.self.toStr
        },
        {
          "label": getLocale("Spouse"),
          "active": true,
          "value": BuyingFor.spouse.toStr
        },
        {
          "label": getLocale("Children"),
          "active": true,
          "value": BuyingFor.children.toStr
        }
      ],
      "label": getLocale("My client is buying this policy for"),
      "value": BuyingFor.self.toStr,
      "size": {"textWidth": 80, "fieldWidth": 90, "emptyWidth": 10},
      "required": true,
      "column": true
    }
  };

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Customers Details", "CustomersDetails");
    tabController = TabController(vsync: this, length: 5);
    tabController.addListener(_setActiveTabIndex);

    tabList = {
      "policyOwner": {
        "label": getLocale("Policy Owner", entity: true),
        "route": PolicyOwner(
            buyingFor: data["buyingFor"],
            obj: data["policyOwner"],
            onChanged: (value) {
              data["policyOwner"] = value;
              checkCompleted();
            }),
        "active": true,
        "completed": false,
        "required": true,
        "index": 0,
        "size": 39
      },
      "lifeInsured": {
        "label": getLocale("Life Insured", entity: true),
        "route": ChildInsured(
            obj: data["lifeInsured"],
            onChanged: (value) {
              data["lifeInsured"] = value;
              checkCompleted();
            }),
        "active": false,
        "completed": false,
        "required": true,
        "index": 1,
        "size": 29
      },
      "payor": {
        "label": getLocale("Payor"),
        "route": Payor(
            buyingFor: 'self',
            obj: data["payor"],
            info: data,
            onChanged: (value) {
              data["payor"] = value;
              checkCompleted();
            }),
        "active": false,
        "completed": false,
        "required": true,
        "index": 2,
        "size": 20
      },
      "guardian": {
        "label": getLocale("Consent Minor"),
        "route": Guardian(
            obj: data["guardian"],
            onChanged: (value) {
              data["guardian"] = value;
              checkCompleted();
            }),
        "active": false,
        "completed": false,
        "required": true,
        "index": 3,
        "size": 20
      },
      "familyMember": {
        "label": getLocale("Family Member"),
        "route": FamilyMember(
            obj: data["familyMember"],
            onChanged: (value) {
              data["familyMember"] = value;
              checkCompleted(isSave: true);
            }),
        "active": false,
        "completed": false,
        "required": false,
        "index": 4,
        "size": 25
      }
    };
    scrollController.addListener(() {
      if (scrollController.offset < 0.0 && !showBuyingFor) {
        setState(() {
          showBuyingFor = true;
        });
      } else if (scrollController.offset > 0.0 && showBuyingFor) {
        setState(() {
          showBuyingFor = false;
        });
      }
    });

    checkAndChangeTab();
  }

  void _setActiveTabIndex() {
    setState(() {
      currentIndex = tabController.index;
    });
  }

  void checkCompleted({isSave = false, isInit = false}) {
    checkAndChangeTab();
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] &&
          (tabList[key]["enabled"] == null ||
              tabList[key]["enabled"] == true)) {
        tabList[key]["completed"] = checkRequiredField(data[key]);
      }

      if (tabList[key]["required"] == true &&
          tabList[key]["completed"] == false) completed = false;
    }

    setState(() {
      widget.callback(completed, isSave, isInit);
    });
  }

  void onTabClicked(obj, {isSave = true, isInit = false}) {
    FocusScope.of(context).unfocus();
    scrollController.jumpTo(0.0);
    checkCompleted(isSave: isSave, isInit: isInit);

    setState(() {
      tabController.animateTo(obj["index"]);
      for (var key in tabList.keys) {
        tabList[key]["active"] = false;
      }
      obj["active"] = true;
      tabController.animateTo(obj["index"]);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void checkAndChangeTab() {
    if (data["buyingFor"] == null) {
      data["buyingFor"] = inputList["buyingFor"]!["value"];
    } else {
      inputList["buyingFor"]!["value"] = data["buyingFor"];
    }
    if (data["consentMinor"] == null) data["consentMinor"] = false;

    if (data["buyingFor"] == BuyingFor.self.toStr) {
      data["lifeInsured"] = data["policyOwner"];
      if (data["policyOwner"] != null) {
        if (data["policyOwner"]["age"] != null) {
          if (data["policyOwner"]["age"] > 9 &&
              data["policyOwner"]["age"] < 16) {
            data["consentMinor"] = true;
          } else {
            data["consentMinor"] = false;
          }
        }
      }

      tabList["lifeInsured"]["enabled"] = false;
      tabList["policyOwner"]["label"] =
          "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}";

      if (tabController.index == tabList["lifeInsured"]["index"]) {
        tabList["lifeInsured"]["active"] = false;
        tabList["policyOwner"]["active"] = true;
        tabController.animateTo(tabList["policyOwner"]["index"]);
      }
    } else {
      data["consentMinor"] = false;
      tabList["lifeInsured"]["enabled"] = true;
      tabList["policyOwner"]["label"] = getLocale("Policy Owner", entity: true);
    }
    tabList["guardian"]["enabled"] = data["consentMinor"];
    if (!data["consentMinor"]) data.remove("guardian");
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ExpandableContainer(
          expanded: showBuyingFor,
          duration: 400,
          child: Container(
              padding: EdgeInsets.only(
                  top: gFontSize * 2,
                  left: gFontSize * 3,
                  right: gFontSize,
                  bottom: gFontSize * 1.7),
              child: Stack(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  customDropDown(inputList["buyingFor"], (value) {
                    setState(() {
                      if (data["buyingFor"] == BuyingFor.self.toStr &&
                          value != BuyingFor.self.toStr) {
                        data["lifeInsured"] = null;
                      }

                      data["buyingFor"] = value;
                      inputList["buyingFor"]!["value"] = value;

                      checkAndChangeTab();
                      checkCompleted(isSave: true);
                    });
                  }, context),
                  SizedBox(height: gFontSize * 0.5)
                ]),
                ApplicationFormData.data["appStatus"] !=
                            AppStatus.incomplete.toString() ||
                        (data["tsarRes"] != null &&
                            data["tsarRes"]["VPMSFailAA"] &&
                            data["listOfQuotation"][0]["adhocAmt"] != null)
                    ? Positioned.fill(
                        child: Container(
                            color: const Color.fromRGBO(255, 255, 255, 0.5)))
                    : const SizedBox()
              ]))),
      Container(
          padding: EdgeInsets.only(
              top: gFontSize * 0.3, left: gFontSize * 2.5, right: gFontSize),
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
          child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
            SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  PolicyOwner(
                      buyingFor: data["buyingFor"],
                      obj: data["policyOwner"],
                      onChanged: (value) {
                        data["policyOwner"] = value;
                        checkCompleted();
                      }),
                  ApplicationFormData.data["appStatus"] !=
                              AppStatus.incomplete.toString() ||
                          (data["tsarRes"] != null &&
                              data["tsarRes"]["VPMSFailAA"] &&
                              data["listOfQuotation"][0]["adhocAmt"] != null)
                      ? Positioned.fill(
                          child: Container(
                              color: const Color.fromRGBO(255, 255, 255, 0.5)))
                      : const SizedBox()
                ])),
            Visibility(
                visible: data["buyingFor"] != BuyingFor.self.toStr,
                child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Stack(children: [
                      ChildInsured(
                          buyingFor: data["buyingFor"],
                          obj: data["lifeInsured"],
                          onChanged: (value) {
                            data["lifeInsured"] = value;
                            checkCompleted();
                          }),
                      ApplicationFormData.data["appStatus"] !=
                                  AppStatus.incomplete.toString() ||
                              (data["tsarRes"] != null &&
                                  data["tsarRes"]["VPMSFailAA"] &&
                                  data["listOfQuotation"][0]["adhocAmt"] !=
                                      null)
                          ? Positioned.fill(
                              child: Container(
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.5)))
                          : const SizedBox()
                    ]))),
            SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  Payor(
                      buyingFor: data["buyingFor"],
                      obj: data["payor"],
                      info: data,
                      onChanged: (value) {
                        data["payor"] = value;
                        checkCompleted();
                      }),
                  ApplicationFormData.data["appStatus"] !=
                              AppStatus.incomplete.toString() ||
                          (data["tsarRes"] != null &&
                              data["tsarRes"]["VPMSFailAA"] &&
                              data["listOfQuotation"][0]["adhocAmt"] != null)
                      ? Positioned.fill(
                          child: Container(
                              color: const Color.fromRGBO(255, 255, 255, 0.5)))
                      : const SizedBox()
                ])),
            Visibility(
                visible: data["consentMinor"],
                child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Stack(children: [
                      Guardian(
                          obj: data["guardian"],
                          onChanged: (value) {
                            data["guardian"] = value;
                            checkCompleted();
                          }),
                      ApplicationFormData.data["appStatus"] !=
                                  AppStatus.incomplete.toString() ||
                              (data["tsarRes"] != null &&
                                  data["tsarRes"]["VPMSFailAA"] &&
                                  data["listOfQuotation"][0]["adhocAmt"] !=
                                      null)
                          ? Positioned.fill(
                              child: Container(
                                  color:
                                      const Color.fromRGBO(255, 255, 255, 0.5)))
                          : const SizedBox()
                    ]))),
            SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  FamilyMember(
                      obj: data["familyMember"],
                      onChanged: (value) {
                        data["familyMember"] = value;
                        checkCompleted(isSave: true);
                      }),
                  ApplicationFormData.data["appStatus"] !=
                              AppStatus.incomplete.toString() ||
                          (data["tsarRes"] != null &&
                              data["tsarRes"]["VPMSFailAA"] &&
                              data["listOfQuotation"][0]["adhocAmt"] != null)
                      ? Positioned.fill(
                          child: Container(
                              color: const Color.fromRGBO(255, 255, 255, 0.5)))
                      : const SizedBox()
                ]))
          ]))
    ]);
  }
}
