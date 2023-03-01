part of 'master_lookup_bloc.dart';

abstract class MasterLookupState extends Equatable {
  const MasterLookupState();
}

class MasterLookupInitial extends MasterLookupState {
  @override
  List<Object> get props => [];
}

class MasterLookupLoading extends MasterLookupState {
  const MasterLookupLoading();
  @override
  List<Object> get props => [];
}

class MasterLookupLoaded extends MasterLookupState {
  final List<MasterLookup> masterLookupList;
  const MasterLookupLoaded(this.masterLookupList);

  @override
  List<Object> get props => [masterLookupList];
}

class MasterLookupError extends MasterLookupState {
  final String message;
  const MasterLookupError(this.message);

  @override
  List<Object> get props => [message];
}
