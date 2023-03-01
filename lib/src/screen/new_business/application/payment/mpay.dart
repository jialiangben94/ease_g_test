import 'dart:async';
import 'dart:convert';

import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/choice_check.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:flutter/material.dart';

class MPay extends StatefulWidget {
  final dynamic obj;
  final Function(dynamic obj) callback;
  final Function(dynamic obj) onChanged;
  const MPay(
      {Key? key, this.obj, required this.callback, required this.onChanged})
      : super(key: key);
  @override
  MPayState createState() => MPayState();
}

class MPayState extends State<MPay> {
  var data = ApplicationFormData.data;

  String? qrcode;
  var isLoading = true;
  var tab = "qrcode";
  var lockSecond = 60 * 1000 * 1000;
  Timer? emailTimer;
  var timerLabel =
      "${getLocale("Not received email? Resend again after")} {{second}} ${getLocale("second")}.";
  num? currentSecond;

  var email = {
    "type": "email",
    "label": getLocale("Email"),
    "value": "",
    "regex": "",
    "required": true,
    "placeholder": "",
    "column": true,
    "size": {"textWidth": 85, "fieldWidth": 100, "emptyWidth": 0}
  };

  @override
  void initState() {
    super.initState();
    if (data["buyingFor"] == BuyingFor.self.toStr) {
      if (data["payor"] != null) {
        if (data["payor"]["whopaying"] == "policyOwner" ||
            data["payor"]["whopaying"] == "lifeInsured") {
          email["value"] = data["policyOwner"]["email"];
        } else {
          email["value"] = data["payor"]["email"];
        }
      }
    } else {
      if (data["payor"] != null) {
        if (data["payor"]["whopaying"] == "policyOwner") {
          email["value"] = data["policyOwner"]["email"];
        } else if (data["payor"]["whopaying"] == "lifeInsured") {
          email["value"] = data["lifeInsured"]["email"];
        } else {
          email["value"] = data["payor"]["email"];
        }
      }
    }

    analyticsSetCurrentScreen("Scan QR Code", "QRCode");
    var obj = {
      "Method": "GET",
      "Param": {
        "Type": "GETQRCODE",
        "ProposalNo": widget.obj["proposalNo"],
        "RecFlag": 1
      }
    };
    NewBusinessAPI().payment(obj).then((status) {
      startEmailTimer();
      if (status != null &&
          status["IsSuccess"] != null &&
          status["IsSuccess"]) {
        setState(() {
          qrcode = status["QRCode"];
        });
        startPaymentTimer(widget.obj, widget.obj["proposalNo"], (result) {
          Navigator.pop(context, result);
        });
      }
    }).catchError((err) {});
  }

  bool emailLocked() {
    if (widget.obj != null &&
        widget.obj["email"] != null &&
        widget.obj["lastSent"] != null) {
      var diff = getTimestamp() - widget.obj["lastSent"];
      if (diff < lockSecond) {
        return true;
      }
    }
    return false;
  }

  void startEmailTimer() {
    if (emailLocked()) {
      emailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!emailLocked()) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            num diff = lockSecond - (getTimestamp() - widget.obj["lastSent"]);
            diff = diff / 1000 ~/ 1000;
            if (timerLabel.contains("{{second}}")) {
              timerLabel = timerLabel.replaceAll('{{second}}', diff.toString());
            } else {
              timerLabel = timerLabel.replaceAll(
                  currentSecond.toString(), diff.toString());
            }
            currentSecond = diff;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    emailTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget qrcodeContainer() {
      if (tab != "qrcode") {
        return const SizedBox();
      }

      return Column(children: [
        Text(getLocale("Scan the QR code below"), style: t2FontW5()),
        SizedBox(height: gFontSize),
        Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Image.memory(base64Decode(qrcode!),
                width: gFontSize * 12,
                height: gFontSize * 12,
                scale: gFontSize * 0.03)),
        SizedBox(height: gFontSize)
      ]);
    }

