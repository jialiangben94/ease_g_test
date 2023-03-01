import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseGCPAndSalaryDeduct extends StatefulWidget {
  final bool isValidate;
  const ChooseGCPAndSalaryDeduct({Key? key, this.isValidate = false})
      : super(key: key);

  @override
  ChooseGCPAndSalaryDeductState createState() =>
      ChooseGCPAndSalaryDeductState();
}

class ChooseGCPAndSalaryDeductState extends State<ChooseGCPAndSalaryDeduct> {
  int? _firstTimeScreenLoaded;
  int _firstTimeEditingScreenLoaded = 0;

  String? prodCode;
  ProductPlanType? productPlanType;
  String? _selectedGuaranteedCashPayment;
  bool deductSalary = false;
  List<RiderOutputData>? riderOutputData;

  @override
  void initState() {
    super.initState();
  }

  List<DropdownMenuItem<String>> guaranteedCashPayment = [];

  void setData() {
    BlocProvider.of<ChooseProductBloc>(context).add(SetSumInsuredAndPrem(
        deductSalary: deductSalary,
        guaranteedCashPayment: _selectedGuaranteedCashPayment));
  }

  List<DropdownMenuItem<String>> getGCPOption(ProductPlan? selectedPlan) {
    List<DropdownMenuItem<String>> guaranteedCashPayment2 = [];

    if (selectedPlan != null &&
        selectedPlan.productSetup!.isRateScale != null &&
        selectedPlan.productSetup!.isRateScale!) {
      var rateScaleList = selectedPlan.rateScaleList;
      if (rateScaleList != null && rateScaleList.isNotEmpty) {
        for (var element in rateScaleList) {
          guaranteedCashPayment2.add((DropdownMenuItem(
              value: element.rateScale,
              child: Text(lookupRateScale[element.rateScale] ?? ""))));
        }
      }
    }
    return guaranteedCashPayment2;
  }

