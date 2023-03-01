import 'package:collection/collection.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ease/src/data/new_business_model/limited_payment_premium_list.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/service/product_setup_helper.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseCalculation extends StatefulWidget {
  final TextEditingController? sumInsuredController;
  final TextEditingController? premiumController;
  final GlobalKey<FormState>? siKey;
  final GlobalKey<FormState>? siPremKey;
  final Status? status;

  const ChooseCalculation(
      {Key? key,
      this.sumInsuredController,
      this.premiumController,
      this.siKey,
      this.siPremKey,
      this.status})
      : super(key: key);

  @override
  ChooseCalculationState createState() => ChooseCalculationState();
}

class ChooseCalculationState extends State<ChooseCalculation> {
  ProductPlan? selectedPlan;
  CalcBasedOn? _calcType;
  String _sumInsuredString = "";
  String _premiumString = "";
  String? _selectedPaymentMode;
  String? _selectedPremiumTerm;
  String? _selectedPlanDetail;
  String? _selectedPolicyTerm;
  double? _multiplier = 0;
  int? _firstTimeScreenLoaded;
  int _firstTimeEditingScreenLoaded = 0; // To run code only once if status == 2
  int? _minPremium = 0;
  int? _minSumAssured = 0;
  int? _maxSumAssured = 0;
  bool isCampaign = false;
  Campaign? campaignSelected;

  @override
  void initState() {
    super.initState();
    _firstTimeScreenLoaded = 0;
    _selectedPaymentMode = "Monthly";
    _selectedPlanDetail = "8P25T";
    _selectedPremiumTerm = "5";
    _selectedPolicyTerm = "5";
    _calcType = CalcBasedOn.sumInsuredPremium;
  }

  List<DropdownMenuItem<String>> paymentMode = [
    (DropdownMenuItem(value: "Monthly", child: Text(getLocale('Monthly')))),
    (DropdownMenuItem(value: "Quarterly", child: Text(getLocale('Quarterly')))),
    (DropdownMenuItem(
        value: "Half Yearly", child: Text(getLocale('Half Yearly')))),
    (DropdownMenuItem(value: "Yearly", child: Text(getLocale('Yearly'))))
  ];

  List<DropdownMenuItem<String>> premiumTerm = [
    (const DropdownMenuItem(value: "5", child: Text('5'))),
    (const DropdownMenuItem(value: "10", child: Text('10'))),
    (const DropdownMenuItem(value: "15", child: Text('15'))),
    (const DropdownMenuItem(value: "20", child: Text('20'))),
    (DropdownMenuItem(value: "Full Term", child: Text(getLocale('Full Term'))))
  ];

  List<DropdownMenuItem<String>> planDetail = [];
  List<DropdownMenuItem<String>> policyTermList = [];
  List<RiderOutputData>? riderOutputData;
  List<ProductPlan?>? selectedRiders;

  String computePaymentMode(String? paymentMode) {
    if (paymentMode == "Monthly") {
      return "1";
    } else if (paymentMode == "Quarterly") {
      return "3";
    } else if (paymentMode == "Half Yearly") {
      return "6";
    } else {
      return "12";
    }
  }

  void mapCalculationText() {
    // This method is to clear text field if user did not pressed enter
    if (widget.status == Status.edit ||
        widget.status == Status.editFromApp ||
        widget.status == Status.editAgeFromApp ||
        widget.status == Status.newFromApplication) {
    } else if (widget.status != Status.edit ||
        widget.status != Status.editFromApp ||
        widget.status != Status.editAgeFromApp ||
        widget.status != Status.newFromApplication) {
      if (widget.sumInsuredController!.text != "") {
        if (_sumInsuredString != widget.sumInsuredController!.text) {
          setState(() {
            widget.sumInsuredController!.text = "";
          });
        }
      }

      if (widget.premiumController!.text != "") {
        if (_premiumString != widget.premiumController!.text) {
          setState(() {
            widget.premiumController!.text = "";
          });
        }
      }
    }
  }

