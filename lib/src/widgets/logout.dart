import 'dart:async';

import 'package:ease/main.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/login_screen.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:ease/src/widgets/three_size_dot.dart';
import 'package:flutter/material.dart';

void loggingOutDialog(BuildContext context, String? message) {
  timer?.cancel();
  timerDialog?.cancel();
  if (message != null && message != "") showSnackBarError(message);

  Future.delayed(Duration(seconds: message != null && message != "" ? 2 : 0),
      () {
    showDialog(
        context: context,
        builder: (_) => Material(
            type: MaterialType.transparency,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(getLocale("Logging out"),
                      style: bFontW5().copyWith(color: Colors.white)),
                  const SizedBox(height: 10),
                  ThreeSizeDot(
                      color_1: honeyColor,
                      color_2: honeyColor,
                      color_3: honeyColor)
                ])));
  });
}

void handleLogoutSession() async {
  timer?.cancel();
  timerDialog?.cancel();

  await ServicingAPI().logout();
  AuthenticationRepository.internal().removeUserProfile();

  Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
  loggingOutDialog(navigatorKey.currentState!.overlay!.context, "");

  Future.delayed(const Duration(seconds: 3), () {
    Navigator.pushAndRemoveUntil(
        navigatorKey.currentState!.overlay!.context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  });
}

void handleLoggedOut(String? message) {
  timer?.cancel();
  timerDialog?.cancel();

  Future.delayed(const Duration(seconds: 1), () {
    loggingOutDialog(navigatorKey.currentState!.overlay!.context, message);
  });

  Future.delayed(const Duration(seconds: 4), () {
    Navigator.of(navigatorKey.currentState!.overlay!.context).pop();
    Navigator.pushAndRemoveUntil(
        navigatorKey.currentState!.overlay!.context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
  });
}
