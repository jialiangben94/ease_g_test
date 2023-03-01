import 'dart:convert';
import 'dart:typed_data';

import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/remote/widget/dialog.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Verify extends StatefulWidget {
  final String setID;
  final Map obj;
  const Verify(this.setID, this.obj, {Key? key}) : super(key: key);
  @override
  VerifyState createState() => VerifyState();
}

class VerifyState extends State<Verify> {
  bool checked = false;
  Uint8List? frontByte;
  Uint8List? backByte;
  Uint8List? signatureByte;

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen("Remote Verify", "RemoteVerify");
    if (widget.obj["Front"] != null) {
      frontByte = base64.decode(widget.obj["Front"]);
    }
    if (widget.obj["Back"] != null) {
      backByte = base64.decode(widget.obj["Back"]);
    }
    if (widget.obj["signature"] != null) {
      signatureByte = base64.decode(widget.obj["signature"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget clientDetail() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.obj["role"], style: t2FontWB()),
        const SizedBox(height: 10),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(getLocale("Name"),
                        style: bFontWN().copyWith(color: greyTextColor)),
                    Text(widget.obj["name"], style: bFontW5())
                  ])),
              Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getLocale("ID No."),
                            style: bFontWN().copyWith(color: greyTextColor)),
                        Text(widget.obj["nric"] ?? "", style: bFontW5())
                      ]))
            ])),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text("${getLocale("Phone No")}.",
                        style: bFontWN().copyWith(color: greyTextColor)),
                    Text(widget.obj["recipientMobile"], style: bFontW5())
                  ])),
              Expanded(
                  flex: 2,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getLocale("Email Address"),
                            style: bFontWN().copyWith(color: greyTextColor)),
                        Text(widget.obj["recipientEmail"], style: bFontW5())
                      ]))
            ]))
      ]);
    }

    Widget nricCapture() {
      return Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("NRIC Front"), style: bFontW5()),
          Container(
              padding: const EdgeInsets.all(20),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: frontByte != null
                      ? Image.memory(frontByte!)
                      : Container()))
        ])),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("NRIC Back"), style: bFontW5()),
          Container(
              padding: const EdgeInsets.all(20),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      backByte != null ? Image.memory(backByte!) : Container()))
        ]))
      ]);
    }

    Widget signature() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.obj["role"] + " - " + widget.obj["name"], style: bFontW5()),
        Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: MediaQuery.of(context).size.width * 0.2,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
                border:
                    Border.all(color: lightCyanColor, width: gFontSize * 0.3),
                borderRadius: BorderRadius.circular(gFontSize * 0.5)),
            child: signatureByte != null
                ? Image.memory(signatureByte!)
                : Container()),
      ]);
    }

    Widget agree() {
      return GestureDetector(
          onTap: () {
            setState(() {
              checked = !checked;
            });
          },
          child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                  color: lightCyanColor,
                  borderRadius: BorderRadius.circular(gFontSize * 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: checked
                        ? const Image(
                            width: 40,
                            height: 40,
                            image: AssetImage('assets/images/check_circle.png'))
                        : Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey)))),
                Text(
                    getLocale(
                        "I hereby confirm that I have check all documents uploaded"),
                    style: bFontW5())
              ])));
    }

    Widget submitButton() {
      return Row(children: [
        SizedBox(
            width: 200,
            height: 60,
            child: TextButton(
                style: TextButton.styleFrom(
                    minimumSize: const Size(100, 50),
                    backgroundColor: checked ? honeyColor : lightGreyColor),
                onPressed: () async {
                  if (checked) {
                    if (await confirmVerify(context)) {
                      loadingDialog(context, getLocale("Updating"));
                      var obj = {
                        "Method": "PUT",
                        "Body": {
                          "SetID": widget.setID,
                          "ClientID": remoteClientListID([widget.obj]),
                          "VerifyStatus": "5",
                          "Remark": "",
                          "IsResend": false,
                          "Via": "",
                          "ViaDetail": ""
                        }
                      };
                      await NewBusinessAPI().remote(obj).then((res) {
                        Navigator.of(context).pop();
                        dynamic data = {
                          "status": "confirmed",
                          "datetime": DateFormat('dd-MM-yyyy hh:mm a')
                              .format(DateTime.now()),
                          "res": res
                        };
                        Navigator.of(context).pop(data);
                      }).onError((error, stackTrace) {
                        Navigator.of(context).pop();
                        remoteFailed(context, "Failed to send the remote link",
                            error.toString());
                      });
                    }
                  }
                },
                child: Text(getLocale("Confirm"), style: bFontW5()))),
        Container(
            width: 200,
            height: 60,
            margin: const EdgeInsets.only(left: 20),
            child: OutlinedButton(
                style:
                    OutlinedButton.styleFrom(backgroundColor: greyBorderColor),
                onPressed: () async {
                  if (await confirmReject(context)) {
                    loadingDialog(context, getLocale("Updating"));
                    var obj = {
                      "Method": "PUT",
                      "Body": {
                        "SetID": widget.setID,
                        "ClientID": remoteClientListID([widget.obj]),
                        "VerifyStatus": "4",
                        "Remark": "",
                        "IsResend": false,
                        "Via": "",
                        "ViaDetail": ""
                      }
                    };
                    await NewBusinessAPI().remote(obj).then((res) {
                      Navigator.of(context).pop();
                      dynamic data = {
                        "status": "rejectedByAgent",
                        "datetime": DateFormat('dd-MM-yyyy hh:mm a')
                            .format(DateTime.now()),
                        "res": res
                      };
                      Navigator.of(context).pop(data);
                    }).onError((error, stackTrace) {});
                  }
                },
                child: Text(getLocale("Reject"), style: bFontW5())))
      ]);
    }

    Widget divider() {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 2,
          width: double.infinity,
          color: lightGreyColor2);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          progressBar(context, 6, 1),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
              child: Row(children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.adaptive.arrow_back)),
                Expanded(
                    child: Center(
                        child: Text(
                            getLocale("Verify Remote Identity & Signature"),
                            style: t2FontWB())))
              ])),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 60.0, right: 60, top: 0, bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      clientDetail(),
                      divider(),
                      nricCapture(),
                      divider(),
                      signature(),
                      agree(),
                      submitButton()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