  void setData(String sumInsured, String premAmount) {
    var mode = computePaymentMode(_selectedPaymentMode);
    var sumInsuredAmt = convertCurrencyStringToGeneralNumber(sumInsured);
    var premAmt = convertCurrencyStringToGeneralNumber(premAmount);

    BlocProvider.of<ChooseProductBloc>(context).add(SetSumInsuredAndPrem(
        calcBasedOn: _calcType,
        sumInsuredAmt: int.tryParse(sumInsuredAmt),
        premAmt: int.tryParse(premAmt),
        paymentMode: mode,
        premiumTerm: _selectedPremiumTerm,
        planDetail: _selectedPlanDetail,
        policyTerm: _selectedPolicyTerm));
  }

  List<DropdownMenuItem<String>> getPlanDetail(ProductPlan? selectedPlan) {
    List<DropdownMenuItem<String>> planDetail2 = [];
    if (selectedPlan != null) {
      List<LimitedPaymentPremium>? limitedPaymentPremiumList =
          selectedPlan.limitedPaymentPremiumList;
      List<LimitedPaymentPremium>? campaignPaymentPremiumList = [];
      List<LimitedPaymentPremium>? noncampaignPaymentPremiumList = [];
      if (limitedPaymentPremiumList != null &&
          limitedPaymentPremiumList.isNotEmpty) {
        var campaignList = selectedPlan.campaignList;
        if (campaignList != null && campaignList.isNotEmpty) {
          for (var campaign in campaignList) {
            for (var list in campaign.limitedPaymentPremiumList!) {
              var replace = list.replaceAll("{", "").replaceAll("}", "");
              var splits = replace.split(",");
              var premiumterm = int.parse(splits[0]);
              var termTo = int.parse(splits[1]);

              LimitedPaymentPremium? paymentpremium =
                  limitedPaymentPremiumList.firstWhereOrNull((element) =>
                      element.premiumTerm == premiumterm &&
                      element.termTo == termTo);

              if (paymentpremium != null) {
                campaignPaymentPremiumList.add(paymentpremium);
              }
            }
          }
          for (var element in limitedPaymentPremiumList) {
            if (!campaignPaymentPremiumList.contains(element)) {
              noncampaignPaymentPremiumList.add(element);
            }
          }
        }

        if (selectedPlan.productSetup!.prodCode == "PCHI03" ||
            selectedPlan.productSetup!.prodCode == "PCHI04") {
          limitedPaymentPremiumList = isCampaign &&
                  campaignSelected != null &&
                  campaignSelected!.campaignName == "MaxiPro 3 and 5 Campaign"
              ? campaignPaymentPremiumList
              : noncampaignPaymentPremiumList;
        }

        for (var element in limitedPaymentPremiumList) {
          String value =
              "${element.premiumTerm.toString()}P${element.termFrom.toString()}T";
          planDetail2.add((DropdownMenuItem(value: value, child: Text(value))));
        }
      }
    }
    return planDetail2;
  }

  String? setPolicyTerm(ProductPlan? selectedPlan, anb) {
    String? polTerm;
    if (selectedPlan != null) {
      List<int?> listOfMaturityTerm =
          getTermList(selectedPlan.maturityTermList!, anb);
      polTerm = (listOfMaturityTerm[0]! - anb!).toString();
    }
    return polTerm;
  }

  List<DropdownMenuItem<String>> getPolicyTermList(selectedPlan, gender, age) {
    if (selectedPlan!.productSetup!.prodCode == "PCTA01") {
      age = age + 1;
    }
    List<DropdownMenuItem<String>> policyTermList2 = [];
    if (selectedPlan != null) {
      var policyTerm = selectedPlan.policyTermList;
      if (policyTerm != null && policyTerm.isNotEmpty) {
        for (var element in policyTerm) {
          if (element.clientType == "2") {
            if ((gender == "Male" &&
                    age >= element.minAgeMale &&
                    age <= element.maxAgeMale) ||
                (gender == "Female" &&
                    age >= element.minAgeFemale &&
                    age <= element.maxAgeFemale)) {
              String value = element.termFrom.toString();
              String value2 = element.termTo.toString();
              for (int i = int.parse(value); i <= int.parse(value2); i++) {
                policyTermList2.add((DropdownMenuItem(
                    value: i.toString(), child: Text(i.toString()))));
              }
            }
          }
        }
      }
    }
    return policyTermList2;
  }

