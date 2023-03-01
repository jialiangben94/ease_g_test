import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/medical_exam_model/medical_letter.dart';
import 'package:ease/src/service/medical_appointment_service.dart';
import 'package:equatable/equatable.dart';

part 'medical_letter_event.dart';
part 'medical_letter_state.dart';

class MedicalLetterBloc extends Bloc<MedicalLetterEvent, MedicalLetterState> {
  MedicalLetterBloc() : super(MedicalLetterInitial()) {
    on<GetMedicalLetterPath>(mapGetMedicalLetterPathEventToState);
    on<LoadMedicalLetter>(mapLoadMedicalLetterEventToState);
  }

  void mapGetMedicalLetterPathEventToState(
      GetMedicalLetterPath event, Emitter<MedicalLetterState> emit) async {
    emit(const MedicalLetterLoading());
    try {
      final List<MedicalLetter> listOfMedicalLetter =
          await fetchMedicalLetter(event.proposalMEId);
      listOfMedicalLetter.sort((a, b) {
        var aDocId = DateTime.parse(a.createdDateTime!);
        var bDocId = DateTime.parse(b.createdDateTime!);
        return bDocId.compareTo(aDocId);
      });
      emit(
          MedicalLetterPathLoaded(listOfMedicalLetter, listOfMedicalLetter[0]));
    } catch (e) {
      emit(MedicalLetterError(e.toString()));
    }
  }

  void mapLoadMedicalLetterEventToState(
      LoadMedicalLetter event, Emitter<MedicalLetterState> emit) async {
    emit(const MedicalLetterLoading());
    try {
      final List<MedicalLetter> listOfMedicalLetter = event.listOfML;
      emit(MedicalLetterPathLoaded(listOfMedicalLetter, event.selectedML));
    } catch (e) {
      emit(MedicalLetterError(e.toString()));
    }
  }
}

Future<List<MedicalLetter>> fetchMedicalLetter(String? proposalMEId) async {
  List<MedicalLetter> listOfML = [];
  final res =
      await MedicalAppointmentAPI().retrieveAllMedicalDocument(proposalMEId);
  if (res != null) {
    final data = jsonDecode(res["docList"]);
    for (int i = 0; i < data.length; i++) {
      MedicalLetter medicalLetter = MedicalLetter.fromJson(data[i]);
      listOfML.add(medicalLetter);
    }
  }
  return listOfML;
}
