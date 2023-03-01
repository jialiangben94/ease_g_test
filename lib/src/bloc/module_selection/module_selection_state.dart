part of 'module_selection_bloc.dart';

abstract class ModuleSelectionState extends Equatable {
  const ModuleSelectionState();
}

class ModuleSelectionInitial extends ModuleSelectionState {
  @override
  List<Object> get props => [];
}

class NewBusiness extends ModuleSelectionState {
  @override
  List<Object> get props => [];
}

class MedicalCheckAppointment extends ModuleSelectionState {
  @override
  List<Object> get props => [];
}

class Eletter extends ModuleSelectionState {
  @override
  List<Object> get props => [];
}

class ModuleError extends ModuleSelectionState {
  final String message;
  const ModuleError(this.message);

  @override
  List<Object> get props => [message];
}
