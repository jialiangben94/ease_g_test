part of 'product_plan_bloc.dart';

abstract class ProductPlanEvent extends Equatable {
  const ProductPlanEvent();
}

final productPlanEventController = StreamController<ProductPlanEvent>();
Sink<ProductPlanEvent> get productPlanEventSink {
  return productPlanEventController.sink;
}

class FilterProductPlanList extends ProductPlanEvent {
  final ProductPlanType? type;
  const FilterProductPlanList({this.type});
  @override
  List<Object> get props => [];
}
