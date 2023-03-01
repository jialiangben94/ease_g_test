import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseProductPlanType extends StatefulWidget {
  final ProductPlanType? productPlanType;
  const ChooseProductPlanType(this.productPlanType, {Key? key})
      : super(key: key);

  @override
  ChooseProductPlanTypeState createState() => ChooseProductPlanTypeState();
}

class ChooseProductPlanTypeState extends State<ChooseProductPlanType> {
  ProductPlanType? productPlanType;
  int _firstTimeEditingScreenLoaded = 0;

  @override
  void initState() {
    super.initState();
    //productPlanType = ProductPlanType.investmentLink;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChooseProductBloc, ChooseProductState>(
        builder: (context, state) {
      if (state is SetProductPlanType) {
        productPlanType = state.productPlanType;
      }

      if (state is EditingQuotation && _firstTimeEditingScreenLoaded == 0) {
        _firstTimeEditingScreenLoaded = 1;

        var pproductPlanType = state.quickQuotation.productPlanLOB;

        if (pproductPlanType != null &&
            pproductPlanType.toLowerCase().contains("investmentlink")) {
          productPlanType = ProductPlanType.investmentLink;
        } else {
          productPlanType = ProductPlanType.traditional;
        }
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 30),
        Text(getLocale("Which plan would you like to proceed with?"),
            style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        BlocListener<QuotationBloc, QuotationBlocState>(
            listener: (context, state) {},
            child: BlocBuilder<QuotationBloc, QuotationBlocState>(
                builder: (context, state) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                productPlanType = ProductPlanType.traditional;
                              });
                              BlocProvider.of<ChooseProductBloc>(context)
                                  .add(SetPlanType(productPlanType!));
                              BlocProvider.of<ProductPlanBloc>(context).add(
                                  FilterProductPlanList(type: productPlanType));
                            },
                            child: Container(
                                height: commonTextFieldHeight,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    border: Border.all(
                                        width: 2,
                                        color: productPlanType ==
                                                ProductPlanType.traditional
                                            ? cyanColor
                                            : Colors.grey[400]!)),
                                child: Center(
                                    child: Text(getLocale("Traditional"),
                                        style: bFontW5().copyWith(
                                            color: productPlanType ==
                                                    ProductPlanType.traditional
                                                ? cyanColor
                                                : Colors.grey[600])))))),
                    const SizedBox(width: 20),
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                                productPlanType =
                                    ProductPlanType.investmentLink;
                              });
                              BlocProvider.of<ChooseProductBloc>(context)
                                  .add(SetPlanType(productPlanType!));
                              BlocProvider.of<ProductPlanBloc>(context).add(
                                  FilterProductPlanList(type: productPlanType));
                              // BlocProvider.of<QuotationBloc>(context)
                              //     .add(LoadQuotation());
                            },
                            child: Container(
                                height: commonTextFieldHeight,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                    border: Border.all(
                                        width: 2,
                                        color: productPlanType ==
                                                ProductPlanType.investmentLink
                                            ? cyanColor
                                            : Colors.grey[400]!)),
                                child: Center(
                                    child: Text(
                                  "Investment Link",
                                  style: bFontW5().copyWith(
                                      color: productPlanType ==
                                              ProductPlanType.investmentLink
                                          ? cyanColor
                                          : Colors.grey[600]),
                                ))))),
                  ]));
            }))
      ]);
    });
  }
}
