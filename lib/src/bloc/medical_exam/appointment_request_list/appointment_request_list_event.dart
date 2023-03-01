part of 'appointment_request_list_bloc.dart';

abstract class AppointmentRequestListsEvent extends Equatable {
  const AppointmentRequestListsEvent();
}

class GetPendingAppointmentList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetPanelDecisionList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetScheduleConfirmedList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetCheckUpCompletedList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetCustomerNoShowList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetCancelledAppointmentList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}

class GetOthersAppointmentList extends AppointmentRequestListsEvent {
  @override
  List<Object> get props => [];
}
