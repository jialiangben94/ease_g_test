part of 'notification_list_bloc.dart';

abstract class NotificationListState extends Equatable {
  const NotificationListState();
}

class NotificationListInitial extends NotificationListState {
  @override
  List<Object> get props => [];
}

class NotificationListLoading extends NotificationListState{
  const NotificationListLoading();
  @override
  List<Object> get props => [];
}

class NotificationListLoaded extends NotificationListState{
  final List<Notifications> notificationList;
  const NotificationListLoaded(this.notificationList);

  @override
  List<Object> get props => [notificationList];
}

class NotificationListError extends NotificationListState{
  final String message;
  const NotificationListError(this.message);
  
  @override
  List<Object> get props => [message];
}