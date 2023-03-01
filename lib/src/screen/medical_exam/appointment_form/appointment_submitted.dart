import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/widget/assessment_type.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentSubmitted extends StatefulWidget {
  final Panel? panel;
  final DateTime? selectedDate;
  final String? selectedTime;
  final AppointmentDetails? appointmentDetails;
  final AppointmentHistory? prevAppointmentDetails;
  final AppointmentRequest? appointmentRequest;
  final PagesStatus? pagesStatus;

  const AppointmentSubmitted(
      {Key? key,
      this.appointmentDetails,
      this.prevAppointmentDetails,
      this.panel,
      this.selectedTime,
      this.selectedDate,
      this.appointmentRequest,
      this.pagesStatus})
      : super(key: key);

  @override
  AppointmentSubmittedState createState() => AppointmentSubmittedState();
}

class AppointmentSubmittedState extends State<AppointmentSubmitted> {
  String completeAddress = "";
  String prevSlot = "";

  @override
  void initState() {
    super.initState();
    analyticsSetCurrentScreen(
        widget.pagesStatus == PagesStatus.setApp
            ? "Medical Appointment submitted!"
            : widget.pagesStatus == PagesStatus.reschedule
                ? "Reschedule Medical Appointment submitted!"
                : widget.pagesStatus == PagesStatus.edit
                    ? "New Medical Appointment submitted!"
                    : "Medical Appointment submitted!",
        "MedicalCheckAppointment");
    // completeAddress = sortAddress(
    //     addressOne: widget.appointmentRequest.addressOne,
    //     addressTwo: widget.appointmentRequest.addressTwo,
    //     addressThree: widget.appointmentRequest.addressThree,
    //     city: widget.appointmentRequest.city,
    //     postcode: widget.appointmentRequest.postcode);

    if (widget.pagesStatus == PagesStatus.edit ||
        widget.pagesStatus == PagesStatus.reschedule) {
      if (widget.prevAppointmentDetails!.appointmentSlot == "AM") {
        prevSlot = "9am to 12pm";
      } else {
        prevSlot = "12pm to 6pm";
      }
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
    Widget clientDetail() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(getLocale("Life Insured", entity: true),
                          style: bFontWN().copyWith(color: greyTextColor)),
                      const SizedBox(height: 10),
                      Row(children: [
                        CircleAvatar(
                            backgroundColor: lightCyanColor,
                            child: Text(
                                widget
                                    .appointmentRequest!.client!.clientName![0],
                                style: t2FontW5().copyWith(color: cyanColor))),
                        const SizedBox(width: 12),
                        Text(widget.appointmentRequest!.client!.clientName!,
                            style: t2FontW5())
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
                      Text(
                          sortAddress(
                              addressOne:
                                  widget.appointmentRequest!.client!.addressOne,
                              addressTwo:
                                  widget.appointmentRequest!.client!.addressTwo,
                              addressThree: widget
                                  .appointmentRequest!.client!.addressThree,
                              city: widget.appointmentRequest!.client!.city,
                              postcode:
                                  widget.appointmentRequest!.client!.postcode),
                          style: bFontW5())
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

    return Scaffold(
        body: Column(children: [
      progressBar(context, 6, 1),
      Expanded(
          child: ListView(children: [
        Padding(
            padding: const EdgeInsets.only(
                left: 60.0, right: 60, top: 40, bottom: 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Image(
                            width: 60,
                            height: 60,
                            image:
                                AssetImage('assets/images/submitted_icon.png')),
                        const SizedBox(height: 10),
                        Text(
                            widget.pagesStatus == PagesStatus.setApp
                                ? getLocale("Medical Appointment submitted!")
                                : widget.pagesStatus == PagesStatus.reschedule
                                    ? getLocale(
                                        "Reschedule Medical Appointment submitted!")
                                    : widget.pagesStatus == PagesStatus.edit
                                        ? getLocale(
                                            "New Medical Appointment submitted!")
                                        : getLocale(
                                            "Medical Appointment submitted!"),
                            style: tFontWN()),
                        const SizedBox(height: 20),
                        Text(
                            getLocale(
                                "The appointment is pending confirmation from the selected panel clinic/hospital. Please check back for confirmation of appointment."),
                            style: bFontWN().copyWith(color: greyTextColor))
                      ]),
                  const SizedBox(height: 60),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            widget.pagesStatus == PagesStatus.setApp
                                ? "${getLocale("Appointment details")}!"
                                : widget.pagesStatus == PagesStatus.reschedule
                                    ? getLocale(
                                        "Reschedule Appointment details")
                                    : widget.pagesStatus == PagesStatus.edit
                                        ? getLocale(
                                            "New Medical Appointment details")
                                        : getLocale("Appointment details"),
                            style: bFontW5().copyWith(color: tealGreenColor)),
                        const SizedBox(height: 20),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(getLocale("Selected Panel"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)),
                                    const SizedBox(height: 10),
                                    Text("${widget.panel!.name}",
                                        style: t2FontW5()),
                                    Text(
                                        cleanPanelAddress(
                                            widget.panel!.address!),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor))
                                  ])),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(getLocale("Date & Time"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)),
                                    const SizedBox(height: 10),
                                    Text(
                                        "${DateFormat("d MMMM y").format(widget.selectedDate!)}, ${widget.selectedTime}",
                                        style: bFontW5())
                                  ]))
                            ]),
                        Divider(height: 60, color: Colors.grey[500]),
                        widget.pagesStatus == PagesStatus.edit ||
                                widget.pagesStatus == PagesStatus.reschedule
                            ? Visibility(
                                visible:
                                    widget.pagesStatus == PagesStatus.edit ||
                                        widget.pagesStatus ==
                                            PagesStatus.reschedule,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          getLocale(
                                              "Previous Appointment details"),
                                          style: bFontW5()
                                              .copyWith(color: tealGreenColor)),
                                      const SizedBox(height: 20),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(
                                                      getLocale(
                                                          "Selected Panel"),
                                                      style: bFontWN().copyWith(
                                                          color:
                                                              greyTextColor)),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                      widget
                                                          .prevAppointmentDetails!
                                                          .panelName!,
                                                      style: t2FontW5()),
                                                  Text(
                                                      widget
                                                          .prevAppointmentDetails!
                                                          .panelAddress!,
                                                      style: bFontWN().copyWith(
                                                          color: greyTextColor))
                                                ])),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text(getLocale("Date & Time"),
                                                      style: bFontWN().copyWith(
                                                          color:
                                                              greyTextColor)),
                                                  const SizedBox(height: 20),
                                                  Text(
                                                      "${DateFormat("d MMMM y").format(DateTime.parse(widget.prevAppointmentDetails!.appointmentDate!))}, $prevSlot",
                                                      style: bFontW5())
                                                ]))
                                          ]),
                                      Divider(
                                          height: 60, color: Colors.grey[500])
                                    ]),
                              )
                            : const SizedBox(height: 0),
                        Text(getLocale("Client details"),
                            style: bFontW5().copyWith(color: tealGreenColor)),
                        const SizedBox(height: 20),
                        clientDetail(),
                        Divider(height: 60, color: Colors.grey[500]),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(getLocale("Proposal date"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)),
                                    const SizedBox(height: 10),
                                    Text(
                                        DateFormat("d MMMM y")
                                            .format(DateTime.now()),
                                        style: bFontW5())
                                  ])),
                              // Visibility(
                              //     visible:
                              //         widget.appointmentRequest.clientName !=
                              //             widget.appointmentRequest.policyOwner,
                              //     child: Expanded(
                              //         child: Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //           Text("Policy Owner",
                              //               style: bFontWN().copyWith(color: greyTextColor)),
                              //           SizedBox(height: 10),
                              //           Text(
                              //               "${widget.appointmentRequest.policyOwner}",
                              //               style: bFontW5())
                              //         ]))),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(getLocale("Product Name"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)),
                                    const SizedBox(height: 10),
                                    Text(
                                        "${widget.appointmentRequest!.productName}",
                                        style: bFontW5())
                                  ])),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text("${getLocale("Proposal No")}.",
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)),
                                    const SizedBox(height: 10),
                                    Text(
                                        "${widget.appointmentRequest!.ssProposalNo}",
                                        style: bFontW5())
                                  ]))
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  margin: const EdgeInsets.all(40),
                                  child: OutlinedButton(
                                      // shape: RoundedRectangleBorder(
                                      //     borderRadius:
                                      //         BorderRadius.circular(8.0),
                                      //     side: BorderSide(
                                      //         color: cyanColor, width: 1.2)),
                                      style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: cyanColor)),
                                      onPressed: () {
                                        analyticsSendEvent("back_to_home",
                                            {"button_name": "Back To Home"});
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Home()));
                                      },
                                      child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Text(getLocale("Back To Home"),
                                              style: bFontW5()
                                                  .apply(color: cyanColor)))))
                            ])
                      ])
                ]))
      ]))
    ]));
  }
}
