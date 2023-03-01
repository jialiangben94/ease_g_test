import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/medical_exam_model/notification.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:equatable/equatable.dart';

part 'notification_list_event.dart';
part 'notification_list_state.dart';

class NotificationListBloc
    extends Bloc<NotificationListEvent, NotificationListState> {
  final MedicalAppointmentServiceRepo repository;

  NotificationListBloc(this.repository) : super(NotificationListInitial()) {
    on<GetNotificationList>(mapGetNotificationListEventToState);
    on<UpdateNotificationList>(mapUpdateNotificationListEventToState);
  }

  void mapGetNotificationListEventToState(
      GetNotificationList event, Emitter<NotificationListState> emit) async {
    emit(const NotificationListLoading());
    try {
      List<Notifications> data = [];
      await _getNotificationList().then((value) {
        data = value;
      });
      emit(NotificationListLoaded(data));
    } catch (e) {
      emit(NotificationListError(e.toString()));
    }
  }

  void mapUpdateNotificationListEventToState(
      UpdateNotificationList event, Emitter<NotificationListState> emit) async {
    emit(const NotificationListLoading());
    try {
      bool? update = await _updateNotificationList(event.notifications);
      if (update != null && update) {
        List<Notifications> data = await _getNotificationList();
        emit(NotificationListLoaded(data));
      }
    } catch (e) {
      emit(NotificationListError(e.toString()));
    }
  }

  Future<List<Notifications>> _getNotificationList() async {
    List<Notifications> notificationList = [];

    await repository.getNotificationList().then((value) async {
      final data = jsonDecode(value["NotificationList"]);

      for (int i = 0; i < data.length; i++) {
        Notifications notification = Notifications.fromJson(data[i]);
        notificationList.add(notification);
      }

      return;
    });
    return notificationList;
  }

  Future<bool?> _updateNotificationList(Notifications notifications) async {
    bool? isSuccess;
    await repository.updateNotification(notifications).then((data) async {
      isSuccess = data["IsSuccess"];
    });
    return isSuccess;
  }
}
