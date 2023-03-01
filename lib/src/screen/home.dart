import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/src/bloc/medical_exam/notification_list/notification_list_bloc.dart';
import 'package:ease/src/bloc/module_selection/module_selection_bloc.dart';
import 'package:ease/src/bloc/setting/setting_bloc.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/eppdashboard/home.dart';
import 'package:ease/src/screen/fera/home.dart';
import 'package:ease/src/screen/medical_exam/medical_exam_home.dart';
import 'package:ease/src/screen/new_business/new_business_home.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/servicing_config.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/idle_timeout.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/notification_widget.dart';
import 'package:ease/src/widgets/push_notification_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:ease/src/widgets/terms_condition_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

var timeout = const Duration(seconds: 600);
var afterTimeout = const Duration(seconds: 30);
Timer? timer;
Timer? timerDialog;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int x = 0;

  GlobalKey<MedicalExamHomeState> globalKey = GlobalKey();

  int? currentModule;
  int? currentIndex;
  int medicalAppointmentData = 0;

  bool isHideModule = false;
  bool isNotificationBar = false;
  bool isConnected = false;

  //double appBarHeight = 350;
  double appBarHeight = 270;

  String? feraUrlError;
  String? eppUrlError;

  List<dynamic> moduleList = [
    {
      "enabled": false,
      "moduleBinary": "10",
      "title": "New Business",
      "logo": "new_business",
      "bloc": ActivateNewBusiness()
    },
    {
      "enabled": true,
      "moduleBinary": "01",
      "title": "Medical Check Up Appointment",
      "logo": "medical",
      "bloc": ActivateMedicalCheckAppointment()
    },
    {"enabled": true, "title": "FERA", "logo": "fera_new"},
    {"enabled": false, "title": "EPP Dashboard", "logo": "dashboard"},
    {
      "enabled": false,
      "title": "E-Letter",
      "logo": "eletter",
      "bloc": ActivateEletter()
    }
  ];

  bool? showTnc = false;
  @override
  void initState() {
    super.initState();
    getIdleTimeout();
    getModuleBinary();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (mounted) {
          setState(() {
            isConnected = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isConnected = false;
            currentModule = 0;

            for (var element in moduleList) {
              if (!element["enabled"]) {
                continue;
              } else {
                if (element["bloc"] != null) {
                  setState(() {
                    BlocProvider.of<ModuleSelectionBloc>(context)
                        .add(element["bloc"]);
                  });
                } else {
                  if (isConnected) {
                    if (element["title"] == "FERA") {
                      if (feraUrl.isNotEmpty) {
                        setState(() async {
                          await Navigator.of(context)
                              .push(createRoute(FeraHome(mainUrl: feraUrl)));
                        });
                      } else {
                        setState(() {
                          showAlertDialog(
                              context,
                              getLocale('Sorry'),
                              feraUrlError ??
                                  getLocale('Unexpected error occurs'));
                        });
                      }
                    } else if (element["title"] == "EPP Dashboard") {
                      if (eppUrl.isNotEmpty) {
                        setState(() async {
                          await Navigator.of(context)
                              .push(createRoute(EPPDashboard(mainUrl: eppUrl)));
                        });
                      } else {
                        setState(() {
                          showAlertDialog(
                              context,
                              getLocale('Sorry'),
                              eppUrlError ??
                                  getLocale('Unexpected error occurs'));
                        });
                      }
                    }
                  }
                }
                break;
              }
            }
          });
        }
      }
    });
    loadSetting();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (message.data['url'] != null) {
        var result = await showFCMConfirmDialog(
            getLocale("New Version Available"),
            getLocale("Do you want to update EaSE now?"));
        if (result != null && result) {
          launchURL(message.data['url']);
        }
      } else {
        showNotiDialog(notification!.title, body: notification.body);
      }
    });
    setState(() {
      currentModule = 0;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (message.data['url'] != null) {
        var result = await showFCMConfirmDialog(
            getLocale("New Version Available"),
            getLocale("Do you want to update EaSE now?"));
        if (result != null && result) {
          launchURL(message.data['url']);
        }
      } else {
        showNotiDialog(notification!.title, body: notification.body);
      }
    });
  }

  void getModuleBinary() async {
    await getAccessControl().then((access) {
      if (access != null) {
        for (var element in moduleList) {
          if (element["moduleBinary"] != null) {
            if (checkAccess(access, element["moduleBinary"]) != "00") {
              element["enabled"] = true;
            } else {
              element["enabled"] = false;
            }
          }
        }

        for (var element in moduleList) {
          if (!element["enabled"]) {
            continue;
          } else {
            if (element["bloc"] != null) {
              setState(() {
                BlocProvider.of<ModuleSelectionBloc>(context)
                    .add(element["bloc"]);
              });
            } else {
              if (element["title"] == "FERA") {
                if (feraUrl.isNotEmpty) {
                  setState(() async {
                    await Navigator.of(context)
                        .push(createRoute(FeraHome(mainUrl: feraUrl)));
                  });
                } else {
                  setState(() {
                    showAlertDialog(context, getLocale('Sorry'),
                        feraUrlError ?? getLocale('Unexpected error occurs'));
                  });
                }
              } else if (element["title"] == "EPP Dashboard") {
                if (eppUrl.isNotEmpty) {
                  setState(() async {
                    await Navigator.of(context)
                        .push(createRoute(EPPDashboard(mainUrl: eppUrl)));
                  });
                } else {
                  setState(() {
                    showAlertDialog(context, getLocale('Sorry'),
                        eppUrlError ?? getLocale('Unexpected error occurs'));
                  });
                }
              }
            }
            break;
          }
        }
      }
    }).catchError((error) {
      if (error is AppCustomException) {
        showSnackBarError(
            "Failed to access module binary API\n${error.message}. Please try again.");
      } else {
        showSnackBarError(
            "Failed to access module binary API\n$error. Please try again.");
      }
    });
  }

  void launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  void loadSetting() async {
    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');
    if (lang != null) {
      if (!mounted) {}
      BlocProvider.of<SettingBloc>(context).add(ChangeSetting(Locale(lang)));
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (x == 0) {
      await validateTnc();
      if (!mounted) {}
      BlocProvider.of<UserProfileBloc>(context).add(LoadUserProfile());
    }
    x = 1;
  }

  Future<void> validateTnc() async {
    showTnc = await loadTNC();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (!showTnc!) {
          setState(() {
            showTncDialog(context, () async {
              await saveTNC(true);
              if (!mounted) {}
              Navigator.of(context).pop();
            });
          });
        }
      });
    });
  }

  void getIdleTimeout() async {
    ConnectivityResult conn = await (Connectivity().checkConnectivity());
    setState(() {
      if (conn != ConnectivityResult.none) {
        isConnected = true;
      } else {
        isConnected = false;
      }
    });
    if (isConnected) {
      await NewBusinessAPI().getConfig("IdleTimeout").then((res) {
        if (res != null) {
          var data = res["ParamValue"];

          List<String> value = data.split(',');
          int ttimeout = int.parse(value[0]);
          int aafterTimeout = int.parse(value[1]);

          timeout = Duration(seconds: ttimeout);
          afterTimeout = Duration(seconds: aafterTimeout);
        } else {
          timeout = const Duration(seconds: 600);
          afterTimeout = const Duration(seconds: 30);
        }
      }).onError((dynamic error, stackTrace) {
        // if server timeout; set to default value
        timeout = const Duration(seconds: 600);
        afterTimeout = const Duration(seconds: 30);
      });
      resetIdleTime();
    }

    // Get latest FERA URL
    await NewBusinessAPI().getConfig("FERAAPI").then((res) {
      if (res != null) {
        var data = res["ParamValue"];

        setState(() {
          feraUrl = data;
        });
      } else {
        var error = res['Message'];
        setState(() {
          feraUrlError = error;
        });
      }
    }).onError((dynamic error, stackTrace) {
      // Park
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget moduleSelection() {
      return SizedBox(
          width: double.infinity,
          height: 165,
          child: ListView.builder(
              itemCount: moduleList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, i) {
                if (!moduleList[i]["enabled"]) {
                  return Container();
                }
                return GestureDetector(
                    onTap: () async {
                      currentModule = i;
                      if (moduleList[i]["bloc"] != null) {
                        setState(() {
                          BlocProvider.of<ModuleSelectionBloc>(context)
                              .add(moduleList[i]["bloc"]);
                        });
                      } else {
                        if (moduleList[i]["title"] == "FERA") {
                          if (feraUrl.isNotEmpty) {
                            setState(() {
                              Navigator.of(context).push(
                                  createRoute(FeraHome(mainUrl: feraUrl)));
                            });
                          } else {
                            setState(() {
                              showAlertDialog(
                                  context,
                                  getLocale('Sorry'),
                                  feraUrlError ??
                                      getLocale('Unexpected error occurs'));
                            });
                          }
                        } else if (moduleList[i]["title"] == "EPP Dashboard") {
                          if (eppUrl.isNotEmpty) {
                            setState(() async {
                              await Navigator.of(context).push(
                                  createRoute(EPPDashboard(mainUrl: eppUrl)));
                            });
                          } else {
                            setState(() {
                              showAlertDialog(
                                  context,
                                  getLocale('Sorry'),
                                  eppUrlError ??
                                      getLocale('Unexpected error occurs'));
                            });
                          }
                        }
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: moduleList[i]["moduleBinary"] == "01"
                                ? isConnected
                                    ? i == currentModule
                                        ? creamColor
                                        : Colors.white
                                    : lightGreyColor2
                                : i == currentModule
                                    ? creamColor
                                    : Colors.white,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                topLeft: Radius.circular(15))),
                        height: 160,
                        width: 115,
                        child: Stack(children: [
                          Opacity(
                              opacity: moduleList[i]["moduleBinary"] == "01"
                                  ? isConnected
                                      ? 1
                                      : 0.3
                                  : 1,
                              child: Column(children: [
                                const SizedBox(height: 20),
                                SizedBox(
                                    height: 80,
                                    width: 115,
                                    child: Stack(children: [
                                      Center(
                                          child: Stack(children: [
                                        Container(
                                            height: 70,
                                            width: 70,
                                            decoration: ShapeDecoration(
                                                shape: const CircleBorder(),
                                                color: i == currentModule
                                                    ? honeyColor
                                                    : greyDividerColor)),
                                        Visibility(
                                            visible:
                                                medicalAppointmentData != 0 &&
                                                    i == 0,
                                            child: Positioned(
                                                top: 5,
                                                right: 5,
                                                child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: ShapeDecoration(
                                                        shape:
                                                            const CircleBorder(),
                                                        color:
                                                            orangeRedColor))))
                                      ])),
                                      Center(
                                          child: Image(
                                              width: 64,
                                              height: 64,
                                              image: AssetImage(
                                                  'assets/images/${moduleList[i]['logo']}.png')))
                                    ])),
                                SizedBox(
                                    height: 65,
                                    width: 115,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8, bottom: 18.0),
                                        child: Text(
                                            getLocale(moduleList[i]["title"]),
                                            textAlign: TextAlign.center,
                                            style: sFontWN().copyWith(
                                                fontSize: i == currentModule
                                                    ? gFontSize * 0.75
                                                    : gFontSize * 0.7778,
                                                fontWeight: i == currentModule
                                                    ? FontWeight.w500
                                                    : FontWeight.normal))))
                              ])),
                          Align(
                              alignment: Alignment.center,
                              child: Visibility(
                                  visible:
                                      moduleList[i]["moduleBinary"] == "01" &&
                                          !isConnected,
                                  child: Text("No Internet Connection",
                                      textAlign: TextAlign.center,
                                      style: bFontWB()
                                          .copyWith(color: scarletRedColor))))
                        ])));
              }));
    }

    // void searchData() {
    //   Navigator.push(
    //       context, MaterialPageRoute(builder: (context) => SearchScreen()));
    // }

    void triggerNotification() {
      if (isConnected) {
        setState(() {
          isNotificationBar = !isNotificationBar;
        });
        if (isNotificationBar) {
          BlocProvider.of<NotificationListBloc>(context)
              .add(const GetNotificationList());
        }
      }
    }

    void manualActivateMETabIndex(int index) {
      // To manually set which tab to activate on medical exam.
      // Need to recheck if this is a good practice...
      // ... since we make medicalExamHomeState public

      // 1) Activate Medical Check appointment (In case on diff module)
      BlocProvider.of<ModuleSelectionBloc>(context)
          .add(ActivateMedicalCheckAppointment());

      setState(() {
        currentModule = moduleList.indexWhere(
            (element) => element["title"] == "Medical Check Up Appointment");
      });

      // 2) Once Medical Check appointment is activate, set index
      Future.delayed(const Duration(milliseconds: 500), () {
        globalKey.currentState!.manualSetActiveTabIndexCallback(index);
      });
    }

    // To hide module if user scroll down on Medical Check appointment
    Null Function() hideModuleMEHome() {
      return () {
        setState(() {
          isHideModule = true;
          appBarHeight = 120.0;
        });
      };
    }

    // To unhide module if user scroll down on Medical Check appointment
    Null Function() unhideModuleMEHome() {
      return () {
        setState(() {
          isHideModule = false;
          appBarHeight = 270.0;
        });
      };
    }

    changeLanguage() async {
      var pref = await SharedPreferences.getInstance();
      var lang = pref.getString('language_code');

      if (lang != null) {
        if (lang == "en") {
          if (!mounted) {}
          BlocProvider.of<SettingBloc>(context)
              .add(const ChangeSetting(Locale('ms')));
          showAlertDialog(context, getLocale("Change language successful"),
              getLocale("Current language: Bahasa Malaysia"));
        } else {
          if (!mounted) {}
          BlocProvider.of<SettingBloc>(context)
              .add(const ChangeSetting(Locale('en')));
          showAlertDialog(context, "Change language successful",
              "Current language: English");
        }
      } else {
        if (!mounted) {}
        BlocProvider.of<SettingBloc>(context)
            .add(const ChangeSetting(Locale('ms')));
        showAlertDialog(context, getLocale("Change language successful"),
            getLocale("Current language: Bahasa Malaysia"));
      }
    }

    Widget notificationView() {
      return Stack(children: [
        Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 10),
                curve: Curves.linearToEaseOut,
                height:
                    isNotificationBar ? MediaQuery.of(context).size.height : 0,
                width:
                    isNotificationBar ? MediaQuery.of(context).size.width : 0,
                child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linearToEaseOut,
                    opacity: isNotificationBar ? 1 : 0,
                    child: GestureDetector(
                        onTap: () {
                          triggerNotification();
                        },
                        child:
                            Container(color: Colors.black.withOpacity(0.5)))))),
        Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
                height: MediaQuery.of(context).size.height,
                width: isNotificationBar
                    ? MediaQuery.of(context).size.width * 0.35
                    : 0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.linearToEaseOut,
                child: Container(
                    color: Colors.white,
                    child: NotificationWidget(triggerNotification,
                        isNotificationBar, manualActivateMETabIndex))))
      ]);
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(children: [
          AbsorbPointer(
              absorbing: isNotificationBar,
              child: Column(children: [
                AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    height: appBarHeight,
                    child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(children: [
                          progressBar(context, 6, 1),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 10.0),
                              child: customAppBar(context, triggerNotification,
                                  () {
                                changeLanguage();
                              })),
                          const SizedBox(height: 5),
                          AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return SizeTransition(
                                    sizeFactor: animation, child: child);
                              },
                              child: isHideModule
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30.0, right: 30.0, top: 10.0),
                                      child: moduleSelection()))
                        ]))),
                BlocBuilder<ModuleSelectionBloc, ModuleSelectionState>(
                    builder: (context, state) {
                  if (state is NewBusiness) {
                    analyticsSetCurrentScreen(
                        "New Business Home", "NewBusinessHome");
                    currentModule = moduleList.indexWhere(
                        (element) => element["title"] == "New Business");
                  } else if (state is MedicalCheckAppointment) {
                    analyticsSetCurrentScreen("Medical Check Appointment Home",
                        "MedicalCheckAppointmentHome");
                    currentModule = moduleList.indexWhere((element) =>
                        element["title"] == "Medical Check Up Appointment");
                  }

                  return Expanded(
                      child: AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          child: (state is NewBusiness)
                              ? NewBusinessHome(
                                  hideModule: hideModuleMEHome(),
                                  unhideModule: unhideModuleMEHome())
                              : MedicalExamHome(
                                  key: globalKey,
                                  hideModule: hideModuleMEHome(),
                                  unhideModule: unhideModuleMEHome())));
                })
              ])),
          notificationView()
        ]));
  }
}
