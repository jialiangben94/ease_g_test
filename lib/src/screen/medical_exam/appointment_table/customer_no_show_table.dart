import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_status.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/general_column.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../util/function.dart';

class CustomerNoShowTable extends StatefulWidget {
  const CustomerNoShowTable({Key? key}) : super(key: key);

  @override
  CustomerNoShowTableState createState() => CustomerNoShowTableState();
}

class CustomerNoShowTableState extends State<CustomerNoShowTable> {
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

  @override
  Widget build(BuildContext context) {
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
                                        subtitle: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20),
                                            child: Column(children: [
                                              GeneralColumn(
                                                  data[i]), // GENERAL COLUMN
                                              const SizedBox(height: 20),
                                              AppointmentColumn(
                                                  data: data[i],
                                                  status: TabStatus
                                                      .customerNoShow), // appointment COLUMN
                                              AppointmentStatus(
                                                  data: data[i],
                                                  appointmentData: data[i]
                                                          .appointmentHistory![
                                                      0]), // appointment STATUS
                                              const SizedBox(height: 20)
                                            ])))
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
                      : state is CustomerNoShowLoaded
                          ? buildLoaded(state.customerNoShowRequest)
                          : state is AppointmentRequestListsError
                              ? buildError(context, state.message)
                              : buildInitialInput(context));
        })));
  }
}
