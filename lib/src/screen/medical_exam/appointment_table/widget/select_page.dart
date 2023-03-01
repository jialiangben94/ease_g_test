import 'dart:convert';

import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/journey.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../util/function.dart';

// enum Pages { EDIT, RESCHEDULE, VIEW, CANCEL, REOPEN }
// enum ConfirmAction { CANCEL, YES }

Future<dynamic> cancelAppointmentAPI(AppointmentRequest appointmentRequest) {
  return MedicalAppointmentAPI()
      .cancelAppointment(appointmentRequest: appointmentRequest)
      .then((res) {
    if (res != null) {
      return {"isSuccess": res["IsSuccess"], "message": res["Message"]};
    } else {
      return {"isSuccess": false, "message": "Failed to submit appointment"};
    }
  });
}

Future<List<Journey>> getStatusJourneyAPI(
    AppointmentRequest appointmentRequest) async {
  List<Journey> journeyList = [];
  await MedicalAppointmentAPI()
      .getStatusJourney(appointmentRequest.proposalMEId)
      .then((res) {
    final journeylist = jsonDecode(res["JourneyList"]);
    if (journeylist.length != null) {
      for (int i = 0; i < journeylist.length; i++) {
        Journey journey = Journey.fromJson(journeylist[i]);
        journeyList.add(journey);
      }
    }
  });
  return journeyList;
}

Widget reportList(BuildContext context, List<Journey> data) {
  return Column(children: [
    for (int i = 0; i < data.length; i++)
      if (data[i].isCompleted!)
        Container(
            padding: const EdgeInsets.only(top: 20, right: 40),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Stack(alignment: Alignment.center, children: [
                const CircleAvatar(backgroundColor: Colors.white, radius: 12),
                data[i].isCompleted!
                    ? const Image(
                        width: 25,
                        height: 25,
                        image: AssetImage('assets/images/check_circle.png'))
                    : Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey)))
              ])),
              Expanded(
                  flex: 8,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            data[i].journeyDesc != null
                                ? data[i]
                                    .journeyDesc!
                                    .replaceAll("<br>         ", "\n")
                                : "",
                            style: bFontWN()),
                        Visibility(
                            visible: data[i].statusDateTime != null,
                            child: Text(
                                data[i].statusDateTime != null
                                    ? DateFormat("d MMMM y").format(
                                        DateTime.parse(data[i].statusDateTime!))
                                    : "",
                                style:
                                    bFontWN().copyWith(color: greyTextColor)))
                      ]))
            ]))
  ]);
}

void statusJourneyView(BuildContext context,
    AppointmentRequest appointmentRequest, bool viewSJ) async {
  List<Journey> journeyList = await getStatusJourneyAPI(appointmentRequest);
  await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) {
        return Container();
      },
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, a1, a2, child) {
        final curvedValue = Curves.easeOut.transform(a1.value) - 1.0;
        return DefaultTextStyle(
            style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Meta',
                fontSize: 24,
                color: Colors.black),
            child: Transform(
                transform:
                    Matrix4.translationValues(-(curvedValue * 200), 0.0, 0.0),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                        radius: 22,
                                        backgroundColor: lightCyanColor,
                                        child: Text(
                                            appointmentRequest
                                                .client!.clientName![0],
                                            style: bFontW5()
                                                .apply(color: cyanColor))),
                                    Expanded(
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10),
                                                      child: Text(
                                                          appointmentRequest
                                                              .client!
                                                              .clientName!,
                                                          style: bFontW5())),
                                                  Text(
                                                      "${getLocale("Proposal No")}.",
                                                      style: bFontWN()),
                                                  Text(
                                                      appointmentRequest
                                                          .ssProposalNo!,
                                                      style: bFontW5())
                                                ]))),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Padding(
                                            padding: EdgeInsets.all(0),
                                            child: Icon(Icons.close,
                                                color: Colors.black)))
                                  ])),
                          Container(
                              color: creamColor,
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 22),
                                  child: Text(
                                      getLocale("Medical Report Status"),
                                      style: bFontW5()))),
                          Expanded(
                              child: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  child: SingleChildScrollView(
                                      physics: const ClampingScrollPhysics(),
                                      child: Stack(children: [
                                        Positioned.fill(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.026,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.473,
                                            child:
                                                Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                    width: 1.0,
                                                    color: Colors.grey)),
                                        reportList(context, journeyList)
                                      ]))))
                        ])))));
      });
}

