import 'dart:convert';

import 'package:ease/main.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/three_size_dot.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<FormState> _shareSIMIFormKey = GlobalKey<FormState>();
TextEditingController _emailAddressCont = TextEditingController();

void sendEmailAPI(BuildContext context, Quotation quotation,
    QuickQuotation quickQuotation, String base64) async {
  Navigator.pop(context);
  loadingSend(navigatorKey.currentContext!);

  var pref = await SharedPreferences.getInstance();
  Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

  var encodeJson = {
    "CustomerName": quotation.lifeInsured!.name,
    "CustomerEmail": _emailAddressCont.text,
    "ProductName": quickQuotation.productPlanName,
    "AgentEmail": agent.emailAddress,
    "AttachFile": base64,
    "IsPasswordProtected": false
  };
  var obj = {
    "Method": "POST",
    "Param": {"Type": "EMAIL"},
    "Body": {"Quotation": encodeJson}
  };
  try {
    await NewBusinessAPI().quotation(obj).then((res) async {
      Navigator.pop(navigatorKey.currentContext!);
      if (res != null && res["IsSuccess"]) {
        await analyticsSendEvent(
            "share_si", {"email_address": _emailAddressCont.text});
        sendComplete(navigatorKey.currentContext!, true);
      } else {
        sendComplete(navigatorKey.currentContext!, false);
      }
    });
  } catch (e) {
    Navigator.pop(navigatorKey.currentContext!);
    sendComplete(navigatorKey.currentContext!, false);
  }
}

void loadingSend(BuildContext context) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ThreeSizeDot(
                          color_1: honeyColor,
                          color_2: honeyColor,
                          color_3: honeyColor),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text(getLocale("Sending Email"),
                              style: t2FontWB().copyWith(fontSize: 24)))
                    ])));
      });
}

void sendComplete(BuildContext context, bool complete) {
  showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.4,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
                child: Column(children: [
                  const SizedBox(height: 36),
                  complete
                      ? const Image(
                          width: 90,
                          height: 90,
                          image: AssetImage('assets/images/submitted_icon.png'))
                      : Icon(Icons.cancel_outlined,
                          size: 60, color: scarletRedColor),
                  Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                          complete
                              ? getLocale("Sent!")
                              : getLocale("Failed to sent"),
                          style: t2FontWB().copyWith(fontSize: 24)))
                ])));
      });
}

void showShareDialogBox(BuildContext context, Quotation quotation,
    QuickQuotation? quickQuotation, String base64) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                title: Text(getLocale("Share your SI/MI with customer"),
                    style: t2FontWN().copyWith(fontSize: 24)),
                titlePadding:
                    const EdgeInsets.only(top: 40, left: 42, right: 42),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 42),
                content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.46,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                getLocale(
                                    "Please key in customer’s email address"),
                                style: bFontWN()),
                            Form(
                                key: _shareSIMIFormKey,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: TextFormField(
                                        controller: _emailAddressCont,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return getLocale(
                                                'Please enter email address');
                                          }
                                          return null;
                                        },
                                        textInputAction: TextInputAction.next,
                                        cursorColor: Colors.grey,
                                        style: bFontWN(),
                                        decoration: const InputDecoration(
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0)),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0)))))),
                            const SizedBox(height: 10)
                          ])),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0))),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 20)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(getLocale('Cancel'),
                                        style: t1FontWB())),
                                TextButton(
                                    style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6.0))),
                                        backgroundColor: honeyColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 60, vertical: 20)),
                                    onPressed: () async {
                                      if (_shareSIMIFormKey.currentState!
                                          .validate()) {
                                        sendEmailAPI(context, quotation,
                                            quickQuotation!, base64);
                                      }
                                    },
                                    // shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.all(
                                    //         Radius.circular(6.0))),
                                    // color: honeyColor,
                                    // padding: EdgeInsets.symmetric(
                                    //     horizontal: 60, vertical: 20),
                                    child: Text(getLocale('Send'),
                                        style: t1FontWB()))
                              ]))
                    ]))));
      });
}
