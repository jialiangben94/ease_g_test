part of 'existing_customer_bloc.dart';

abstract class ExistingCustomerEvent extends Equatable {
  const ExistingCustomerEvent();
}

final occupationListEventController = StreamController<ExistingCustomerEvent>();
Sink<ExistingCustomerEvent> get occupationListEventSink {
  return occupationListEventController.sink;
}

class SearchExistingCustomer extends ExistingCustomerEvent {
  final String? keyword;
  const SearchExistingCustomer(this.keyword);
  @override
  List<Object> get props => [];
}
