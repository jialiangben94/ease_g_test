import 'dart:convert';

import 'package:ease/main.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/service/local_push_notification.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? _selectedCategory;
int? _selectedSetReminder;
bool isSetDate = false;
bool validCategory = false;
DateTime? _selectedDate;
DateTime? initialDate;

List<String> get category => [
      getLocale("High Potential"),
      getLocale("Follow Up Required"),
      getLocale("Low Potential")
    ];

List<DropdownMenuItem<int>> get duration => [
      (DropdownMenuItem(value: 0, child: Text(getLocale('Select duration')))),
      (DropdownMenuItem(value: 1, child: Text(getLocale('1 Week')))),
      (DropdownMenuItem(value: 2, child: Text(getLocale('2 Weeks'))))
    ];

String greeting(int hour) {
  if (hour < 12) return getLocale('Morning');
  if (hour < 17) return getLocale('Afternoon');
  return getLocale('Evening');
}

Future<void> _setReminder(
    BuildContext context,
    Quotation quotation,
    DateTime? notificationDate,
    int? numOfWeeks,
    String? selectedCategory) async {
  String? tabId;
  if (selectedCategory == "High Potential") {
    tabId = "H";
  } else if (selectedCategory == "Follow Up Required") {
    tabId = "N";
  } else if (selectedCategory == "Low Potential") {
    tabId = "L";
  }

  var pref = await SharedPreferences.getInstance();
  Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

  var encodeJson = {
    "CustomerName": quotation.lifeInsured!.name,
    "UserId": agent.accountCode,
    "NumOfWeeks": numOfWeeks,
    "RefId": quotation.id.toString(),
    "TabId": tabId,
    "PushNotificationPlatform": "P",
    "NotificationDate": notificationDate.toString()
  };
  var obj = {
    "Method": "POST",
    "Param": {"Type": "CATEGORY"},
    "Body": {"Quotation": encodeJson}
  };

  await NewBusinessAPI().quotation(obj).then((value) async {
    if (value["IsSuccess"]) {
      showAlertDialog(navigatorKey.currentContext!, "Success",
          getLocale("Reminder has been set"));
      quotation.isSetReminder = true;
      quotation.reminderDate = notificationDate.toString();
      BlocProvider.of<QuotationBloc>(navigatorKey.currentContext!)
          .add(UpdateAndLoadQuotation(quotation));
      // Scheduled Local Reminder Notification
      DateTime localNotificationDate = notificationDate ??
          (DateTime.now().add(Duration(days: (numOfWeeks ?? 0) * 7)));
      await LocalPushNotificationsManager().createScheduleNoti(
          quotation.id ?? 0,
          getLocale("Customer Follow Up"),
          "${getLocale("Good")} ${greeting(localNotificationDate.hour)}. ${getLocale("You have")} ${quotation.policyOwner?.name ?? ""} ${getLocale("from the quick quote to follow up with today")}.",
          localNotificationDate);
    } else {
      showAlertDialog(navigatorKey.currentContext!, "Error",
          getLocale("Failed to set reminder"));
    }
  }).catchError((onError) {
    showAlertDialog(navigatorKey.currentContext!, "Error",
        "${getLocale("Failed to set reminder")}. $onError");
  });
}

Widget categoryList(String label, bool isSelected, onTap) {
  return Expanded(
      child: GestureDetector(
          onTap: onTap,
          child: Container(
              height: 180,
              margin: const EdgeInsets.only(left: 5),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: isSelected ? cyanColor : greyBorderColor),
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        textAlign: TextAlign.center,
                        style: bFontWN().copyWith(
                            color: isSelected ? cyanColor : Colors.black)),
                    const SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: isSelected
                            ? const Image(
                                width: 32,
                                height: 32,
                                image: AssetImage(
                                    'assets/images/check_circle.png'))
                            : Icon(Icons.brightness_1,
                                size: 38, color: Colors.grey[200]))
                  ]))));
}

