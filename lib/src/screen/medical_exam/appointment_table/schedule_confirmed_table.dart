import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_details.dart';
import 'package:ease/src/data/medical_exam_model/appointment_history.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_status.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/build_initial_input.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/general_column.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/select_page.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../util/function.dart';

class ScheduleConfirmedTable extends StatefulWidget {
  final int? selectedIndex;
  const ScheduleConfirmedTable({Key? key, this.selectedIndex})
      : super(key: key);
  @override
  ScheduleConfirmedTableState createState() => ScheduleConfirmedTableState();
}

class ScheduleConfirmedTableState extends State<ScheduleConfirmedTable> {
  AppointmentDetails? appointmentDetails;
  AppointmentRequest? appointmentRequest;
  AppointmentHistory? currentAppDetails;
  List<AppointmentHistory> listAppointmentHistory = [];

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.selectedIndex != null) {
      itemScrollController.scrollTo(
          index: widget.selectedIndex!, duration: const Duration(seconds: 1));
    }
  }

  void sortData(AppointmentRequest appointmentRequest) {
    appointmentRequest.appointmentHistory!.sort((a, b) {
      DateTime dateA = DateTime.parse(a.createdDateTime!);
      DateTime dateB = DateTime.parse(b.createdDateTime!);
      return dateB.compareTo(dateA);
    });
  }

  void action(BuildContext context, result, data) async {
    if (result == PagesStatus.reschedule) {
      final ConfirmAction? action =
          await confirmDialog(context, data, PagesStatus.reschedule);
      if (action == ConfirmAction.yes) {
        if (!mounted) {}
        await Navigator.of(context).push(createRoute(AppointmentForm(
            appointmentRequest: data, pagesStatus: PagesStatus.edit)));
      }
    } else if (result == PagesStatus.view) {
      statusJourneyView(context, data, true);
    } else if (result == PagesStatus.cancel) {
      final ConfirmAction? action =
          await confirmDialog(context, data, PagesStatus.cancel);
      if (action == ConfirmAction.yes) {
        if (!mounted) {}
        await cancel(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTable(List<AppointmentRequest> data) {
      return ScrollablePositionedList.builder(
          itemCount: data.length,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, i) {
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
                                      width: 2, color: greyDividerColor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10))),
                              child: ListTile(
                                  leading: CircleAvatar(
                                      radius: 22,
                                      backgroundColor: lightCyanColor,
                                      child: Center(
                                          child: Text(
                                              data[i].client!.clientName![0],
                                              style: t2FontW5()
                                                  .apply(color: cyanColor)))),
                                  title: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20),
                                      child: Text(data[i].client!.clientName!,
                                          style: t2FontW5())),
                                  subtitle: Column(children: [
                                    GeneralColumn(data[i]),
                                    const SizedBox(height: 20),
                                    AppointmentColumn(
                                        data: data[i],
                                        status: TabStatus.scheduleConfirm),
                                    AppointmentStatus(
                                        data: data[i],
                                        appointmentData:
                                            data[i].appointmentHistory![0]),
                                    const SizedBox(height: 20)
                                  ]),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        var result = await selectPage(
                                            context, data[i], "confirmed");
                                        if (!mounted) {}
                                        action(context, result, data[i]);
                                      },
                                      icon: Icon(Icons.adaptive.more)),
                                  isThreeLine: true)))
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
                      : state is ScheduleConfirmedLoaded
                          ? buildLoaded(state.scheduleConfirmedRequest)
                          : state is AppointmentRequestListsError
                              ? buildError(context, state.message)
                              : buildInitialInput(context));
        })));
  }
}
