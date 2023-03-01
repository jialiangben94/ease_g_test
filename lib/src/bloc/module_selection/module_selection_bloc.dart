import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'module_selection_event.dart';
part 'module_selection_state.dart';

class ModuleSelectionBloc
    extends Bloc<ModuleSelectionEvent, ModuleSelectionState> {
  ModuleSelectionBloc() : super(ModuleSelectionInitial()) {
    on<ActivateNewBusiness>(mapActivateNewBusinessEventToState);
    on<ActivateMedicalCheckAppointment>(
        mapActivateMedicalCheckAppointmentEventToState);
    on<ActivateEletter>(mapActivateEletterEventToState);
  }

  void mapActivateNewBusinessEventToState(
      ActivateNewBusiness event, Emitter<ModuleSelectionState> emit) async {
    emit(NewBusiness());
  }

  void mapActivateMedicalCheckAppointmentEventToState(
      ActivateMedicalCheckAppointment event,
      Emitter<ModuleSelectionState> emit) async {
    emit(MedicalCheckAppointment());
  }

  void mapActivateEletterEventToState(
      ActivateEletter event, Emitter<ModuleSelectionState> emit) async {
    emit(Eletter());
  }
}
