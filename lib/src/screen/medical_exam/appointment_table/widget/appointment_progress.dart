import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class AppointmentProgress extends StatefulWidget {
  final AppointmentRequest dataType;
  const AppointmentProgress(this.dataType, {Key? key}) : super(key: key);

  @override
  AppointmentProgressState createState() => AppointmentProgressState();
}

class AppointmentProgressState extends State<AppointmentProgress> {
  final List<String> status = [
    "Check up Done",
    "Partial Report submitted",
    "Full Report submitted",
    "Etiqa Feedback",
    "Revision",
    "Completed"
  ];

  int activeStatus = 0;

  List<AppointmentHistory>? appointmentHistory;

  @override
  void initState() {
    super.initState();
    appointmentHistory = widget.dataType.appointmentHistory;
    appointmentHistory!.sort((a, b) {
      var dateA = a.appointmentDate!; //before -> var dateA = a.expiry;
      var dateB = b.appointmentDate!; //var dateB = b.expiry;
      return dateB.compareTo(dateA);
    });
  }

  void determineStatus() {
    if (appointmentHistory![0].appointmentSubStatus == "P") {
      activeStatus = 1;
    } else if (appointmentHistory![0].appointmentSubStatus == "F") {
      activeStatus = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double tabletWidth = MediaQuery.of(context).size.width;
    final double tabletHeight = MediaQuery.of(context).size.height;

    determineStatus();

    Row dottedLine(x, int position) {
      final bool active = x <= activeStatus ? true : false;
      int i;

      if (tabletWidth <= 1080) {
        i = 6;
      } else if (tabletWidth > 1080 && tabletWidth <= 1113) {
        i = 7; // iPad AIR
      } else if (tabletWidth > 1025 && tabletWidth < 1200) {
        i = 8; // iPad PRO 11 inch
      } else {
        i = 10; // iPad PRO 12.9 inch
      }

      return Row(children: [
        for (int y = 0; y < i; y++)
          Row(children: [
            SizedBox(
                width: tabletWidth == 1080
                    ? 2.8
                    : tabletWidth >= 1024 && tabletWidth <= 1112
                        ? 2.4
                        : 2.3),
            Container(
                height: 3,
                width: 3,
                alignment: const FractionalOffset(0.0, 0.0),
                decoration: BoxDecoration(
                    color: x == 0 && position == 0
                        ? greyDividerColor
                        : x == status.length - 1 && position == 1
                            ? greyDividerColor
                            : active == true
                                ? tealGreenColor
                                : greyBorderColor,
                    shape: BoxShape.circle)),
            SizedBox(
                width: tabletWidth == 1080
                    ? 2.8
                    : tabletWidth >= 1024 && tabletWidth <= 1112
                        ? 2.4
                        : 2.3)
          ])
      ]);
    }

    ConstrainedBox iconBox(x) {
      final bool active = x <= activeStatus ? true : false;

      return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: SizedBox(
              width: 100,
              child: Column(children: [
                SizedBox(height: tabletHeight > 1100 ? 20 : 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  dottedLine(x, 0),
                  const SizedBox(width: 2),
                  active == true
                      ? const Image(
                          width: 25,
                          height: 25,
                          image: AssetImage('assets/images/check_circle.png'))
                      : Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey))),
                  const SizedBox(width: 2),
                  dottedLine(x, 1)
                ]),
                const SizedBox(height: 1),
                Text(status[x],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: active == true ? tealGreenColor : Colors.grey)),
                const SizedBox(height: 10)
              ])));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(getLocale("Progress Status"),
          style: bFontWN().copyWith(color: greyTextColor)),
      const SizedBox(height: 10),
      ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: greyDividerColor,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(children: [
                        for (int x = 0; x < status.length; x++)
                          Expanded(child: iconBox(x))
                      ])))))
    ]);
  }
}
