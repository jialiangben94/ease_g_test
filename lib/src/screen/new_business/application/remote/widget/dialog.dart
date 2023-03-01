import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/three_size_dot.dart';
import 'package:flutter/material.dart';

void remoteComplete(BuildContext context, String text) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.38,
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        title: const Image(
                            width: 60,
                            height: 60,
                            image:
                                AssetImage('assets/images/submitted_icon.png')),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Flexible(child: Text(text, style: t2FontWB())),
                          Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: honeyColor),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(getLocale('Done'),
                                      style: t2FontWB())))
                        ])))));
      });
}

void remoteFailed(BuildContext context, String text, String message) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.38),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    height: MediaQuery.of(context).size.height * 0.42,
                    child: AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        title: Icon(Icons.cancel_outlined,
                            size: 60, color: scarletRedColor),
                        content: Column(children: [
                          Expanded(child: Text(text, style: t2FontWB())),
                          Text(message, style: bFontWN()),
                          Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: honeyColor),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(getLocale('Close'),
                                      style: t2FontWB())))
                        ])))));
      });
}

Future confirmSwitch(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight * 0.38),
                    child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.4,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 2,
                                vertical: gFontSize * 0.5),
                            title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 0.7,
                                    vertical: gFontSize * 0.5),
                                child: Text(
                                    getLocale(
                                        "Do you want to switch this sent remote signature back to capturing it here?"),
                                    style: t2FontWB())),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                          "${getLocale("IMPORTANT NOTE")}\n${getLocale("If yes, the sent remote link will be invalid")}",
                                          style: bFontWN().copyWith(
                                              color: scarletRedColor))),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Cancel"),
                                                secondary: true,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                })),
                                        Container(width: gFontSize * 0.5),
                                        Expanded(
                                            child: CustomButton(
                                                label: "Yes",
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }))
                                      ]))
                                ]))))));
      });
}

Future confirmVerify(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight * 0.38),
                    child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.4,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 2,
                                vertical: gFontSize * 0.5),
                            title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 0.7,
                                    vertical: gFontSize * 0.5),
                                child: Text(
                                    getLocale(
                                        "Would you like to confirm this remote signature and ID?"),
                                    style: bFontW5().copyWith(fontSize: 22))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(child: Text("")),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Cancel"),
                                                secondary: true,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                })),
                                        Container(width: gFontSize * 0.5),
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Confirm"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }))
                                      ]))
                                ]))))));
      });
}

Future confirmReject(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight * 0.38),
                    child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.4,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 2,
                                vertical: gFontSize * 0.5),
                            title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 0.7,
                                    vertical: gFontSize * 0.5),
                                child: Text(
                                    getLocale(
                                        "Would you like to reject this remote signature and ID?"),
                                    style: bFontW5().copyWith(fontSize: 22))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                          getLocale(
                                              "Kindly contact the customer to assist him/her on the next steps required."),
                                          style: bFontWN())),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
                                        Expanded(
                                            child: CustomButton(
                                                label: "Cancel",
                                                secondary: true,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                })),
                                        Container(width: gFontSize * 0.5),
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Confirm"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }))
                                      ]))
                                ]))))));
      });
}

void loadingDialog(BuildContext context, String text) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.36,
                height: MediaQuery.of(context).size.height * 0.28,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 60),
                child: Column(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(text,
                              textAlign: TextAlign.center, style: t1FontW5()))),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ThreeSizeDot(
                          color_1: honeyColor,
                          color_2: honeyColor,
                          color_3: honeyColor))
                ])));
      });
}

Future confirmExit(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight * 0.38),
                    child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.4,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 2,
                                vertical: gFontSize * 0.5),
                            title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 0.7,
                                    vertical: gFontSize * 0.5),
                                child: Text(
                                    getLocale(
                                        "This application has been saved. Do you want to proceed to exit?"),
                                    style: t2FontW5())),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(child: Text("")),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Cancel"),
                                                secondary: true,
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                })),
                                        Container(width: gFontSize * 0.5),
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Yes"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }))
                                      ]))
                                ]))))));
      });
}

