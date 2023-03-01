import 'dart:async';
import 'dart:convert';

import 'package:ease/src/bloc/medical_exam/notification_list/notification_list_bloc.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/medical_exam_model/notification.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/user_profile/user_profile.dart';
import 'package:ease/src/screen/user_profile/widgets/feedback.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/choice_check.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/currency_textfield.dart';
import 'package:ease/src/widgets/custom_cupertino_switch.dart';
import 'package:ease/src/widgets/full_dialog_option.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:ease/src/widgets/switch_button.dart';
import 'package:ease/src/widgets/switch_remote.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/three_size_dot.dart';
import 'package:ease/src/util/auto_populate.dart';
import 'package:ease/src/widgets/information_container.dart';
import 'package:ease/src/widgets/information_dropdown.dart';
import 'package:ease/src/widgets/radio_check.dart';
import 'package:ease/src/widgets/signature_container.dart';
import 'package:ease/src/widgets/camera_container.dart';
import 'package:ease/src/widgets/custom_button.dart';
export 'package:ease/src/widgets/loading.dart';
import 'package:ease/src/widgets/ease_app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

//Progress bar can be use as an app bar or progress bar.

Widget progressBar(BuildContext context, height, double stage) {
  height = height + .0;

  return Container(
      height: height,
      width: MediaQuery.of(context).size.width * stage,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [honeyColor, yellowColor])));
}

Widget normalAppBar(BuildContext context, String title, {Function? onback}) {
  return SizedBox(
      height: 65,
      width: double.infinity,
      child: Column(children: [
        progressBar(context, 6, 1),
        const SizedBox(height: 10),
        Row(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                  icon: Icon(Icons.adaptive.arrow_back, size: 20),
                  onPressed: () {
                    if (onback != null) {
                      onback();
                    } else {
                      Navigator.of(context).pop();
                    }
                  })),
          Visibility(
              visible: title != "",
              child: Center(child: Text(title, style: t2FontW5())))
        ])
      ]));
}

Widget userDetails(BuildContext context, UserProfileLoaded state) {
  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return getLocale('Morning');
    if (hour < 17) return getLocale('Afternoon');
    return getLocale('Evening');
  }

  var data = greeting();
  final Agent agent = state.agent!;

  return Row(children: [
    Text(
        "${getLocale("Good")} $data ${agent.fullName}${getLocale(",\nwhat would you like to do today?")}",
        style: bFontW5().copyWith(fontSize: 14)),
    const SizedBox(width: 10),
    GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(createRoute(UserProfile(agent)));
        },
        child: Container(
            alignment: Alignment.center,
            height: 50,
            width: 50,
            decoration: ShapeDecoration(
                shape: const CircleBorder(), color: scarletRedColor),
            child: agent.profilePhoto != null
                ? ClipOval(
                    child: Image.memory(base64Decode(agent.profilePhoto!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.fill,
                        gaplessPlayback: true))
                : Text(agent.fullName![0],
                    style: bFontWN().copyWith(color: Colors.white))))
  ]);
}

Widget customAppBar(BuildContext context, Function triggerNotification, ontap) {
  return Row(children: [
    GestureDetector(
        child: const Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Image(
                height: 90,
                width: 80,
                image: AssetImage('assets/images/ease_logo_white_bg.png')))),
    Expanded(child: Container()),
    GestureDetector(
        //UI to Switch Languages
        onTap: () {
          Navigator.of(context).push(createRoute(const FeedbackPage()));
        },
        child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(children: [
              Text(getLocale("Feedback"), style: TextStyle(color: cyanColor)),
              const SizedBox(width: 5),
              Icon(Icons.comment, size: 20, color: cyanColor)
            ]))),
    //UI to Switch Languages Start here
    GestureDetector(
        onTap: () {
          ontap();
        },
        child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(children: [
              Text(getLocale("Selected Language"),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text(" | "),
              Text(getLocale("Not Selected Language"))
            ]))),
    //UI to Switch Languages End here
    GestureDetector(
        onTap: () {
          triggerNotification();
        },
        child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SizedBox(
                width: 35,
                child: Stack(children: [
                  const Image(
                      width: 30,
                      height: 30,
                      image: AssetImage('assets/images/notification.png')),
                  Align(
                      alignment: Alignment.topRight,
                      child: BlocListener<NotificationListBloc,
                              NotificationListState>(
                          listener: (context, state) {
                            if (state is NotificationListError) {
                              showSnackBarError(state.message);
                            }
                          },
                          child: BlocBuilder<NotificationListBloc,
                                  NotificationListState>(
                              buildWhen: (NotificationListState previous,
                                      NotificationListState current) =>
                                  previous != current,
                              builder: (context, state) {
                                if (state is NotificationListInitial) {
                                  return Container();
                                } else if (state is NotificationListLoading) {
                                  return Container();
                                } else if (state is NotificationListLoaded) {
                                  final List<Notifications> notificationList =
                                      state.notificationList;
                                  List<Notifications> newList = [];

                                  for (int i = 0;
                                      i < notificationList.length;
                                      i++) {
                                    if (notificationList[i].isRead == false) {
                                      newList.add(notificationList[i]);
                                    }
                                  }
                                  if (newList.isNotEmpty) {
                                    return Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle),
                                        child: Center(
                                            child: Text(
                                                newList.length.toString(),
                                                style: sFontWB().copyWith(
                                                    color: Colors.white,
                                                    fontSize: 10))));
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  return Container();
                                }
                              })))
                ])))),
    BlocListener<UserProfileBloc, UserProfileBlocState>(
        listener: (context, state) {
      if (state is UserProfileError) {
        showSnackBarError(state.message);
      }
    }, child: BlocBuilder<UserProfileBloc, UserProfileBlocState>(
            builder: (context, state) {
      if (state is UserProfileInitial) {
        return Container();
      } else if (state is UserProfileLoading) {
        return buildLoading();
      } else if (state is UserProfileLoaded) {
        return userDetails(context, state);
      } else if (state is UserProfileError) {
        return Container();
      } else {
        return Container();
      }
    }))
  ]);
}

