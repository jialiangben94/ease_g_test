import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/others_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/cancelled_appointment_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/checkup_completed_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/customer_no_show_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/pending_appointment_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/pending_panel_table.dart';
import 'package:ease/src/screen/medical_exam/appointment_table/schedule_confirmed_table.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicalExamHome extends StatefulWidget {
  final Function? hideModule;
  final Function? unhideModule;
  const MedicalExamHome({Key? key, this.hideModule, this.unhideModule})
      : super(key: key);

  @override
  MedicalExamHomeState createState() => MedicalExamHomeState();
}

class MedicalExamHomeState extends State<MedicalExamHome>
    with SingleTickerProviderStateMixin {
  List<String> serviceTitle = [
    "Pending Appointment Set Up",
    "Pending Panel Confirmation",
    "Schedule Confirmed",
    "Check Up Completed",
    "Customer No Show",
    "Cancelled Appointment",
    "Others"
  ];

  int x = 0;
  int? currentIndex;
  int? medicalAppointmentData = 0;
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (currentIndex == 0) {
      BlocProvider.of<AppointmentRequestListsBloc>(context)
          .add(GetPendingAppointmentList());
    }
  }

  void manualSetActiveTabIndexCallback(int index) {
    //No need to call set state here since using globalKey
    setState(() {
      currentIndex = index;
      _tabController!.animateTo(currentIndex!);
    });

    // _tabController.index = index;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      currentIndex = 0;
    });
    _tabController = TabController(vsync: this, length: serviceTitle.length);
    _tabController!.addListener(_setActiveTabIndex);
  }

  void _setActiveTabIndex() {
    setState(() {
      currentIndex = _tabController!.index;
    });

    if (_tabController!.indexIsChanging) {
      // Tab is animating from active to inactive.
      // If do bloc provider here, might get called twice
    } else {
      if (currentIndex == 0) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetPendingAppointmentList());
      }
      if (currentIndex == 1) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetPanelDecisionList());
      }
      if (currentIndex == 2) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetScheduleConfirmedList());
      }
      if (currentIndex == 3) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetCheckUpCompletedList());
      }
      if (currentIndex == 4) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetCustomerNoShowList());
      }
      if (currentIndex == 5) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetCancelledAppointmentList());
      }
      if (currentIndex == 6) {
        BlocProvider.of<AppointmentRequestListsBloc>(context)
            .add(GetOthersAppointmentList());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar() {
      return Container(
          color: creamColor,
          width: double.infinity,
          height: 52,
          child: TabBar(
              isScrollable: true,
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                  _tabController!.animateTo(currentIndex!);
                });
              },
              labelColor: Colors.black,
              indicatorColor: Colors.transparent,
              tabs: [
                for (int i = 0; i < serviceTitle.length; i++)
                  Stack(children: [
                    Center(
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(children: [
                              Text(getLocale(serviceTitle[i]),
                                  style: bFontWN().copyWith(
                                      fontWeight: i == currentIndex
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              SizedBox(width: i == 0 ? 8 : 0)
                            ]))),
                    //RED DOT FOR NOTIFICATION
                    Visibility(
                        visible: i == 0 && medicalAppointmentData != 0,
                        child: Positioned(
                            right: 0,
                            top: 5,
                            child: Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    color: orangeRedColor),
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Center(
                                        child: Text(
                                            medicalAppointmentData.toString(),
                                            textAlign: TextAlign.center,
                                            style: ssFontWN().copyWith(
                                                color: Colors.white))))))),
                    Visibility(
                        visible: i == currentIndex,
                        child: Positioned(
                            right: 0,
                            bottom: 0,
                            left: 0,
                            child: Container(color: honeyColor, height: 2.5)))
                  ])
              ]));
    }

    NotificationListener<UserScrollNotification>
        buildAppointmentRequestTable() {
      return NotificationListener<UserScrollNotification>(
          onNotification: (userScrollNotification) {
            if (userScrollNotification.direction == ScrollDirection.reverse &&
                userScrollNotification.metrics.axisDirection ==
                    AxisDirection.down) {
              widget.hideModule!();
            } else if (userScrollNotification.direction ==
                ScrollDirection.forward) {
              widget.unhideModule!();
            }
            return true;
          },
          child: TabBarView(controller: _tabController, children: const [
            PendingAppointmentTable(),
            PendingPanelTable(),
            ScheduleConfirmedTable(),
            CheckUpCompletedTable(),
            CustomerNoShowTable(),
            CancelledAppointmentTable(),
            OthersAppointmentTable()
          ]));
    }

    return DefaultTabController(
        length: serviceTitle.length,
        child: Scaffold(
            backgroundColor: Colors.white,
            body: BlocBuilder<AppointmentRequestListsBloc,
                AppointmentRequestState>(builder: (context, state) {
              if (state is PendingAppointmentLoaded) {
                medicalAppointmentData = state.totalUnread;
              }
              return Column(children: [
                tabBar(),
                Expanded(
                    child: BlocListener<AppointmentRequestListsBloc,
                            AppointmentRequestState>(
                        listener: (context, state) {
                          if (state is AppointmentRequestListsError) {
                            showSnackBarError(state.message);
                          }
                        },
                        child: buildAppointmentRequestTable()))
              ]);
            })));
  }
}
