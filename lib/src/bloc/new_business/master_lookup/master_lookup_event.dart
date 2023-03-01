part of 'master_lookup_bloc.dart';

abstract class MasterLookupEvent extends Equatable {
  const MasterLookupEvent();
}

final productPlanEventController = StreamController<MasterLookupEvent>();
Sink<MasterLookupEvent> get productPlanEventSink {
  return productPlanEventController.sink;
}

class GetMasterLookUpList extends MasterLookupEvent {
  const GetMasterLookUpList();
  @override
  List<Object> get props => [];
}
