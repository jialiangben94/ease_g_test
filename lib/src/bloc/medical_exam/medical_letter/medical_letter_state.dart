part of 'medical_letter_bloc.dart';

abstract class MedicalLetterState extends Equatable {
  const MedicalLetterState();
}

class MedicalLetterInitial extends MedicalLetterState {
  @override
  List<Object> get props => [];
}

class MedicalLetterLoading extends MedicalLetterState {
  const MedicalLetterLoading();
  @override
  List<Object> get props => [];
}

class MedicalLetterPathLoaded extends MedicalLetterState {
  final List<MedicalLetter> listOfMedicalLetter;
  final MedicalLetter selectedML;
  const MedicalLetterPathLoaded(this.listOfMedicalLetter, this.selectedML);

  @override
  List<Object> get props => [listOfMedicalLetter, selectedML];
}

class MedicalLetterError extends MedicalLetterState {
  final String message;
  const MedicalLetterError(this.message);

  @override
  List<Object> get props => [message];
}
