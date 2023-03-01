import 'package:ease/src/bloc/medical_exam/notification_list/notification_list_bloc.dart';
import 'package:ease/src/data/medical_exam_model/notification.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NotificationWidget extends StatefulWidget {
  final bool isShown;
  final Function triggerNotification;
  final Function manualSetActiveIndex;

  const NotificationWidget(
      this.triggerNotification, this.isShown, this.manualSetActiveIndex,
      {Key? key})
      : super(key: key);
  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget> {
  int segmentedControlGroupValue = 0;

  final Map<int, Widget> myTabs = <int, Widget>{
    0: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(getLocale("New"))),
    1: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(getLocale("Viewed")))
  };

  @override
  Widget build(BuildContext context) {
    Widget notificationCard(
        BuildContext context, String type, Notifications notification) {
      //type == String "new" - cyan color border
      //type == String "viewed" - grey color border

      return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(
                  color: type == "new" ? cyanColor : greyBorderColor)),
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(right: 30.0),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(notification.topic!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style:
                                          bFontW5().apply(fontSizeDelta: -1)),
                                  const SizedBox(height: 6),
                                  Text(notification.body!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                      style: bFontWN()
                                          .copyWith(color: greyTextColor)
                                          .apply(fontSizeDelta: -1))
                                ]))),
                        Row(children: [
                          Expanded(
                              flex: 2,
                              child: Text(
                                  DateFormat.yMMMd()
                                      .format(DateTime.now())
                                      .toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: bFontWN()
                                      .copyWith(color: greyTextColor))),
                          Expanded(
                              flex: 3,
                              child: GestureDetector(
                                  onTap: () async {
                                    if (notification.tabId == "P") {
                                      // Pending Set Up
                                      widget.manualSetActiveIndex(0);
                                    } else if (notification.tabId == "A") {
                                      // Pending Panel Decision
                                      widget.manualSetActiveIndex(1);
                                    } else if (notification.tabId == "C") {
                                      // Schedule Confirmed
                                      widget.manualSetActiveIndex(2);
                                    } else if (notification.tabId == "D") {
                                      // Check Up Completed
                                      widget.manualSetActiveIndex(3);
                                    } else if (notification.tabId == "N") {
                                      // No Show
                                      widget.manualSetActiveIndex(4);
                                    } else if (notification.tabId == "X") {
                                      // Cancelled
                                      widget.manualSetActiveIndex(5);
                                    }
                                    if (type == "new") {
                                      BlocProvider.of<NotificationListBloc>(
                                              context)
                                          .add(UpdateNotificationList(
                                              notification));
                                    }
                                    widget.triggerNotification();
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //       AppointmentForm(
                                    //           appointmentRequest: appointmentRequest,
                                    //           pagesStatus: appointmentRequest.appointmentHistory.length == 0
                                    //               ? PagesStatus.SET
                                    //               : PagesStatus.RESET
                                    //      )
                                    // );
                                  },
                                  child: Text("View >",
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                      style: sFontWN()
                                          .copyWith(color: cyanColor))))
                        ])
                      ]))));
    }

    Widget notificationCardList(
        BuildContext context, NotificationListLoaded data) {
      final List<Notifications> notificationList = data.notificationList;
      // final List<String> _savedData = savedData;
      List<Notifications> newList = [];
      List<Notifications> viewedList = [];

      for (int i = 0; i < notificationList.length; i++) {
        if (notificationList[i].isRead == true) {
          viewedList.add(notificationList[i]);
        } else {
          newList.add(notificationList[i]);
        }
      }

      return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // new
            Visibility(
                visible: segmentedControlGroupValue == 0,
                child: Column(children: [
                  Visibility(
                      visible: newList.isNotEmpty,
                      child: Column(children: [
                        for (int i = 0; i < newList.length; i++)
                          notificationCard(context, "new", newList[i]),
                      ])),
                  if (newList.isEmpty)
                    Center(
                        child: Text(getLocale("No new notification"),
                            style: bFontWN())),
                ])),
            // viewed
            Visibility(
                visible: segmentedControlGroupValue == 1,
                child: Column(children: [
                  if (viewedList.isNotEmpty)
                    for (int i = 0; i < viewedList.length; i++)
                      notificationCard(context, "viewed", viewedList[i]),
                  if (viewedList.isEmpty)
                    Center(
                        child: Text(getLocale("No new notification"),
                            style: bFontWN()))
                ]))
          ]));
    }

    Widget buildInitialInput(BuildContext context) {
      return Text(getLocale("No new notification"));
    }

    Widget buildError(BuildContext context, String message) {
      return Text(message);
    }

    return widget.isShown
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(getLocale("Notifications"),
                                          softWrap: false, style: tFontW5())),
                                  IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 30, color: Colors.black),
                                      onPressed: () {
                                        widget.triggerNotification();
                                      })
                                ])),
                        Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            width: MediaQuery.of(context).size.width,
                            child: CupertinoSegmentedControl(
                                borderColor: Colors.transparent,
                                pressedColor: cyanColor,
                                selectedColor: cyanColor,
                                unselectedColor: lightCyanColor,
                                padding: const EdgeInsets.all(0),
                                groupValue: segmentedControlGroupValue,
                                children: myTabs,
                                onValueChanged: (dynamic i) {
                                  setState(() {
                                    segmentedControlGroupValue = i;
                                  });
                                }))
                      ]),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: BlocBuilder<NotificationListBloc,
                          NotificationListState>(builder: (context, state) {
                        if (state is NotificationListInitial) {
                          return buildInitialInput(context);
                        } else if (state is NotificationListLoading) {
                          return buildLoading();
                        } else if (state is NotificationListLoaded) {
                          return notificationCardList(context, state);
                        } else if (state is NotificationListError) {
                          return buildError(context, state.message);
                        } else {
                          return buildInitialInput(context);
                        }
                      }))
                ])))
        : const SizedBox(height: 0, width: 0);
  }
}