Widget buildLoading() {
  return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(honeyColor))));
}

Widget buildLinearProgress(double percentage) {
  return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
          child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
            value: percentage,
            minHeight: 5,
            backgroundColor: lightGreyColor,
            valueColor: AlwaysStoppedAnimation<Color>(honeyColor)),
      )));
}

void loadingScreen(BuildContext context, String result) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.38,
                height: MediaQuery.of(context).size.height * 0.3,
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                child: Column(children: [
                  Expanded(
                      child: result != "pending uw"
                          ? RichText(
                              text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                  text:
                                      "${getLocale("Moving this appointment to")} ",
                                  style: bFontW5()),
                              TextSpan(
                                  text: result == "confirmed"
                                      ? getLocale("Schedule Confirmed")
                                      : getLocale("Cancelled"),
                                  style: bFontWB()),
                              TextSpan(text: " status", style: bFontW5())
                            ]))
                          : Text(
                              getLocale(
                                  "Sending request to underwriter to reopen the proposal"),
                              style: bFontW5())),
                  Expanded(
                      child: ThreeSizeDot(
                          color_1: honeyColor,
                          color_2: honeyColor,
                          color_3: honeyColor))
                ])));
      });
}

void showSuccessResetDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.38),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        title: Row(children: [
                          const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Image(
                                  width: 70,
                                  height: 70,
                                  image: AssetImage(
                                      'assets/images/submitted_icon.png'))),
                          Text(getLocale("Password Reset Successful"),
                              style: bFontW5().apply(fontSizeFactor: 1.2))
                        ]),
                        content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(
                                      getLocale(
                                          "We have sent you a temporary password on your registered email address"),
                                      style: bFontW5()
                                          .apply(fontWeightDelta: -1))),
                              Container(
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

void showAlertDialog(BuildContext context, String title, String? message,
    [VoidCallback? onTap]) {
  analyticsSetCurrentScreen(
      "Alert Dialog, Title: $title, Message: $message", "General");

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.38),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 3),
                            title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 3),
                                child: Text(title,
                                    style:
                                        bFontW5().apply(fontSizeFactor: 1.2))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message!,
                                          style: bFontW5()
                                              .apply(fontWeightDelta: -1))),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: honeyColor),
                                          onPressed: onTap ??
                                              () {
                                                Navigator.of(context).pop();
                                              },
                                          child: Text(getLocale('Close'),
                                              style: t2FontWB())))
                                ]))))));
      });
}

void showAlertDialog2(BuildContext context, String title, String? message,
    [VoidCallback? onTap]) {
  analyticsSetCurrentScreen("Alert Dialog, Message: $message", "General");

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.38),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(title,
                                    style:
                                        bFontW5().apply(fontSizeFactor: 1.2))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message!,
                                          style: bFontW5()
                                              .apply(fontWeightDelta: -1))),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: honeyColor),
                                          onPressed: onTap ??
                                              () {
                                                Navigator.of(context).pop();
                                              },
                                          child: Text(getLocale('Close'),
                                              style: t2FontWB())))
                                ]))))));
      });
}

Future showAlertDialog3(BuildContext context, String title, String message) {
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
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(title,
                                    style:
                                        bFontW5().apply(fontSizeFactor: 1.2))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message,
                                          style: bFontW5()
                                              .apply(fontWeightDelta: -1))),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: honeyColor),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text(getLocale('Close'),
                                              style: t2FontWB())))
                                ]))))));
      });
}

Future showAlertDialog4(BuildContext context, String title, String message) {
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
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: Text(title,
                                    style:
                                        bFontW5().apply(fontSizeFactor: 1.2))),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message,
                                          style: bFontW5()
                                              .apply(fontWeightDelta: -1))),
                                  Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 60,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: honeyColor),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text(getLocale('Close'),
                                              style: t2FontWB())))
                                ]))))));
      });
}

Future showConfirmDialog(BuildContext context, String title, String message) {
  return showDialog(
      context: context,
      barrierDismissible: true,
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

Widget customChoiceDialog(BuildContext context, obj, onTap) {
  if (obj["size"] == null || obj["size"].isEmpty) {
    obj["size"] = {};
    obj["size"]["textWidth"] = 22;
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 10;
  }

  return Container(
      padding: textFieldPaddingBetween(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            flex: obj["size"]["textWidth"],
            child: Text(obj["label"], style: bFontWN())),
        Expanded(
            flex: obj["size"]["fieldWidth"],
            child: GestureDetector(
                onTap: onTap,
                child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    alignment: Alignment.centerLeft,
                    height: 60.0,
                    decoration: BoxDecoration(
                        border: Border.all(color: greyBorderTFColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Row(children: [
                      Expanded(
                          flex: 75,
                          child: Text(obj["value"], style: t2FontWN())),
                      const Expanded(
                          flex: 25,
                          child: Padding(
                              padding: EdgeInsets.only(right: 17.0),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(Icons.keyboard_arrow_down))))
                    ])))),
        Expanded(flex: obj["size"]["emptyWidth"], child: Container())
      ]));
}

Widget switchContainer(obj, onChanged) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }

  if (obj["size"] == null || obj["size"].isEmpty) {
    obj["size"] = {};
    obj["size"]["textWidth"] = 22;
    obj["size"]["fieldWidth"] = 10;
    obj["size"]["emptyWidth"] = 70;
  }

  Widget? label;

  if (obj["label"] != null && obj["label"] is Widget) {
    label = obj["label"];
  }

  label ??= Text(obj["label"] ?? "", style: bFontWN());

  return Container(
      // height: 70.0,
      padding: textFieldPaddingBetween(),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
            flex: obj["size"]["textWidth"],
            child: Container(
                padding: const EdgeInsets.only(right: 10), child: label)),
        Expanded(
            flex: 15,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(obj["value"] ? getLocale("Yes") : getLocale("No"),
                      style: bFontWN())),
              CustomCupertinoSwitch(
                  activeColor: cyanColor,
                  bgColor: lightGreyColor2,
                  bgActiveColor: lightCyanColor,
                  value: obj["value"],
                  onChanged: onChanged)
            ])),
        Expanded(flex: obj["size"]["emptyWidth"], child: Container())
      ]));
}

