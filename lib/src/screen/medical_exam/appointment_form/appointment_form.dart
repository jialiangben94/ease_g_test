import 'dart:convert';

import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_submitted.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/choose_panel.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/widget/assessment_type.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/widget/previous_appointment_details.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PagesStatus { setApp, edit, reset, reschedule, cancel, reopen, view }

enum ConfirmAction { cancel, yes }

enum SelectedTime { morning, evening }

class AppointmentForm extends StatefulWidget {
  final AppointmentRequest? appointmentRequest;
  final PagesStatus? pagesStatus;
  const AppointmentForm({Key? key, this.appointmentRequest, this.pagesStatus})
      : super(key: key);

  @override
  AppointmentFormState createState() => AppointmentFormState();
}

class AppointmentFormState extends State<AppointmentForm> {
  AppointmentDetails? appointmentDetails;
  AppointmentRequest? appointmentRequest;
  AppointmentHistory? currentAppDetails;
  List<AppointmentHistory> listAppointmentHistory = [];
  Map<String, String>? clientAddress;

  Panel? _selectedPanel;
  DateTime? _selectedDate;
  SelectedTime _selectedTime = SelectedTime.morning;

  bool hideHistory = true;
  bool isSubmitting = false;
  bool isValidDate = false;

  void sortEditData() {
    currentAppDetails = appointmentRequest!.appointmentHistory![0];
    _selectedDate = DateTime.parse(currentAppDetails!.appointmentDate!);

    if (currentAppDetails!.appointmentSlot == "AM") {
      setState(() {
        _selectedTime = SelectedTime.morning;
      });
    } else {
      setState(() {
        _selectedTime = SelectedTime.evening;
      });
    }

    _selectedPanel = Panel(
        bizHrs: currentAppDetails!.panelWorkingHours,
        name: currentAppDetails!.panelName,
        contact: currentAppDetails!.panelContactNo,
        address: currentAppDetails!.panelAddress,
        providerCode: currentAppDetails!.panelCode,
        providerType: currentAppDetails!.panelType);
  }

  void sortEditHistory() {
    for (int i = 0; i < appointmentRequest!.appointmentHistory!.length; i++) {
      listAppointmentHistory.add(appointmentRequest!.appointmentHistory![i]);
    }

    listAppointmentHistory.sort((a, b) {
      var dateA = a.appointmentDate!; //before -> var dateA = a.expiry;
      var dateB = b.appointmentDate!; //var dateB = b.expiry;
      return dateB.compareTo(dateA);
    });
  }

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen(
        widget.pagesStatus == PagesStatus.setApp
            ? "Set Appointment"
            : widget.pagesStatus == PagesStatus.edit
                ? "Edit Appointment"
                : "Re-schedule Appointment",
        "MedicalCheckAppointment");
    //1. Assign initial date
    _selectedDate = DateTime.now().add(const Duration(days: 3));

    //2. Just for less code
    appointmentRequest = widget.appointmentRequest;

    //3. Sort appointment history according to created date time
    //   This is to get latest appointment request

    appointmentRequest!.appointmentHistory!.sort((a, b) {
      var dateA = a.createdDateTime!;
      var dateB = b.createdDateTime!;
      return dateB.compareTo(dateA);
    });

    if (widget.pagesStatus == PagesStatus.reschedule ||
        widget.pagesStatus == PagesStatus.edit) {
      sortEditData();
    }

