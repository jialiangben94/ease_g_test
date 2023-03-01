import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/declaration/agent.dart';
import 'package:ease/src/screen/new_business/application/declaration/declaration.dart';
import 'package:ease/src/screen/new_business/application/declaration/witness.dart';
import 'package:ease/src/screen/new_business/application/declaration/consent_minor.dart';
import 'package:ease/src/screen/new_business/application/declaration/trusteesign.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class DeclarationHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const DeclarationHome({Key? key, required this.callback}) : super(key: key);
  @override
  DeclarationHomeState createState() => DeclarationHomeState();
}

class DeclarationHomeState extends State<DeclarationHome> {
  dynamic tabList;
  dynamic currentTab;
  var data = ApplicationFormData.data;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Declaration", "Declaration");
    if (data["guardiansign"] != null &&
        data["guardiansign"]["signature"] == null) {
      data["guardiansign"]["signature"] = null;
    }
    tabList = {
      "declaration": {
        "label":
            "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}",
        "route": Declaration(onChanged: (value) {
          data["declaration"] = value;
          if (value["status"] == "sent") {
            data["reassessmentCounter"] = 0;
          }
          cancelRemote(value, "declaration");
          checkCompleted(isSave: true);
        }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 25
      },
      "guardiansign": {
        "label": getLocale("Consent For Minor"),
        "route": ConsentMinor(
            obj: data["guardiansign"],
            info: data,
            onChanged: (value) {
              data["guardiansign"] = value;
              if (value["status"] == "sent") {
                data["reassessmentCounter"] = 0;
              }
              cancelRemote(value, "guardian");
              checkCompleted(isSave: true);
            }),
        "active": false,
        "completed": false,
        "required": true,
        "enabled": true,
        "size": 25
      },
      "trusteesign": {
        "label": getLocale("Trustee"),
        "route": TrusteeSign(
            obj: data["trusteesign"],
            info: data,
            onChanged: (value) {
              data["trusteesign"] = value;
              if (value["status"] == "sent") {
                data["reassessmentCounter"] = 0;
              }
              cancelRemote(value, "trustee");
              checkCompleted(isSave: true);
            }),
        "active": false,
        "completed": false,
        "required": true,
        "enabled": true,
        "size": 16
      },
      "witness": {
        "label": getLocale("Witness"),
        "route": Witness(onChanged: (value) {
          data["witness"] = value;
          if (value["status"] == "sent") {
            data["reassessmentCounter"] = 0;
          }
          cancelRemote(value, "witness");
          checkCompleted(isSave: true);
        }),
        "active": false,
        "completed": false,
        "required": true,
        "size": 16
      },
      "agent": {
        "label": getLocale("Agent"),
        "route": AgentDeclaration(
            obj: data["agent"],
            onChanged: (value) {
              data["agent"] = value;
              checkCompleted(isSave: true);
            }),
        "active": false,
        "completed": false,
        "required": true,
        "size": 16
      }
    };
    currentTab = tabList["declaration"]["route"];
    if (data["nomination"] != null &&
        data["nomination"]["trustee"] != null &&
        data["nomination"]["trustee"].length > 0) {
      tabList["trusteesign"]["enabled"] = true;
    } else {
      tabList["trusteesign"]["enabled"] = false;
    }
    if (data["consentMinor"] != null && data["consentMinor"]) {
      tabList["guardiansign"]["enabled"] = true;
    } else {
      tabList["guardiansign"]["enabled"] = false;
    }
    checkCompleted(isSave: false, isInit: true);
  }

  void cancelRemoteAPI(List<dynamic> clientList) async {
    List<dynamic> newClientList = [];
    for (var element in clientList) {
      if (element["ClientID"] != null) {
        newClientList.add(element);
      }
    }
    if (newClientList.isNotEmpty) {
      var obj = {
        "Method": "PUT",
        "Body": {
          "SetID": data["SetID"].toString(),
          "ClientID": remoteClientListID(newClientList),
          "VerifyStatus": "8",
          "Remark": "",
          "IsResend": false,
          "Via": "",
          "ViaDetail": ""
        }
      };
      await NewBusinessAPI()
          .remote(obj)
          .then((res) {})
          .onError((dynamic error, stackTrace) {});
    }
  }

  void cancelRemote(value, String type) {
    if (data["remote"] != null &&
        data["remote"]["isSentRemote"] != null &&
        data["remote"]["isSentRemote"]) {
      List<dynamic> clientList = [];
      var remoteList = updateRemoteStatus(
          data["remote"]["listOfRecipient"], data["remote"]["remoteStatus"]);

      remoteList.forEach((element) {
        if (type == "declaration") {
          if (element["clientType"] == "1" || element["clientType"] == "3") {
            if (!data["declaration"]["ownerIdentity"]["remote"] &&
                element["VerifyStatus"] != null) {
              clientList.add(element);
            }
          } else if (element["clientType"] == "2") {
            if (!data["declaration"]["insuredIdentity"]["remote"] &&
                element["VerifyStatus"] != null) {
              clientList.add(element);
            }
          } else if (element["clientType"] == "7") {
            if (!data["declaration"]["payorIdentity"]["remote"] &&
                element["VerifyStatus"] != null) {
              clientList.add(element);
            }
          }
        } else if (type == "guardian" && element["clientType"] == "11") {
          if (!data["guardiansign"]["remote"] &&
              element["VerifyStatus"] != null) {
            clientList.add(element);
          }
        } else if (type == "trustee" && element["clientType"] == "6") {
          String key = "Identity-${element["nric"]}";
          if (!data["trusteesign"][key]["remote"] &&
              element["VerifyStatus"] != null) {
            clientList.add(element);
          }
        } else if (type == "witness" && element["clientType"] == "8") {
          if (data["witness"]["remote"] != null &&
              !data["witness"]["remote"] &&
              element["VerifyStatus"] != null) {
            clientList.add(element);
          }
        }
      });
      if (clientList.isNotEmpty) cancelRemoteAPI(clientList);
    }
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    for (var key in tabList.keys) {
      if (tabList[key]["required"] == true) {
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
