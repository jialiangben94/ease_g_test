import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/user_repository/agent_product.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:equatable/equatable.dart';

part 'product_plan_event.dart';
part 'product_plan_state.dart';

class ProductPlanBloc extends Bloc<ProductPlanEvent, ProductPlanState> {
  ProductPlanBloc(this.repository) : super(ProductPlanInitial()) {
    on<FilterProductPlanList>(mapFilterProductPlanListEventToState);
  }

  ProductPlanRepository repository;

  void mapFilterProductPlanListEventToState(
      FilterProductPlanList event, Emitter<ProductPlanState> emit) async {
    emit(const ProductPlanLoading());
    try {
      List<AgentProduct> agentProduct = await repository.getAgentProduct();
      List<ProductPlan> data = await repository.getProductPlanSetup(
          type: event.type, agentProducts: agentProduct, isFilterName: true);
      List<ProductPlan> rider = await repository.getRiderPlanSetup();

      emit(ProductPlanLoaded(data, rider, agentProduct, event.type));
    } catch (e) {
      emit(ProductPlanError(e.toString()));
    }
  }
}
