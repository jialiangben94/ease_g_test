import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'dart:isolate';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ease/app_localization.dart';
import 'package:ease/src/bloc/module_selection/module_selection_bloc.dart';
import 'package:ease/src/bloc/setting/setting_bloc.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/login_screen.dart';
import 'package:ease/src/screen/new_business/application/questions/questionbloc/question_bloc.dart';
import 'package:ease/src/screen/splash_screen.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/network_util.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/idle_timeout.dart';
import 'package:ease/src/widgets/logout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/bloc/medical_exam/medical_letter/medical_letter_bloc.dart';
import 'package:ease/src/bloc/medical_exam/notification_list/notification_list_bloc.dart';
import 'package:ease/src/bloc/medical_exam/panel_lists_bloc/panel_lists_bloc.dart';
import 'package:ease/src/bloc/new_business/existing_customer_bloc/existing_customer_bloc.dart';
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/bloc/user_profile_form/user_profile_form_bloc.dart';
import 'package:ease/src/data/new_business_model/quotation_repository.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/setting/app_language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart'
    show FirebaseRemoteConfig, RemoteConfigSettings;

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Crashlytics.instance.enableInDevMode = true;
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    String uuid = await getDeviceUUiD();
    FirebaseCrashlytics.instance.setUserIdentifier(uuid);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FirebasePerformance performance = FirebasePerformance.instance;
    if (!kIsWeb) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);
      await performance.setPerformanceCollectionEnabled(true);
    }

    runApp(MultiBlocProvider(providers: [
      BlocProvider<AppointmentRequestListsBloc>(
          create: (BuildContext context) =>
              AppointmentRequestListsBloc(MedicalAppointmentAPI())),
      BlocProvider<MedicalLetterBloc>(
          create: (BuildContext context) => MedicalLetterBloc()),
      BlocProvider<PanelListsBloc>(
          create: (BuildContext context) =>
              PanelListsBloc(MedicalAppointmentAPI())),
      BlocProvider<SettingBloc>(
          create: (BuildContext context) => SettingBloc(AppLanguage())),
      BlocProvider<UserProfileBloc>(
          create: (BuildContext context) =>
              UserProfileBloc(AuthenticationRepository())),
      BlocProvider<UserProfileFormBloc>(
          create: (BuildContext context) =>
              UserProfileFormBloc(AuthenticationRepository(), ServicingAPI())),
      BlocProvider<NotificationListBloc>(
          create: (BuildContext context) =>
              NotificationListBloc(MedicalAppointmentAPI())),
      BlocProvider<ModuleSelectionBloc>(
          create: (BuildContext context) => ModuleSelectionBloc()),
      BlocProvider<QuotationBloc>(
          create: (BuildContext context) =>
              QuotationBloc(quotationRepository: QuotationRepository())),
      BlocProvider<ProductPlanBloc>(
          create: (BuildContext context) =>
              ProductPlanBloc(ProductPlanRepositoryImpl())),
      BlocProvider<ChooseProductBloc>(
          create: (BuildContext context) => ChooseProductBloc()),
      BlocProvider<MasterLookupBloc>(
          create: (BuildContext context) => MasterLookupBloc()),
      BlocProvider<ExistingCustomerBloc>(
          create: (BuildContext context) => ExistingCustomerBloc()),
      BlocProvider<QuestionBloc>(
          create: (BuildContext context) => QuestionBloc())
    ], child: const MyApp()));
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance
        .recordError(errorAndStacktrace.first, errorAndStacktrace.last);
  }).sendPort);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Locale? language;
  bool? isFirstTime;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getEnforcedVersion();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // FirebaseCrashlytics.instance.crash();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    BlocProvider.of<SettingBloc>(context).add(GetSetting());
    BlocProvider.of<ModuleSelectionBloc>(context).add(ActivateNewBusiness());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String? currentVersionRaw;
  String? enforcedVersionRaw = "0.0.0";

  // Get latest enforced version
  void getEnforcedVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    currentVersionRaw = packageInfo.version;

    try {
      await remoteConfig
          .setConfigSettings(RemoteConfigSettings(
              fetchTimeout: const Duration(seconds: 30),
              minimumFetchInterval: const Duration(minutes: 5)))
          .then((value) => remoteConfig.fetchAndActivate());

      setState(() {
        enforcedVersionRaw = remoteConfig.getString('enforced_version');
        log('app enforce version: $enforcedVersionRaw');
        log('app current version: $currentVersionRaw');
      });
    } catch (e) {
      log('error caught: $e');
    }
  }

  bool get needsUpdate {
    final List<int> currentVersion = currentVersionRaw!
        .split('.')
        .map((String number) => int.parse(number))
        .toList();
    final List<int> enforcedVersion = enforcedVersionRaw!
        .split('.')
        .map((String number) => int.parse(number))
        .toList();
    for (int i = 0; i < 3; i++) {
      if (currentVersion[i] > enforcedVersion[i]) {
        return false;
      } else if (currentVersion[i] == enforcedVersion[i]) {
        continue;
      } else {
        return true;
      }
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // If app resumed: validate token and redirect
      validateSession(true);
      // If app resumed, check apps latest version
      getEnforcedVersion();
    }
  }

  dynamic validateSession(bool isResumed) async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;

      var version = "${iosInfo.systemVersion}.0";
      var vversion = version.split(".");
      var mainVersion = int.parse(vversion[0]);
      // Validate if version >= 12
      if (mainVersion >= 12) {
        if (isResumed) {
          await AuthenticationRepository.internal()
              .validateToken()
              .then((value) {
            if (!value["isTokenValid"] &&
                value["message"] != "No token found") {
              handleLoggedOut(value["message"]);
            }
          });
        } else {
          return AuthenticationRepository.internal().validateToken();
        }
      } else {
        return {"isTokenValid": false};
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (e) => resetIdleTime(),
        child: BlocListener<SettingBloc, SettingState>(
            listener: (context, state) {
              if (state is SettingLoaded) {
                setState(() {
                  language = state.language;
                });
              }
            },
            child: MaterialApp(
                title: 'EASE',
                theme: ThemeData(
                    primarySwatch: Colors.blue,
                    fontFamily: 'Meta',
                    textTheme: TextTheme(
                        headline1: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                        headline2: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        headline3: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                        headline4: const TextStyle(fontSize: 16.0),
                        headline5: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: tealGreenColor),
                        // headline6 is for red notification
                        headline6:
                            TextStyle(fontSize: 15, color: scarletRedColor),
                        bodyText1: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                            color: greyTextColor),
                        bodyText2:
                            TextStyle(fontSize: 16, color: greyTextColor),
                        subtitle1: const TextStyle(fontSize: 14),
                        subtitle2: TextStyle(fontSize: 16, color: cyanColor),
                        button: TextStyle(fontSize: 14.0, color: cyanColor))),
                locale: language,
                supportedLocales: const [
                  Locale('en', 'US'),
                  Locale('ms', 'MY')
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                home: Scaffold(body: Builder(builder: (context) {
                  return FutureBuilder<dynamic>(
                      future: validateSession(false),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data["isTokenValid"]) {
                            return needsUpdate == true
                                ? NewVersion(
                                    message: getLocale(
                                        "Please download the latest EaSE version from EPP"))
                                : const Home();
                            // return const Home();
                          } else {
                            if (snapshot.data["message"] == "No token found" ||
                                snapshot.data["message"] ==
                                    "Jwt Token Expired") {
                              return needsUpdate == true
                                  ? NewVersion(
                                      message: getLocale(
                                          "Please download the latest EaSE version from EPP"))
                                  : const LoginScreen();
                            } else {
                              return SplashScreen(
                                  message: getLocale(
                                      "Session Expired. Please log in again") /*snapshot.data["message"] is String
                                      ? snapshot.data["message"]
                                      : ""*/
                                  );
                            }
                          }
                        } else if (snapshot.hasError) {
                          return SplashScreen(
                              message: snapshot.error as String?);
                        } else {
                          return const SplashScreen();
                        }
                      });
                })))));
  }
}
