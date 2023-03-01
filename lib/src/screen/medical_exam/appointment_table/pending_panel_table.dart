import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/screen/medical_exam/appointment_form/appointment_form.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/widget/appointment_column.dart';
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

import '../../../util/function.dart';

class PendingPanelTable extends StatefulWidget {
  const PendingPanelTable({Key? key}) : super(key: key);

  @override
  PendingPanelTableState createState() => PendingPanelTableState();
}

class PendingPanelTableState extends State<PendingPanelTable> {
  @override
  Widget build(BuildContext context) {
    void action(BuildContext context, result, data) async {
      if (result == PagesStatus.edit) {
        final ConfirmAction? action =
            await confirmDialog(context, data, PagesStatus.edit);
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

    Widget buildPendingTable(List<AppointmentRequest> appointment) {
      return ListView.builder(
          itemCount: appointment.length,
          itemBuilder: (BuildContext cxt, i) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (i == 0)
                        Padding(
                            padding:
                                const EdgeInsets.only(top: 15.0, bottom: 10),
                            child: SelectableText(
                                "${getLocale("Total")} (${appointment.length}) ${getLocale("requests found")}",
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
                                              appointment[i]
                                                  .client!
                                                  .clientName![0],
                                              style: t2FontW5()
                                                  .apply(color: cyanColor)))),
                                  title: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20),
                                      child: Text(
                                          appointment[i].client!.clientName!,
                                          style: t2FontW5())),
                                  subtitle: Column(children: [
                                    GeneralColumn(appointment[i]),
                                    const SizedBox(height: 20),
                                    AppointmentColumn(
                                        data: appointment[i],
                                        status: TabStatus.pendingPanel),
                                    const SizedBox(height: 20)
                                  ]),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        var result = await selectPage(context,
                                            appointment[i], "pendingPanel");
                                        if (!mounted) {}
                                        action(context, result, appointment[i]);
                                      },
                                      icon: Icon(Icons.adaptive.more)),
                                  isThreeLine: true)))
                    ]));
          });
    }

    Widget buildLoaded(data) {
      return data.length == 0
          ? buildInitialInput(context)
          : buildPendingTable(data);
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
                      : state is PendingPanelLoaded
                          ? buildLoaded(state.pendingPanelRequest)
                          : state is AppointmentRequestListsError
                              ? buildError(context, state.message)
                              : buildInitialInput(context));
        })));
  }
}
