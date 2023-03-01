part of 'appointment_request_list_bloc.dart';

abstract class AppointmentRequestState extends Equatable {
  const AppointmentRequestState();
}

class AppointmentRequestListsInitial extends AppointmentRequestState {
  const AppointmentRequestListsInitial();
  @override
  List<Object> get props => [];
}

class AppointmentRequestListsLoading extends AppointmentRequestState {
  const AppointmentRequestListsLoading();
  @override
  List<Object> get props => [];
}

class AppointmentRequestListsLoaded extends AppointmentRequestState {
  final int totalUnread;
  final int pendingAppointmentSetupNum;
  final List<String> alreadySavedId;
  final List<AppointmentRequest> appointmentRequest;
  final List<AppointmentRequest> pendingPanel;
  final List<AppointmentRequest> pendingAppointmentSetup;
  final List<AppointmentRequest> scheduleConfirm;
  final List<AppointmentRequest> checkUpComplete;
  final List<AppointmentRequest> customerNoShow;
  final List<AppointmentRequest> cancelledAppointment;

  const AppointmentRequestListsLoaded(
      this.totalUnread,
      this.pendingAppointmentSetupNum,
      this.alreadySavedId,
      this.appointmentRequest,
      this.pendingPanel,
      this.pendingAppointmentSetup,
      this.scheduleConfirm,
      this.checkUpComplete,
      this.customerNoShow,
      this.cancelledAppointment);

  @override
  List<Object> get props => [
        totalUnread,
        pendingAppointmentSetupNum,
        alreadySavedId,
        appointmentRequest,
        pendingPanel,
        pendingAppointmentSetup,
        scheduleConfirm,
        checkUpComplete,
        customerNoShow,
        cancelledAppointment
      ];
}

class PendingAppointmentLoaded extends AppointmentRequestState {
  final int? totalUnread;
  final int? pendingAppointmentSetupNum;
  final List<String> alreadySavedId;
  final List<AppointmentRequest> pendingAppointmentRequest;

  const PendingAppointmentLoaded(
      this.totalUnread,
      this.pendingAppointmentSetupNum,
      this.alreadySavedId,
      this.pendingAppointmentRequest);

  @override
  List<Object?> get props => [
        totalUnread,
        pendingAppointmentSetupNum,
        alreadySavedId,
        pendingAppointmentRequest
      ];
}

class PendingPanelLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> pendingPanelRequest;

  const PendingPanelLoaded(this.pendingPanelRequest);

  @override
  List<Object> get props => [pendingPanelRequest];
}

class ScheduleConfirmedLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> scheduleConfirmedRequest;

  const ScheduleConfirmedLoaded(this.scheduleConfirmedRequest);

  @override
  List<Object> get props => [scheduleConfirmedRequest];
}

class CheckUpCompletedLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> checkUpCompletedRequest;

  const CheckUpCompletedLoaded(this.checkUpCompletedRequest);

  @override
  List<Object> get props => [checkUpCompletedRequest];
}

class CustomerNoShowLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> customerNoShowRequest;

  const CustomerNoShowLoaded(this.customerNoShowRequest);

  @override
  List<Object> get props => [customerNoShowRequest];
}

class CancelledAppointmentLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> cancelledRequest;

  const CancelledAppointmentLoaded(this.cancelledRequest);

  @override
  List<Object> get props => [cancelledRequest];
}

class OthersAppointmentLoaded extends AppointmentRequestState {
  final List<AppointmentRequest> othersRequest;

  const OthersAppointmentLoaded(this.othersRequest);

  @override
  List<Object> get props => [othersRequest];
}

class AppointmentRequestListsError extends AppointmentRequestState {
  final String message;
  const AppointmentRequestListsError(this.message);

  @override
  List<Object> get props => [message];
}
