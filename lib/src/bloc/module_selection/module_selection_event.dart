part of 'module_selection_bloc.dart';

abstract class ModuleSelectionEvent extends Equatable {
  const ModuleSelectionEvent();
}

class ActivateNewBusiness extends ModuleSelectionEvent {
  @override
  List<Object> get props => [];
}

class ActivateMedicalCheckAppointment extends ModuleSelectionEvent {
  @override
  List<Object> get props => [];
}

class ActivateEletter extends ModuleSelectionEvent {
  @override
  List<Object> get props => [];
}
