part of 'panel_lists_bloc.dart';

abstract class PanelListsState extends Equatable {
  const PanelListsState();
}

class PanelListsInitial extends PanelListsState {
  @override
  List<Object> get props => [];
}

class PanelListsLoading extends PanelListsState{
  const PanelListsLoading();
  @override
  List<Object> get props => [];
}

class PanelListsLoaded extends PanelListsState{
  final List<Panel> panelList;
  const PanelListsLoaded(this.panelList);

  @override
  List<Object> get props => [panelList];
}

class PanelDetailsLoaded extends PanelListsState{
  final Panel panel;
  const PanelDetailsLoaded(this.panel);

  @override
  List<Object> get props => [panel];
}


class PanelListsError extends PanelListsState{
  final String? message;
  const PanelListsError(this.message);
  
  @override
  List<Object?> get props => [message];
}