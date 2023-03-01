import 'package:ease/src/data/new_business_model/fund_output_data.dart';
import 'package:ease/src/data/new_business_model/funds.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseFunds extends StatefulWidget {
  final GlobalKey<FormState> fundFormKey;

  const ChooseFunds(this.fundFormKey, {Key? key}) : super(key: key);
  @override
  ChooseFundsState createState() => ChooseFundsState();
}

class ChooseFundsState extends State<ChooseFunds> {
  bool isFunds = false;
  int _firstTimeScreenLoaded = 0;
  bool hideRiskDisclosure = true;
  Map<String?, TextEditingController> textEditingControllers = {};

  List<Funds> filteredFunds = [];
  List<Funds> selectedFunds = [];
  List<FundOutputData>? fundOutputData = [];

  double? totalAllocation;

  @override
  void initState() {
    super.initState();
  }

  void getController() {
    for (var str in filteredFunds) {
      var textEditingController = TextEditingController();
      textEditingControllers.putIfAbsent(
          str.fundCode, () => textEditingController);
    }
  }

  Widget bulletPoint(String text) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.only(right: 18), child: Text("\u2022")),
      Expanded(
          child: Text(text, style: bFontWN().copyWith(color: greyTextColor)))
    ]);
  }

  Column riskParagraph(String title, String body) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: t2FontWB()),
      Text(body, style: bFontWN().copyWith(color: greyTextColor))
    ]);
  }

  Widget riskDisclosure() {
    return Container(
        decoration: textFieldBoxDecoration()
            .copyWith(color: creamColor, border: Border.all(color: creamColor)),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getLocale("Risk Disclosure"), style: t2FontW5()),
            TextButton(
                onPressed: () {
                  setState(() {
                    hideRiskDisclosure = !hideRiskDisclosure;
                  });
                },
                child: Row(children: [
                  Text(
                      !hideRiskDisclosure
                          ? getLocale("Hide")
                          : getLocale("View all"),
                      style: bFontWN().copyWith(color: cyanColor)),
                  Icon(
                      !hideRiskDisclosure
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: cyanColor)
                ]))
          ]),
          AnimatedContainer(
              curve: Curves.easeInOutQuart,
              duration: const Duration(seconds: 1),
              height: hideRiskDisclosure ? 0 : 1300,
              child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        riskParagraph(
                            getLocale("Market Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund, due to factors that affect the overall performance of financial markets. These factors could be the current situation or future outlook, and could be both local and foreign. These factors could include the economy, politics, government bond yields, credit spreads on corporate bonds, country credit rating, stock market levels, foreign exchange rates, and commodity prices.\n\nThe investment manager reduces the risk to the fund by purchasing price protection (hedges), investing in a wide range of asset classes or by increasing exposure to cash. The policyholder can reduce their exposure to market risk by choosing funds with a higher proportion of assets in cash.\n")),
                        riskParagraph(
                            getLocale("Credit (including Default) Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund invested in cash, bonds or debt, due to factors that delay or restructure a scheduled payment from the counterparty. These factors could include bankruptcy of the counterparty. The investment manager reduces the risk to the fund by purchasing credit risk protection (hedges), selecting assets of counterparties with a lower credit risk, or selecting assets of many unrelated counterparties. The policyholder can reduce their exposure to credit risk by choosing funds which have lower exposure to cash, bonds or debt; or those funds with lower exposure to banks or issuers with a higher credit risk.\n")),
                        riskParagraph(
                            getLocale("Liquidity Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund, due to factors that constrain the quick sale of an asset of the fund. These factors could include a lack of buyers in the market, or the availability of liquidity to the buyers.\n\nThe investment manager reduces the risk to the fund by selecting liquid assets, including assets for which there are regular trades.\n\nThe policyholder can reduce their exposure to liquidity risk by choosing funds with higher exposure to cash or assets with regular trades.\n")),
                        riskParagraph(
                            getLocale("Concentration Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund, due to an excessive exposure to a single or similar assets, or markets. The investment manager reduces the risk to the fund, by investing in a wide range of assets. The policyholder can reduce their exposure to concentration risk by choosing funds holding a wide range of assets, covering different asset classes, market sectors, and counterparties.\n")),
                        riskParagraph(
                            getLocale("Operational Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund due to inadequate or failed processes, people and systems or external events. Some examples of operational incidents include:")),
                        bulletPoint(getLocale(
                            "misappropriation of investments, due to fraud, an illegal act, malicious intent, spite, terrorism;")),
                        bulletPoint(getLocale(
                            "disruption or failure of IT systems and infrastructure, which may be used for monitoring, execution, administration;")),
                        bulletPoint(getLocale(
                            "inaccurate calculations due to data quality or errors, methodology flaws, miscalculations; and")),
                        bulletPoint(
                            getLocale("inaccurate or incomplete controls.")),
                        Text(
                            getLocale(
                                "The investment manager reduces the risk by segregating the duties and functions of individuals; setting disaster recovery and business continuation processes; performing independent regular checks; and third party vendor selection and ongoing assessment processes.\n"),
                            style: bFontWN().copyWith(color: greyTextColor)),
                        riskParagraph(
                            getLocale("Shariah Non-Compliance Risk"),
                            getLocale(
                                "The risk of losses in the value of a fund due to factors arising due to the non-compliance of specific assets with Shariah rules and principles. The factors arise due to the mandatory charitable donation of income arising on a non-compliant asset, or illiquidity arising due to an excess of sellers in the market. The Shariah rules and principles are determined by the Shariah Committee or other regulatory council. The investment manager reduces the risk by monitoring the investments held against an approved list of Shariah compliant securities.")),
                        const SizedBox(height: 20)
                      ])))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    getController();

    void getFundData(List<Funds> selectedFunds) {
      // Get list of rider code inside riderOuputData;
      List<String?> fundCode = [];

      for (var element in fundOutputData!) {
        if (!fundCode.contains(element.fundName)) {
          fundCode.add(element.fundCode);
        }
      }

      for (int i = 0; i < selectedFunds.length; i++) {
        if (!fundCode.contains(selectedFunds[i].fundCode)) {
          FundOutputData ffundOutputData = FundOutputData(
              fundCode: selectedFunds[i].fundCode,
              fundName: selectedFunds[i].fundDescription,
              fundRiskLevel: selectedFunds[i].riskLevel,
              fundRiskType: selectedFunds[i].riskType,
              fundOption: selectedFunds[i].fundOption,
              fundAlloc: "");

          fundOutputData!.add(ffundOutputData);
        }
      }
    }

    void deleteFundData(Funds key) {
      for (int i = 0; i < fundOutputData!.length; i++) {
        if (fundOutputData![i].fundCode == key.fundCode) {
          fundOutputData!.removeAt(i);
        }
      }
    }

    int getFundsIndex(Funds key, List<Funds> funds) {
      return selectedFunds.indexWhere(
          (element) => element.fundDescription == key.fundDescription);
    }

    Widget fundTypex(ChooseProductState state) {
      filteredFunds.sort((a, b) {
        int compare = a.riskLevel!.compareTo(b.riskLevel!);
        if (compare != 0) return compare;
        return a.fundDescription!
            .toUpperCase()
            .compareTo(b.fundDescription!.toUpperCase());
      });

      return Form(
          key: widget.fundFormKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                  children: filteredFunds.map((Funds key) {
                bool selected = false;
                int? indexFundData;

                try {
                  var indexFundData = fundOutputData!.indexWhere(
                      (element) => element.fundCode == key.fundCode);
                  if (indexFundData != -1) {
                    selected = true;
                    if (state is! FundsChosen &&
                        (fundOutputData![indexFundData].fundAlloc != null ||
                            fundOutputData![indexFundData].fundAlloc != "")) {
                      textEditingControllers[key.fundCode]!.text =
                          fundOutputData![indexFundData].fundAlloc!;
                    }
                  }
                } catch (e) {
                  selected = false;
                  indexFundData = null;
                }

                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Expanded(
                          flex: 4,
                          child: GestureDetector(
                              onTap: () async {
                                var index = getFundsIndex(key, selectedFunds);

                                setState(() {
                                  if (index != -1) {
                                    selectedFunds.removeAt(index);
                                    deleteFundData(key);

                                    textEditingControllers[key.fundCode]!.text =
                                        "";

                                    BlocProvider.of<ChooseProductBloc>(context)
                                        .add(DeleteFunds(
                                            outputFundData: fundOutputData));
                                  } else {
                                    selectedFunds.add(key);
                                  }
                                });
                                getFundData(selectedFunds);

                                // BlocProvider.of<ChooseProductBloc>(context).add(
                                //     AddFunds(
                                //         fundsData: selectedFunds,
                                //         outputFundData: fundOutputData));
                              },
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  constraints:
                                      const BoxConstraints(minHeight: 70),
                                  decoration: textFieldBoxDecoration().copyWith(
                                      border: Border.all(
                                          width: 1, color: greyBorderTFColor)),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Row(children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: selectedFunds
                                                              .contains(key) ||
                                                          selected
                                                      ? const Image(
                                                          width: 25,
                                                          height: 25,
                                                          image: AssetImage(
                                                              'assets/images/check_circle.png'))
                                                      : Container(
                                                          width: 25,
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)))),
                                              Expanded(
                                                  child: Text(
                                                      key.fundDescription!,
                                                      style: bFontW5()))
                                            ])),
                                        Expanded(
                                            flex: 1,
                                            child: Text(key.riskLevel!,
                                                textAlign: TextAlign.center,
                                                style: bFontW5())),
                                        Expanded(
                                            flex: 2,
                                            child: Text(key.riskType!,
                                                style: bFontW5()))
                                      ])))),
                      Expanded(
                          flex: 1,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextFormField(
                                  controller:
                                      textEditingControllers[key.fundCode],
                                  enabled:
                                      selectedFunds.contains(key) || selected,
                                  cursorColor: Colors.grey,
                                  style: t2FontWB(),
                                  decoration:
                                      selectedFunds.contains(key) || selected
                                          ? (selected == true &&
                                                  indexFundData != null &&
                                                  fundOutputData![indexFundData]
                                                          .fundAlloc ==
                                                      ""
                                              ? textFieldInputDecoration()
                                                  .copyWith(suffixText: "%")
                                              : textFieldInputDecoration()
                                                  .copyWith(suffixText: "%"))
                                          : disabledTextFieldInputDecoration(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ], // Only numbers
                                  onChanged: (data) {
                                    var indexFundData = fundOutputData!
                                        .indexWhere((element) =>
                                            element.fundCode == key.fundCode);
                                    fundOutputData![indexFundData].fundAlloc =
                                        data;

                                    BlocProvider.of<ChooseProductBloc>(context)
                                        .add(SetFunds(
                                            outputFundData: fundOutputData));
                                  },
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).unfocus();

                                    // final codes = key.fundDescription;
                                    // final vpmsField = vpFundMapMatrix[codes];

                                    // var indexFundData = fundOutputData.indexWhere(
                                    //     (element) =>
                                    //         element.fundCode == key.fundCode);
                                    // fundOutputData[indexFundData].fundAlloc = data;

                                    // print("SETTING FUNDS");

                                    // BlocProvider.of<ChooseProductBloc>(context)
                                    //   ..add(SetFunds(
                                    //     input: vpmsField,
                                    //     data: data,
                                    //     fundsData: selectedFunds,
                                    //     outputFundData: fundOutputData,
                                    //   ));
                                  },
                                  validator: (value) {
                                    // double total = 0;
                                    // fundOutputData.forEach((element) {
                                    //   total =
                                    //       total + double.parse(element.fundAlloc);
                                    // });
                                    if (selectedFunds.contains(key)) {
                                      int x = isNumeric(value)
                                          ? int.parse(value!)
                                          : 0;
                                      if (value!.isEmpty || value == "") {
                                        return getLocale(
                                            'Amount cannot be empty');
                                      } else if (x < 10.00 || x > 100.00) {
                                        return getLocale(
                                            'Please enter value from 10% to 100%');
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return null;
                                    }
                                  })))
                    ]));
              }).toList())));
    }

    int fundheight = 240 + filteredFunds.length * 82;
    double height = filteredFunds.isNotEmpty ? fundheight.toDouble() : 50;
    if (!hideRiskDisclosure) {
      height = (fundheight + 1300).toDouble();
    }

    return BlocListener<ChooseProductBloc, ChooseProductState>(
        listener: (context, state) {
      if (state is BasicPlanChosen) {
        //If x == 1, means user have choose basic plan.
        _firstTimeScreenLoaded = 1;
        filteredFunds = state.selectedPlan.fundList!
            .where((e) => e.fundCode != "JFT")
            .toList();
        fundOutputData = state.quickQtn.fundOutputDataList ?? [];
        if (fundOutputData != null && fundOutputData!.isNotEmpty) {
          isFunds = true;
          for (var element in fundOutputData!) {
            Funds fund = Funds(
                fundCode: element.fundCode, fundDescription: element.fundName);
            selectedFunds.add(fund);
          }

          int ffundheight = 240 + filteredFunds.length * 82;
          height = filteredFunds.isNotEmpty ? ffundheight.toDouble() : 50;
          if (!hideRiskDisclosure) {
            height = (ffundheight + 1300).toDouble();
          }
        }
      } else if (state is QuotationDuplicated) {
        _firstTimeScreenLoaded = 2;
      } else if (state is EditingQuotation && _firstTimeScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;
        if (state.selectedPlan != null) {
          filteredFunds = state.selectedPlan!.fundList!
              .where((e) => e.fundCode != "JFT")
              .toList();
        }
        fundOutputData = state.quickQuotation.fundOutputDataList;
        if (fundOutputData!.isNotEmpty) {
          isFunds = true;
          for (var element in fundOutputData!) {
            Funds fund = Funds(
                fundCode: element.fundCode, fundDescription: element.fundName);
            selectedFunds.add(fund);
          }

          int ffundheight = 240 + filteredFunds.length * 82;
          height = filteredFunds.isNotEmpty ? ffundheight.toDouble() : 50;
          if (!hideRiskDisclosure) {
            height = (ffundheight + 1300).toDouble();
          }
        }
      }
    }, child: BlocBuilder<ChooseProductBloc, ChooseProductState>(
            builder: (context, state) {
      if (filteredFunds.isEmpty) {
        return Container();
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(thickness: 4),
        GestureDetector(
            onTap: () {
              if (_firstTimeScreenLoaded == 0) {
                showSnackBarError(getLocale("Please select basic plan first"));
              } else {
                setState(() {
                  isFunds = !isFunds;
                });
              }
            },
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
                child: Row(children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: isFunds
                          ? const Image(
                              width: 32,
                              height: 32,
                              image: AssetImage(
                                  'assets/images/check_circle_black.png'))
                          : Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey)))),
                  Expanded(
                      child: Text(getLocale("Funds"),
                          style: tFontW5()
                              .copyWith(fontWeight: FontWeight.normal)))
                ]))),
        AnimatedContainer(
            curve: Curves.easeInOutQuart,
            duration: const Duration(seconds: 1),
            height: isFunds ? height : 0,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: height,
                padding: const EdgeInsets.only(left: 96, right: 45),
                child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: filteredFunds.isNotEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 25),
                                    child: Text(
                                        getLocale(
                                            "You can choose multiple fund below"),
                                        style: bFontWN())),
                                Row(children: [
                                  Expanded(
                                      flex: 4,
                                      child: Row(children: [
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                getLocale("Fund Description"),
                                                style: bFontWN().copyWith(
                                                    color: greyTextColor))),
                                        Expanded(
                                            flex: 1,
                                            child: Text(getLocale("Risk Level"),
                                                textAlign: TextAlign.center,
                                                style: bFontWN().copyWith(
                                                    color: greyTextColor))),
                                        Expanded(
                                            flex: 2,
                                            child: Text(getLocale("Risk Title"),
                                                style: bFontWN().copyWith(
                                                    color: greyTextColor)))
                                      ])),
                                  Expanded(
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Text(
                                              getLocale(
                                                  "Investment Allocation"),
                                              style: bFontWN().copyWith(
                                                  color: greyTextColor))))
                                ]),
                                fundTypex(state),
                                riskDisclosure()
                              ])
                        : Center(
                            child: Text(getLocale("- No funds -"),
                                style: bFontWN())))))
      ]);
    }));
  }
}
