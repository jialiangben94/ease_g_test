part of 'medical_letter_bloc.dart';

abstract class MedicalLetterEvent extends Equatable {
  const MedicalLetterEvent();
}

final medicalLetterEventController = StreamController<MedicalLetterEvent>();
Sink<MedicalLetterEvent> get medicalLetterEventSink {
  return medicalLetterEventController.sink;
}

class GetMedicalLetterPath extends MedicalLetterEvent {
  final String? proposalMEId;
  const GetMedicalLetterPath(this.proposalMEId);
  @override
  List<Object> get props => [];
}

class LoadMedicalLetter extends MedicalLetterEvent {
  final List<MedicalLetter> listOfML;
  final MedicalLetter selectedML;
  const LoadMedicalLetter(this.listOfML, this.selectedML);
  @override
  List<Object> get props => [];
}