DateTime? validateDate(date) {
  if (date != null && date != "") {
    if (date is DateTime) {
      return date;
    } else if (date is String) {
      if (date.contains("/")) {
        return DateFormat('dd/MM/yyyy', 'en_US').parse(date);
      }
    } else if (date is int) {
      return DateTime.fromMicrosecondsSinceEpoch(date);
    }
  }
  return null;
}

Widget openDateChoose(obj, onChanged) {
  if (obj == null) {
    throw ("Missing params");
  }

  DateTime selectedDate = DateTime.now().subtract(const Duration(days: 1));
  var date = validateDate(obj["value"]);
  if (date != null) {
    selectedDate = date;
  }

  var maxdate = validateDate(obj["maximum"]);
  var mindate = validateDate(obj["minimum"]);
  maxdate ??= DateTime.now().subtract(const Duration(days: 1));
  return CupertinoDatePicker(
      initialDateTime: selectedDate,
      onDateTimeChanged: onChanged,
      minimumDate: mindate,
      maximumDate: maxdate,
      minuteInterval: 1,
      mode: CupertinoDatePickerMode.date);
}

Widget dateChooser(BuildContext context, obj, onChanged) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }

  if (obj["size"] == null || obj["size"].isEmpty) {
    obj["size"] = {};
    obj["size"]["textWidth"] = 22;
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 10;
  }

  var column = false;
  if (obj["column"] != null && obj["column"]) {
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 30;

    obj["size"]["textWidth"] = 85;

    column = true;
  }

  String? displayDate = "";
  if (obj["value"] != null) {
    if (obj["value"] is String) {
      displayDate = obj["value"];
    } else if (obj["value"] is int) {
      displayDate = DateFormat('dd MMM yyyy')
          .format(DateTime.fromMicrosecondsSinceEpoch(obj["value"]));
    } else if (obj["value"] is DateTime) {
      displayDate = DateFormat('dd MMM yyyy').format(obj["value"]);
    }
  }

  Widget label;
  if (obj["required"] == true) {
    label = RichText(
        text: TextSpan(
            text: obj["label"] ?? "",
            style: bFontWN(),
            children: <TextSpan>[
          TextSpan(text: "*", style: bFontWN().copyWith(color: scarletRedColor))
        ]));
  } else {
    label = Text(obj["label"] ?? "", style: bFontWN());
  }

  Widget ageWidget = Container();
  if (obj["label"] == getLocale("Date of Birth")) {
    int age = 0;
    if (obj["value"] != null && obj["value"] != "") {
      DateTime? dob = validateDate(obj["value"]);
      age = getAge(dob!) + 1;
    }
    ageWidget = Padding(
        padding: EdgeInsets.symmetric(horizontal: gFontSize),
        child: Text("${getLocale("ANB")}: $age", style: bFontWN()));
  }

  var field = Expanded(
      flex: obj["size"]["fieldWidth"],
      child: Row(children: [
        Expanded(
            child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext builder) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height / 3,
                            child: openDateChoose(obj, onChanged));
                      });
                },
                child: Container(
                    padding: const EdgeInsets.only(left: 15.0),
                    alignment: Alignment.centerLeft,
                    height: 60.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: obj["error"] != null
                                ? scarletRedColor
                                : greyBorderTFColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8))),
                    child: Text(displayDate!, style: bFontW5())))),
        ageWidget
      ]));

  var errorDisplay = Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(flex: obj["size"]["textWidth"], child: Container()),
      !column
          ? Expanded(
              flex: obj["size"]["fieldWidth"],
              child: Text(obj["error"] ?? "",
                  style: ssFontWN().copyWith(color: Colors.red[700])))
          : Container(),
      Expanded(flex: obj["size"]["emptyWidth"], child: Container())
    ]),
    column
        ? Row(children: [
            Expanded(
                flex: obj["size"]["fieldWidth"],
                child: Text(obj["error"] ?? "",
                    style: ssFontWN().copyWith(color: Colors.red[700]))),
            Expanded(flex: obj["size"]["emptyWidth"], child: Container())
          ])
        : Container()
  ]);

  return Container(
      padding: textFieldPaddingBetween(),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: obj["size"]["textWidth"], child: label),
          !column ? field : Container(),
          Expanded(flex: obj["size"]["emptyWidth"], child: Container())
        ]),
        column ? Container(height: 20) : Container(),
        column
            ? Row(children: [
                field,
                Expanded(flex: obj["size"]["emptyWidth"], child: Container()),
              ])
            : Container(),
        Container(height: obj["error"] != null ? 10 : 0),
        Visibility(visible: obj["error"] != null, child: errorDisplay)
      ]));
}

