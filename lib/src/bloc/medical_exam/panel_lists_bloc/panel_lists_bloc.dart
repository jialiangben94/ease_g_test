import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:equatable/equatable.dart';

part 'panel_lists_event.dart';
part 'panel_lists_state.dart';

class PanelListsBloc extends Bloc<PanelListsEvent, PanelListsState> {
  final MedicalAppointmentServiceRepo medicalAppointmentRepository;

  PanelListsBloc(this.medicalAppointmentRepository)
      : super(PanelListsInitial()) {
    on<GetPanelList>(mapGetPanelListEventToState);
  }

  void mapGetPanelListEventToState(
      GetPanelList event, Emitter<PanelListsState> emit) async {
    emit(const PanelListsLoading());
    var facilityCode = event.facilityCode!;
    if (facilityCode[facilityCode.length - 1] == ";") {
      facilityCode = facilityCode.substring(0, facilityCode.length - 1);
    }

    List<Panel> panelList = [];
    String? message;

    await medicalAppointmentRepository
        .fetchPanelList(
            panelType: event.panelType,
            searchKeyword: event.searchKeyword,
            facilityCode: facilityCode)
        .then((res) {
      if (res["IsSuccess"]) {
        if (res["PanelDetailVms"] != null && res["PanelDetailVms"].isNotEmpty) {
          final location = jsonDecode(res["PanelDetailVms"]);
          // final location = data["LocDetails"];
          for (int i = 0; i < location.length; i++) {
            if (location[i] != null) {
              Panel panel = Panel.fromJson(location[i]);
              panelList.add(panel);
            }
          }
        }
      } else {
        message = res["Message"];
      }
    });
    if (panelList.isNotEmpty) {
      emit(PanelListsLoaded(panelList));
    } else {
      if (message != null) {
        emit(PanelListsError(message));
      } else {
        emit(PanelListsLoaded(panelList));
      }
    }
  }
}
