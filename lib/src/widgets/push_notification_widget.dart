import 'package:ease/main.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:flutter/material.dart';

Future showFCMConfirmDialog(String title, String message) {
  return showDialog(
      context: navigatorKey.currentContext!,
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
                                child: Text(title, style: t1FontWN())),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message, style: bFontWN())),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
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

void showNotiDialog(String? title, {String? body}) {
  showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.38),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                    child: AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        title: Text(
                            body != null ? title! : getLocale("Notification"),
                            style: t2FontWB()),
                        content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(body ?? title!, style: t2FontW5()),
                              const SizedBox(height: 20),
                              Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
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
