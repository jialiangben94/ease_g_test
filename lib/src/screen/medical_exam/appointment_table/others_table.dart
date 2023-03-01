import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/general_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/select_page.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OthersAppointmentTable extends StatefulWidget {
  const OthersAppointmentTable({Key? key}) : super(key: key);

  @override
  OthersAppointmentTableState createState() => OthersAppointmentTableState();
}

class OthersAppointmentTableState extends State<OthersAppointmentTable> {
  AppointmentDetails? appointmentDetails;
  AppointmentRequest? appointmentRequest;
  AppointmentHistory? currentAppDetails;
  List<AppointmentHistory> listAppointmentHistory = [];

  void sortData(AppointmentRequest appointmentRequest) {
    appointmentRequest.appointmentHistory!.sort((a, b) {
      var dateA = a.createdDateTime!;
      var dateB = b.createdDateTime!;
      return dateB.compareTo(dateA);
    });
  }

  void action(BuildContext context, result, data) async {
    if (result == PagesStatus.view) {
      statusJourneyView(context, data, true);
    } else if (result == PagesStatus.reopen) {
      final ConfirmAction? action =
          await confirmDialog(context, data, PagesStatus.reopen);
      if (action == ConfirmAction.yes) {
        if (!mounted) {}
        await emailECRM(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget appointmentStatus(AppointmentRequest data) {
      String? proposalStatus = data.proposalStatus;
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: lightPinkColor,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.close, color: Colors.red)),
                Expanded(
                    child: Text(
                        data.appointmentStatus == "W"
                            ? getLocale(
                                "Medical requirement(s) is/are waived. The medical appointment have been cancelled.")
                            : "${getLocale("Proposal")} $proposalStatus",
                        style: bFontWN().copyWith(color: scarletRedColor)))
              ]));
    }

    Widget buildTable(List<AppointmentRequest> data) {
      return ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext cxt, i) {
            sortData(data[i]);
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
                                "${getLocale("Total")} (${data.length}) ${getLocale("requests found")}",
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
                                    ListTile(
                                        leading: CircleAvatar(
                                            radius: 22,
                                            backgroundColor: lightCyanColor,
                                            child: Center(
                                                child: Text(
                                                    data[i]
                                                        .client!
                                                        .clientName![0],
                                                    style: t2FontWB().apply(
                                                        fontWeightDelta: -1,
                                                        color: cyanColor)))),
                                        title: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20, bottom: 20),
                                            child: Text(
                                                data[i].client!.clientName!,
                                                style: t2FontWB().apply(
                                                    fontWeightDelta: -1))),
                                        subtitle: Column(children: [
                                          GeneralColumn(data[i]),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20),
                                              child: Column(children: [
                                                Visibility(
                                                    visible: data[i]
                                                        .appointmentHistory!
                                                        .isNotEmpty,
                                                    child: AppointmentColumn(
                                                        data: data[i],
                                                        status:
                                                            TabStatus.others)),
                                                appointmentStatus(data[i])
                                              ]))
                                        ]),
                                        trailing: IconButton(
                                            onPressed: () async {
                                              var result = await selectPage(
                                                  context, data[i], "ntu");
                                              if (!mounted) {}
                                              action(context, result, data[i]);
                                            },
                                            icon: Icon(Icons.adaptive.more)),
                                        isThreeLine: true)
                                  ])))
                    ]));
          });
    }

    Widget buildLoaded(data) {
      return data.length == 0 ? buildInitialInput(context) : buildTable(data);
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
                      : state is OthersAppointmentLoaded
                          ? buildLoaded(state.othersRequest)
                          : state is AppointmentRequestListsError
                              ? buildError(context, state.message)
                              : buildInitialInput(context));
        })));
  }
}