    if (widget.pagesStatus == PagesStatus.reset) {
      sortEditHistory();
    }
    validateDate();
  }

  void validateDate() {
    setState(() {
      if (_selectedPanel != null) {
        if (_selectedPanel!.providerType == "HOSPITAL" &&
            (_selectedDate!.weekday == 6 || _selectedDate!.weekday == 7)) {
          isValidDate = false;
        } else {
          isValidDate = true;
        }
      } else {
        isValidDate = true;
      }
    });
  }

  Future<Agent> getUserProfile(String key) async {
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(key)!));
    return agent;
  }

  String getFacilityCode() {
    List<String?> facilityCodeList = [];
    for (var element in widget.appointmentRequest!.client!.assestmentList!) {
      // if (!facilityCodeList.contains(element.examCode))
      facilityCodeList.add(element.examCode);
    }
    return facilityCodeList.join(";");
  }

  Future<dynamic> postAPI(AppointmentDetails? appointmentDetails) async {
    String facilityCode = getFacilityCode();

    dynamic res;
    if (widget.pagesStatus == PagesStatus.setApp) {
      res = await MedicalAppointmentAPI().submitAppointment(
          appointmentDetails: appointmentDetails!, facilityCode: facilityCode);
    } else if (widget.pagesStatus == PagesStatus.reschedule ||
        widget.pagesStatus == PagesStatus.edit) {
      // IF CHANGED PANEL, CALL RESCHEDULE
      if (currentAppDetails!.panelCode != _selectedPanel!.providerCode) {
        res = await MedicalAppointmentAPI().rescheduleAppointment(
            appointmentDetails: appointmentDetails!,
            facilityCode: facilityCode);
      } else {
        res = await MedicalAppointmentAPI().editAppointment(
            appointmentDetails: appointmentDetails!,
            facilityCode: facilityCode);
      }
    } else if (widget.pagesStatus == PagesStatus.reset) {
      res = await MedicalAppointmentAPI().submitAppointment(
          appointmentDetails: appointmentDetails!, facilityCode: facilityCode);
    }

    if (res != null) {
      return {"isSuccess": res["IsSuccess"], "message": res["Message"]};
    } else {
      return {
        "isSuccess": false,
        "message": getLocale("Failed to submit appointment")
      };
    }
  }

  String sortAddress(
      {String? addressOne,
      String? addressTwo,
      String? addressThree,
      String? postcode,
      String? city}) {
    final String newAddress = (addressOne != "" ? "${addressOne!} " : "") +
        (addressTwo != "" ? "${addressTwo!} " : "") +
        (addressThree != "" ? "${addressThree!} " : "") +
        (postcode != "" ? "${postcode!} " : "") +
        (city != "" ? "${city!} " : "");

    return newAddress;
  }

  @override
  Widget build(BuildContext context) {
    Widget selectDate() {
      // check if selected date is already passed
      if (_selectedDate!.isBefore(DateTime.now())) {
        _selectedDate = DateTime.now().add(const Duration(days: 3));
      }
      DateTime minDate;

      minDate = DateTime.now().add(const Duration(days: 3));
      minDate =
          DateTime(minDate.year, minDate.month, minDate.day, 0, 0, 0, 0, 0);

      return CupertinoDatePicker(
          initialDateTime: _selectedDate,
          onDateTimeChanged: (DateTime newDate) {
            setState(() {
              _selectedDate = newDate;
            });
            validateDate();
          },
          minimumDate: minDate,
          minuteInterval: 1,
          mode: CupertinoDatePickerMode.date);
    }

    Widget clientDetails() {
      // final address = sortAddress(
      //     addressOne: client.addressOne,
      //     addressTwo: appointmentRequest.addressTwo,
      //     addressThree: appointmentRequest.addressThree,
      //     city: appointmentRequest.city,
      //     postcode: appointmentRequest.postcode);

      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(getLocale("Life Insured", entity: true),
                          style: bFontWN().copyWith(color: greyTextColor)),
                      const SizedBox(height: 5),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                                radius: 18,
                                backgroundColor: lightCyanColor,
                                child: Text(
                                    widget.appointmentRequest!.client!
                                        .clientName![0],
                                    style:
                                        bFontW5().copyWith(color: cyanColor))),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    widget.appointmentRequest!.client!
                                        .clientName!,
                                    style: t2FontW5())),
                            const SizedBox(width: 10)
                          ])
                    ])),
                Visibility(
                    visible: !widget.appointmentRequest!.client!.isPO!,
                    child: Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(getLocale("Policy Owner", entity: true),
                              style: bFontWN().copyWith(color: greyTextColor)),
                          const SizedBox(height: 5),
                          Text(
                              widget.appointmentRequest!.client!.poName != null
                                  ? widget.appointmentRequest!.client!.poName!
                                  : "",
                              style: bFontW5())
                        ]))),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          "${getLocale("Special Translation 1 for 's Home Address")}${getLocale("Life Insured", entity: true)}${getLocale("Special Translation 2 for 's Home Address")}",
                          style: bFontWN().copyWith(color: greyTextColor)),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                              sortAddress(
                                  addressOne: widget
                                      .appointmentRequest!.client!.addressOne,
                                  addressTwo: widget
                                      .appointmentRequest!.client!.addressTwo,
                                  addressThree: widget
                                      .appointmentRequest!.client!.addressThree,
                                  city: widget.appointmentRequest!.client!.city,
                                  postcode: widget
                                      .appointmentRequest!.client!.postcode),
                              style: bFontW5()))
                    ])),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(getLocale("Assessment Type"),
                          style: bFontWN().copyWith(color: greyTextColor)),
                      const SizedBox(height: 10),
                      widget.appointmentRequest!.client!.assestmentList!
                              .isNotEmpty
                          ? AssessmentType(
                              string: widget
                                  .appointmentRequest!.client!.assestmentList)
                          : Text("-", style: bFontW5())
                    ]))
              ]));
    }

    Widget prevAppointment() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Previous Appointment Details"),
            style: bFontWN().copyWith(color: cyanColor).copyWith(fontSize: 15)),
        PreviousAppointmentDetails(listAppointmentHistory),
      ]);
    }

    Future<void> selectPanel() async {
      String facilityCode = getFacilityCode();
      try {
        final tmpPanel = await Navigator.of(context).push(createRoute(
            ChoosePanel(
                widget.appointmentRequest!.client!.postcode, facilityCode)));

        if (tmpPanel != null) {
          setState(() {
            _selectedPanel = tmpPanel;
          });
        }
      } catch (e) {
        rethrow;
      }
    }

    Widget panel() {
      Widget child;
      if (_selectedPanel == null) {
        child = GestureDetector(
            onTap: () {
              selectPanel();
              analyticsSendEvent("choose_a_panel",
                  {"button_name": "Choose a service panel here"});
            },
            child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: lightCyanColorTwo),
                child: Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      const Image(
                          width: 30,
                          height: 30,
                          image: AssetImage('assets/images/location_icon.png')),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(getLocale("Choose a service panel here"),
                              style: bFontW5().copyWith(color: cyanColor)))
                    ]))));
      } else {
        child = Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: greyBorderColor)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_selectedPanel!.name!, style: t2FontW5()),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(cleanPanelAddress(_selectedPanel!.address!),
                      style: bFontWN().copyWith(color: greyTextColor))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Open at ${_selectedPanel!.bizHrs}",
                      style: bFontWN().copyWith(color: greyTextColor)),
                  Text("${_selectedPanel!.contact}",
                      style: bFontWN().copyWith(color: greyTextColor))
                ]),
                OutlinedButton(
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.all(Radius.circular(5))),
                    // borderSide: BorderSide(color: cyanColor),
                    // color: cyanColor,
                    // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cyanColor)),
                    onPressed: () {
                      analyticsSendEvent("change_panel", {
                        "button_name": "change",
                        "desc": "change selected panel"
                      });
                      if (appointmentRequest!.appointmentStatus != "P") {
                        _showDialog(context, selectPanel);
                      } else {
                        selectPanel();
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Text(getLocale("Change"),
                            style: sFontWN().copyWith(color: cyanColor))))
              ])
            ]));
      }
      return child;
    }

    Widget currentConfirmed() {
      return Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 30),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getLocale("Current Confirmed Date"),
                  style: bFontWN().copyWith(color: greyTextColor)),
              const SizedBox(height: 10),
              Text(
                  DateFormat("d MMMM y")
                      .format(
                          DateTime.parse(currentAppDetails!.appointmentDate!))
                      .toString(),
                  style: bFontW5())
            ]),
            const SizedBox(width: 320),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getLocale("Current Confirmed Time"),
                  style: bFontWN().copyWith(color: greyTextColor)),
              const SizedBox(height: 10),
              Text(
                  currentAppDetails!.appointmentSlot == "AM"
                      ? getLocale("9am to 12pm")
                      : getLocale("12pm to 6pm"),
                  style: bFontW5())
            ])
          ]));
    }

    Widget dateRow() {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(getLocale("Choose date"),
                      style: bFontWN().copyWith(color: greyTextColor)),
                  const SizedBox(height: 16),
                  GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 3,
                                  child: selectDate());
                            });
                      },
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minWidth: 300, maxWidth: 310),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: !isValidDate
                                          ? scarletRedColor
                                          : greyBorderColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            flex: 4,
                                            child: Row(children: [
                                              const Image(
                                                  width: 20,
                                                  height: 20,
                                                  image: AssetImage(
                                                      'assets/images/calendar_icon.png')),
                                              const SizedBox(width: 10),
                                              Text(
                                                  DateFormat("d MMMM y")
                                                      .format(_selectedDate!)
                                                      .toString(),
                                                  style: bFontW5()),
                                              const SizedBox(width: 10)
                                            ])),
                                        const Expanded(
                                            flex: 1,
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.black)))
                                      ]))))),
                  Visibility(
                      visible: !isValidDate,
                      child: Text(
                          "**${getLocale("choose date on weekday only")}",
                          style: bFontWN().copyWith(color: scarletRedColor)))
                ])),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      widget.pagesStatus == PagesStatus.setApp
                          ? getLocale("Choose time between")
                          : widget.pagesStatus == PagesStatus.edit
                              ? getLocale("Selected time")
                              : widget.pagesStatus == PagesStatus.reschedule
                                  ? "Re-schedule time"
                                  : "Choose time between",
                      style: bFontWN().copyWith(color: greyTextColor)),
                  const SizedBox(height: 16),
                  Row(children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = SelectedTime.morning;
                          });
                          analyticsSendEvent(
                              "choose_time", {"selectedTime": "9am to 12pm"});
                        },
                        child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                color: _selectedTime == SelectedTime.morning
                                    ? lightCyanColor
                                    : Colors.white,
                                border: Border.all(
                                    color: _selectedTime == SelectedTime.morning
                                        ? lightCyanColor
                                        : greyBorderColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(getLocale("9am to 12pm"),
                                          style: bFontW5().apply(
                                              color: _selectedTime ==
                                                      SelectedTime.morning
                                                  ? cyanColor
                                                  : Colors.black))),
                                  if (_selectedTime == SelectedTime.morning)
                                    Expanded(
                                        flex: 1,
                                        child: Icon(Icons.check,
                                            color: cyanColor, size: 20))
                                ])))),
                    const SizedBox(width: 20),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTime = SelectedTime.evening;
                          });
                          analyticsSendEvent(
                              "choose_time", {"selectedTime": "12pm to 6pm"});
                        },
                        child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                color: _selectedTime == SelectedTime.evening
                                    ? lightCyanColor
                                    : Colors.white,
                                border: Border.all(
                                    color: _selectedTime == SelectedTime.evening
                                        ? lightCyanColor
                                        : greyBorderColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(children: [
                                  Expanded(
                                      flex: 4,
                                      child: Text(getLocale("12pm to 6pm"),
                                          style: bFontW5().apply(
                                              color: _selectedTime ==
                                                      SelectedTime.evening
                                                  ? cyanColor
                                                  : Colors.black))),
                                  if (_selectedTime == SelectedTime.evening)
                                    Expanded(
                                        flex: 1,
                                        child: Icon(Icons.check,
                                            color: cyanColor, size: 20))
                                ]))))
                  ])
                ]))
          ]);
    }

    bool isFormValid() {
      // TO AVOID USER SUBMIT UNEDITED DATA
      if (widget.pagesStatus == PagesStatus.edit ||
          widget.pagesStatus == PagesStatus.reschedule) {
        bool slotChanged = false;
        bool panelChanged = false;
        bool dateChanged = false;
        //check if slot changed ()
        if (_selectedTime == SelectedTime.morning &&
            currentAppDetails!.appointmentSlot == "AM") {
          slotChanged = false;
        } else if (_selectedTime == SelectedTime.evening &&
            currentAppDetails!.appointmentSlot == "PM") {
          slotChanged = false;
        } else {
          slotChanged = true;
        }

        if (currentAppDetails!.panelCode != _selectedPanel!.providerCode) {
          panelChanged = true;
        }

        if (_selectedDate !=
                DateTime.parse(currentAppDetails!.appointmentDate!) &&
            isValidDate) dateChanged = true;

        return (slotChanged || panelChanged || dateChanged);
      } else {
        return _selectedPanel != null && _selectedDate != null && isValidDate;
      }
    }

    void handleSubmit() async {
      setState(() {
        isSubmitting = true;
      });

      // Get Agent details
      Agent agent = await getUserProfile(spkAgent);
      String timeRange;
      String? appointmentCode;

      if (_selectedPanel != null) {
        var selectedTime = "";
        if (_selectedTime == SelectedTime.morning) {
          selectedTime = "9am to 12pm";
          timeRange = "AM";
        } else {
          selectedTime = "12pm to 6pm";
          timeRange = "PM";
        }
        if (widget.pagesStatus == PagesStatus.setApp) {
          appointmentCode = "";
        } else if (widget.pagesStatus == PagesStatus.edit ||
            widget.pagesStatus == PagesStatus.reschedule ||
            widget.pagesStatus == PagesStatus.reset) {
          appointmentCode =
              appointmentRequest!.appointmentHistory![0].mcsAppointmentCode;
        }
        // Setup data to submit
        appointmentDetails = AppointmentDetails(
            agentCode: agent.accountCode,
            selectedPanels: _selectedPanel,
            appointmentRequest: appointmentRequest,
            appointmentDateTime:
                DateFormat("y-MM-d").format(_selectedDate!).toString(),
            timeRange: timeRange,
            appointmentCode: appointmentCode);

        // PostAPI will send request type based on PagesStatus.status
        var response = await postAPI(appointmentDetails).catchError((e) {
          // Error handling
          setState(() {
            isSubmitting = false;
          });
          showAlertDialog(context, getLocale("Connection Error"), e.toString());
        });

        if (response["isSuccess"]) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Navigator.of(context).push(createRoute(AppointmentSubmitted(
                panel: _selectedPanel,
                selectedDate: _selectedDate,
                selectedTime: selectedTime,
                appointmentRequest: appointmentRequest,
                prevAppointmentDetails: currentAppDetails,
                pagesStatus: widget.pagesStatus)));
          });
        } else {
          setState(() {
            isSubmitting = false;
          });
          String? message;
          if (response["message"] != "" && response["message"] != null) {
            message = response["message"];
          } else {
            message = getLocale("Unexpected error occurred");
          }
          if (!mounted) {}
          showAlertDialog(context, getLocale("Error"), message);
        }
      }
    }

    Widget buttonSubmit() {
      return AnimatedContainer(
          height: isFormValid() ? 60 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Visibility(
              child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 0))
                  ]),
                  child: TextButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: honeyColor),
                      onPressed: () async {
                        await analyticsSendEvent(
                            widget.pagesStatus == PagesStatus.edit ||
                                    widget.pagesStatus == PagesStatus.reschedule
                                ? "resubmit_appointment"
                                : "submit_appointment",
                            {
                              "button_name": widget.pagesStatus ==
                                          PagesStatus.edit ||
                                      widget.pagesStatus ==
                                          PagesStatus.reschedule
                                  ? getLocale(
                                      "RE-SUBMIT FOR PANEL'S CONFIRMATION")
                                  : getLocale("SUBMIT FOR PANEL'S CONFIRMATION")
                            });
                        bool haveConn = await checkConnectivity();
                        if (!haveConn) {
                          if (!mounted) {}
                          showAlertDialog(
                              context,
                              getLocale("Error"),
                              getLocale(
                                  "Please check your internet connection"));
                        } else {
                          handleSubmit();
                        }
                      },
                      // color: honeyColor,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: isSubmitting == true
                                  ? const SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.black))))
                                  : Text(
                                      widget.pagesStatus == PagesStatus.edit ||
                                              widget.pagesStatus ==
                                                  PagesStatus.reschedule
                                          ? getLocale(
                                              "RE-SUBMIT FOR PANEL'S CONFIRMATION")
                                          : getLocale(
                                              "SUBMIT FOR PANEL'S CONFIRMATION"),
                                      style: t2FontWB())))))));
    }

    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          normalAppBar(context, ""),
          Expanded(
              child:
                  ListView(physics: const ClampingScrollPhysics(), children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          widget.pagesStatus == PagesStatus.setApp
                              ? getLocale("Set Appointment")
                              : widget.pagesStatus == PagesStatus.edit
                                  ? getLocale("Edit Appointment")
                                  : getLocale("Re-schedule Appointment"),
                          style: tFontWN()),
                      const SizedBox(height: 20),
                      clientDetails()
                    ])),
            const SizedBox(height: 20),
            listAppointmentHistory.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 20),
                    child: prevAppointment())
                : const SizedBox(height: 0),
            Container(
                height: 1.2, width: double.infinity, color: greyDividerColor),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 16),
                          child: Text(
                              _selectedPanel == null
                                  ? getLocale("Choose a panel")
                                  : getLocale("Selected Panel"),
                              style: bFontWN().copyWith(color: greyTextColor))),
                      panel(),
                      const SizedBox(height: 20),
                      if (widget.pagesStatus == PagesStatus.reschedule)
                        currentConfirmed(),
                      if (_selectedPanel != null) dateRow(),
                      const SizedBox(height: 50)
                    ]))
          ]))
        ]),
        bottomNavigationBar: buttonSubmit());
  }

  Future<ConfirmAction?> _showDialog(
      BuildContext context, Function chooseNewPanel) async {
    await analyticsSetCurrentScreen(
        "Dialog: Confirm to change panel", "MedicalCheckAppointment");
    return showDialog<ConfirmAction>(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return Center(
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.45),
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
                                  horizontal: 20, vertical: 6),
                              child: Text(
                                  getLocale(
                                      'Are you sure you want to change the selected service panel?'),
                                  style: t2FontW5())),
                          content: Column(children: [
                            Text(
                                getLocale(
                                    'If yes, we will proceed to cancel the current service panel appointment and proceed with the new submission'),
                                style: bFontWN()),
                            const SizedBox(height: 50),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                      child: TextButton(
                                          onPressed: () {
                                            analyticsSendEvent(
                                                "cancel_change_panel",
                                                {"button_name": "Cancel"});
                                            Navigator.of(context)
                                                .pop(ConfirmAction.cancel);
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              child: Text(getLocale("Cancel"),
                                                  style: t2FontWB())))),
                                  Expanded(
                                      child: TextButton(
                                          style: TextButton.styleFrom(
                                              backgroundColor: honeyColor),
                                          onPressed: () {
                                            analyticsSendEvent(
                                                "confirm_change_panel",
                                                {"button_name": "Yes"});
                                            Navigator.of(context).pop();
                                            chooseNewPanel();
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6),
                                              child: Text(getLocale('Yes'),
                                                  style: t2FontWB()))))
                                ])
                          ])))));
        });
  }
}
