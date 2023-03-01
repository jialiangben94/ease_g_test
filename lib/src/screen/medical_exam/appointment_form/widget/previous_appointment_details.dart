import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class PreviousAppointmentDetails extends StatefulWidget {
  final List<AppointmentHistory> appointmentHistory;
  const PreviousAppointmentDetails(this.appointmentHistory, {Key? key})
      : super(key: key);
  @override
  PreviousAppointmentDetailsState createState() =>
      PreviousAppointmentDetailsState();
}

class PreviousAppointmentDetailsState
    extends State<PreviousAppointmentDetails> {
  late bool hideHistory;
  int? showMedCheckType;
  final GlobalKey _key = GlobalKey();
  RenderBox? renderBox;

  List<AppointmentHistory> data = [];

  @override
  void initState() {
    data = widget.appointmentHistory;
    hideHistory = true;
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _getSizes());
  }

  void _getSizes() {
    renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
  }

  @override
  Widget build(BuildContext context) {
    Widget prevAppointmentDetails(
        int i, AppointmentHistory appointmentHistory) {
      String slot = appointmentHistory.appointmentSlot == "AM"
          ? getLocale("9am to 12pm")
          : getLocale("12pm to 6pm");
      String rescheduleReason = appointmentHistory.appointmentStatus == "C"
          ? "${getLocale("Appointment confirmed on")} ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentHistory.appointmentDate!)).toString()}, $slot"
          : (appointmentHistory.appointmentStatus == "X" ||
                  appointmentHistory.appointmentStatus == "S" ||
                  appointmentHistory.appointmentStatus == "R")
              ? appointmentHistory.modifiedBy == "Service Provider"
                  ? "${getLocale("Cancelled by")} ${appointmentHistory.panelName} ${getLocale("on")} ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentHistory.modifiedDateTime!)).toString()}, ${getLocale("due to")} ${appointmentHistory.remarks!.toLowerCase()}"
                  : "${getLocale("Cancelled on")} ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentHistory.modifiedDateTime!)).toString()}, ${getLocale("agent decided to cancel the examination appointment")}"
              : appointmentHistory.appointmentStatus == "N"
                  ? getLocale("Customer No Show")
                  : "";

      return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text("$i.",
                      style:
                          bFontWN().copyWith(color: cyanColor, fontSize: 15)),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getLocale("Selected Panel"),
                                    style: bFontWN()
                                        .copyWith(color: greyTextColor)),
                                const SizedBox(height: 5),
                                Text(appointmentHistory.panelName!,
                                    overflow: TextOverflow.ellipsis,
                                    style: bFontW5())
                              ])))
                ])),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(getLocale("Book Date & Time"),
                      style: bFontWN().copyWith(color: greyTextColor)),
                  const SizedBox(height: 5),
                  Text(
                      "${DateFormat("d MMMM y").format(DateTime.parse(appointmentHistory.appointmentDate!)).toString()}, $slot",
                      style: bFontW5())
                ])),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(getLocale("Reason to Re-schedule"),
                      style: bFontWN().copyWith(color: greyTextColor)),
                  const SizedBox(height: 5),
                  Text(rescheduleReason, style: bFontW5())
                ]))
          ]));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // First list
      prevAppointmentDetails(1, data[0]),
      // Animate the rest list here
      AnimatedContainer(
          curve: Curves.easeInOutQuart,
          duration: const Duration(seconds: 1),
          height: hideHistory ? 0 : renderBox!.size.height,
          child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(key: _key, children: [
                for (int i = 1; i < data.length; i++)
                  prevAppointmentDetails(i + 1, data[i]),
              ]))),
      Visibility(
          visible: data.length > 1,
          child: Center(
              child: InkWell(
                  onTap: () {
                    _getSizes();
                    setState(() {
                      hideHistory = !hideHistory;
                    });
                    analyticsSendEvent(
                        hideHistory
                            ? "show_assessment_type"
                            : "hide_assessment_type",
                        {
                          "button_name": hideHistory
                              ? getLocale("Show all type")
                              : getLocale("Show less")
                        });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20))),
                      height: 45,
                      width: 150,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(hideHistory
                                ? getLocale("See More")
                                : getLocale("Hide")),
                            Icon(
                                hideHistory
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                color: Colors.grey)
                          ])))))
    ]);
  }
}