  @override
  Widget build(BuildContext context) {
    // mapCalculationText();

    TextFormField sumInsuredAmountsTF() {
      return TextFormField(
          cursorColor: Colors.grey,
          style: bFontW5(),
          enabled: _firstTimeScreenLoaded != 0,
          decoration: textFieldInputDecoration().copyWith(
              prefixText: 'RM ', prefixStyle: bFontW5(), errorMaxLines: 2),
          textInputAction: TextInputAction.send,
          controller: widget.sumInsuredController,
          inputFormatters: [
            CurrencyTextInputFormatter(locale: 'ms', symbol: '')
          ],
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _sumInsuredString = widget.sumInsuredController!.text;
            _premiumString = widget.premiumController!.text;
            if (widget.siPremKey!.currentState!.validate()) {
              setData(_sumInsuredString, _premiumString);
            }
          },
          onEditingComplete: () async {
            FocusScope.of(context).unfocus();
          },
          validator: (value) {
            if (value!.isEmpty) {
              return getLocale('Amount cannot be empty');
            } else {
              value = value.replaceAll(RegExp(','), "");
              var x = value.split('.');
              int y = 0;
              try {
                y = int.parse(x[0]);
              } catch (e) {
                return getLocale('Wrong format');
              }
              if (x[0].isEmpty) {
                return getLocale('Amount cannot be empty');
              } else {
                if (y < _minSumAssured!) {
                  return '${getLocale("Amount is lower than minimum")} ${toRM(_minSumAssured, rm: true)}';
                } else if (y > _maxSumAssured!) {
                  return '${getLocale("Amount exceed")} ${toRM(_maxSumAssured, rm: true)}';
                } else if (_multiplier! % y != 0) {
                  return '${getLocale("The amount must be in")} $_multiplier';
                } else {
                  return null;
                }
              }
            }
          });
    }

    TextFormField premiumAmountTF(String? prodCode) {
      return TextFormField(
          cursorColor: Colors.grey,
          enabled: _firstTimeScreenLoaded != 0,
          style: bFontW5(),
          decoration: textFieldInputDecoration().copyWith(
              prefixText: 'RM ', prefixStyle: bFontW5(), errorMaxLines: 2),
          controller: widget.premiumController,
          inputFormatters: [
            CurrencyTextInputFormatter(locale: 'ms', symbol: '')
          ],
          keyboardType: TextInputType.number,
          onChanged: (data) {
            _sumInsuredString = widget.sumInsuredController!.text;
            _premiumString = widget.premiumController!.text;

            if (widget.siPremKey!.currentState!.validate()) {
              setData(_sumInsuredString, _premiumString);
            }
          },
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
          validator: (value) {
            if (value!.isEmpty) {
              return getLocale('Amount cannot be empty');
            } else {
              //FIRST REMOVE ANY ','
              value = value.replaceAll(RegExp(','), "");
              //REMOVE ANY DECIMAL POINT
              var x = value.split('.');
              int y = 0;
              try {
                y = int.parse(x[0]);
              } catch (e) {
                return getLocale('Wrong format');
              }
              if (x[0].isEmpty) {
                return getLocale('Amount cannot be empty');
              } else {
                if (y < _minPremium!) {
                  return '${getLocale('Amount is lower than minimum')} ${toRM(_minPremium, rm: true)}';
                } else {
                  return null;
                }
              }
            }
          });
    }