Widget customDropDown(obj, onChanged, context) {
  var column = false;

  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }

  if (obj["column"] != null && obj["column"]) {
    column = true;
  }

  if (column && (obj["size"] == null || obj["size"].isEmpty)) {
    obj["size"] = {};
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 30;
    obj["size"]["textWidth"] = 85;
  } else if (obj["size"] == null || obj["size"].isEmpty) {
    obj["size"] = {};
    obj["size"]["textWidth"] = 22;
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 10;
  }

  String? placeholder;
  if (obj["value"] != null &&
      obj["value"].isEmpty &&
      obj["placeholder"] != null &&
      !obj["placeholder"].isEmpty) {
    placeholder = obj["placeholder"];
  } else if (obj["value"] == null || obj["value"].isEmpty) {
    obj["value"] = obj["options"][0]["value"];
    placeholder = null;
  }

  Widget element;
  List<DropdownMenuItem<dynamic>> list = [];
  if (obj["options"].length > 10 || obj["onTap"] != null) {
    String? displayLabel = "";
    if (obj["value"] != null) {
      int? index;
      index = obj["options"]
          .indexWhere((option) => option["value"] == obj["value"]);
      if (index! > -1) {
        displayLabel = obj["options"][index]["label"];
      } else {
        displayLabel = obj["value"];
      }
    }
    element = GestureDetector(
        onTap: obj["onTap"] ??
            () async {
              if (obj["disabled"] != null && obj["disabled"]) {
              } else {
                var selected = await _selectOption(obj, context);
                if (selected != null) {
                  onChanged(selected);
                }
              }
            },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            height: 60.0,
            child: Row(children: [
              Expanded(
                  flex: 75,
                  child: Text(placeholder ?? displayLabel!,
                      style: bFontW5().copyWith(
                          color: placeholder != null
                              ? greyTextColor
                              : Colors.black,
                          fontSize: placeholder != null ? 16 : 18))),
              Expanded(
                  flex: 25,
                  child: Padding(
                      padding: const EdgeInsets.only(right: 0.0),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 25, color: greyTextColor))))
            ])));
  } else {
    var value =
        obj["value"] == "" || obj["value"] == null || obj["value"].isEmpty
            ? null
            : obj["value"];
    for (var i = 0; i < obj["options"].length; i++) {
      if (obj["value"] == obj["options"][i]["value"]) {
        value = obj["options"][i]["value"];
      }
      if (obj["options"][i]["active"]) {
        list.add(DropdownMenuItem(
            value: obj["options"][i]["value"],
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(obj["options"][i]["label"]))));
      }
    }
    element = DropdownButton(
        isExpanded: true,
        value: list.indexWhere((element) => element.value == value) != -1
            ? value
            : null,
        style: bFontW5(),
        icon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.keyboard_arrow_down, size: 25.0)),
        hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(placeholder ?? getLocale("Please select an option"),
                style: sFontW5().copyWith(color: greyTextColor))),
        items: list,
        onChanged:
            obj["disabled"] != null && obj["disabled"] ? null : onChanged);
  }

  var field = Expanded(
      flex: obj["size"]["fieldWidth"],
      child: Container(
          height: 60.0,
          decoration: BoxDecoration(
              border: Border.all(
                  color: obj["error"] != null
                      ? scarletRedColor
                      : greyBorderTFColor),
              borderRadius: const BorderRadius.all(Radius.circular(8))),
          child: DropdownButtonHideUnderline(child: element)));

  Widget labelWidget;
  if (obj["disabled"] != null && obj["disabled"]) {
    labelWidget = Text(obj["label"], style: bFontWN());
  } else if (obj["required"]) {
    labelWidget = RichText(
        text: TextSpan(
            text: obj["label"],
            style: bFontWN(),
            children: <TextSpan>[
          TextSpan(text: "*", style: bFontWN().copyWith(color: scarletRedColor))
        ]));
  } else {
    labelWidget = Text(obj["label"], style: bFontWN());
  }

  var errorDisplay = Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(flex: obj["size"]["textWidth"], child: Container()),
      !column
          ? Expanded(
              flex: obj["size"]["fieldWidth"],
              child: Text(obj["error"] ?? "",
                  style: ssFontWN().copyWith(color: Colors.red[700])))
          : Container(),
      Expanded(flex: obj["size"]["emptyWidth"], child: Container())
    ]),
    column
        ? Row(children: [
            Expanded(
                flex: obj["size"]["fieldWidth"],
                child: Text(obj["error"] ?? "",
                    style: ssFontWN().copyWith(color: Colors.red[700]))),
            Expanded(flex: obj["size"]["emptyWidth"], child: Container())
          ])
        : Container()
  ]);

  return Container(
      padding: textFieldPaddingBetween(),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: obj["size"]["textWidth"], child: labelWidget),
          !column ? field : Container(),
          Expanded(flex: obj["size"]["emptyWidth"], child: Container())
        ]),
        column ? Container(height: 20) : Container(),
        column
            ? Row(children: [
                field,
                Expanded(flex: obj["size"]["emptyWidth"], child: Container())
              ])
            : Container(),
        Container(height: obj["error"] != null ? 10 : 0),
        Visibility(visible: obj["error"] != null, child: errorDisplay)
      ]));
}

Widget customMultipleSelection(obj, onChanged, context) {
  bool column = false;

  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }

  if (obj["column"] != null && obj["column"]) {
    column = true;
  }

  if (column && (obj["size"] == null || obj["size"].isEmpty)) {
    obj["size"] = {};
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 30;
    obj["size"]["textWidth"] = 85;
  } else if (obj["size"] == null || obj["size"].isEmpty) {
    obj["size"] = {};
    obj["size"]["textWidth"] = 22;
    obj["size"]["fieldWidth"] = 70;
    obj["size"]["emptyWidth"] = 10;
  }

  List<Widget> list = [];
  List? value = obj["value"].isEmpty ? [] : obj["value"];

  for (var i = 0; i < obj["options"].length; i++) {
    if (obj["value"] == obj["options"][i]["value"]) {
      value = obj["options"][i]["value"];
    }
    list.add(GestureDetector(
        onTap: () {
          var data = obj["options"][i]["label"].toString().toLowerCase();
          if (value!.contains(data)) {
            value.remove(data.toString().toLowerCase());
          } else {
            value.add(data.toString().toLowerCase());
          }
          onChanged(value);
        },
        child: Padding(
            padding: const EdgeInsets.only(bottom: 4.0, right: 6.0),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: (value!.contains(obj["options"][i]["label"]
                                .toString()
                                .toLowerCase()))
                            ? cyanColor
                            : Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: AnimatedSwitcher(
                                  switchInCurve: Curves.ease,
                                  duration: const Duration(milliseconds: 1000),
                                  child: value.contains(obj["options"][i]
                                              ["label"]
                                          .toString()
                                          .toLowerCase())
                                      ? Icon(Icons.check_circle,
                                          color: cyanColor)
                                      : const Icon(Icons.circle_outlined,
                                          color: Colors.grey))),
                          Text(obj["options"][i]["label"])
                        ]))))));
  }
  var element = GestureDetector(
      onTap: () {
        onChanged();
      },
      child: Wrap(children: list));

  var field = Expanded(
      flex: obj["size"]["fieldWidth"],
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0), child: element));

  return Container(
      padding: textFieldPaddingBetween(),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              flex: obj["size"]["textWidth"],
              child: Text(obj["label"], style: bFontWN())),
          !column ? field : Container(),
          Expanded(flex: obj["size"]["emptyWidth"], child: Container())
        ]),
        column ? Container(height: 20) : Container(),
        column
            ? Row(children: [
                field,
                Expanded(flex: obj["size"]["emptyWidth"], child: Container())
              ])
            : Container()
      ]));
}

