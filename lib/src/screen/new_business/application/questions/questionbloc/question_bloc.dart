import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'question_event.dart';
part 'question_state.dart';

class QuestionBloc extends Bloc<QuestionTypeEvent, QuestionTypeState> {
  QuestionBloc() : super(QuestionTypeInitial()) {
    on<SetQuestionType>(mapSetQuestionTypeEventToState);
  }

  void mapSetQuestionTypeEventToState(
      SetQuestionType event, Emitter<QuestionTypeState> emit) async {
    emit(QuestionTypeLoaded(event.questionType));
  }
}
