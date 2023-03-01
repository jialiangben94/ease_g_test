part of 'panel_lists_bloc.dart';

abstract class PanelListsEvent extends Equatable {
  const PanelListsEvent();
}

class GetPanelList extends PanelListsEvent {
  final String panelType;
  final String? searchKeyword;
  final String? facilityCode;

  const GetPanelList(this.panelType, this.searchKeyword, this.facilityCode);
  @override
  List<Object> get props => [];
}
