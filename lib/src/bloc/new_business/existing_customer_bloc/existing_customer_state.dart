part of 'existing_customer_bloc.dart';

abstract class ExistingCustomerListState extends Equatable {
  const ExistingCustomerListState();
}

class ExistingCustomerListInitial extends ExistingCustomerListState {
  @override
  List<Object> get props => [];
}

class ExistingCustomerListLoading extends ExistingCustomerListState {
  const ExistingCustomerListLoading();
  @override
  List<Object> get props => [];
}

class ExistingCustomerListLoaded extends ExistingCustomerListState {
  final List<Person> personList;
  const ExistingCustomerListLoaded(this.personList);

  @override
  List<Object> get props => [personList];
}

class ExistingCustomerListError extends ExistingCustomerListState {
  final String message;
  const ExistingCustomerListError(this.message);

  @override
  List<Object> get props => [message];
}
