import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_status.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/general_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/select_page.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PendingAppointmentTable extends StatefulWidget {
  const PendingAppointmentTable({Key? key}) : super(key: key);

  @override
  PendingAppointmentTableState createState() => PendingAppointmentTableState();
}

class PendingAppointmentTableState extends State<PendingAppointmentTable> {
  void action(BuildContext context, result, data) async {
    if (result == PagesStatus.view) {
      statusJourneyView(context, data, true);
    }
  }

  Widget newRibbon() {
    return Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Container(
            decoration: BoxDecoration(
                color: cyanColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(getLocale("New"),
                    style: const TextStyle(
                        fontFamily: "Meta", color: Colors.white)))));
  }

  void sortData(AppointmentRequest appointmentRequest) {
    appointmentRequest.appointmentHistory!.sort((a, b) {
      DateTime dateA = DateTime.parse(a.createdDateTime!);
      DateTime dateB = DateTime.parse(b.createdDateTime!);
      return dateB.compareTo(dateA);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget appointmentcard(AppointmentRequest appointment, readIds) {
      return ListTile(
          isThreeLine: true,
          leading: CircleAvatar(
              radius: 22,
              backgroundColor: lightCyanColor,
              child: Center(
                  child: Text(appointment.client!.clientName![0],
                      style: t2FontWB().copyWith(
                          color: cyanColor, fontWeight: FontWeight.w500)))),
          title: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(appointment.client!.clientName!, style: t2FontW5())),
          subtitle: Column(children: [
            GeneralColumn(appointment), // GENERAL COLUMN
            const SizedBox(height: 10),
            appointment.appointmentHistory!.isNotEmpty
                ? Visibility(
                    visible: appointment.appointmentHistory!.isNotEmpty,
                    child: AppointmentColumn(
                        data: appointment,
                        status: TabStatus.pendingAppointmentSetup))
                : const SizedBox(width: 0),
            appointment.appointmentHistory!.isNotEmpty
                ? Visibility(
                    visible: appointment.appointmentHistory!.isNotEmpty,
                    child: AppointmentStatus(
                        data: appointment,
                        appointmentData: appointment.appointmentHistory![0]))
                : const SizedBox(width: 0),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SizedBox(
                      height: 50.0,
                      child: TextButton(
                          // shape: RoundedRectangleBorder(
                          //     borderRadius:
                          //         BorderRadius
                          //             .circular(
                          //                 5.0),
                          //     side: BorderSide(
                          //         color:
                          //             cyanColor)),
                          style: TextButton.styleFrom(
                              side: BorderSide(color: cyanColor)),
                          onPressed: () async {
                            await saveReadIds(appointment.propNo);
                            await analyticsSendEvent(
                                appointment.appointmentHistory!.isEmpty
                                    ? "setup_appointment"
                                    : "reschedule_appointment",
                                {
                                  "button_name":
                                      appointment.appointmentHistory!.isEmpty
                                          ? "Set Up Appointment"
                                          : "Re-Schedule Appointment",
                                  "propNo": appointment.propNo
                                });
                            if (!mounted) {}
                            await Navigator.of(context).push(createRoute(
                                AppointmentForm(
                                    appointmentRequest: appointment,
                                    pagesStatus:
                                        appointment.appointmentHistory!.isEmpty
                                            ? PagesStatus.setApp
                                            : PagesStatus.reset)));
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                  appointment.appointmentHistory!.isEmpty
                                      ? getLocale("Set Up Appointment")
                                      : getLocale("Re-Schedule Appointment"),
                                  style:
                                      bFontWN().copyWith(color: cyanColor)))))
                ]))
          ]),
          trailing: IconButton(
              onPressed: () async {
                var result =
                    await selectPage(context, appointment, "pendingSet");
                if (!mounted) {}
                action(context, result, appointment);
              },
              icon: Icon(Icons.adaptive.more)));
    }

    ListView buildTable(
        List<AppointmentRequest> appointmentlist, List<String>? readIds) {
      return ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: appointmentlist.length,
          itemBuilder: (BuildContext cxt, i) {
            sortData(appointmentlist[i]);
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i == 0)
                        Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, bottom: 10),
                            child: Text(
                                "${getLocale("Total")} (${appointmentlist.length}) ${getLocale("requests found")}",
                                style: sFontW5())),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: greyBorderColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                        visible: readIds!.contains(
                                                appointmentlist[i].propNo) ==
                                            false,
                                        child: newRibbon()),
                                    appointmentcard(appointmentlist[i], readIds)
                                  ]))),
                      const SizedBox(height: 20)
                    ]));
          });
    }

    Widget buildPendingLoaded({required data, savedData}) {
      return data.length == 0
          ? buildInitialInput(context)
          : buildTable(data, savedData);
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<AppointmentRequestListsBloc,
            AppointmentRequestState>(listener: (context, state) {
          if (state is AppointmentRequestListsError) {
            showSnackBarError(state.message);
          }
        }, child:
            BlocBuilder<AppointmentRequestListsBloc, AppointmentRequestState>(
                builder: (context, state) {
          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: state is AppointmentRequestListsInitial
                  ? buildInitialInput(context)
                  : state is AppointmentRequestListsLoading
                      ? buildLoading()
                      : state is PendingAppointmentLoaded
                          ? buildPendingLoaded(
                              data: state.pendingAppointmentRequest,
                              savedData: state.alreadySavedId)
                          : state is AppointmentRequestListsError
                              ? buildError(context, state.message)
                              : buildInitialInput(context));
        })));
  }
}
