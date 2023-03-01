part of 'question_bloc.dart';

abstract class QuestionTypeEvent extends Equatable {
  const QuestionTypeEvent();
}

class SetQuestionType extends QuestionTypeEvent {
  final String questionType;

  const SetQuestionType(this.questionType);
  @override
  List<Object> get props => [];
}
