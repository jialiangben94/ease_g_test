import 'package:collection/collection.dart' show IterableExtension;
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/user_repository/agent_product.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseBasicPlan extends StatefulWidget {
  final Quotation quotation;
  final QuickQuotation quickQtn;
  const ChooseBasicPlan(this.quotation, this.quickQtn, {Key? key})
      : super(key: key);
  @override
  ChooseBasicPlanState createState() => ChooseBasicPlanState();
}

class ChooseBasicPlanState extends State<ChooseBasicPlan> {
  String? selectedProdCode;

  @override
  Widget build(BuildContext context) {
    Widget planCard(ProductPlan plan, bool isAvailable, bool isSelected) {
      return GestureDetector(
          onTap: () {
            if (isAvailable) {
              selectedProdCode = plan.productSetup!.prodCode;
              BlocProvider.of<ChooseProductBloc>(context).add(SetBasicPlan(
                  prodCode: selectedProdCode!,
                  qtn: widget.quotation,
                  quickQtn: widget.quickQtn));
            }
          },
          child: Container(
              width: 240,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: textFieldBoxDecoration().copyWith(
                  border: Border.all(
                      width: isSelected ? 2 : 1,
                      color: isSelected ? cyanColor : greyBorderTFColor)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.productSetup!.isTakaful! ? "EFTB" : "ELIB",
                        style: bFontW5().copyWith(
                            color: !isAvailable ? Colors.grey : cyanColor)),
                    Text(plan.productSetup!.prodName.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t1FontW5().copyWith(
                            color: !isAvailable ? Colors.grey : Colors.black)),
                    Visibility(
                        visible: !isAvailable,
                        child: Text('* ${getLocale("Coming soon")}',
                            style: sFontWN().copyWith(color: Colors.grey))),
                    Expanded(child: Container()),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                              visible: isSelected,
                              child: Text(getLocale("Selected"),
                                  style: t2FontW5())),
                          const SizedBox(width: 10),
                          isSelected
                              ? const Image(
                                  width: 25,
                                  height: 25,
                                  image: AssetImage(
                                      'assets/images/check_circle.png'))
                              : Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.grey)))
                        ])
                  ])));
    }

    Widget filterResult(
        List<ProductPlan> productList, List<AgentProduct> agentProduct) {
      return BlocBuilder<ChooseProductBloc, ChooseProductState>(
          builder: (context, state) {
        if (state is BasicPlanChosen) {
          selectedProdCode = state.selectedPlan.productSetup!.prodCode;
        } else if (state is EditingQuotation) {
          if (state.selectedPlan != null) {
            selectedProdCode = state.selectedPlan!.productSetup!.prodCode;
          }
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 30),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45.0),
              child: Text(getLocale("Please select a basic plan below:"),
                  style: t2FontW5())),
          productList.isEmpty
              ? Center(
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: gFontSize * 3),
                      child: Text(getLocale("No basic plan found"),
                          style: bFontW5().copyWith(color: greyTextColor))))
              : SizedBox(
                  height: 220,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(left: 45),
                      scrollDirection: Axis.horizontal,
                      itemCount: productList.length,
                      itemBuilder: (BuildContext ctxt, i) {
                        bool isAvailable;
                        // compare with agent's product list
                        var prod = agentProduct.firstWhereOrNull((value) =>
                            value.prodCode ==
                            productList[i].productSetup!.prodCode);
                        if (prod != null) {
                          // compare with list of available product
                          if (availableProductCode.keys.contains(
                              productList[i].productSetup!.prodCode)) {
                            isAvailable = true;
                          } else {
                            isAvailable = false;
                          }
                        } else {
                          isAvailable = false;
                        }

                        bool isSelected = isAvailable
                            ? productList[i].productSetup!.prodCode ==
                                        "PCHI03" ||
                                    productList[i].productSetup!.prodCode ==
                                        "PCHI04"
                                ? selectedProdCode == "PCHI03" ||
                                    selectedProdCode == "PCHI04"
                                : productList[i].productSetup!.prodCode ==
                                    selectedProdCode
                            : false;

                        return planCard(
                            productList[i], isAvailable, isSelected);
                      }))
        ]);
      });
    }

    return BlocListener<ProductPlanBloc, ProductPlanState>(
        listener: (context, state) {
      if (state is ProductPlanError) {
        showSnackBarError(state.message);
      }
    }, child: BlocBuilder<ProductPlanBloc, ProductPlanState>(
            builder: (context, state) {
      Widget widget = Container();
      if (state is ProductPlanInitial) {
        widget = Container();
      } else if (state is ProductPlanLoading) {
        widget =
            Padding(padding: const EdgeInsets.all(30.0), child: buildLoading());
      } else if (state is ProductPlanLoaded) {
        widget = filterResult(state.productPlanList, state.agentProduct);
      } else if (state is ProductPlanError) {
        widget = Container();
      } else {
        widget = Container();
      }
      return AnimatedSwitcher(
          switchInCurve: Curves.ease,
          duration: const Duration(milliseconds: 500),
          child: widget);
    }));
  }
}
