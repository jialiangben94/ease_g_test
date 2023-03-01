import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/application_tabbar.dart';
import 'package:ease/src/screen/new_business/application/payment/payment.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';

import 'package:flutter/material.dart';

class PaymentHome extends StatefulWidget {
  final Function(bool completed, bool isSave, bool isInit) callback;

  const PaymentHome({Key? key, required this.callback}) : super(key: key);
  @override
  PaymentHomeState createState() => PaymentHomeState();
}

class PaymentHomeState extends State<PaymentHome> {
  var data = ApplicationFormData.data;
  dynamic tabList;
  dynamic currentTab;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Payment", "Payment");
    tabList = {
      "payment": {
        "label": getLocale("Payment"),
        "route": Payment(
            obj: data["payment"],
            info: data,
            onChanged: (value) {
              data["payment"] = value;
              checkCompleted(isSave: true);
            }),
        "active": true,
        "completed": false,
        "required": true,
        "size": 30
      }
    };
    currentTab = tabList["payment"]["route"];
  }

  void checkCompleted({isSave = true, isInit = false}) {
    var completed = true;
    for (var key in tabList.keys) {
      if (data["payment"] != null &&
          data["payment"]["remotePayment"] != null &&
          data["payment"]["remotePayment"]) {
        tabList["payment"]["completed"] = true;
      } else {
        if (tabList[key]["required"] != null && tabList[key]["required"]) {
          if (data[key]["paymentStatus"] != null &&
              data[key]["paymentStatus"] == paymentStatus[PayS.pending]) {
            tabList[key]["completed"] = false;
          } else {
            tabList[key]["completed"] = checkRequiredField(data[key]);
          }
        }
      }
      if (tabList[key]["required"] == true &&
          tabList[key]["completed"] == false) completed = false;
    }
    if (mounted) {
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
      Expanded(child: currentTab)
    ]);
  }
}
