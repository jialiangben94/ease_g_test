import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/remote/remote.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';

class RemoteHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const RemoteHome({Key? key, required this.callback}) : super(key: key);
  @override
  RemoteHomeState createState() => RemoteHomeState();
}

class RemoteHomeState extends State<RemoteHome> {
  dynamic currentTab;
  dynamic tabList;
  var data = ApplicationFormData.data;
  bool isSendAll = false;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Remote", "Remote");
    tabList = {
      "remote": {
        "label": getLocale("Remote"),
        "route": Remote(
            obj: data["remote"],
            info: data,
            onChanged: (value) {
              bool sentremote = false;
              String? setID;
              var listOfRecipient = [];
              setState(() {
                data["remote"]["listOfRecipient"].forEach((element) {
                  if (element["role"] == value["role"] &&
                      element["nric"] == value["nric"]) {
                    listOfRecipient.add(value);
                  } else {
                    listOfRecipient.add(element);
                  }
                  if (value["status"] != "") sentremote = true;
                  if (value["SetID"] != null && value["SetID"] != "") {
                    setID = value["SetID"];
                  }
                });
                data["remote"]["listOfRecipient"] = listOfRecipient;
                data["SetID"] = setID;
                data["remote"]["isSentRemote"] = sentremote;
              });
              checkCompleted(isSave: true);
            },
            remoteChange: () {
              String? setID;
              var value = {
                "readAndAgree": false,
                "agreeMarketing": false,
                "ownerIdentity": {
                  "signature": null,
                  "identityFront": null,
                  "identityBack": null
                },
                "empty": null,
                "isSignRemote": false
              };
              data["declaration"] = value;
              data["remote"]["listOfRecipient"].forEach((element) {
                if (element["SetID"] != null && element["SetID"] != "") {
                  setID = element["SetID"];
                }
              });
              if (setID != null) data["SetID"] = setID;
              checkCompleted(isSave: true);
            }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["remote"]["route"];
    checkCompleted(isSave: false, isInit: false);
  }

  void checkCompleted({isSave = true, isInit = true}) {
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Stack(children: [currentTab]));
  }
}
