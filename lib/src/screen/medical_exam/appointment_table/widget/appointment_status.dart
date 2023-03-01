import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// enum dataType {ScheduleConfirm, Cancelled, CustomerNoShow}

class AppointmentStatus extends StatelessWidget {
  final AppointmentRequest? data;
  final AppointmentHistory? appointmentData;

  const AppointmentStatus({Key? key, this.data, this.appointmentData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Padding iconData() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
              appointmentData!.appointmentStatus == "C"
                  ? Icons.check
                  : Icons.close,
              color: appointmentData!.appointmentStatus == "C"
                  ? tealGreenColor
                  : Colors.red));
    }

    Text statusMessage() {
      String? slot;
      if (appointmentData!.appointmentSlot == "AM") {
        slot = getLocale("9am to 12pm");
      } else if (appointmentData!.appointmentSlot == "PM") {
        slot = getLocale("12pm to 6pm");
      }
      return Text(
          appointmentData!.appointmentStatus == "C"
              ? "${getLocale("Appointment confirmed on")} ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentData!.appointmentDate!)).toString()}, $slot"
              : (appointmentData!.appointmentStatus == "S" ||
                      appointmentData!.appointmentStatus == "R")
                  ? "${getLocale("Cancelled by")} ${appointmentData!.panelName} on ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentData!.modifiedDateTime!)).toString()}, ${getLocale("due to")} ${appointmentData!.remarks!.toLowerCase()}"
                  : appointmentData!.appointmentStatus == "X"
                      ? "${getLocale("Cancelled on")} ${DateFormat('dd MMM yyyy').format(DateTime.parse(appointmentData!.modifiedDateTime!)).toString()}, ${getLocale("agent decided to cancel the examination appointment")}"
                      : appointmentData!.appointmentStatus == "N"
                          ? getLocale("Customer No Show")
                          : "",
          style: appointmentData!.appointmentStatus == "C"
              ? bFontW5().copyWith(color: tealGreenColor)
              : bFontWN().copyWith(color: scarletRedColor));
    }

    return Column(children: [
      const SizedBox(height: 10),
      Container(
          decoration: BoxDecoration(
              color: appointmentData!.appointmentStatus == "C"
                  ? lightCyanColorThree
                  : lightPinkColor,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconData(),
                Expanded(child: statusMessage()),
                const SizedBox(width: 10)
              ])),
      const SizedBox(height: 10)
    ]);
  }
}
