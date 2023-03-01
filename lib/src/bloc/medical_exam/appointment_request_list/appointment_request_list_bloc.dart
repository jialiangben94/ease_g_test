import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'appointment_request_list_event.dart';
part 'appointment_request_list_state.dart';

enum AppointmentListCounter { increment, decrement }

class AppointmentRequestListsBloc
    extends Bloc<AppointmentRequestListsEvent, AppointmentRequestState> {
  final MedicalAppointmentServiceRepo medicalAppointmentRepository;

  AppointmentRequestListsBloc(this.medicalAppointmentRepository)
      : super(const AppointmentRequestListsInitial()) {
    on<GetPendingAppointmentList>(mapGetPendingAppointmentListEventToState);
    on<GetPanelDecisionList>(mapGetPanelDecisionListEventToState);
    on<GetScheduleConfirmedList>(mapGetScheduleConfirmedListEventToState);
    on<GetCheckUpCompletedList>(mapGetCheckUpCompletedListEventToState);
    on<GetCustomerNoShowList>(mapGetCustomerNoShowListEventToState);
    on<GetCancelledAppointmentList>(mapGetCancelledAppointmentListEventToState);
    on<GetOthersAppointmentList>(mapGetOthersAppointmentListEventToState);
  }

  int? totalUnread;
  int? pendingAppointmentSetupNum;

  /*
  Appointment List Status for Reference:
  * A : Pending Panel Decision 
  * C : Schedule Confirmed
  * D : Completed
  * N : No Show
  * OTH : Other
  * P : Pending
  * R : Rejected
  * S : Cancelled by Panel
  * X : Cancelled
  */

  void mapGetPendingAppointmentListEventToState(GetPendingAppointmentList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));
      List<AppointmentRequest> pendingAppointmentRequest = [];

      await medicalAppointmentRepository
          .fetchAppointmentListByStatus(
              agentCode: agent.accountCode, appointmentStatus: "P")
          .then((value) async {
        final appointmentlist = jsonDecode(value["AppointmentStatusList"]);
        for (int i = 0; i < appointmentlist.length; i++) {
          AppointmentRequest appointmentRequest =
              AppointmentRequest.fromJson(appointmentlist[i]);
          pendingAppointmentRequest.add(appointmentRequest);
        }

        return;
      });

      // To highlight notification, the red small dot on module, we need to track 3 variables.
      // 1. Total number of unread data,
      // 2. List of id already read (shared pref),
      // 3. Newly saved id (Shared pref contain all)
      // So if total number of unread data is 5,
      // we need to compare each 5 with data and from shared pref.
      // And save it to another variable.

      List<String> alreadySaved = [];

      // List of id already saved from shared pref.
      await loadReadIds().then((List<String> data) {
        alreadySaved = data;
      });

      List<String?> newAndSaved = [];

      for (int i = 0; i < pendingAppointmentRequest.length; i++) {
        if (alreadySaved.contains(pendingAppointmentRequest[i].propNo)) {
          newAndSaved.add(pendingAppointmentRequest[i].propNo);
        }
      }

      totalUnread = pendingAppointmentRequest.length - newAndSaved.length;

      emit(PendingAppointmentLoaded(
          totalUnread, // Total unread num
          pendingAppointmentSetupNum, // Total num pending for appointment setup
          alreadySaved, // List of id already read
          pendingAppointmentRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetPanelDecisionListEventToState(
      GetPanelDecisionList event, Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      List<AppointmentRequest> pendingPanelDecisionRequest =
          await getAndSortData(agent.accountCode, "A");

      emit(PendingPanelLoaded(pendingPanelDecisionRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetScheduleConfirmedListEventToState(GetScheduleConfirmedList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      List<AppointmentRequest> scheduleConfirmedRequest =
          await getAndSortData(agent.accountCode, "C");

      emit(ScheduleConfirmedLoaded(scheduleConfirmedRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetCheckUpCompletedListEventToState(GetCheckUpCompletedList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      List<AppointmentRequest> completedRequest =
          await getAndSortData(agent.accountCode, "D");

      emit(CheckUpCompletedLoaded(completedRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetCustomerNoShowListEventToState(GetCustomerNoShowList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      List<AppointmentRequest> noShowRequest =
          await getAndSortData(agent.accountCode, "N");

      emit(CustomerNoShowLoaded(noShowRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetCancelledAppointmentListEventToState(
      GetCancelledAppointmentList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));
      List<AppointmentRequest> cancelledRequest =
          await getAndSortData(agent.accountCode, "X");

      emit(CancelledAppointmentLoaded(cancelledRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  void mapGetOthersAppointmentListEventToState(GetOthersAppointmentList event,
      Emitter<AppointmentRequestState> emit) async {
    emit(const AppointmentRequestListsLoading());
    try {
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      List<AppointmentRequest> otherRequest =
          await getAndSortData(agent.accountCode, "OTH");

      emit(OthersAppointmentLoaded(otherRequest));
    } catch (e) {
      emit(AppointmentRequestListsError(e.toString()));
    }
  }

  // MAIN FUNCTION TO CALL API SERVICE

  Future<List<AppointmentRequest>> getAndSortData(
      String? userId, String status) async {
    List<AppointmentRequest> tmpData = [];

    await medicalAppointmentRepository
        .fetchAppointmentListByStatus(
            agentCode: userId, appointmentStatus: status)
        .then((value) async {
      if (value["AppointmentStatusList"] != "null" ||
          value["AppointmentStatusList"] != null) {
        final appointmentlist = jsonDecode(value["AppointmentStatusList"]);

        for (int i = 0; i < appointmentlist.length; i++) {
          AppointmentRequest appointmentRequest =
              AppointmentRequest.fromJson(appointmentlist[i]);
          tmpData.add(appointmentRequest);
        }
        return;
      }
    });

    return tmpData;
  }
}

Future<List<String?>?> saveReadIds(String? propNo) async {
  List<String?>? data = [];
  SharedPreferences pref = await SharedPreferences.getInstance();

  if (pref.getStringList(spkRead) != null) {
    data = pref.getStringList(spkRead);

    if (data!.contains(propNo) != true) {
      data.add(propNo);
      await pref.setStringList(spkRead, List<String>.from(data));
    }
  } else {
    data.add(propNo);
    await pref.setStringList(spkRead, List<String>.from(data));
  }
  return data;
}

Future<List<String>> loadReadIds() async {
  List<String>? data = [];
  SharedPreferences pref = await SharedPreferences.getInstance();

  if (pref.getStringList(spkRead) != null) {
    data = pref.getStringList(spkRead);
  } else {
    data = [];
  }
  return data!;
}
