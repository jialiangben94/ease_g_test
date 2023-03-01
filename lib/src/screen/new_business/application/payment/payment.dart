import 'dart:async';
import 'dart:convert';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/recommended_products/product_table.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/check_circle.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/widgets/choice_check.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/screen/new_business/application/payment/application_completed.dart';
import 'package:ease/src/screen/new_business/application/payment/mpay.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Payment extends StatefulWidget {
  final dynamic obj;
  final dynamic info;
  final Function(dynamic obj) onChanged;
  const Payment({Key? key, this.obj, this.info, required this.onChanged})
      : super(key: key);
  @override
  PaymentState createState() => PaymentState();
}

class PaymentState extends State<Payment> {
  Timer? timer;
  int? countdown = 0;

  late dynamic inputList;
  dynamic obj;
  dynamic info;
  dynamic mapInfo;
  dynamic signatureInputList;
  late dynamic widList;
  bool enabled = false;
  bool isRemotePayment = false;
  Agent? agent;

  TapGestureRecognizer? termsConditionRecognizer;
  TapGestureRecognizer? privacyNoticeRecognizer;

  @override
  void initState() {
    super.initState();
    termsConditionRecognizer = TapGestureRecognizer()
      ..onTap = () {
        showTNC();
      };
    privacyNoticeRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        if (await canLaunchUrl(
            Uri.parse('https://etiqa.com.my/v2/privacy-notice'))) {
          await launchUrl(Uri.parse('https://etiqa.com.my/v2/privacy-notice'));
        }
      };

    obj = widget.obj;
    info = json.decode(json.encode(widget.info)) ?? {};

    if (info["payor"] != null && info["payor"]["whopaying"] == "policyOwner") {
      if (info["declaration"] != null &&
          info["declaration"]["ownerIdentity"] != null) {
        isRemotePayment = info["declaration"]["ownerIdentity"]["remote"];
      }
    } else if (info["payor"] != null &&
        info["payor"]["whopaying"] == "lifeInsured") {
      if (info["declaration"] != null &&
          info["declaration"]["insuredIdentity"] != null) {
        isRemotePayment = info["declaration"]["insuredIdentity"]["remote"];
      }
    } else if (info["payor"] != null &&
        info["payor"]["whopaying"] == "othersrelation") {
      if (info["declaration"] != null &&
          info["declaration"]["payorIdentity"] != null) {
        isRemotePayment = info["declaration"]["payorIdentity"]["remote"];
      }
    }

    filterEmptyValue(info);

    inputList = {
      "payment": {
        "size": {"textWidth": 85, "fieldWidth": 45, "emptyWidth": 0},
        "label": getLocale("Choose a payment method"),
        "type": "option2",
        "options": [],
        "value": "",
        "required": true,
        "column": true,
        "optionColumn": true,
        "check": true
      },
      "agreement": {
        "type": "radiocheck",
        "label": "",
        "value": false,
        "enabled": false,
        "required": true
      }
    };