Widget informationDropDown(obj) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return InformationDropdown(
      obj: obj,
      html: obj["text"],
      style: obj["style"],
      label: obj["label"],
      show: obj["show"]);
}

Widget radioCheck(obj, onChanged) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return RadioCheckContainer(
      checked: obj["value"],
      html: obj["html"],
      style: obj["style"],
      label: obj["label"],
      bgColor: obj["bgColor"],
      onChanged: onChanged);
}

Widget informationExpand(obj) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return InformationContainer(html: obj["text"], style: obj["style"]);
}

Widget signatureContainer(obj, callback) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return SignatureContainer(
      label: obj["label"], callback: callback, image: obj["value"]);
}

Widget cameraContainer(obj, callback) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return CameraContainer(
      label: obj["label"], callback: callback, image: obj["value"]);
}

Widget choiceCheck(obj, callback) {
  if (obj["enabled"] != null && !obj["enabled"]) {
    return Container();
  }
  return ChoiceCheckContainer(obj: obj, onChanged: callback);
}

Widget customSlider(context, obj, onChanged) {
  if (obj["value"] != null && obj["value"] is int) {
    obj["value"] = obj["value"].toDouble();
  }
  return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(obj["label"] ?? "", style: bFontWN()),
        SliderTheme(
            data: SliderTheme.of(context).copyWith(
                activeTickMarkColor: Colors.grey,
                inactiveTickMarkColor: Colors.grey,
                activeTrackColor: lightCyanColor,
                inactiveTrackColor: lightCyanColor,
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 20.0,
                thumbColor: cyanColor,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 20.0),
                overlayColor: cyanColor.withAlpha(32),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 30.0)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(flex: 4, child: Container()),
                Expanded(
                    flex: 85,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                              divisions: obj["divisions"],
                              min: obj["min"],
                              max: obj["max"],
                              value: obj["value"].toDouble(),
                              onChanged: onChanged)
                        ])),
                Expanded(flex: 5, child: Container()),
                Expanded(
                    flex: 10,
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5))),
                        height: 70,
                        width: 105,
                        child: Center(
                            child: Text(
                                obj["value"].toStringAsFixed(0) +
                                    (obj["indicator"] ?? ""),
                                textAlign: TextAlign.center,
                                style: tFontW5().copyWith(color: cyanColor)))))
              ]),
              obj["divisions"] != null
                  ? Row(children: [
                      Expanded(
                          flex: 82,
                          child: Row(
                              children: List.generate(
                                  obj["options"].length,
                                  (index) => Expanded(
                                      child: Text(obj["options"][index],
                                          textAlign: TextAlign.center,
                                          style: bFontWN().copyWith(
                                              fontFamily: "Lato",
                                              color: greyTextColor)))))),
                      Expanded(flex: 10, child: Container())
                    ])
                  : Row(children: [
                      Expanded(
                          flex: 82,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  obj["options"].length,
                                  (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 60),
                                      child: Text(obj["options"][index],
                                          textAlign: TextAlign.center,
                                          style: bFontWN().copyWith(
                                              fontFamily: "Lato",
                                              color: greyTextColor)))))),
                      Expanded(flex: 10, child: Container())
                    ])
            ]))
      ]));
}

Future<String?> _selectOption(obj, context) async {
  try {
    final selected =
        await Navigator.of(context).push(createRoute(FullDialog(obj: obj)));
    return selected;
  } catch (e) {
    rethrow;
  }
}

dynamic generateOptionField(context, obj, callback, autoP) {
  var inWidList = [];

  if (obj["value"] != null && obj["value"] != "" && obj["options"] != null) {
    var found = false;
    for (var i = 0; i < obj["options"].length; i++) {
      if (obj["options"][i]["option_fields"] != null) {
        found = true;
        break;
      }
    }

    if (found) {
      int index = obj["options"]
          .indexWhere((option) => option["value"] == obj["value"]);
      if (index > -1) {
        inWidList = generateEachInputField(
            context, obj["options"][index]["option_fields"], callback, autoP);
      }
    }
  }

  return inWidList;
}

dynamic generateInputField(context, obj, callback) {
  var inWidList = {};
  var autoP = AutoPopulate(inputList: obj);
  for (var key in obj.keys) {
    if (obj[key]["enabled"] != null && !obj[key]["enabled"]) {
      continue;
    }
    if (obj[key]["fields"] != null) {
      inWidList[key] = generateEachInputField(
          context, obj[key]["fields"], callback, autoP,
          clientType: key);
    } else {
      return generateEachInputField(context, obj, callback, autoP,
          clientType: key);
    }
  }
  return inWidList;
}

bool isValidDate(String input) {
  final date = DateTime.parse(input);
  final originalFormatString = toOriginalFormatString(date);
  return input == originalFormatString;
}

String toOriginalFormatString(DateTime dateTime) {
  final y = dateTime.year.toString().padLeft(4, '0');
  final m = dateTime.month.toString().padLeft(2, '0');
  final d = dateTime.day.toString().padLeft(2, '0');
  return "$y$m$d";
}