    Widget emailContainer() {
      if (tab != "email") {
        return const SizedBox();
      }

      return SizedBox(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            EaseAppTextField(
                obj: email,
                callback: (_) {
                  setState(() {});
                },
                onChanged: (value) {
                  setState(() {
                    email["value"] = value;
                    String? error =
                        validEmail(email["value"], checkAgentEmail: true);
                    if (error != null) {
                      email["error"] = error;
                    } else {
                      email.remove("error");
                    }
                  });
                }),
            SizedBox(height: gFontSize),
            Text(getLocale("Important Note"),
                style: bFontWB().copyWith(color: greyTextColor)),
            Text(
                getLocale(
                    "Make sure customer complete the payment transaction within 1 hour as the payment link will be expired afterward."),
                style: bFontWN().copyWith(color: greyTextColor)),
            SizedBox(height: gFontSize * 3),
            CustomButton(
                label: getLocale("Send Now"),
                fontSize: gFontSize,
                labelColor: Colors.white,
                buttonColor: const Color.fromRGBO(63, 130, 143, 1),
                width: double.infinity,
                onPressed: (emailLocked() ||
                        (email["error"] != null || email["value"] == ""))
                    ? null
                    : () {
                        if (emailLocked()) {
                          return;
                        }
                        startLoading(context);

                        var obj = {
                          "Method": "GET",
                          "Param": {
                            "Type": "MPAYPAYMENTLINK",
                            "email": email["value"],
                            "proposalNo": widget.obj["proposalNo"]
                          }
                        };
                        NewBusinessAPI().payment(obj).then((status) {
                          stopLoading();
                          if (status["IsSuccess"]) {
                            showAlertDialog2(context, "Success", "Email sent!");
                            widget.obj["lastSent"] = getTimestamp();
                            widget.obj["email"] = email["value"];
                            startEmailTimer();
                            widget.onChanged(widget.obj);
                          }
                        }).catchError((err) {
                          stopLoading();

                          showAlertDialog2(
                              context,
                              getLocale("Error"),
                              getLocale(
                                  "Email sent failed please try again later."));
                        });
                      }),
            SizedBox(height: gFontSize),
            emailLocked()
                ? Text(timerLabel,
                    style: bFontWN().copyWith(color: greyTextColor))
                : const SizedBox()
          ]));
    }

    Widget mpayPaymentMethod() {
      if (qrcode == null) {
        return Center(child: containerLoading());
      }
      var paymentMethod = {
        "size": {"textWidth": 85, "fieldWidth": 100, "emptyWidth": 0},
        "label": getLocale("Payment Methods"),
        "type": "option2",
        "options": [
          {
            "label": getLocale("Pay via customer mobile"),
            "value": "qrcode",
            "active": true
          },
          {
            "label": getLocale("Send payment link via email"),
            "value": "email",
            "active": true
          }
        ],
        "value": tab,
        "required": true,
        "column": true,
        "check": true
      };
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: gFontSize * 3, horizontal: gFontSize * 10),
          child: Column(children: [
            ChoiceCheckContainer(
                obj: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    tab = value;
                  });
                }),
            SizedBox(height: gFontSize),
            qrcodeContainer(),
            emailContainer()
          ]));
    }

    Widget amountContainer() {
      var info = ApplicationFormData.data["listOfQuotation"][0];
      String totalPremium;
      if (isNumeric(info["totalPremium"])) {
        totalPremium = toRM(info["totalPremium"], rm: true);
      } else {
        totalPremium = "RM ${info["totalPremium"]}";
      }

      return Container(
          color: honeyColor,
          child: Row(children: [
            Expanded(
                flex: 34,
                child: Text(getLocale("Total payable amount"),
                    style: t1FontWN(), textAlign: TextAlign.right)),
            Expanded(child: Container()),
            Expanded(flex: 34, child: Text(totalPremium, style: t1FontW5()))
          ]));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 8,
                          child: Container(
                              width: screenWidth,
                              height: screenHeight,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: gFontSize * 1.5),
                              child: Stack(children: [
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: CustomButton(
                                        width: gFontSize * 3,
                                        icon: Icons.close,
                                        iconSize: gFontSize * 2,
                                        buttonColor: Colors.transparent,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        })),
                                Center(
                                    child: Text(
                                        "${getLocale("Payment Gateway")}${objMapping[widget.obj["payment"]] != null ? " (${objMapping[widget.obj["payment"]]})" : ""}",
                                        style: t2FontW5()))
                              ]))),
                      Expanded(flex: 8, child: amountContainer()),
                      Expanded(
                          flex: 84,
                          child: Container(
                              width: screenWidth,
                              color: Colors.white,
                              child: mpayPaymentMethod()))
                    ]))));
  }
}