    Widget paymentModeDropdown() {
      return Container(
          height: commonTextFieldHeight - 2.5,
          width: MediaQuery.of(context).size.width,
          decoration: textFieldBoxDecoration(),
          child: DropdownButtonHideUnderline(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton(
                      value: _selectedPaymentMode,
                      style: t2FontW5(),
                      icon: Transform.scale(
                          scale: 0.8,
                          child: const Icon(Icons.keyboard_arrow_down)),
                      items: paymentMode,
                      onChanged: _firstTimeScreenLoaded == 0
                          ? null
                          : (dynamic value) async {
                              setState(() {
                                _selectedPaymentMode = value;
                                _minSumAssured =
                                    selectedPlan!.sumAssuredList![0].minSA;
                                _maxSumAssured =
                                    selectedPlan!.sumAssuredList![0].maxSA;
                                _multiplier =
                                    selectedPlan!.sumAssuredList![0].multiplier;
                                _minPremium = getMinPremium(
                                    selectedPaymentMode: _selectedPaymentMode,
                                    productPlan: selectedPlan);

                                if (widget.siKey!.currentState != null) {
                                  widget.siKey!.currentState!.validate();
                                }
                                widget.siPremKey!.currentState!.validate();

                                _sumInsuredString =
                                    widget.sumInsuredController!.text;
                                _premiumString = widget.premiumController!.text;
                                setData(_sumInsuredString, _premiumString);
                              });
                              FocusScope.of(context).unfocus();
                            }))));
    }

    Widget premiumTermDropdown() {
      return Container(
          height: commonTextFieldHeight - 2.5,
          width: MediaQuery.of(context).size.width,
          decoration: textFieldBoxDecoration(),
          child: DropdownButtonHideUnderline(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton(
                      value: _selectedPremiumTerm,
                      style: t2FontW5(),
                      icon: Transform.scale(
                          scale: 0.8,
                          child: const Icon(Icons.keyboard_arrow_down)),
                      items: premiumTerm,
                      onChanged: _firstTimeScreenLoaded == 0
                          ? null
                          : (dynamic value) async {
                              setState(() {
                                _selectedPremiumTerm = value;
                                _sumInsuredString =
                                    widget.sumInsuredController!.text;
                                _premiumString = widget.premiumController!.text;
                                setData(_sumInsuredString, _premiumString);
                              });
                              FocusScope.of(context).unfocus();
                            }))));
    }

    Widget policyTermDropdown() {
      return Container(
          height: commonTextFieldHeight - 2.5,
          width: MediaQuery.of(context).size.width,
          decoration: textFieldBoxDecoration(),
          child: DropdownButtonHideUnderline(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton(
                      value: planDetail.indexWhere((element) =>
                                  element.value == _selectedPlanDetail) !=
                              -1
                          ? _selectedPlanDetail
                          : null,
                      style: t2FontW5(),
                      icon: Transform.scale(
                          scale: 0.8,
                          child: const Icon(Icons.keyboard_arrow_down)),
                      items: planDetail,
                      onChanged: _firstTimeScreenLoaded == 0
                          ? null
                          : (dynamic value) async {
                              setState(() {
                                _selectedPlanDetail = value;
                                _sumInsuredString =
                                    widget.sumInsuredController!.text;
                                _premiumString = widget.premiumController!.text;
                                setData(_sumInsuredString, _premiumString);
                              });
                              FocusScope.of(context).unfocus();
                            }))));
    }

    Widget policyTermListDropdown() {
      return Container(
          height: commonTextFieldHeight - 2.5,
          width: MediaQuery.of(context).size.width,
          decoration: textFieldBoxDecoration(),
          child: DropdownButtonHideUnderline(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton(
                      value: policyTermList.indexWhere((element) =>
                                  element.value == _selectedPolicyTerm) !=
                              -1
                          ? _selectedPolicyTerm
                          : null,
                      style: t2FontW5(),
                      icon: Transform.scale(
                          scale: 0.8,
                          child: const Icon(Icons.keyboard_arrow_down)),
                      items: policyTermList,
                      onChanged: _firstTimeScreenLoaded == 0
                          ? null
                          : (dynamic value) async {
                              setState(() {
                                _selectedPolicyTerm = value;
                                _sumInsuredString =
                                    widget.sumInsuredController!.text;
                                _premiumString = widget.premiumController!.text;
                                setData(_sumInsuredString, _premiumString);
                              });
                              FocusScope.of(context).unfocus();
                            }))));
    }

    //THIS IS FOR SUM INSURED CALCULATION
    Widget sumInsuredCalcField() {
      return Form(
          key: widget.siKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(getLocale("Amount"),
                              style: bFontW5().copyWith(fontSize: 18))),
                      sumInsuredAmountsTF()
                    ])),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Text(getLocale("Payment Frequency"),
                                      style: bFontW5().copyWith(fontSize: 18))),
                              paymentModeDropdown()
                            ])))
              ])));
    }

    //THIS IS FOR PREMIUM CALCULATION
    Widget premiumCalcField() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(getLocale("Frequency"),
                          style: bFontW5().copyWith(fontSize: 18))),
                  paymentModeDropdown()
                ])),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Text(getLocale("Amount"),
                                  style: bFontW5().copyWith(fontSize: 18))),
                          premiumAmountTF(selectedPlan != null
                              ? selectedPlan!.productSetup!.prodCode
                              : "null")
                        ])))
          ]));
    }

    //THIS IS FOR SUM INSURED CALCULATION
    Form sumInsuredPremiumCalcField(String? prodCode) {
      return Form(
          key: widget.siPremKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Text(getLocale("Payment Frequency"),
                                      style: bFontW5().copyWith(fontSize: 18))),
                              paymentModeDropdown()
                            ]))),
                if (prodCode == "PCJI01" ||
                    prodCode == "PCJI02" ||
                    prodCode == "PTJI01")
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Text(getLocale("Premium Term"),
                                        style:
                                            bFontW5().copyWith(fontSize: 18))),
                                premiumTermDropdown()
                              ]))),
                Visibility(
                    visible: prodCode == "PCHI03" ||
                        prodCode == "PCHI04" ||
                        prodCode == "PTHI01" ||
                        prodCode == "PTHI02",
                    child: Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Text(
                                          getLocale("Policy Term",
                                              entity: true),
                                          style: bFontW5()
                                              .copyWith(fontSize: 18))),
                                  policyTermDropdown()
                                ])))),
                Visibility(
                    visible: prodCode == "PCTA01" || prodCode == "PCEL01",
                    child: Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      child: Text(
                                          getLocale("Policy Term",
                                              entity: true),
                                          style: bFontW5()
                                              .copyWith(fontSize: 18))),
                                  policyTermListDropdown()
                                ])))),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: Text(getLocale("Sum Insured Amount"),
                                      style: bFontW5().copyWith(fontSize: 18))),
                              sumInsuredAmountsTF(),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: Text(
                                      "${getLocale("Minimum Sum Insured:", entity: true)} ${toRM(_minSumAssured, rm: true)}",
                                      style: ssFontWN()))
                            ]))),
                prodCode == "PCWA01" ||
                        prodCode == "PCTA01" ||
                        prodCode == "PCEE01" ||
                        prodCode == "PCEL01" ||
                        prodCode == "PTJI01"
                    ? Container()
                    : Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                    getLocale("Premium Amount", entity: true),
                                    style: bFontW5().copyWith(fontSize: 18))),
                            premiumAmountTF(selectedPlan != null
                                ? selectedPlan!.productSetup!.prodCode
                                : "null"),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(
                                    "${getLocale("Minimum Premium:", entity: true)} ${toRM(_minPremium, rm: true)}",
                                    style: ssFontWN()))
                          ]))
              ])));
    }

    return BlocBuilder<ChooseProductBloc, ChooseProductState>(
        builder: (context, state) {
      if (state is CampaignSelected) {
        isCampaign = state.isCampaign;
        campaignSelected = state.campaign;
        planDetail = getPlanDetail(selectedPlan);
      } else if (state is BasicPlanChosen) {
        _firstTimeScreenLoaded = 1;
        selectedPlan = state.selectedPlan;
        planDetail = getPlanDetail(selectedPlan);
        if ((selectedPlan!.productSetup!.prodCode == "PCHI03" ||
                selectedPlan!.productSetup!.prodCode == "PCHI04" ||
                selectedPlan!.productSetup!.prodCode == "PTHI01" ||
                selectedPlan!.productSetup!.prodCode == "PTHI02") &&
            planDetail.isNotEmpty &&
            planDetail.indexWhere(
                    (element) => element.value == _selectedPlanDetail) <=
                -1) {
          _selectedPlanDetail = planDetail[0].value;
        }
        policyTermList =
            getPolicyTermList(selectedPlan, state.gender, state.age);
        if (policyTermList.isNotEmpty &&
            policyTermList.indexWhere(
                    (element) => element.value == _selectedPolicyTerm) <=
                -1) {
          _selectedPolicyTerm = policyTermList[0].value;
        }

        //check the purpose
        _minSumAssured = selectedPlan!.sumAssuredList![0].minSA;
        _maxSumAssured = selectedPlan!.sumAssuredList![0].maxSA;
        _multiplier = selectedPlan!.sumAssuredList![0].multiplier;
        _minPremium = getMinPremium(
            selectedPaymentMode: _selectedPaymentMode,
            productPlan: selectedPlan);

        if (widget.siKey!.currentState != null) {
          widget.siKey!.currentState!.validate();
        }
        if (widget.siPremKey!.currentState != null) {
          widget.siPremKey!.currentState!.validate();
        }

        _sumInsuredString = widget.sumInsuredController!.text;
        _premiumString = widget.premiumController!.text;
        setData(_sumInsuredString, _premiumString);
      } else if (state is EditingQuotation &&
          _firstTimeEditingScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;
        _firstTimeEditingScreenLoaded = 1;

        var mode = state.quickQuotation.paymentMode;

        if (isNumeric(mode)) {
          _selectedPaymentMode = convertPaymentMode(mode);
        } else {
          _selectedPaymentMode = mode;
        }

        selectedPlan = state.selectedPlan;
        isCampaign = state.quickQuotation.isCampaign;

        planDetail = getPlanDetail(selectedPlan);
        _selectedPlanDetail = state.quickQuotation.planDetail;
        if (planDetail.isNotEmpty &&
            planDetail.indexWhere(
                    (element) => element.value == _selectedPlanDetail) <=
                -1) {
          _selectedPlanDetail = planDetail[0].value;
        }
        policyTermList =
            getPolicyTermList(selectedPlan, state.gender, state.age);
        _selectedPolicyTerm = state.quickQuotation.policyTerm;
        if (policyTermList.isNotEmpty &&
            policyTermList.indexWhere(
                    (element) => element.value == _selectedPolicyTerm) <=
                -1) {
          _selectedPolicyTerm = policyTermList[0].value;
        }

        _minSumAssured = selectedPlan!.sumAssuredList![0].minSA;
        _maxSumAssured = selectedPlan!.sumAssuredList![0].maxSA;
        _multiplier = selectedPlan!.sumAssuredList![0].multiplier;
        _minPremium = getMinPremium(
            selectedPaymentMode: _selectedPaymentMode,
            productPlan: selectedPlan);

        if (state.quickQuotation.sumInsuredAmt != null) {
          widget.sumInsuredController!.text =
              toRM(state.quickQuotation.sumInsuredAmt!);
        }
        if (state.quickQuotation.premAmt != null) {
          widget.premiumController!.text = toRM(state.quickQuotation.premAmt!);
        }
        if (state.quickQuotation.productPlanCode == "PCJI02") {
          if (state.quickQuotation.premiumTerm != null &&
              state.quickQuotation.premiumTerm != "0" &&
              state.quickQuotation.premiumTerm != "null") {
            var term = premiumTerm.firstWhereOrNull(
                (element) => element.value == state.quickQuotation.premiumTerm);
            if (term != null) {
              _selectedPremiumTerm = term.value;
            } else {
              _selectedPremiumTerm = premiumTerm
                  .firstWhere((element) => element.value == "Full Term")
                  .value;
            }
          } else {
            _selectedPremiumTerm = "5";
          }
        }
        riderOutputData = state.quickQuotation.riderOutputDataList;
        _sumInsuredString = widget.sumInsuredController!.text;
        _premiumString = widget.premiumController!.text;
        setData(_sumInsuredString, _premiumString);
      } else if (state is RidersChosen) {
        riderOutputData = state.riderOutputDataList;
      }

      return Column(children: [
        // calcBasedOn(),
        GestureDetector(
            onTap: () {
              if (_firstTimeScreenLoaded == 0) {
                showSnackBarError(getLocale("Please select basic plan first"));
              }
            },
            child: Column(children: [
              AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: _calcType == CalcBasedOn.sumInsured
                      ? sumInsuredCalcField()
                      : _calcType == CalcBasedOn.premium
                          ? premiumCalcField()
                          : sumInsuredPremiumCalcField(selectedPlan != null
                              ? selectedPlan!.productSetup!.prodCode
                              : "null"))
            ]))
      ]);
    });
  }
}
