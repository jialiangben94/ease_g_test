import 'dart:io' show Platform;

import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum TabStatus {
  pendingAppointmentSetup,
  pendingPanel,
  scheduleConfirm,
  checkUpCompleted,
  customerNoShow,
  cancelledAppointment,
  others
}

class AppointmentColumn extends StatelessWidget {
  final AppointmentRequest? data;
  final TabStatus? status;
  const AppointmentColumn({Key? key, this.data, this.status}) : super(key: key);

  void launchURL(String? lat, String? lng) async {
    late String url;
    if (Platform.isAndroid) {
      url = "https://google.navigation:?q=$lat,$lng";
    } else if (Platform.isIOS) {
      url = "https://maps.apple.com/?q=$lat,$lng";
    }

    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await analyticsSendEvent("url_launched", {
        "url": Platform.isAndroid
            ? "https://google.navigation:?q=$lat,$lng"
            : "https://maps.apple.com/?q=$lat,$lng",
        "panelCode": data!.appointmentHistory![0].panelCode
      });
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget panelDetail(String label, String? detail) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text(label,
                    style: bFontWN().copyWith(color: greyTextColor))),
            Expanded(flex: 2, child: Text(detail ?? "-", style: bFontW5()))
          ]));
    }

    Widget buildLoaded(AppointmentRequest? request, AppointmentHistory data) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Selected Panel Details"),
            style: bFontWN().copyWith(color: greyTextColor)),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(data.panelName != null ? data.panelName! : "-",
                  style: bFontW5())),
          panelDetail("Address", cleanPanelAddress(data.panelAddress!)),
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(children: [
                Expanded(child: Container()),
                Expanded(
                    flex: 2,
                    child: GestureDetector(
                        onTap: () {
                          analyticsSendEvent("launch_url", {
                            "button_name": Platform.isAndroid
                                ? "View in Google Maps"
                                : "View in Apple Maps",
                            "panelCode": data.panelCode
                          });
                          launchURL(data.panelLatitude, data.panelLongitude);
                        },
                        child: Row(children: [
                          Text(
                              Platform.isAndroid
                                  ? getLocale("View in Google Maps")
                                  : getLocale("View in Apple Maps"),
                              style: sFontWN().copyWith(color: cyanColor)),
                          Icon(Icons.adaptive.arrow_forward, color: cyanColor)
                        ])))
              ])),
          panelDetail("Business Hours", data.panelWorkingHours),
          panelDetail("Contact No.", data.panelContactNo)
        ])),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
                onPressed: () {
                  analyticsSendEvent("close_panel_detail",
                      {"button_name": "Close", "panelCode": data.panelCode});
                  Navigator.of(context).pop();
                },
                // shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.all(Radius.circular(4.0))),
                // color: honeyColor,
                // padding: EdgeInsets.symmetric(vertical: 12),
                style: TextButton.styleFrom(backgroundColor: honeyColor),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(getLocale("CLOSE"), style: bFontW5()))))
      ]);
    }

    void viewSelectedPanel(
        AppointmentRequest? request, AppointmentHistory data) {
      analyticsSetCurrentScreen(
          "View Selected Panel", "MedicalCheckAppointment");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.5,
                    padding: const EdgeInsets.all(30),
                    child: buildLoaded(request, data)));
          });
    }

    if (data!.appointmentHistory != null) {
      //SORT appointmentHISTORY FROM LATEST TO OLD
      data!.appointmentHistory!.sort((a, b) {
        DateTime dateA = DateTime.parse(
            a.createdDateTime!); //before -> var dateA = a.expiry;
        DateTime dateB =
            DateTime.parse(b.createdDateTime!); //var dateB = b.expiry;
        return dateB.compareTo(dateA);
      });
    }

    final String range = data!.appointmentHistory![0].appointmentSlot == "AM"
        ? "9.00am - 12.00pm"
        : "12.00pm - 6.00pm";

    final date = data!.appointmentHistory != null
        ? data!.appointmentHistory![0].appointmentDate!
        : DateTime.now().toString();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Divider(),
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
              status == TabStatus.pendingAppointmentSetup
                  ? getLocale("Previous Appointment Details")
                  : getLocale("Appointment Details"),
              style: sFontW5().copyWith(color: cyanColor))),
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getLocale("Selected Panel"),
                              style: bFontWN().copyWith(color: greyTextColor)),
                          const SizedBox(height: 5),
                          Row(children: [
                            Expanded(
                                flex: 4,
                                child: Text(
                                    data!.appointmentHistory != null
                                        ? data!
                                            .appointmentHistory![0].panelName!
                                        : "",
                                    overflow: TextOverflow.ellipsis,
                                    style: bFontW5())),
                            Expanded(
                                flex: 1,
                                child: InkWell(
                                    onTap: () {
                                      analyticsSendEvent("view_panel_detail", {
                                        "button_name": "View Panel",
                                        "propNo": data!.propNo,
                                        "panelCode": data!
                                            .appointmentHistory![0].panelCode,
                                        "panelName": data!
                                            .appointmentHistory![0].panelName
                                      });
                                      viewSelectedPanel(
                                          data, data!.appointmentHistory![0]);
                                    },
                                    child: Row(children: [
                                      Text(getLocale("View"),
                                          style: bFontWN()
                                              .copyWith(color: cyanColor)),
                                      Icon(Icons.adaptive.arrow_forward,
                                          color: cyanColor, size: 12)
                                    ])))
                          ])
                        ])),
                Expanded(
                    flex: 2,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getLocale("Book Date & Time"),
                              style: bFontWN().copyWith(color: greyTextColor)),
                          const SizedBox(height: 5),
                          Text(
                              "${DateFormat('dd MMM yyyy').format(DateTime.parse(date)).toString()}, $range",
                              style: bFontW5())
                        ]))
              ]))
    ]);
  }
}