Widget selectDuration(selectedDate, onChanged, onTap, {double? width}) {
  return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(getLocale("Set reminder in"),
        style: bFontWN().copyWith(color: greyTextColor)),
    Container(
        margin: const EdgeInsets.only(top: 5, bottom: 14),
        width: width,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: DropdownButtonHideUnderline(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: DropdownButton(
                    value: _selectedSetReminder,
                    style: bFontWN(),
                    hint: Text(getLocale("Select duration"),
                        textAlign: TextAlign.right, style: bFontWN()),
                    items: duration,
                    onChanged: (dynamic value) {
                      onChanged(value);
                    })))),
    Row(children: [
      Expanded(
          flex: 2,
          child: GestureDetector(
              onTap: onTap,
              child: Row(children: [
                Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: isSetDate
                        ? const Image(
                            width: 32,
                            height: 32,
                            image: AssetImage('assets/images/check_circle.png'))
                        : Icon(Icons.brightness_1,
                            size: 38, color: Colors.grey[200])),
                Text(getLocale("or set a date"),
                    style: bFontWN().copyWith(color: greyTextColor))
              ]))),
      Expanded(
          flex: 2,
          child: GestureDetector(
              onTap: onTap,
              child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: greyBorderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      _selectedDate != null
                          ? DateFormat("d/MM/y hh:mm a")
                              .format(_selectedDate!)
                              .toString()
                          : "DD/MM/YYYY HH:MM",
                      style: bFontW5()))))
    ])
  ]));
}

Widget errorMessage(bool valid, String errorMsg) {
  return Container(
      height: 30,
      padding: const EdgeInsets.only(top: 6),
      child: Visibility(
          visible: valid,
          child: Text("* $errorMsg",
              style: ssFontWN().copyWith(color: Colors.red[700]))));
}

Widget bottomButton(onCancel, onConfirm) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20)),
            child: Text(getLocale('Cancel'), style: t2FontW5())),
        TextButton(
            style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                backgroundColor: honeyColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 20)),
            onPressed: onConfirm,
            child: Text(getLocale('Confirm'), style: t2FontW5()))
      ]));
}

void pickDate(BuildContext context, onDateTimeChanged) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: CupertinoDatePicker(
                initialDateTime: _selectedDate ?? initialDate,
                onDateTimeChanged: onDateTimeChanged,
                minimumDate: DateTime.now().add(const Duration(minutes: 1)),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                minuteInterval: 1,
                mode: CupertinoDatePickerMode.dateAndTime));
      });
}

void setCategory(BuildContext context, Quotation quotation) async {
  await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _selectedCategory = quotation.category;
        return SystemPadding(
            child: StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Text(getLocale("You want to categorize this quotation as"),
                  style: t1FontW5()),
              titlePadding: const EdgeInsets.only(top: 40, left: 42, right: 42),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 42),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var i in category)
                                categoryList(i, _selectedCategory == i, () {
                                  setState(() {
                                    _selectedCategory = i;
                                  });
                                })
                            ]),
                        errorMessage(validCategory,
                            getLocale("Please choose one category")),
                        selectDuration(_selectedDate, (dynamic value) {
                          setState(() {
                            if (value != null && value != 0) {
                              _selectedSetReminder = value;
                              isSetDate = false;
                              _selectedDate =
                                  DateTime.now().add(Duration(days: value * 7));
                            }
                          });
                        }, () {
                          setState(() {
                            initialDate = DateTime.now()
                                .add(const Duration(minutes: 1, seconds: 1));
                          });
                          pickDate(context, (DateTime newDate) {
                            setState(() {
                              initialDate = DateTime.now()
                                  .add(const Duration(minutes: 1, seconds: 1));
                              _selectedDate = newDate;
                              isSetDate = true;
                              _selectedSetReminder = 0;
                            });
                          });
                        }),
                        bottomButton(() {
                          setState(() {
                            validCategory = false;
                            isSetDate = false;
                            _selectedDate = null;
                            _selectedCategory = null;
                            _selectedSetReminder = null;
                          });
                          Navigator.of(context).pop();
                        }, () async {
                          setState(() {
                            if (_selectedCategory == "Uncategorized") {
                              validCategory = true;
                            } else {
                              validCategory = false;
                            }
                          });

                          if (_selectedCategory != "Uncategorized") {
                            Navigator.of(context).pop();
                          }

                          if (_selectedCategory != null) {
                            quotation.category = _selectedCategory;
                          }
                          BlocProvider.of<QuotationBloc>(context)
                              .add(UpdateAndLoadQuotation(quotation));

                          if (_selectedCategory != "Uncategorized" &&
                              _selectedDate != null) {
                            await _setReminder(
                                context,
                                quotation,
                                _selectedDate,
                                _selectedSetReminder,
                                _selectedCategory);
                          }
                        })
                      ])));
        }));
      });
}