dynamic generateEachInputField(context, obj, callback, autoP, {clientType}) {
  // print(obj);
  var inWidList = [];
  if (obj == null) {
    return inWidList;
  }

  for (var key in obj.keys) {
    // print(key);
    // print(obj[key]);
    if (obj[key] is! Map || obj[key]["type"] == null) {
      continue;
    }
    if (obj[key]["type"] == "text" ||
        obj[key]["type"] == "number" ||
        obj[key]["type"] == "telnumber" ||
        obj[key]["type"] == "email") {
      if (key == "name") {
        String? error = validateName(obj[key]["value"], minLength: 5);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "nric" || key == "mypr") {
        var identitytype = getObjectByKey(autoP.inputList, "identitytype");
        String? error = validateID(key, obj[key], identitytype["clientType"]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
          if (obj[key]["value"].isNotEmpty && obj[key]["value"].length == 12) {
            var year = obj[key]["value"].substring(0, 2);
            var day = obj[key]["value"].substring(4, 6);
            var month = obj[key]["value"].substring(2, 4);

            //TEMP WORKAROUND AS DateFormat not support for 2 digit as now
            if (int.parse(year) > 50) {
              year = "19$year";
            } else {
              year = "20$year";
            }

            if (!isValidDate(year + month + day)) {
              obj[key]["error"] = getLocale("Invalid IC format");
            }

            if (obj["oldic"] != null) {
              if (int.parse(year) < 1977) {
                obj["oldic"]["enabled"] = true;
                obj["oldic"]["required"] = true;
              } else {
                obj["oldic"]["enabled"] = false;
                obj["oldic"]["required"] = false;
              }
            }
          }
        }
      }

      if (key == "oldic" ||
          key == "birthcert" ||
          key == "passport" ||
          key == "policeic" ||
          key == "armyic") {
        var identitytype = getObjectByKey(autoP.inputList, "identitytype");
        String? error = validateID(key, obj[key], identitytype["clientType"]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "usTaxId") {
        if (obj[key]["value"].isEmpty || obj[key]["value"].length < 9) {
          obj[key]["error"] = getLocale("Please enter a valid US Tax ID");
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "postcode") {
        obj["city"]["type"] = "option1";
        obj["city"].remove("error");
        obj["state"]["type"] = "option1";
        obj["state"].remove("error");
        obj["postcode"]["type"] = "number";
        obj["postcode"]["maxLength"] = 5;
        if (!isNumeric(obj["postcode"]["value"])) {
          obj["postcode"]["value"] = "";
        }
        if (obj["postcode"]["value"].length == 5) {
          var ee = getCityByPostcode(obj["postcode"]["value"]);
          if (obj["state"] != null && obj["city"] != null && ee != null) {
            obj["state"]["value"] = ee["state"];
            obj["city"]["value"] = ee["city"];
          }
        }
      }

      if (key == "mailingpostcode") {
        if (obj["mailingcountry"]["value"] != "MYS") {
          obj["mailingpostcode"]["maxLength"] = 10;
          obj["mailingpostcode"]["type"] = "text";
          obj["mailingcity"]["type"] = "text";
          obj["mailingcity"].remove("error");
          obj["mailingcity"]["value"] = "";
          obj["mailingstate"]["type"] = "text";
          obj["mailingstate"].remove("error");
          obj["mailingstate"]["value"] = "";
        } else {
          obj["mailingcity"]["type"] = "option1";
          obj["mailingcity"].remove("error");
          obj["mailingcity"]["value"] = "";
          obj["mailingstate"]["type"] = "option1";
          obj["mailingstate"].remove("error");
          obj["mailingstate"]["value"] = "";
          obj["mailingpostcode"]["type"] = "number";
          obj["mailingpostcode"]["maxLength"] = 5;
          if (!isNumeric(obj["mailingpostcode"]["value"])) {
            obj["mailingpostcode"]["value"] = "";
          }
          if (obj["mailingpostcode"]["value"].length == 5) {
            var ee = getCityByPostcode(obj["mailingpostcode"]["value"]);
            if (obj["mailingstate"] != null &&
                obj["mailingcity"] != null &&
                ee != null) {
              obj["mailingstate"]["value"] = ee["state"];
              obj["mailingcity"]["value"] = ee["city"];
            }
          }
        }
      }

      if (key == "hometel" || key == "officetel") {
        String? error = validHomeTel(obj[key]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "mobileno") {
        String? error = validPhoneNo(obj[key]["value"]);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "email") {
        String? error = validEmail(obj[key]["value"], checkAgentEmail: true);
        if (error != null) {
          obj[key]["error"] = error;
        } else {
          obj[key].remove("error");
        }
      }

      if (key == "accountno") {
        var regex = validateAccNo(obj);
        if (!regex["isValid"]) {
          obj[key]["error"] = regex["message"];
        } else {
          obj[key].remove("error");
        }
      }

      inWidList.add({
        "key": key,
        "widget": EaseAppTextField(
            obj: obj[key],
            onChanged: (val) {
              if (val != obj[key]["value"]) {
                obj[key]["value"] = val;
                autoP.autoPopulate(obj, key, callback, context: context);
              }
              callback(key);
            })
      });
    } else if (obj[key]["type"] == "currency") {
      inWidList.add({
        "key": key,
        "widget": CurrencyTextField(
            obj: obj[key],
            onChanged: (val) {
              if (val != obj[key]["value"]) {
                obj[key]["value"] = val;
                autoP.autoPopulate(obj, key, callback, context: context);
              }
              callback(key);
            })
      });
    } else if (obj[key]["type"].toString() == "option2") {
      var gender = getObjectByKey(autoP.inputList, "gender");
      var nric = getObjectByKey(autoP.inputList, "nric");
      var mypr = getObjectByKey(autoP.inputList, "mypr");
      if (nric != null && nric["value"].length == 12) {
        if ((int.parse(nric["value"][11]) % 2) == 0) {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Female") {
            gender["notice"] = getLocale(
                "* Please make sure the gender selected match with the New IC(myKad / myKid) you provided");
          } else {
            gender.remove("notice");
          }
        } else {
          if (gender["value"] == "") {
            gender.remove("notice");
          } else if (gender["value"] != "Male") {
            gender["notice"] = getLocale(
                "* Please make sure the gender selected match with the New IC(myKad / myKid) you provided");
          } else {
            gender.remove("notice");
          }
        }
      }
      if (mypr != null && mypr["value"].length == 12) {
        if ((int.parse(mypr["value"][11]) % 2) == 0) {
          if (gender["value"] != "Female") {
            gender["notice"] = getLocale(
                "* Please make sure the gender selected match with the New IC(myKad / myKid) you provided");
          } else {
            gender.remove("notice");
          }
        } else {
          if (gender["value"] != "Male") {
            gender["notice"] = getLocale(
                "* Please make sure the gender selected match with the New IC(myKad / myKid) you provided");
          } else {
            gender.remove("notice");
          }
        }
      }
      inWidList.add({
        "key": key,
        "widget": ChoiceCheckContainer(
            obj: obj[key],
            textColorChange: true,
            fontWeight: FontWeight.w500,
            fontSize: gFontSize * 0.85,
            optionPadding: EdgeInsets.all(gFontSize * 0.1),
            onChanged: (value) {
              int? index = -1;
              // int widLength = 0;
              if (obj[key]["value"] != null) {
                index = obj[key]["options"].indexWhere(
                    (option) => option["value"] == obj[key]["value"]);
              }
              if (index! > -1 &&
                  obj[key]["options"][index]["option_fields"] != null) {
                // widLength =
                //     obj[key]["options"][index]["option_fields"].keys.length;
              }
              int index2 = inWidList.indexWhere((wid) => wid["key"] == key);
              obj[key]["value"] = value;
              var addNewList =
                  generateOptionField(context, obj[key], callback, autoP);
              inWidList.insertAll(index2 + 1, addNewList);
              autoP.autoPopulate(obj, key, callback,
                  index: index, context: context);
              callback(key);
            })
      });
      var addNewList = generateOptionField(context, obj[key], callback, autoP);
      for (var i = 0; i < addNewList.length; i++) {
        inWidList.add(addNewList[i]);
      }
    } else if (obj[key]["type"].toString().contains("option")) {
      if (key == "occupationDisplay") {
        var dob = getObjectByKey(autoP.inputList, "dob");
        if (dob["value"] != null && dob["value"] is! String) {
          var validOcc = validateOcc(dob["value"], obj[key]["value"]);
          if (!validOcc["isValid"]) {
            obj[key]["error"] = validOcc["message"];
          } else {
            obj[key].remove("error");
          }
        }
      }

      if (key == "bankname" || key == "bankaccounttype") {
        var regex = validateAccNo(obj);
        if (!regex["isValid"]) {
          obj["accountno"]["error"] = regex["message"];
        } else {
          obj["accountno"].remove("error");
        }
      }

      inWidList.add({
        "key": key,
        "widget": customDropDown(obj[key], (value) {
          if (value != null) {
            int index = -1;
            int widLength = 0;
            if (obj[key]["value"] != null) {
              index = obj[key]["options"]
                  .indexWhere((option) => option["value"] == obj[key]["value"]);
            }
            if (index > -1 &&
                obj[key]["options"][index]["option_fields"] != null) {
              widLength =
                  obj[key]["options"][index]["option_fields"].keys.length;
            }

            int index2 = inWidList.indexWhere((wid) => wid["key"] == key);

            obj[key]["value"] = value;
            var addNewList =
                generateOptionField(context, obj[key], callback, autoP);
            inWidList.replaceRange(
                index2 + 1, index2 + 1 + widLength, addNewList);
            // print("before callback");
            autoP.autoPopulate(obj, key, callback,
                index: index, context: context);

            callback(key);
          }
        }, context)
      });

      var addNewList = generateOptionField(context, obj[key], callback, autoP);
      for (var i = 0; i < addNewList.length; i++) {
        inWidList.add(addNewList[i]);
      }
    } else if (obj[key]["type"] == "switch") {
      inWidList.add({
        "key": key,
        "widget": switchContainer(obj[key], (value) {
          obj[key]["value"] = value;
          generateOptionField(context, obj[key], callback, autoP);
          if (obj[key]["value"] == false && obj[key]["option_fields"] != null) {
            int index = inWidList.indexWhere((wid) => wid["key"] == key);

            var addNewList = generateEachInputField(
                context, obj[key]["option_fields"], callback, autoP);
            for (var i = 0; i < addNewList.length; i++) {
              inWidList.insert(index + 1, addNewList[i]);
              index++;
            }
          }
          callback(key);
        })
      });
      if (obj[key]["value"] == false && obj[key]["option_fields"] != null) {
        int index = inWidList.indexWhere((wid) => wid["key"] == key);

        var addNewList = generateEachInputField(
            context, obj[key]["option_fields"], callback, autoP);
        for (var i = 0; i < addNewList.length; i++) {
          inWidList.insert(index + 1, addNewList[i]);
          index++;
        }
      }
    } else if (obj[key]["type"] == "switchButton") {
      inWidList.add({
        "key": key,
        "widget": SwitchButton(
            obj: obj[key],
            onChanged: (value) {
              int? index = -1;
              if (obj[key]["value"] != null) {
                index = obj[key]["options"].indexWhere(
                    (option) => option["value"] == obj[key]["value"]);
              }
              if (index! > -1 &&
                  obj[key]["options"][index]["option_fields"] != null) {}
              int index2 = inWidList.indexWhere((wid) => wid["key"] == key);
              obj[key]["value"] = value;
              var addNewList =
                  generateOptionField(context, obj[key], callback, autoP);
              inWidList.insertAll(index2 + 1, addNewList);
              autoP.autoPopulate(obj, key, callback,
                  index: index, context: context);
              callback(key);
            })
      });
      var addNewList = generateOptionField(context, obj[key], callback, autoP);
      for (var i = 0; i < addNewList.length; i++) {
        inWidList.add(addNewList[i]);
      }
    } else if (obj[key]["type"] == "switchRemote") {
      inWidList.add({
        "key": key,
        "widget": SwitchRemote(
            obj: obj[key],
            onChanged: (value) {
              obj[key]["value"] = value;
              generateOptionField(context, obj[key], callback, autoP);
              if (obj[key]["value"] && obj[key]["option_fields"] != null) {
                int index = inWidList.indexWhere((wid) => wid["key"] == key);

                var addNewList = generateEachInputField(
                    context, obj[key]["option_fields"], callback, autoP);
                for (var i = 0; i < addNewList.length; i++) {
                  inWidList.insert(index + 1, addNewList[i]);
                  index++;
                }
              }
              callback(key);
            })
      });
      if (!obj[key]["value"] && obj[key]["option_fields"] != null) {
        var addNewList = generateEachInputField(
            context, obj[key]["option_fields"], callback, autoP);
        int index = inWidList.indexWhere((wid) => wid["key"] == key);
        for (var i = 0; i < addNewList.length; i++) {
          inWidList.insert(index + 1, addNewList[i]);
          index++;
        }
      }
    } else if (obj[key]["type"] == "date") {
      if (key == "dob" &&
          obj[key]["value"] != null &&
          obj[key]["value"] is! String) {
        DateTime date = DateTime.fromMicrosecondsSinceEpoch(obj[key]["value"]);
        var buyingFor = ApplicationFormData.data["buyingFor"];
        var identitytype = getObjectByKey(autoP.inputList, "identitytype");
        var validatedob = validateAge(date, identitytype["clientType"],
            selectedBuyingFor: buyingFor);
        if (!validatedob["isValid"]) {
          obj[key]["error"] = validatedob["message"];
        } else {
          obj[key].remove("error");
        }
      }

      inWidList.add({
        "key": key,
        "widget": dateChooser(context, obj[key], (date) {
          obj[key]["value"] = date.microsecondsSinceEpoch;
          if (key == "dob" &&
              obj[key]["value"] != null &&
              obj[key]["value"] is! String) {
            DateTime date =
                DateTime.fromMicrosecondsSinceEpoch(obj[key]["value"]);
            var buyingFor = ApplicationFormData.data["buyingFor"];
            var identitytype = getObjectByKey(autoP.inputList, "identitytype");
            var validatedob = validateAge(date, identitytype["clientType"],
                selectedBuyingFor: buyingFor);
            if (!validatedob["isValid"]) {
              obj[key]["error"] = validatedob["message"];
            } else {
              obj[key].remove("error");
            }
          }
          callback(key);
        })
      });
    } else if (obj[key]["type"].indexOf("slider") > -1) {
      inWidList.add({
        "key": key,
        "widget": customSlider(context, obj[key], (value) {
          if (obj[key]["type"] == "sliderInt") {
            obj[key]["value"] = value.round().toInt();
          } else if (obj[key]["type"] == "sliderDouble") {
            obj[key]["value"] = num.parse(value.toStringAsFixed(2));
          } else {
            obj[key]["value"] = value;
          }
          callback(key);
        })
      });
    } else if (obj[key]["type"] == "info") {
      inWidList.add({"key": key, "widget": informationDropDown(obj[key])});
    } else if (obj[key]["type"] == "info2") {
      inWidList.add({"key": key, "widget": informationExpand(obj[key])});
    } else if (obj[key]["type"] == "radiocheck") {
      inWidList.add({
        "key": key,
        "widget": radioCheck(obj[key], (value) {
          obj[key]["value"] = value;
          if (obj[key]["value"] && obj[key]["option_fields"] != null) {
            int index = inWidList.indexWhere((wid) => wid["key"] == key);
            var addNewList = generateEachInputField(
                context, obj[key]["option_fields"], callback, autoP);
            for (var i = 0; i < addNewList.length; i++) {
              inWidList.insert(index + 1, addNewList[i]);
              index++;
            }
          }
          callback(key);
        })
      });
      if (obj[key]["value"] && obj[key]["option_fields"] != null) {
        var addNewList = generateEachInputField(
            context, obj[key]["option_fields"], callback, autoP);
        int index = inWidList.indexWhere((wid) => wid["key"] == key);
        for (var i = 0; i < addNewList.length; i++) {
          inWidList.insert(index + 1, addNewList[i]);
          index++;
        }
      }
    } else if (obj[key]["type"] == "signature") {
      inWidList.add({
        "key": key,
        "widget": signatureContainer(obj[key], (value) {
          if (value != null) {
            obj[key]["value"] = value;
          } else {
            obj[key]["value"] = "";
          }
          callback(key);
        })
      });
    } else if (obj[key]["type"] == "camera") {
      inWidList.add({
        "key": key,
        "widget": cameraContainer(obj[key], (value) {
          obj[key]["value"] = value;
          callback(key);
        })
      });
    } else if (obj[key]["type"] == "paragraph") {
      Widget label;
      if (obj[key]["isRequired"] != null && obj[key]["isRequired"]) {
        label = Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize),
            child: RichText(
                text: TextSpan(
                    text: "* ",
                    style: bFontWN().copyWith(color: scarletRedColor),
                    children: <TextSpan>[
                  TextSpan(text: obj[key]["text"], style: obj[key]["style"])
                ])));
      } else {
        label = Padding(
            padding: EdgeInsets.symmetric(vertical: gFontSize),
            child: Text(obj[key]["text"], style: obj[key]["style"]));
      }
      if (obj[key]["column"] != null) {
        label = Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 40, child: Container()),
          Expanded(flex: 70, child: label),
          Expanded(flex: 12, child: Container())
        ]);
      }
      inWidList.add({"key": key, "widget": label});
    } else {
      // print("Unhandled Type = " + obj[key].toString());
    }
  }
  return inWidList;
}

typedef OnWidgetSizeChange = void Function(Size? size);

class MeasureSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasureSize({Key? key, required this.onChange, required this.child})
      : super(key: key);

  @override
  MeasureSizeState createState() => MeasureSizeState();
}

class MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(key: widgetKey, child: widget.child);
  }

  var widgetKey = GlobalKey();
  dynamic oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onChange(newSize);
  }
}
