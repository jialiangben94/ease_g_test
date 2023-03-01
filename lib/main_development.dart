import 'dart:async';
import 'package:ease/main.dart';
import 'package:ease/src/bloc/medical_exam/appointment_request_list/appointment_request_list_bloc.dart';
import 'package:ease/src/bloc/medical_exam/medical_letter/medical_letter_bloc.dart';
import 'package:ease/src/bloc/medical_exam/notification_list/notification_list_bloc.dart';
import 'package:ease/src/bloc/medical_exam/panel_lists_bloc/panel_lists_bloc.dart';
import 'package:ease/src/bloc/module_selection/module_selection_bloc.dart';
import 'package:ease/src/bloc/new_business/existing_customer_bloc/existing_customer_bloc.dart';
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/bloc/setting/setting_bloc.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/bloc/user_profile_form/user_profile_form_bloc.dart';
import 'package:ease/src/data/user_repository/authentication_repo.dart';
import 'package:ease/src/data/new_business_model/quotation_repository.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/application/questions/questionbloc/question_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/service/auth_service.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/setting/app_language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

void main() async {
  // Crashlytics.instance.enableInDevMode = true;
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    }
    FirebasePerformance performance = FirebasePerformance.instance;
    if (!kIsWeb) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);
      await performance.setPerformanceCollectionEnabled(false);
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
}
