part of 'question_bloc.dart';

abstract class QuestionTypeState extends Equatable {
  const QuestionTypeState();
}

class QuestionTypeInitial extends QuestionTypeState {
  @override
  List<Object> get props => [];
}

class QuestionTypeLoaded extends QuestionTypeState {
  final String questionType;
  const QuestionTypeLoaded(this.questionType);

  @override
  List<Object> get props => [questionType];
}

class QuestionTypeError extends QuestionTypeState {
  final String message;
  const QuestionTypeError(this.message);

  @override
  List<Object> get props => [message];
}
