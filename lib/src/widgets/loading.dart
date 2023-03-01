import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

import '../util/function.dart';

BuildContext? dialog;

Widget containerLoading() {
  return SizedBox(
      height: gFontSize * 5,
      width: gFontSize * 5,
      child: CircularProgressIndicator(
          strokeWidth: gFontSize * 0.3,
          valueColor: AlwaysStoppedAnimation<Color>(honeyColor)));
}

Widget wholeScreenLoading() {
  return Container(
      height: screenHeight,
      width: screenWidth,
      color: Colors.white,
      child: Center(child: containerLoading()));
}

void startLoading(context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context1) {
        dialog = context1;
        return SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  containerLoading(),
                  SizedBox(height: gFontSize * 1.2),
                  Material(
                      color: Colors.transparent,
                      child: Text("${getLocale("Please wait")} ...",
                          style: t1FontWN().copyWith(color: Colors.white)))
                ]));
      });
}

void stopLoading([context]) {
  if (context != null) {
    Navigator.of(context).pop();
    dialog = null;
  }
  if (dialog != null) {
    Navigator.of(dialog!).pop();
    dialog = null;
  }
}