  bool validateGCP() {
    if (!widget.isValidate) return true;
    return (_selectedGuaranteedCashPayment ?? "").isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    Widget salaryDeduction() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Salary Deduction as Payment Method"),
            style: bFontW5().copyWith(fontSize: 18)),
        Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 30),
            child: Row(children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      deductSalary = true;
                    });
                    setData();
                  },
                  child: Container(
                      width: 220,
                      height: 70,
                      decoration: textFieldBoxDecoration().copyWith(
                          border: Border.all(
                              width: deductSalary ? 2 : 1,
                              color: deductSalary
                                  ? cyanColor
                                  : greyBorderTFColor)),
                      child: Center(
                          child: Text(getLocale("Yes"),
                              style: t2FontW5().copyWith(
                                  color: deductSalary
                                      ? cyanColor
                                      : Colors.black))))),
              const SizedBox(width: 15),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      deductSalary = false;
                    });
                    setData();
                  },
                  child: Container(
                      width: 220,
                      height: 70,
                      decoration: textFieldBoxDecoration().copyWith(
                          border: Border.all(
                              width: !deductSalary ? 2 : 1,
                              color: !deductSalary
                                  ? cyanColor
                                  : greyBorderTFColor)),
                      child: Center(
                          child: Text(getLocale("No"),
                              style: t2FontW5().copyWith(
                                  color: !deductSalary
                                      ? cyanColor
                                      : Colors.black)))))
            ]))
      ]);
    }

    Widget errorMessage(bool valid, String errorMsg) {
      return Visibility(
          visible: valid,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(errorMsg,
                  style: ssFontWN().copyWith(color: scarletRedColor))));
    }

    Widget guaranteedCashPaymentDropdown() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        RichText(
            text: TextSpan(
                text: getLocale("Guaranteed Cash Payment"),
                style: bFontW5().copyWith(fontSize: 18),
                children: <TextSpan>[
              TextSpan(
                  text: "*", style: bFontWN().copyWith(color: scarletRedColor))
            ])),
        Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 5),
            child: Row(children: [
              Container(
                  height: commonTextFieldHeight - 2.5,
                  width: 400,
                  decoration: validateGCP()
                      ? textFieldBoxDecoration()
                      : textFieldScarletRedBoxDecoration(),
                  child: DropdownButtonHideUnderline(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton(
                              value: guaranteedCashPayment.indexWhere(
                                          (element) =>
                                              element.value ==
                                              _selectedGuaranteedCashPayment) !=
                                      -1
                                  ? _selectedGuaranteedCashPayment
                                  : null,
                              style: t2FontW5(),
                              icon: Transform.scale(
                                  scale: 0.8,
                                  child: const Icon(Icons.keyboard_arrow_down)),
                              items: guaranteedCashPayment,
                              onChanged: _firstTimeScreenLoaded == 0
                                  ? null
                                  : (dynamic value) async {
                                      setState(() {
                                        _selectedGuaranteedCashPayment = value;
                                      });
                                      setData();
                                    })))),
            ])),
        errorMessage(!validateGCP(),
            "${getLocale("Please choose one")} ${getLocale("Guaranteed Cash Payment")}"),
        const SizedBox(height: 30)
      ]);
    }

    return BlocBuilder<ChooseProductBloc, ChooseProductState>(
        builder: (context, state) {
      bool showGCP = false;
      bool showSalaryDeduct = true;

      if (state is BasicPlanChosen) {
        _firstTimeScreenLoaded = 1;
        prodCode = state.selectedPlan.productSetup!.prodCode;
        guaranteedCashPayment = getGCPOption(state.selectedPlan);
        if (state.quickQtn.guaranteedCashPayment != null &&
            state.quickQtn.guaranteedCashPayment!.isNotEmpty) {
          _selectedGuaranteedCashPayment = state.quickQtn.guaranteedCashPayment;
        }
        deductSalary = state.quickQtn.deductSalary;
      } else if (state is EditingQuotation &&
          _firstTimeEditingScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;
        _firstTimeEditingScreenLoaded = 1;

        if (state.selectedPlan != null) {
          prodCode = state.selectedPlan!.productSetup!.prodCode;
        }
        guaranteedCashPayment = getGCPOption(state.selectedPlan);
        if (state.quickQuotation.guaranteedCashPayment != null &&
            state.quickQuotation.guaranteedCashPayment!.isNotEmpty) {
          _selectedGuaranteedCashPayment =
              state.quickQuotation.guaranteedCashPayment;
        }
        riderOutputData = state.quickQuotation.riderOutputDataList;
        deductSalary = state.quickQuotation.deductSalary;
        if (state.quickQuotation.productPlanLOB != null) {
          productPlanType =
              convertProductPlan(state.quickQuotation.productPlanLOB);
        }
      } else if (state is RidersChosen) {
        riderOutputData = state.riderOutputDataList;
      } else if (state is RidersDeleted) {
        riderOutputData = state.riderOutputDataList;
      } else if (state is SetProductPlanType) {
        productPlanType = state.productPlanType;
      }

      if (guaranteedCashPayment.isNotEmpty) {
        showGCP = prodCode == "PCHI03" ||
                prodCode == "PCHI04" ||
                prodCode == "PTHI01" ||
                prodCode == "PTHI02"
            ? riderOutputData != null
                ? riderOutputData!
                        .any((element) => element.riderCode == "PCHI03") ||
                    riderOutputData!
                        .any((element) => element.riderCode == "PTHI01")
                : false
            : true;
      }
      //showSalaryDeduct = productPlanType == ProductPlanType.investmentLink;

      return Column(children: [
        GestureDetector(
            onTap: () {
              if (_firstTimeScreenLoaded == 0) {
                showSnackBarError(getLocale("Please select basic plan first"));
              }
            },
            child: Column(children: [
              if (showGCP) guaranteedCashPaymentDropdown(),
              if (showSalaryDeduct) salaryDeduction()
            ]))
      ]);
    });
  }
}

var lookupRateScale = {
  "1": "To Receive GCP",
  "2": "To Deposit GCP with the Company",
  "3": "Utilized For Premium Payments",
  "4": "Maturity Payments"
};
