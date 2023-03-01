part of 'notification_list_bloc.dart';

abstract class NotificationListEvent extends Equatable {
  const NotificationListEvent();
}

final notificationListEventController =
    StreamController<NotificationListEvent>();
Sink<NotificationListEvent> get notificationListEventSink {
  return notificationListEventController.sink;
}

class GetNotificationList extends NotificationListEvent {
  const GetNotificationList();
  @override
  List<Object> get props => [];
}

class UpdateNotificationList extends NotificationListEvent {
  final Notifications notifications;
  const UpdateNotificationList(this.notifications);
  @override
  List<Object> get props => [];
}