    if (info["payment"] != null && info["payment"]["payment"] != null) {
      inputList["payment"]["value"] = info["payment"]["payment"];
      if (info["payment"] != null && info["payment"]["agreement"] != null) {
        inputList["agreement"]["value"] = info["payment"]["agreement"];
      }
      enableExtraField(inputList["payment"]["value"]);
    }
    getAgentDetails();
  }

  Future showTNC() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SystemPadding(
              child: Center(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.38),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.98,
                          height: MediaQuery.of(context).size.height * 0.95,
                          child: AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 0),
                              title: Row(children: [
                                Expanded(
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                        child: Text(
                                            getLocale(
                                                "TERMS AND CONDITIONS FOR CREDIT/DEBIT CARD AUTHORISATION (AUTOPAY) VISA/ MASTERCARD / AMEX"),
                                            style: bFontW5().copyWith(
                                                decoration: TextDecoration
                                                    .underline)))),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close))
                              ]),
                              content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: RichText(
                                            text: TextSpan(
                                                text:
                                                    "${getLocale("In consideration of your agreement to accept my authorization to you to debit my Visa / MasterCard / Amex Card account to pay for my insurance premium(s), I expressly agree to the following Terms and Conditions:\n1. I authorise Etiqa Life Insurance Berhad to debit my Visa / MasterCard / Amex Card account for payment of my insurance premium(s) under the given Proposal / Policy Number.\n2. The first debit will be made anytime from the date of submission of the Credit/Debit Card Authorisation (AutoPay) Visa / MasterCard / Amex Payment Instruction Form.\n3. I shall accept full responsibility for all transactions arising from the use of my Visa / MasterCard / Amex Card for payment of my premium(s).\n4. Etiqa Life Insurance Berhad shall not be held responsible or liable for any claims, loss, damage, cost and expenses arising from the successful processing of the debit due to exceeding credit limit, malfunction of the system, electrical failure and any other factors beyond the control of Etiqa Life Insurance Berhad.\n5. Etiqa Life Insurance Insurance Berhad is only responsible for making arrangement to debit my Visa / MasterCard / Amex Card account through the Card Centre as authorised by me. Therefore, for any problems or disputes arising from the processing / debiting of my Visa / MasterCard / Amex Card account will be at my own responsibility to resolve it with my Card company.\n6. I will ensure that Etiqa Life Insurance Berhad is notified in writing of any changes, loss or replacement of my Visa / MasterCard / Amex Card or cancellation of this authorisation at least one month before the next premium(s) due. Such changes or cancellation will become effective only after Etiqa Life Insurance Berhad has duly acknowledged receipt of such request.\n7. Etiqa Life Insurance Berhad may at its absolute discretion at any time terminate the Visa / MasterCard / Amex Card debiting arrangement if the proposal / policy inactive.\n8. Etiqa Life Insurance Berhad reserves the right to change the Terms and Conditions set out herein at any time or from time to time when circumstances warrant without giving prior notice to me.\n9. The premium payment(s) that is/are payable will be considered as paid only upon successful processing of the debiting by the Card Centre.\n10. The insurance coverage shall only commenced from the date of approval of the application subject to the full premium being paid according to terms and conditions specified in policy contract.\n11. I/We agree and consent that Etiqa Life Insurance Berhad and/or its service providers may collect, use and process my personal information (whether obtained in this form or otherwise obtained) and disclose such information in accordance with Etiqa Life Insurance Berhad’s Privacy Notice as found at")} ",
                                                style: sFontWN(),
                                                children: [
                                          TextSpan(
                                              text:
                                                  'https://etiqa.com.my/v2/privacy-notice',
                                              style: sFontWN().copyWith(
                                                  decoration:
                                                      TextDecoration.underline),
                                              recognizer:
                                                  privacyNoticeRecognizer),
                                          TextSpan(
                                              text:
                                                  '\n12. ${getLocale("In the event of any conflict or discrepancy between these Terms and Conditions in English and Malay language, the English version shall prevail.")}',
                                              style: sFontWN())
                                        ])))
                                  ]))))));
        });
  }

  Future<void> getAgentDetails() async {
    final pref = await SharedPreferences.getInstance();
    agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    setState(() {});
  }

  void setAllField(o, field, value) {
    for (var key in o.keys) {
      if (o[key]["enabled"] != null && !o[key]["enabled"]) {
        continue;
      }
      if (key == "identitytype") {
        if (value != "") {
          o[key][field] = value;
        }
        for (var i = 0; i < o[key]["options"].length; i++) {
          for (var key2 in o[key]["options"][i]["option_fields"].keys) {
            o[key]["options"][i]["option_fields"][key2][field] = value;
          }
        }
      } else {
        o[key][field] = value;
      }
    }
  }

  void getPaymentResult(result) {
    if (result != null &&
        result["IsSuccess"] == true &&
        result["ResponseCode"] == paymentStatus[PayS.success]) {
      setState(() {
        var result = getInputedData(inputList);
        result["paymentStatus"] = paymentStatus[PayS.success];
        result["paymentDate"] = getTimestamp();
        obj = result;

        widget.onChanged(result);
        if (!ApplicationFormData.tabList["remote"]["enable"] ||
            (ApplicationFormData.tabList["remote"]["enable"] &&
                ApplicationFormData.tabList["remote"]["completed"])) {
          Navigator.of(context)
              .push(createRoute(ApplicationCompleted(data: info)));
        }
      });
    } else if (result != null &&
        result["IsSuccess"] == true &&
        result["ResponseCode"] == paymentStatus[PayS.failed]) {
      setState(() {
        var result = getInputedData(inputList);
        result["paymentStatus"] = paymentStatus[PayS.failed];
        obj = result;

        widget.onChanged(result);
      });
    }
  }

  void startTimer(int? ccountdown) {
    if (countdown == 0) countdown = ccountdown;
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (Timer ttimer) {
      if (countdown == 0 || !mounted) {
        ttimer.cancel();
      } else {
        setState(() {
          if (countdown != null) countdown = countdown! - 1;
        });
      }
    });
  }

  void enableExtraField(String value) {
    setState(() {
      if (value == "creditdebit") {
        inputList["agreement"]["enabled"] = true;
      } else {
        inputList["agreement"]["enabled"] = false;
        inputList["agreement"]["value"] = false;
      }
    });
  }

  Future<void> submitApplication(String paymethod) async {
    startLoading(context);

    try {
      var res = await NewBusinessAPI().submitApp(await getSubmitAppObj(
          setID: ApplicationFormData.data["SetID"], paymentMethod: paymethod));
      ApplicationFormData.data["application"] = res["data"];
      ApplicationFormData.data["appStatus"] =
          AppStatus.pendingPayment.toString();
      ApplicationFormData.data["applicationDate"] = getTimestamp();
      info = ApplicationFormData.data;
      var product = ApplicationFormData.data["listOfQuotation"][0];
      List<AnalyticsEventItem> items = [];

      items.add(AnalyticsEventItem(
          itemId: product["productPlanCode"],
          itemName: product["productPlanName"],
          price: double.tryParse(product["premAmt"] ?? "0.00")));

      if (product["enricherPremiumAmount"] != null &&
          product["enricherPremiumAmount"] != "0.00") {
        items.add(AnalyticsEventItem(
            itemId: "RCTE02",
            itemName: "Enricher",
            price: double.tryParse(product["enricherPremiumAmount"])));
      }

      if (product["rtuAmt"] != "0" && product["rtuAmt"] != "0.00") {
        items.add(AnalyticsEventItem(
            itemId: "RCITU4",
            itemName: "Regular Top-Up",
            price: double.tryParse(product["rtuAmt"] ?? "0.00")));
      }

      if (product['riderOutputData'] != null) {
        for (var element in product["riderOutputData"]) {
          items.add(AnalyticsEventItem(
              itemId: element["riderName"],
              itemName: element["riderName"],
              price: isNumeric(element["riderMonthlyPremium"])
                  ? double.parse(element["riderMonthlyPremium"])
                  : 0));
        }
      }
      FirebaseAnalytics.instance.logBeginCheckout(
          items: items,
          value: double.tryParse(product["totalPremium"]),
          currency: "MYR");

      if (!mounted) {}
      stopLoading(context);
      setState(() {});
    } catch (e) {
      stopLoading(context);

      if (e is AppCustomException) {
        showAlertDialog(
            context, getLocale("Oops, there seems to be an issue."), e.message);
        FirebaseCrashlytics.instance
            .log('Error during submission, ${e.message}');
      } else {
        FirebaseCrashlytics.instance.log('Error during submission, $e');
        showAlertDialog(context, getLocale("Oops, there seems to be an issue."),
            "Unhandle Error.");
      }
    }
  }

  @override
  void dispose() async {
    if (timer != null) timer!.cancel();
    termsConditionRecognizer!.dispose();
    privacyNoticeRecognizer!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void checkInput() {
      var result = getInputedData(inputList);
      if (isRemotePayment) {
        setState(() {
          if (inputList["agreement"]["enabled"] &&
              result["agreement"] != null &&
              !result["agreement"]) {
            result["empty"] = null;
          }
          obj = result;
          widget.onChanged(obj);
        });
      }
      var result2 = {};
      var inEnabled = true;

      if (result["recurring"] == null) {
        result["recurring"] = 1;
      }

      for (var key in result.keys) {
        if (result[key] == null || result[key] == false) {
          inEnabled = false;
        }
      }

      if (result2.isNotEmpty) {
        for (var key in result2.keys) {
          if (result2[key] == null || result2[key] == false) {
            inEnabled = false;
          }
        }
      }

      if (enabled != inEnabled) {
        setState(() {
          enabled = inEnabled;
        });
      }
    }

    Widget proposalDetails() {
      var obj = [
        {
          "size": {"labelWidth": 1, "valueWidth": 2},
          "naText": "-",
          "liname": {
            "label": getLocale("Life Insured's Name", entity: true),
            "value": info["lifeInsured"]["name"]
          },
          "gender": {
            "label": getLocale("Gender"),
            "value": getLocale(info["lifeInsured"]["gender"])
          },
          "agentCode": {
            "label": getLocale("Agent Code"),
            "value": info["agentCodes"]
          },
          "agentName": {
            "label": getLocale("Agent Name"),
            "value":
                agent != null && agent!.fullName != null ? agent!.fullName : ""
          }
        }
      ];
      return Container(
          padding: EdgeInsets.symmetric(
              horizontal: gFontSize * 2, vertical: gFontSize),
          decoration: BoxDecoration(
              color: lightGreyColor2,
              borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.2))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(getLocale("Proposal Details"), style: t2FontW5()),
            CustomColumnTable(arrayObj: obj, valueFontStyle: bFontW5())
          ]));
    }

    Widget twoRowText(mainText, subText) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainText, style: bFontWN()),
            Text(subText, style: ssFontWN())
          ]);
    }

    Widget threeRowText(mainText, subText, highlighted) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mainText, style: bFontWN()),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: lightCyanColorSix,
                    borderRadius:
                        BorderRadius.all(Radius.circular(gFontSize * 0.2))),
                child: Text(highlighted, style: ssFontWN())),
            Text(subText, style: ssFontWN())
          ]);
    }

    Widget paymentMethod() {
      inputList["payment"]["options"] = [
        {
          "label":
              twoRowText(getLocale("Debit/Credit Card Auto Pay"), "(MPay)"),
          "value": "creditdebit",
          "active": widget.info["listOfQuotation"][0]["deductSalary"] == true
              ? false
              : true
        },
        {
          "label": twoRowText(objMapping["autodebit"],
              getLocale("(Only applicable for Maybank & BSN)")),
          "value": "autodebit",
          "active": widget.info["listOfQuotation"][0]["deductSalary"] == true
              ? false
              : true
        },
        {
          "label": Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(objMapping["directpayment"]!, style: bFontWN())),
          "value": "directpayment",
          "active": widget.info["listOfQuotation"][0]["deductSalary"] == true ||
                  widget.info["listOfQuotation"][0]["paymentMode"] != 1
              ? false
              : true
        },
        {
          "label": Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(objMapping["fpx"]!, style: bFontWN())),
          "value": "fpx",
          "active": widget.info["listOfQuotation"][0]["deductSalary"] == true
              ? false
              : true
        },
        {
          "label": threeRowText(
              objMapping["salarydeduction"],
              getLocale(
                  "For Salary Deduction and BPA, the advanced payment of 2 months ahead is required as the deduction by those bodies will take effect on the 3rd month"),
              getLocale(
                  "You will need to submit the Borang Kebenaran Potongan Gaji, Borang Penentuan Had Kelayakan Potongan Gaji and Authorized Salary Slip to Etiqa via Agent Portal (EPP)")),
          "value": "salarydeduction",
          "active": widget.info["listOfQuotation"][0]["deductSalary"] == true
              ? true
              : false
        }
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize * 3),
            child: Divider(thickness: gFontSize * 0.1)),
        Text(getLocale("Payment Details"), style: t2FontW5()),
        ChoiceCheckContainer(
            setHeight: false,
            obj: inputList["payment"],
            onChanged: (value) {
              enableExtraField(value);
              checkInput();
            })
      ]);
    }

    Widget agreement() {
      if (inputList["agreement"]["enabled"] != true) {
        return const SizedBox();
      }

      return Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.all(gFontSize),
          decoration: BoxDecoration(
              color: lightCyanColor,
              borderRadius: BorderRadius.circular(gFontSize * 0.5)),
          child: GestureDetector(
              onTap: () {
                inputList["agreement"]["value"] =
                    !(inputList["agreement"]["value"]);
                checkInput();
              },
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CheckCircle(
                    checked: inputList["agreement"]["value"],
                    alignment: Alignment.topLeft),
                Expanded(
                    child: RichText(
                        text: TextSpan(
                            text:
                                '${getLocale("I hereby authorize")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)} ${getLocale("to charge my initial and subsequent premiums payable from my Visa /MasterCard / Amex Card account. In the even that my Visa / MasterCard / Amex Card account cannot be successfully debited and processed on a particular deduction date, I authorize")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)} ${getLocale("to re-attempt to charge the premium due from my Visa / MasterCard / Amex Card account on the subsequent deduction date(s). I also agree to abide to the")} ',
                            style: bFontWN(),
                            children: [
                      TextSpan(
                          text: getLocale("Terms & Conditions"),
                          style: bFontW5()
                              .copyWith(decoration: TextDecoration.underline),
                          recognizer: termsConditionRecognizer),
                      TextSpan(
                          text:
                              ' ${getLocale("as specified overleaf and understand that no receipts will be issued for premiums paid through my Visa / MasterCard / Amex Card account.")}',
                          style: bFontWN())
                    ])))
              ])));
    }

    Widget payButton() {
      return Container(
          padding: EdgeInsets.only(top: gFontSize * 2, bottom: gFontSize),
          width: double.infinity,
          child: Row(children: [
            inputList["payment"]["value"] == "creditdebit" ||
                    inputList["payment"]["value"] == "fpx"
                ? isRemotePayment
                    ? Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: creamColor,
                                borderRadius:
                                    BorderRadius.circular(gFontSize * 0.5)),
                            padding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 1.6,
                                vertical: gFontSize),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      getLocale("Capture the payment remotely"),
                                      style: sFontWN()),
                                  Text(
                                      getLocale(
                                          "Remote payment link will be sent together with the remote signature"),
                                      style: sFontWN()
                                          .copyWith(color: scarletRedColor))
                                ])))
                    : Expanded(
                        child: CustomButton(
                            label: getLocale("Pay Now"),
                            fontSize: gFontSize,
                            onPressed: !enabled
                                ? null
                                : () async {
                                    await submitApplication(inputList["payment"]
                                                ["value"] ==
                                            "creditdebit"
                                        ? "creditcard"
                                        : inputList["payment"]["value"]);
                                    var result = getInputedData(inputList);
                                    result["paymentStatus"] =
                                        paymentStatus[PayS.pending];
                                    result["payDate"] = getTimestamp();
                                    result["proposalNo"] = ApplicationFormData
                                        .data["application"]["ProposalNo"];
                                    obj = result;

                                    widget.onChanged(result);
                                    setState(() {});

                                    if (!mounted) {}
                                    var result2 = await Navigator.of(context)
                                        .push(createRoute(MPay(
                                            obj: obj,
                                            onChanged: (result) {
                                              widget.onChanged(result);
                                            },
                                            callback: (result) {
                                              getPaymentResult(result);
                                            })));
                                    getPaymentResult(result2);
                                  }))
                : Container()
          ]));
    }

    Widget submitApp() {
      var result = getInputedData(inputList);
      bool isNotRemote = false;
      if (widget.info["remote"] == null) {
        isNotRemote = true;
      } else {
        if (widget.info["remote"]["listOfRecipient"] == null ||
            widget.info["remote"]["listOfRecipient"].isEmpty) {
          isNotRemote = true;
        }
      }

      return Visibility(
          visible: result["payment"] != "creditdebit" &&
              result["payment"] != "fpx" &&
              enabled &&
              isNotRemote,
          child: Row(children: [
            Expanded(
                child: CustomButton(
                    label: getLocale("Submit Application"),
                    fontSize: gFontSize,
                    onPressed: !enabled
                        ? null
                        : () async {
                            if (result["payment"] != "creditdebit") {
                              await submitApplication(result["payment"])
                                  .then((value) {
                                if (ApplicationFormData.data["application"] !=
                                        null &&
                                    ApplicationFormData.data["application"]
                                            ["ProposalNo"] !=
                                        null) {
                                  result["paymentStatus"] =
                                      paymentStatus[PayS.success];
                                  result["paymentDate"] = getTimestamp();
                                  obj = result;

                                  widget.onChanged(result);
                                  if (!mounted) {}
                                  Navigator.of(context).push(createRoute(
                                      ApplicationCompleted(data: info)));
                                } else {
                                  result["paymentStatus"] =
                                      paymentStatus[PayS.failed];
                                  result["paymentDate"] = getTimestamp();
                                  obj = result;
                                  widget.onChanged(result);
                                }
                              });
                            }
                          }))
          ]));
    }

    Widget paymentContainer() {
      if (obj != null && obj.isNotEmpty) {
        if (obj["paymentStatus"] == paymentStatus[PayS.success]) {
          return const SizedBox();
        } else {
          int ts = obj["lastSent"] ?? obj["payDate"] ?? obj["paymentDate"] ?? 0;
          int seconds;
          if (ts != 0) {
            int y = 3600000000 - (getTimestamp() - ts);
            seconds = Duration(microseconds: y).inSeconds;
            if (seconds > 0) {
              return const SizedBox();
            }
          }
        }
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        paymentMethod(),
        // autoDebitContent(),
        agreement(),
        payButton(),
        submitApp()
      ]);
    }

    Widget paymentStatusContainer() {
      if (obj == null || obj.isEmpty) {
        return const SizedBox();
      }
      startPaymentTimer(obj, obj["proposalNo"], (result) {
        getPaymentResult(result);
      });
      int? ts = obj["lastSent"];
      ts ??= obj["payDate"] ?? obj["paymentDate"] ?? 0;
      int? seconds;
      String? timerCountdown;
      if (ts != 0) {
        int y = 3600000000 - (getTimestamp() - ts!);
        seconds = Duration(microseconds: y).inSeconds;
        if (seconds > 0) startTimer(seconds);
      }
      if (seconds != null && seconds > 0) {
        Duration clockTimer = Duration(seconds: seconds);
        var hours = clockTimer.inHours.toString().padLeft(2, '0');
        var mins =
            clockTimer.inMinutes.remainder(60).toString().padLeft(2, '0');
        var secs = (clockTimer.inSeconds.remainder(60) % 60)
            .toString()
            .padLeft(2, '0');
        timerCountdown = '$hours:$mins:$secs';
      }

      dynamic arrayObj;
      Color color;
      Color titleColor;
      String titleText;
      String buttonText;
      var sendDate = obj["lastSent"] != null
          ? DateFormat('dd MMM yyyy')
              .format(DateTime.fromMicrosecondsSinceEpoch(obj["lastSent"]))
          : obj["payDate"] != null
              ? DateFormat('dd MMM yyyy hh:mm aa')
                  .format(DateTime.fromMicrosecondsSinceEpoch(obj["payDate"]))
              : obj["paymentDate"] != null
                  ? DateFormat('dd MMM yyyy hh:mm aa').format(
                      DateTime.fromMicrosecondsSinceEpoch(obj["paymentDate"]))
                  : "-";
      var smth = timerCountdown;

      if (obj["paymentStatus"] == paymentStatus[PayS.pending] &&
          seconds != null &&
          seconds > 0) {
        color = lightHoneyColor;
        titleColor = honeyColor;
        titleText = "Payment link sent!";
        buttonText = "QRCode/Resend email";

        arrayObj = [
          {
            "size": {"labelWidth": 30, "valueWidth": 70},
            "sd": {"label": getLocale("Sent Date"), "value": sendDate},
            "pm": {
              "label": getLocale("Payment Method"),
              "value": obj["payment"] != null
                  ? obj["payment"] == "creditdebit"
                      ? objMapping["mpay"]
                      : objMapping[obj["payment"]]
                  : objMapping[obj["payment"]]
            },
            "em": {"label": getLocale("Email"), "value": obj["email"] ?? "-"},
            "ps": {
              "label": getLocale("Payment Status"),
              "value": getLocale("Pending payment")
            },
            "et": {"label": getLocale("Expired time"), "value": smth}
          }
        ];
      } else if (obj["paymentStatus"] == paymentStatus[PayS.failed]) {
        color = lightOrangeRedColor;

        titleColor = orangeRedColor;
        titleText = "Payment Failed/Expired";
        buttonText = "Retry payment";
        arrayObj = [
          {
            "size": {"labelWidth": 30, "valueWidth": 70},
            "sd": {"label": getLocale("Sent Date"), "value": sendDate},
            "pm": {
              "label": getLocale("Payment Method"),
              "value": obj["payment"] != null
                  ? obj["payment"] == "creditdebit"
                      ? objMapping["mpay"]
                      : objMapping[obj["payment"]]
                  : objMapping[obj["payment"]]
            },
            "em": {"label": getLocale("Email"), "value": obj["email"] ?? "-"},
            "ps": {
              "label": getLocale("Payment Status"),
              "value": "Failed payment"
            },
            "et": {"label": getLocale("Expired time"), "value": smth}
          }
        ];
      } else if (obj["paymentStatus"] == paymentStatus[PayS.success]) {
        color = lightCyanColor;

        titleColor = cyanColor;
        titleText = "Payment Success";
        buttonText = "";
        arrayObj = [
          {
            "size": {"labelWidth": 30, "valueWidth": 70},
            "sd": {"label": getLocale("Sent Date"), "value": sendDate},
            "pm": {
              "label": getLocale("Payment Method"),
              "value": obj["payment"] != null
                  ? obj["payment"] == "creditdebit"
                      ? objMapping["mpay"]
                      : objMapping[obj["payment"]]
                  : objMapping[obj["payment"]]
            },
            "em": {"label": getLocale("Email"), "value": obj["email"] ?? "-"},
            "ps": {
              "label": getLocale("Payment Status"),
              "value": "Payment Success"
            }
          }
        ];
      } else {
        return const SizedBox();
      }

      return Container(
          margin: EdgeInsets.symmetric(vertical: gFontSize),
          padding: EdgeInsets.symmetric(
              horizontal: gFontSize * 2, vertical: gFontSize),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.2))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titleText, style: t2FontW5().copyWith(color: titleColor)),
            SizedBox(height: gFontSize),
            CustomColumnTable(arrayObj: arrayObj),
            Visibility(
                visible: obj["paymentStatus"] != paymentStatus[PayS.success],
                child: Row(children: [
                  CustomButton(
                      padding: EdgeInsets.symmetric(
                          horizontal: gFontSize * 1.2,
                          vertical: gFontSize * 0.8),
                      label: buttonText,
                      fontSize: bFontW5().fontSize,
                      onPressed: () async {
                        obj["payDate"] = getTimestamp();
                        obj["proposalNo"] = info["application"]["ProposalNo"];
                        widget.onChanged(obj);

                        var result2 =
                            await Navigator.of(context).push(createRoute(MPay(
                                obj: obj,
                                onChanged: (result) {
                                  widget.onChanged(result);
                                },
                                callback: (result) {
                                  getPaymentResult(result);
                                })));

                        getPaymentResult(result2);
                      }),
                  SizedBox(width: gFontSize),
                  CustomButton(
                      padding: EdgeInsets.symmetric(
                          horizontal: gFontSize * 1.2,
                          vertical: gFontSize * 0.8),
                      label: getLocale("Change Payment Method"),
                      fontSize: bFontW5().fontSize,
                      borderColor: tealGreenColor,
                      labelColor: tealGreenColor,
                      secondary: true,
                      onPressed: () {
                        obj = {};
                        widget.onChanged(obj);
                        setState(() {});
                      })
                ]))
          ]));
    }

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          proposalDetails(),
          Padding(
              padding: EdgeInsets.symmetric(vertical: gFontSize),
              child: Text(
                  "${getLocale("Thank you for choosing")} ${getLocale("Etiqa Life Insurance Berhad", entity: true)}. ${getLocale("Please find below your summary of payment")}.",
                  style: t2FontW5())),
          ProductTable(info: info, isSITable: true),
          paymentContainer(),
          paymentStatusContainer()
        ]));
  }
}
