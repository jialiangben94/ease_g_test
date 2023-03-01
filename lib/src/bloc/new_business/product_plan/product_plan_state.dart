part of 'product_plan_bloc.dart';

abstract class ProductPlanState extends Equatable {
  const ProductPlanState();
}

class ProductPlanInitial extends ProductPlanState {
  @override
  List<Object> get props => [];
}

class ProductPlanLoading extends ProductPlanState {
  const ProductPlanLoading();
  @override
  List<Object> get props => [];
}

class ProductPlanLoaded extends ProductPlanState {
  final List<ProductPlan> productPlanList;
  final List<ProductPlan> riderPlanList;
  final List<AgentProduct> agentProduct;
  final ProductPlanType? prodType;
  const ProductPlanLoaded(this.productPlanList, this.riderPlanList,
      this.agentProduct, this.prodType);

  @override
  List<Object> get props => [productPlanList, riderPlanList, agentProduct];
}

class ProductPlanError extends ProductPlanState {
  final String message;
  const ProductPlanError(this.message);

  @override
  List<Object> get props => [message];
}
