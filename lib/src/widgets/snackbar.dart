import 'package:ease/main.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';

void showSnackBarSuccess(String message) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: honeyColor,
      duration: const Duration(seconds: 2)));
}

void showSnackBarError(String message, {bool dismiss = false}) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
          label: getLocale("Dismiss"),
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentContext!)
                .hideCurrentSnackBar();
          }),
      backgroundColor: scarletRedColor,
      duration: Duration(seconds: dismiss ? 10 : 2)));
}

void showSnackBarCustom(String message, Color color) {
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 2)));
}
