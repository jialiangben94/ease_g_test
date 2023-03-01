import 'dart:async';

import 'package:ease/main.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/logout.dart';
import 'package:flutter/material.dart';

// Future<bool> checkFirstTime() async {
//   bool isFirstTime;
//   var pref = await SharedPreferences.getInstance();
//   String? firstTime = pref.getString(SPK_WALKTHROUGH);
//   if (firstTime == "false")
//     isFirstTime = false;
//   else
//     isFirstTime = true;
//   return isFirstTime;
// }

void resetIdleTime() async {
  bool haveConn = await checkConnectivity();
  if (haveConn) {
    timer?.cancel();
    timer = Timer(timeout, sessionTimeOut);
  }
}

void handleStayLoggedIn(BuildContext context) async {
  Navigator.of(context).pop();
  await AuthenticationRepository.internal().refreshToken().then((res) {
    if (res["IsSuccess"]) {
      timer?.cancel();
      timer = Timer(timeout, sessionTimeOut);
      timerDialog?.cancel();
    } else {
      handleLoggedOut(res["message"]);
    }
  });
}

void sessionTimeOut() async {
  await AuthenticationRepository.internal().validateToken().then((value) {
    if (value["isTokenValid"]) {
      timerDialog?.cancel();
      timerDialog = Timer(afterTimeout, handleLogoutSession);
      showDialog(
          context: navigatorKey
              .currentState!.overlay!.context, // Using overlay's context
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                title: Text(getLocale("Your session is about to end"),
                    style: tFontW5().copyWith(fontWeight: FontWeight.normal)),
                titlePadding:
                    const EdgeInsets.only(top: 40, left: 42, right: 42),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 42),
                content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.36,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                                getLocale(
                                    "You have been inactive for a while. For your security, we will automatically log you out in approximately 30 seconds. Please choose 'Stay logged in' to continue or 'Log out' if you are done."),
                                style: bFontWN()),
                            const SizedBox(height: 10)
                          ])),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(children: [
                            Expanded(
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16)),
                                    onPressed: () {
                                      handleLogoutSession();
                                    },
                                    child: Text(getLocale('Log out'),
                                        style: t2FontW5()
                                            .copyWith(fontSize: 20)))),
                            Expanded(
                                child: TextButton(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        backgroundColor: honeyColor),
                                    onPressed: () async {
                                      handleStayLoggedIn(context);
                                    },
                                    child: Text(getLocale('Stay logged in'),
                                        style:
                                            t2FontW5().copyWith(fontSize: 20))))
                          ]))
                    ])));
          });
    } else {
      if (value["message"] == "No token found") {
        timer?.cancel();
        timerDialog?.cancel();
      } else if (value["message"] == "Jwt Token Expired") {
        timer?.cancel();
        timerDialog?.cancel();
        handleLoggedOut(getLocale("Session Expired. Please log in again"));
      } else {
        // timer?.cancel();
        // timerDialog?.cancel();
        // handleLoggedOut(value["message"]);
      }
    }
  });
}