Future<PagesStatus> selectPage(
    BuildContext context, AppointmentRequest data, String page) async {
  await analyticsSendEvent("appointment_more_option",
      {"button_name": "More", "propNo": data.propNo});
  return await showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
              titlePadding: const EdgeInsets.only(left: 30, right: 30, top: 10),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getLocale('Select one action'), style: sFontWN()),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          analyticsSendEvent("close_appointment_more_option",
                              {"button_name": "Close", "propNo": data.propNo});
                        },
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(Icons.close))
                  ]),
              children: [
                Visibility(
                    visible: page == "pendingPanel" || page == "confirmed",
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          SimpleDialogOption(
                              onPressed: () {
                                page == "pendingPanel"
                                    ? Navigator.pop(context, PagesStatus.edit)
                                    : Navigator.pop(
                                        context, PagesStatus.reschedule);
                              },
                              child: Text(
                                  page == "pendingPanel"
                                      ? getLocale('Edit Appointment')
                                      : getLocale('Re-Schedule Appointment'),
                                  style: bFontWN().copyWith(color: cyanColor)))
                        ])),
                const Divider(),
                SimpleDialogOption(
                    onPressed: () {
                      analyticsSendEvent("view_status_journey", {
                        "button_name": "View Status Journey",
                        "propNo": data.propNo
                      });
                      Navigator.pop(context, PagesStatus.view);
                    },
                    child: Text(getLocale('View Status Journey'),
                        style: bFontWN().copyWith(color: cyanColor))),
                const Divider(),
                Visibility(
                    visible: page == "pendingPanel" || page == "confirmed",
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimpleDialogOption(
                              onPressed: () {
                                analyticsSendEvent("cancel_appointment", {
                                  "button_name": "Cancel",
                                  "propNo": data.propNo
                                });
                                Navigator.pop(context, PagesStatus.cancel);
                              },
                              child: Text(getLocale('Cancel this check-up'),
                                  style: bFontWN().copyWith(color: cyanColor))),
                          const Divider()
                        ])),
                Visibility(
                    visible: page == "ntu" && data.appointmentStatus == "NTU",
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimpleDialogOption(
                              onPressed: () {
                                analyticsSendEvent(
                                    "request_to_reopen_proposal", {
                                  "button_name": "Request to Reopen Proposal",
                                  "propNo": data.propNo
                                });
                                Navigator.pop(context, PagesStatus.reopen);
                              },
                              child: Text(
                                  getLocale('Request to Reopen Proposal'),
                                  style: bFontWN().copyWith(color: cyanColor))),
                          const Divider()
                        ]))
              ]));
}

Future<void> cancel(BuildContext context, AppointmentRequest data) async {
  loadingScreen(context, "cancel");
  // Submit through API
  await cancelAppointmentAPI(data).then((response) {
    if (response != null) {
      // Refresh page
      Navigator.pop(context);
      BlocProvider.of<AppointmentRequestListsBloc>(context)
          .add(GetPanelDecisionList());
      if (response["isSuccess"]) {
        return showAlertDialog(
            context, getLocale("Successful"), response["message"]);
      } else {
        return showAlertDialog(
            context, getLocale("Error"), response["message"]);
      }
    }
  }).catchError((e) {
    // Error handling
    Navigator.pop(context);
    showAlertDialog(context, getLocale("Connection Error"), e.toString());
  });
}

Future<void> emailECRM(BuildContext context, AppointmentRequest data) async {
  loadingScreen(context, "pending uw");
  // Submit through API
  await MedicalAppointmentAPI()
      .emailECRM(data.propNo, data.proposalMEId)
      .then((response) {
    if (response != null) {
      // Refresh page
      Navigator.pop(context);
      BlocProvider.of<AppointmentRequestListsBloc>(context)
          .add(GetOthersAppointmentList());
      if (response["IsSuccess"]) {
        return showAlertDialog(context, getLocale("Successful"),
            getLocale("Request have been successfully sent"));
      } else {
        return showAlertDialog(context, "Error", response["Message"]);
      }
    }
  }).catchError((e) {
    // Error handling
    Navigator.pop(context);
    showAlertDialog(context, "Connection Error", e.toString());
  });
}

Future<ConfirmAction?> confirmDialog(
    BuildContext context, AppointmentRequest data, PagesStatus status) async {
  String? action;
  String object = getLocale("medical check appointment");
  if (status == PagesStatus.edit) {
    action = getLocale("edit");
  } else if (status == PagesStatus.reschedule) {
    action = getLocale("reschedule");
  } else if (status == PagesStatus.cancel) {
    action = getLocale("cancel");
  } else if (status == PagesStatus.reopen) {
    action = "send this request to underwriter to reopen";
    object = getLocale("proposal");
  }
  if (status != PagesStatus.reopen) {
    await analyticsSetCurrentScreen(
        "Confirm Dialog to $action appointment", "MedicalCheckAppointment");
  } else {
    await analyticsSetCurrentScreen(
        "Confirm Dialog to reopen appointment", "MedicalCheckAppointment");
  }
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
                            horizontal: 36, vertical: 32),
                        title: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            child: Text(
                                '${getLocale("Are you sure you want to")} $action ${getLocale("this")} $object?',
                                style: bFontW5().apply(fontSizeFactor: 1.2))),
                        content: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(children: [
                                Expanded(
                                    child: TextButton(
                                        onPressed: () {
                                          analyticsSendEvent(
                                              (status != PagesStatus.reopen)
                                                  ? "cancel_$action"
                                                  : "cancel_reopen",
                                              {
                                                "action": action,
                                                "button_name": "Cancel",
                                                "propNo": data.propNo
                                              });
                                          Navigator.of(context)
                                              .pop(ConfirmAction.cancel);
                                        },
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(getLocale('No'),
                                                style: t2FontWB())))),
                                Expanded(
                                    child: TextButton(
                                        onPressed: () async {
                                          Navigator.of(context)
                                              .pop(ConfirmAction.yes);
                                          await analyticsSendEvent(
                                              (status != PagesStatus.reopen)
                                                  ? "confirm_$action"
                                                  : "confirm__reopen",
                                              {
                                                "action": action,
                                                "button_name": "Yes",
                                                "propNo": data.propNo
                                              });
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: honeyColor),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6),
                                            child: Text(getLocale('Yes'),
                                                style: t2FontWB()))))
                              ])
                            ])))));
      });
}
