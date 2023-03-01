import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_mapping.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_prod_fieldlist.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/qtn_form_widget.dart';
import 'package:ease/src/service/product_setup_helper.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseRiders extends StatefulWidget {
  final GlobalKey<FormState> riderFormKey;

  const ChooseRiders({Key? key, required this.riderFormKey}) : super(key: key);
  @override
  ChooseRidersState createState() => ChooseRidersState();
}

class ChooseRidersState extends State<ChooseRiders> {
  int _firstTimeScreenLoaded = 0;

  ProductPlan? basicPlan;

  bool isModalRiderLoading = false;
  bool isSupplementaryRiders = false;

  String? _currentSA; // Temporary hold sum insured value for sa with dropdown
  String? selectedRiderPlan;

  VpmsMapping? vpmsMappingFile;

  List<String> inputValueOption = [];
  List<String> coverageTerm = [];

  List<ProductPlan> eligibleRiders = [];
  List<ProductPlan?> selectedRiders = [];
  List<RiderOutputData>? riderOutputData = [];

  final Map<String?, TextEditingController> _siTextEditingControllers = {};
  final Map<String?, TextEditingController> _policyTermTextEditingControllers =
      {};

  List vpRiderPlanMatrix = [
    {"name": "Plan1", "value": "Plan 1"},
    {"name": "Plan2", "value": "Plan 2"},
    {"name": "Plan3", "value": "Plan 3"},
    {"name": "Plan4", "value": "Plan 4"},
    {"name": "Plan5", "value": "Plan 5"}
  ];

  List vpRiderPlanMatrix2 = [
    {"name": "Plan 1", "value": "Plan 1"},
    {"name": "Plan 2", "value": "Plan 2"},
    {"name": "Plan 3", "value": "Plan 3"},
    {"name": "Plan 4", "value": "Plan 4"},
    {"name": "Plan 5", "value": "Plan 5"}
  ];

  List hcbunits = [];
  List cmblist = [];

  int? liAnb;
  int? sustainabilityOptionVal;
  // List<int?> listOfMaturityTerm = [];

  String? liDob;

  @override
  void initState() {
    super.initState();
    for (int i = 3; i <= 10; i++) {
      hcbunits.add({"name": "$i units", "value": i.toString()});
    }
    for (int i = 1; i <= 3; i++) {
      cmblist.add({"name": "Benefit $i", "value": i.toString()});
    }
  }

  void getRiderData(List<ProductPlan?> riders) {
    // Get list of rider code inside riderOuputData;
    List<String?> riderCodes = [];
    List<String?> selectedRiderCodes = [];
    List<int> toRemove = [];

    for (var element in riderOutputData!) {
      if (!riderCodes.contains(element.riderCode)) {
        riderCodes.add(element.riderCode);
      }
    }

    for (int i = 0; i < riders.length; i++) {
      if (!riderCodes.contains(riders[i]!.productSetup!.prodCode)) {
        RiderOutputData riderData = RiderOutputData(
            riderCode: riders[i]!.productSetup!.prodCode,
            riderName: riders[i]!.productSetup!.prodName,
            isUnitBasedProd: riders[i]!.productSetup!.isUnitBasedProd);
        riderOutputData!.add(riderData);
      }
      if (!selectedRiderCodes.contains(riders[i]!.productSetup!.prodCode)) {
        selectedRiderCodes.add(riders[i]!.productSetup!.prodCode);
      }
    }
    // check and remove rider
    for (int i = 0; i < riderOutputData!.length; i++) {
      if (!selectedRiderCodes.contains(riderOutputData![i].riderCode)) {
        toRemove.add(i);
      }
    }
    toRemove.sort((a, b) => b.compareTo(a));

    for (var element in toRemove) {
      _siTextEditingControllers[riderOutputData![element].riderCode]?.text = "";
      riderOutputData!.removeAt(element);
    }
  }

  void deleteRiderData(ProductPlan? key) {
    for (int i = 0; i < riderOutputData!.length; i++) {
      if (riderOutputData![i].riderCode == key!.productSetup!.prodCode) {
        riderOutputData!.removeAt(i);
      }
    }
  }

  void getController() {
    for (var str in selectedRiders) {
      var textEditingController = TextEditingController();
      var textEditingController2 = TextEditingController();
      _siTextEditingControllers.putIfAbsent(
          str!.productSetup!.prodCode, () => textEditingController);
      _policyTermTextEditingControllers.putIfAbsent(
          str.productSetup!.prodCode, () => textEditingController2);
    }
  }

  @override
  Widget build(BuildContext context) {
    getController();

    Widget riderProdName(String prodName) {
      return Expanded(
          flex: 5,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 70,
              decoration: textFieldBoxDecoration().copyWith(
                  border: Border.all(width: 1, color: greyBorderTFColor)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(prodName,
                            overflow: TextOverflow.ellipsis, style: bFontW5())),
                    // Icon(Icons.info, size: 28, color: cyanColor)
                  ])));
    }

    Widget sumInsuredTextField(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 3,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextFormField(
                  enabled: riderData.inputSa != "" || riderData.isUnit,
                  cursorColor: Colors.grey,
                  controller: _siTextEditingControllers[prodCode],
                  style: textFieldStyle(),
                  decoration: riderData.inputSa == "" && !riderData.isUnit
                      ? disabledTextFieldInputDecoration()
                      : riderOutputData![index].requiredSA == true &&
                              (riderOutputData![index].riderSA == "" ||
                                  riderOutputData![index].riderSA == null)
                          ? errorTextFieldInputDecoration().copyWith(
                              prefixText: riderData.isUnit ? null : 'RM ',
                              prefixStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500))
                          : textFieldInputDecoration().copyWith(
                              prefixText: riderData.isUnit ? null : 'RM ',
                              prefixStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                  keyboardType: TextInputType.number,
                  inputFormatters: !riderData.isUnit
                      ? [CurrencyTextInputFormatter(locale: 'ms', symbol: '')]
                      : [],
                  onChanged: (value) {
                    if (riderData.isUnit) {
                      riderOutputData![index].riderSA = value;
                    } else {
                      var data = convertCurrencyStringToGeneralNumber(value);
                      riderOutputData![index].riderSA = data;
                    }
                    BlocProvider.of<ChooseProductBloc>(context)
                        .add(SetRidersData(ridersOutputData: riderOutputData));
                    setState(() {});
                  },
                  onFieldSubmitted: (data) async {
                    FocusScope.of(context).unfocus();
                  },
                  onEditingComplete: () {},
                  validator: (value) {
                    //FIRST REMOVE ANY ','
                    value = value!.replaceAll(RegExp(','), "");
                    //REMOVE ANY DECIMAL POINT
                    var x = value.split('.');

                    if (riderData.inputSa == "") {
                      return null;
                    } else {
                      if (x[0].isEmpty) {
                        return getLocale('Amount cannot be empty');
                      } else {
                        if (double.parse(value) <= 0) {
                          return getLocale(
                              'Amount cannot be less than RM 0.00');
                        }
                        return null;
                      }
                    }
                  })));
    }

    Widget riderUnitDropdown(String? prodCode, VpmsProdFieldsList riderData) {
      int i = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 3,
          child: Container(
              margin: const EdgeInsets.only(left: 20),
              height: commonTextFieldHeight,
              decoration: textFieldBoxDecoration(),
              child: DropdownButtonHideUnderline(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton(
                          items: riderData.isUnit
                              ? hcbunits.map((map) {
                                  return DropdownMenuItem(
                                      value: map["value"],
                                      child: Text(map["name"]));
                                }).toList()
                              : null,
                          value: riderOutputData![i].tempSA,
                          style: t2FontW5(),
                          icon: Transform.scale(
                              scale: 0.8,
                              child: const Icon(Icons.keyboard_arrow_down)),
                          onChanged: (dynamic data) async {
                            FocusScope.of(context).unfocus();

                            setState(() {
                              riderOutputData![i].tempSA = riderOutputData![i]
                                  .riderSA = _currentSA = data;
                            });

                            BlocProvider.of<ChooseProductBloc>(context).add(
                                SetRidersData(
                                    ridersOutputData: riderOutputData));
                          })))));
    }

    Widget riderPlanDropdown(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 3,
          child: Container(
              margin: const EdgeInsets.only(left: 20),
              height: commonTextFieldHeight,
              decoration: riderData.inputPlan != "" &&
                      riderOutputData![index].tempSA == null
                  ? disabledTextFieldBoxDecoration()
                  : textFieldBoxDecoration(),
              child: DropdownButtonHideUnderline(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton(
                          items: riderData.inputPlan != ""
                              ? inputValueOption.map((map) {
                                  return DropdownMenuItem(
                                      value: map,
                                      child: Text(isNumeric(map)
                                          ? toRM(map, rm: true)
                                          : map));
                                }).toList()
                              : null,
                          value: riderOutputData![index].tempSA,
                          style: t2FontW5(),
                          icon: Transform.scale(
                              scale: 0.8,
                              child: const Icon(Icons.keyboard_arrow_down)),
                          onChanged: (dynamic data) async {
                            FocusScope.of(context).unfocus();

                            setState(() {
                              riderOutputData![index].tempSA = data;
                              riderOutputData![index].riderSA =
                                  data == "Full Coverage" ? "0" : data;
                              _currentSA = data == "Full Coverage" ? "0" : data;
                            });

                            BlocProvider.of<ChooseProductBloc>(context).add(
                                SetRidersData(
                                    ridersOutputData: riderOutputData));
                          })))));
    }

    Widget riderPlanField(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 2,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                  height: commonTextFieldHeight,
                  decoration: riderData.inputPlan != "" &&
                          riderOutputData![index].riderPlan == null
                      ? disabledTextFieldBoxDecoration()
                      : riderData.inputPlan != "" &&
                              riderOutputData![index].riderPlan != null
                          ? textFieldBoxDecoration()
                          : textFieldBoxDecoration()
                              .copyWith(color: Colors.grey[200]),
                  child: DropdownButtonHideUnderline(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton(
                              items: riderData.inputPlan != ""
                                  ? basicPlan!.productSetup!.prodCode ==
                                              "PCTA01" ||
                                          basicPlan!.productSetup!.prodCode ==
                                              "PCWA01"
                                      ? vpRiderPlanMatrix2.map((map) {
                                          return DropdownMenuItem(
                                              value: map['name'],
                                              child: Text(map['value']));
                                        }).toList()
                                      : vpRiderPlanMatrix.map((map) {
                                          return DropdownMenuItem(
                                              value: map['name'],
                                              child: Text(map['value']));
                                        }).toList()
                                  : null,
                              value: index != -1
                                  ? riderOutputData![index].riderPlan
                                  : "",
                              style: t2FontW5(),
                              icon: Transform.scale(
                                  scale: 0.8,
                                  child: const Icon(Icons.keyboard_arrow_down)),
                              onChanged: (dynamic values) async {
                                setState(() {
                                  riderOutputData![index].riderPlan = values;
                                  riderOutputData![index].riderSA =
                                      _currentSA; // Refresh value for sa
                                });

                                var riderIndex = vpmsMappingFile!
                                    .vpmsProdFieldsList!
                                    .indexWhere((element) =>
                                        element.inputPlanValue == values &&
                                        element.inputPlan ==
                                            riderData.inputPlan);
                                var code = vpmsMappingFile!
                                    .vpmsProdFieldsList![riderIndex].riderCode;
                                riderOutputData![index].childCode = code;

                                if (!mounted) {}
                                BlocProvider.of<ChooseProductBloc>(context).add(
                                    SetRidersData(
                                        ridersOutputData: riderOutputData));
                                setState(() {});
                              }))))));
    }

    Widget riderBenefitField(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 2,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                  height: commonTextFieldHeight,
                  decoration: riderData.inputPlan != "" &&
                          riderOutputData![index].riderPlan == null
                      ? disabledTextFieldBoxDecoration()
                      : riderData.inputPlan != "" &&
                              riderOutputData![index].riderPlan != null
                          ? textFieldBoxDecoration()
                          : textFieldBoxDecoration()
                              .copyWith(color: Colors.grey[200]),
                  child: DropdownButtonHideUnderline(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton(
                              items: cmblist.map((map) {
                                return DropdownMenuItem(
                                    value: map['value'],
                                    child: Text(map['name']));
                              }).toList(),
                              value: cmblist.indexWhere((element) =>
                                          element["value"] ==
                                          selectedRiderPlan) !=
                                      -1
                                  ? selectedRiderPlan
                                  : null,
                              style: t2FontW5(),
                              icon: Transform.scale(
                                  scale: 0.8,
                                  child: const Icon(Icons.keyboard_arrow_down)),
                              onChanged: (dynamic values) async {
                                setState(() {
                                  if (basicPlan!.productSetup!.prodCode ==
                                      "PCWA01") {
                                    riderOutputData![index].riderPlan =
                                        values + "% of Basic Plan Sum Insured";
                                  } else {
                                    riderOutputData![index].riderPlan = values;
                                  }
                                  selectedRiderPlan = values;
                                  riderOutputData![index].riderSA =
                                      _currentSA; // Refresh value for sa
                                });

                                var riderIndex = vpmsMappingFile!
                                    .vpmsProdFieldsList!
                                    .indexWhere((element) =>
                                        element.inputPlanValue ==
                                            riderOutputData![index].riderPlan &&
                                        element.inputPlan ==
                                            riderData.inputPlan);

                                if (basicPlan!.productSetup!.prodCode !=
                                    "PCWA01") {
                                  var code = vpmsMappingFile!
                                      .vpmsProdFieldsList![riderIndex]
                                      .riderCode;
                                  riderOutputData![index].childCode = code;
                                }

                                if (!mounted) {}
                                BlocProvider.of<ChooseProductBloc>(context).add(
                                    SetRidersData(
                                        ridersOutputData: riderOutputData));
                                setState(() {});
                              }))))));
    }

    Widget riderTermField(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      if (index != -1 &&
          !(coverageTerm.contains(riderOutputData![index].tempTerm))) {
        riderOutputData![index].tempTerm = null;
      }
      return Expanded(
          flex: 2,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                  height: commonTextFieldHeight,
                  decoration: riderData.inputTerm != ""
                      ? riderOutputData![index].tempTerm == null
                          ? disabledTextFieldBoxDecoration()
                          : textFieldBoxDecoration()
                      : textFieldBoxDecoration()
                          .copyWith(color: Colors.grey[200]),
                  child: DropdownButtonHideUnderline(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton(
                              items: riderData.inputTerm != ""
                                  ? coverageTerm.map((map) {
                                      return DropdownMenuItem(
                                          value: map,
                                          child: Text(map.toString()));
                                    }).toList()
                                  : null,
                              value: index != -1 &&
                                      coverageTerm.contains(
                                          riderOutputData![index].tempTerm)
                                  ? riderOutputData![index].tempTerm
                                  : null,
                              style: t2FontW5(),
                              icon: Transform.scale(
                                  scale: 0.8,
                                  child: const Icon(Icons.keyboard_arrow_down)),
                              onChanged: (dynamic values) async {
                                setState(() {
                                  riderOutputData![index].tempTerm = values;
                                  riderOutputData![index].riderSA =
                                      _currentSA; // Refresh value for sa
                                });

                                // Convert value to int
                                var riderTerm = int.parse(values);
                                // var convertedTerm = riderTerm - (liAnb!);

                                riderOutputData![index].riderTerm =
                                    riderTerm.toString();

                                BlocProvider.of<ChooseProductBloc>(context).add(
                                    SetRidersData(
                                        ridersOutputData: riderOutputData));
                                setState(() {});
                              }))))));
    }

    Widget riderTermTextField(String? prodCode, VpmsProdFieldsList riderData) {
      int index = riderOutputData!
          .indexWhere((element) => element.riderCode == prodCode);
      return Expanded(
          flex: 2,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextFormField(
                enabled: riderData.inputTerm != "",
                cursorColor: Colors.grey,
                controller: _policyTermTextEditingControllers[prodCode],
                style: textFieldStyle(),
                decoration: riderData.inputTerm == ""
                    ? disabledTextFieldInputDecoration()
                    : (riderOutputData![index].tempTerm == "" ||
                            riderOutputData![index].tempTerm == null)
                        ? errorTextFieldInputDecoration().copyWith()
                        : textFieldInputDecoration().copyWith(),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: true),
                onChanged: (dynamic values) async {
                  setState(() {
                    riderOutputData![index].tempTerm = values;
                    // riderOutputData![index].riderSA = _currentSA;
                  });

                  riderOutputData![index].riderTerm = values;

                  BlocProvider.of<ChooseProductBloc>(context)
                      .add(SetRidersData(ridersOutputData: riderOutputData));
                  setState(() {});
                },
                onFieldSubmitted: (data) async {
                  FocusScope.of(context).unfocus();
                },
                onEditingComplete: () {},
              )));
    }

    Future<bool?> confirmDeleteRiderDialog(String title) async {
      return showDialog<bool>(
          context: context,
          barrierDismissible: false, // user must tap button for close dialog!
          builder: (BuildContext context) {
            return Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.45),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            title: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                child: Text(title, style: bFontW5())),
                            content: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(children: [
                                    Expanded(
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(getLocale('No'),
                                                style: t2FontW5()))),
                                    Expanded(
                                        child: TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(true);
                                            },
                                            style: TextButton.styleFrom(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0))),
                                                backgroundColor: honeyColor,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16)),
                                            child: Text(getLocale('Yes'),
                                                style: t2FontW5())))
                                  ])
                                ])))));
          });
    }

    Widget riderDeleteButton(String? prodCode) {
      return Expanded(
          flex: 1,
          child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                  icon: const Icon(Icons.close, size: 25),
                  onPressed: () async {
                    setState(() {
                      // If user are deleting base rider, we
                      // need to check if sub-rider is selected as well
                      // if yes, then need to remove it together

                      if (prodCode == "RCIFB1") {
                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "RCIFB2");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }
                      }

                      if (prodCode == "RCFB01") {
                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "RCFB02");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }
                      }

                      if (prodCode == "RMNB") {
                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "VMNB");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }
                      }

                      if (prodCode == "RCAB01") {
                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "RCAW01");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }

                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "RCET01");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }

                        try {
                          var x = selectedRiders.indexWhere((element) =>
                              element!.productSetup!.prodCode == "RCRB01");
                          if (x != -1) {
                            var deleteData = selectedRiders[x];
                            deleteRiderData(deleteData);
                            selectedRiders.removeAt(x);
                          }
                        } catch (e) {
                          rethrow;
                        }
                      }
                    });

                    ////////////////////////////////////////////////
                    bool delete = true;
                    if (basicPlan!.productSetup!.prodCode == "PCHI03" &&
                        prodCode == "PCHI03") {
                      delete = await confirmDeleteRiderDialog(getLocale(
                              "Do you want to proceed without IL Savings Growth rider? If yes, click 'Yes' to proceed")) ??
                          true;
                    } else if (basicPlan!.productSetup!.prodCode == "PTHI01" &&
                        prodCode == "PTHI01") {
                      delete = await confirmDeleteRiderDialog(getLocale(
                              "Do you want to proceed without Takafulink Savings Flexi rider? If yes, click 'Yes' to proceed")) ??
                          true;
                    }

                    setState(() {
                      if (delete) {
                        var tempIndex = selectedRiders.indexWhere((element) =>
                            element!.productSetup!.prodCode == prodCode);

                        if (tempIndex != -1) {
                          var deleteData = selectedRiders[tempIndex];
                          deleteRiderData(deleteData);
                          _siTextEditingControllers[selectedRiders[tempIndex]!
                                  .productSetup!
                                  .prodCode]
                              ?.text = "";
                          selectedRiders.removeAt(tempIndex);
                          if (mounted) {}
                          BlocProvider.of<ChooseProductBloc>(context).add(
                              DeleteRiders(ridersOutputData: riderOutputData));
                        }
                      }
                    });
                  })));
    }

    Widget riderCoverage(List<ProductPlan?> maps, ChooseProductState state) {
      return Form(
          key: widget.riderFormKey,
          child: Column(
              children: maps.map((ProductPlan? key) {
            //If rider need plan,
            //riderData.inputSAValue != ""

            //If rider need term,
            //riderData.inputTerm != ""

            var riderData = vpmsMappingFile!.vpmsProdFieldsList!.firstWhere(
                (element) => key!.productSetup!.prodCode == "PCHI04"
                    ? element.riderCode == "PCHI03"
                    : element.riderCode == key.productSetup!.prodCode);

            var indexRiderData = riderOutputData!.indexWhere((element) =>
                key!.productSetup!.prodCode == "PCHI04"
                    ? element.riderCode == "PCHI03"
                    : element.riderCode == key.productSetup!.prodCode);

            //THIS IS TO AUTO POPULATE

            if (indexRiderData != -1 &&
                riderOutputData![indexRiderData].riderSA != null &&
                riderOutputData![indexRiderData].riderSA != "" &&
                riderOutputData![indexRiderData].requiredSA == true &&
                state is EditingQuotation) {
              if (_siTextEditingControllers.isNotEmpty &&
                  _siTextEditingControllers[key!.productSetup!.prodCode] !=
                      null &&
                  isNumeric(riderOutputData![indexRiderData].riderSA!)) {
                _siTextEditingControllers[key.productSetup!.prodCode]!.text =
                    toRM(riderOutputData![indexRiderData].riderSA!);
              }
            }

            if ((basicPlan!.productSetup!.prodCode == "PCWA01" ||
                    basicPlan!.productSetup!.prodCode == "PCTA01" ||
                    basicPlan!.productSetup!.prodCode == "PCEE01") &&
                indexRiderData != -1 &&
                riderOutputData![indexRiderData].requiredTerm == true &&
                state is EditingQuotation) {
              if (_policyTermTextEditingControllers.isNotEmpty &&
                  _policyTermTextEditingControllers[
                          key!.productSetup!.prodCode] !=
                      null &&
                  riderOutputData![indexRiderData].riderTerm != null) {
                _policyTermTextEditingControllers[key.productSetup!.prodCode]!
                    .text = riderOutputData![indexRiderData].riderTerm!;
              }
            }

            //Check SA requirement
            if (indexRiderData != -1) {
              if (riderData.inputSa == "") {
                riderOutputData![indexRiderData].requiredSA = false;
              } else {
                riderOutputData![indexRiderData].requiredSA = true;
              }
            }

            if (indexRiderData != -1) {
              if (riderData.inputTerm == "") {
                riderOutputData![indexRiderData].requiredTerm = false;
              } else {
                riderOutputData![indexRiderData].requiredTerm = true;
              }
            }

            if (indexRiderData != -1) {
              if (riderData.inputPlan == "") {
                riderOutputData![indexRiderData].requiredPlan = false;
              } else {
                riderOutputData![indexRiderData].requiredPlan = true;
              }
            }

            // GETTING SA VALUE OPTION (FOR IL MEDICAL PLUS)

            if (riderData.inputSaValueOption != "") {
              inputValueOption = [];

              try {
                var inputValueOptions =
                    riderData.inputSaValueOption!.split("|");
                for (var element in inputValueOptions) {
                  //element = "RM ${toCurrencyString(element)}";
                  inputValueOption.add(element);
                }
              } catch (e) {
                rethrow;
              }
            }

            coverageTerm = [];
            if (key != null &&
                key.maturityTermList != null &&
                sustainabilityOptionVal != null) {
              List<int?> listOfMaturityTerm =
                  getTermList(key.maturityTermList!, liAnb!);
              if (indexRiderData != -1) {
                if (riderOutputData![indexRiderData].requiredTerm!) {
                  for (var element in listOfMaturityTerm) {
                    if (element! <= sustainabilityOptionVal!) {
                      coverageTerm.add((element - liAnb!).toString());
                    }
                  }
                }
              }
            }

            if (coverageTerm.isEmpty && sustainabilityOptionVal != null) {
              List<int?> listOfMaturityTerm =
                  getTermList(basicPlan!.maturityTermList!, liAnb!);
              if (indexRiderData != -1) {
                if (riderOutputData![indexRiderData].requiredTerm!) {
                  for (var element in listOfMaturityTerm) {
                    if (element! <= sustainabilityOptionVal!) {
                      coverageTerm.add((element - liAnb!).toString());
                    }
                  }
                }
              }
            }

            // This is to cater input for rider with no sum insured, plan & term.

            if (indexRiderData != -1) {
              if (riderOutputData![indexRiderData].requiredPlan == false &&
                  riderOutputData![indexRiderData].requiredSA == false &&
                  riderOutputData![indexRiderData].requiredTerm == false) {
                if (riderOutputData![indexRiderData].tempSA != "0") {
                  riderOutputData![indexRiderData].tempSA = "0";
                  Future.delayed(const Duration(milliseconds: 500)).then(
                      (value) => BlocProvider.of<ChooseProductBloc>(context)
                          .add(SetRidersData(
                              ridersOutputData: riderOutputData)));
                }
              }
            }

            return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  riderProdName(key!.productSetup!.prodName ?? ""),
                  //SUM INSURED TEXTFIELD
                  riderData.inputSaValueOption == ""
                      ? riderData.isUnit
                          ? riderUnitDropdown(
                              key.productSetup!.prodCode, riderData)
                          : sumInsuredTextField(
                              key.productSetup!.prodCode, riderData)
                      : riderPlanDropdown(
                          key.productSetup!.prodCode, riderData),
                  key.productSetup!.prodCode == "RFNA1"
                      ? riderBenefitField(key.productSetup!.prodCode, riderData)
                      : riderPlanField(key.productSetup!.prodCode, riderData),
                  basicPlan!.productSetup!.prodCode == "PCWA01" ||
                          basicPlan!.productSetup!.prodCode == "PCTA01" ||
                          basicPlan!.productSetup!.prodCode == "PCEE01"
                      ? riderTermTextField(
                          key.productSetup!.prodCode, riderData)
                      : riderTermField(key.productSetup!.prodCode, riderData),
                  riderDeleteButton(key.productSetup!.prodCode)
                ]));
          }).toList()));
    }

    Widget riderCheckList(String prodName, bool isSelected, onTap,
        {double? height, String? prodCode, bool? disable}) {
      return AnimatedContainer(
          curve: Curves.ease,
          duration: const Duration(milliseconds: 500),
          height: height,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: disable == true ? null : onTap,
                            child: Row(children: [
                              prodCode == "RCIFB2"
                                  ? Container(width: 50)
                                  : Container(),
                              Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: isSelected
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
                                              border: Border.all(
                                                  color: Colors.grey)))),
                              Expanded(
                                  child: Text(prodName,
                                      overflow: TextOverflow.ellipsis,
                                      style: t1FontW5().copyWith(
                                          color: disable == true
                                              ? Colors.grey
                                              : Colors.black)))
                            ])))
                  ])));
    }

    void showModalSheet() {
      // var _maternityCode = "RCIFB2";

      var tempSelectedRider = selectedRiders;
      var tempSelectedRiders = [];

      for (var element in tempSelectedRider) {
        tempSelectedRiders.add(element!.productSetup!.prodName);
      }

      //TEMP SELECTED RIDER CAN'T BE COMPARED DIRECTLY
      //SO WE GET EACH NAME, STORE IN LIST. AND CHECK THERE

      showModalBottomSheet(
          isScrollControlled: true,
          isDismissible: false,
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return Stack(children: [
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 35.0, horizontal: 35),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(getLocale("Choose Rider"),
                                        style: tFontBB()),
                                    Text(
                                        getLocale(
                                            "You can choose more than ONE rider"),
                                        style: t2FontWN()
                                            .copyWith(color: Colors.grey))
                                  ]),
                              // IconButton(
                              //     iconSize: 35,
                              //     icon: const Icon(Icons.close),
                              //     onPressed: () {
                              //       Navigator.pop(context);

                              //       setState(() {
                              //         tempSelectedRider.clear();
                              //         tempSelectedRiders.clear();
                              //       });
                              //     })
                            ]))),
                Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: EdgeInsets.only(
                        left: 35,
                        right: 35,
                        bottom: 70,
                        top: MediaQuery.of(context).size.height * 0.14),
                    child: eligibleRiders.isNotEmpty
                        ? ListView.builder(
                            itemCount: eligibleRiders.length,
                            itemBuilder: (BuildContext context, i) {
                              List<ProductPlan>? nonwaiverRider = [];
                              List<ProductPlan>? waiverRider = [];
                              for (var element in eligibleRiders) {
                                if (element.productSetup!.prodName!
                                    .contains("Waiver")) {
                                  waiverRider.add(element);
                                } else {
                                  nonwaiverRider.add(element);
                                }
                              }

                              var currentProdName =
                                  eligibleRiders[i].productSetup!.prodName;
                              var currentProdCode =
                                  eligibleRiders[i].productSetup!.prodCode;
                              bool productDisabled = false;

                              // => LOGIC FOR SORTING RIDERS

                              waiverRider.sort((a, b) =>
                                  (a.productSetup!.prodName!.contains("Payor")
                                      ? 0
                                      : 1) -
                                  (b.productSetup!.prodName!.contains("Payor")
                                      ? 0
                                      : 1));

                              eligibleRiders = nonwaiverRider;
                              eligibleRiders.addAll(waiverRider);

                              // => LOGIC FOR RIDERS THAT CANNOT BE TAKEN BOTH

                              if (currentProdCode == "RCIWP7") {
                                List<String> waiver = [
                                  "RCIWT1",
                                  "RCIWC4",
                                  "RCIWP8"
                                ];
                                if (tempSelectedRider.any((element) =>
                                    waiver.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              if (currentProdCode == "RCIWP8") {
                                List<String> waiver = [
                                  "RCIWT1",
                                  "RCIWP7",
                                  "RCIWC4"
                                ];

                                if (tempSelectedRider.any((element) =>
                                    waiver.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              if (currentProdCode == "RCIWT1" ||
                                  currentProdCode == "RCIWC4") {
                                List<String> waiver = ["RCIWP7", "RCIWP8"];
                                if (tempSelectedRider.any((element) =>
                                    waiver.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              if (currentProdCode == "RCIWC6") {
                                List<String> waiver = ["RCIWP6"];
                                if (tempSelectedRider.any((element) =>
                                    waiver.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              if (currentProdCode == "RCIWP6") {
                                List<String> waiver = ["RCIWC6"];
                                if (tempSelectedRider.any((element) =>
                                    waiver.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              if (currentProdCode == "RFNA1") {
                                List<String> cmbrider = ["RFNA2", "RFNA3"];
                                if (tempSelectedRider.any((element) =>
                                    cmbrider.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }
                              if (currentProdCode == "RFNA2") {
                                List<String> cmbrider = ["RFNA1", "RFNA3"];
                                if (tempSelectedRider.any((element) =>
                                    cmbrider.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }
                              if (currentProdCode == "RFNA3") {
                                List<String> cmbrider = ["RFNA1", "RFNA2"];
                                if (tempSelectedRider.any((element) =>
                                    cmbrider.contains(
                                        element!.productSetup!.prodCode))) {
                                  productDisabled = true;
                                }
                              }

                              // => LOGIC FOR RIDERS & SUB RIDERS

                              // SecureLink (PCWI03) Riders
                              ProductPlan? femaleEssential;
                              ProductPlan? maternityRider;

                              // Enrich Life Plan (PCWA01) Riders
                              ProductPlan? levelTerm;
                              ProductPlan? tpdForLevelTerm;
                              ProductPlan? accidentRider;
                              ProductPlan? accidentalIndemnity;
                              ProductPlan? accidentalExtra;
                              ProductPlan? accidentalMedic;
                              ProductPlan? femaleIllness;
                              ProductPlan? maternityElp;

                              if (currentProdCode == "RCIFB1") {
                                femaleEssential = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCIFB2") !=
                                    -1) {
                                  maternityRider = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCIFB2");
                                }
                              }

                              if (currentProdCode == "RCIFB2") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCIFB1") !=
                                    -1) {
                                  femaleEssential = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCIFB1");
                                }
                                maternityRider = eligibleRiders[i];
                              }
///////////////
                              if (currentProdCode == "RCFB01") {
                                femaleIllness = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCFB02") !=
                                    -1) {
                                  maternityElp = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCFB02");
                                }
                              }

                              if (currentProdCode == "RCFB02") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCFB01") !=
                                    -1) {
                                  femaleIllness = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCFB01");
                                }
                                maternityElp = eligibleRiders[i];
                              }

////////////////

                              if (currentProdCode == "RMNB") {
                                levelTerm = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "VMNB") !=
                                    -1) {
                                  tpdForLevelTerm = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "VMNB");
                                }
                              }

                              if (currentProdCode == "VMNB") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RMNB") !=
                                    -1) {
                                  levelTerm = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RMNB");
                                }
                                tpdForLevelTerm = eligibleRiders[i];
                              }

                              if (currentProdCode == "RCAB01") {
                                accidentRider = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCAW01") !=
                                    -1) {
                                  accidentalIndemnity =
                                      eligibleRiders.firstWhere((element) =>
                                          element.productSetup!.prodCode ==
                                          "RCAW01");
                                }
                              }

                              if (currentProdCode == "RCAW01") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCAB01") !=
                                    -1) {
                                  accidentRider = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCAB01");
                                }
                                accidentalIndemnity = eligibleRiders[i];
                              }

                              if (currentProdCode == "RCAB01") {
                                accidentRider = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCET01") !=
                                    -1) {
                                  accidentalExtra = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCET01");
                                }
                              }

                              if (currentProdCode == "RCET01") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCAB01") !=
                                    -1) {
                                  accidentRider = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCAB01");
                                }
                                accidentalExtra = eligibleRiders[i];
                              }

                              if (currentProdCode == "RCAB01") {
                                accidentRider = eligibleRiders[i];
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCRB01") !=
                                    -1) {
                                  accidentalMedic = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCRB01");
                                }
                              }

                              if (currentProdCode == "RCRB01") {
                                if (eligibleRiders.indexWhere((element) =>
                                        element.productSetup!.prodCode ==
                                        "RCAB01") !=
                                    -1) {
                                  accidentRider = eligibleRiders.firstWhere(
                                      (element) =>
                                          element.productSetup!.prodCode ==
                                          "RCAB01");
                                }
                                accidentalMedic = eligibleRiders[i];
                              }

                              return riderCheckList(
                                eligibleRiders[i].productSetup!.prodName!,
                                tempSelectedRiders.contains(
                                    eligibleRiders[i].productSetup!.prodName),
                                () async {
                                  setModalState(() {
                                    if (tempSelectedRiders
                                        .contains(currentProdName)) {
                                      var x = tempSelectedRiders.indexWhere(
                                          (element) =>
                                              element == currentProdName);

                                      // Base Rider Logic

                                      tempSelectedRider.removeAt(x);
                                      tempSelectedRiders.removeAt(x);

                                      if (currentProdCode == "RCIFB1") {
                                        if (maternityRider != null &&
                                            tempSelectedRiders.contains(
                                                maternityRider
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  maternityRider!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }

                                      ////////////////
                                      if (currentProdCode == "RCFB01") {
                                        if (maternityElp != null &&
                                            tempSelectedRiders.contains(
                                                maternityElp
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  maternityElp!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }
                                      ////////////////

                                      if (currentProdCode == "RMNB") {
                                        if (tpdForLevelTerm != null &&
                                            tempSelectedRiders.contains(
                                                tpdForLevelTerm
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  tpdForLevelTerm!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }

                                      if (currentProdCode == "RCAB01") {
                                        if (accidentalIndemnity != null &&
                                            tempSelectedRiders.contains(
                                                accidentalIndemnity
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  accidentalIndemnity!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }

                                      if (currentProdCode == "RCAB01") {
                                        if (accidentalExtra != null &&
                                            tempSelectedRiders.contains(
                                                accidentalExtra
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  accidentalExtra!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }

                                      if (currentProdCode == "RCAB01") {
                                        if (accidentalMedic != null &&
                                            tempSelectedRiders.contains(
                                                accidentalMedic
                                                    .productSetup!.prodName)) {
                                          var index = tempSelectedRiders
                                              .indexWhere((element) =>
                                                  element ==
                                                  accidentalMedic!
                                                      .productSetup!.prodName);
                                          tempSelectedRider.removeAt(index);
                                          tempSelectedRiders.removeAt(index);
                                        }
                                      }
                                    } else {
                                      // Sub Rider Logic

                                      ////////////
                                      if (currentProdCode == "RCFB02") {
                                        if (!tempSelectedRiders.contains(
                                            femaleIllness!
                                                .productSetup!.prodName)) {
                                          tempSelectedRider.add(femaleIllness);
                                          tempSelectedRiders.add(femaleIllness
                                              .productSetup!.prodName);
                                        }
                                      }
                                      ///////////

                                      if (currentProdCode == "RCIFB2") {
                                        if (!tempSelectedRiders.contains(
                                            femaleEssential!
                                                .productSetup!.prodName)) {
                                          tempSelectedRider
                                              .add(femaleEssential);
                                          tempSelectedRiders.add(femaleEssential
                                              .productSetup!.prodName);
                                        }
                                      }

                                      if (currentProdCode == "VMNB") {
                                        if (!tempSelectedRiders.contains(
                                            levelTerm!
                                                .productSetup!.prodName)) {
                                          tempSelectedRider.add(levelTerm);
                                          tempSelectedRiders.add(
                                              levelTerm.productSetup!.prodName);
                                        }
                                      }

                                      if (currentProdCode == "RCAW01" ||
                                          currentProdCode == "RCET01" ||
                                          currentProdCode == "RCRB01") {
                                        if (!tempSelectedRiders.contains(
                                            accidentRider!
                                                .productSetup!.prodName)) {
                                          tempSelectedRider.add(accidentRider);
                                          tempSelectedRiders.add(accidentRider
                                              .productSetup!.prodName);
                                        }
                                      }

                                      tempSelectedRider.add(eligibleRiders[i]);
                                      tempSelectedRiders.add(currentProdName);
                                    }
                                  });
                                },
                                disable: productDisabled,
                                prodCode: currentProdCode,
                                height: currentProdCode == "RCIFB2"
                                    ? (femaleEssential != null &&
                                            tempSelectedRiders.contains(
                                                femaleEssential
                                                    .productSetup!.prodName)
                                        ? null
                                        : 0)
                                    : null,
                              );
                            })
                        : Center(
                            child: Text(getLocale("Please Choose a Basic Plan"),
                                style: t1FontWN()))),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                        onTap: () async {
                          setModalState(() {
                            isModalRiderLoading = true;
                            selectedRiders = tempSelectedRider;
                          });

                          if (basicPlan!.productSetup!.prodCode == "PCHI03") {
                            if (!selectedRiders.any((element) =>
                                element!.productSetup!.prodCode == "PCHI03")) {
                              bool delete = await confirmDeleteRiderDialog(
                                      getLocale(
                                          "Do you want to proceed without IL Savings Growth rider? If yes, click 'Yes' to proceed")) ??
                                  true;
                              if (delete) {
                                if (mounted) {}
                                getRiderData(selectedRiders);
                                BlocProvider.of<ChooseProductBloc>(context)
                                    .add(AddRiders(riderOutputData!));
                                setState(() {});
                                setModalState(() {
                                  isModalRiderLoading = false;
                                });
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              } else {
                                setModalState(() {
                                  isModalRiderLoading = false;
                                });
                              }
                            } else {
                              getRiderData(selectedRiders);
                              BlocProvider.of<ChooseProductBloc>(context)
                                  .add(AddRiders(riderOutputData!));
                              setState(() {});
                              setModalState(() {
                                isModalRiderLoading = false;
                              });
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          } else if (basicPlan!.productSetup!.prodCode ==
                              "PTHI01") {
                            if (!selectedRiders.any((element) =>
                                element!.productSetup!.prodCode == "PTHI01")) {
                              bool delete = await confirmDeleteRiderDialog(
                                      getLocale(
                                          "Do you want to proceed without Takafulink Savings Flexi rider? If yes, click 'Yes' to proceed")) ??
                                  true;
                              if (delete) {
                                if (mounted) {}
                                getRiderData(selectedRiders);
                                BlocProvider.of<ChooseProductBloc>(context)
                                    .add(AddRiders(riderOutputData!));
                                setState(() {});
                                setModalState(() {
                                  isModalRiderLoading = false;
                                });
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              } else {
                                setModalState(() {
                                  isModalRiderLoading = false;
                                });
                              }
                            } else {
                              getRiderData(selectedRiders);
                              BlocProvider.of<ChooseProductBloc>(context)
                                  .add(AddRiders(riderOutputData!));
                              setState(() {});
                              setModalState(() {
                                isModalRiderLoading = false;
                              });
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          } else {
                            getRiderData(selectedRiders);
                            BlocProvider.of<ChooseProductBloc>(context)
                                .add(AddRiders(riderOutputData!));
                            setState(() {});
                            setModalState(() {
                              isModalRiderLoading = false;
                            });
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                            height: 70,
                            color: honeyColor,
                            child: Center(
                                child: isModalRiderLoading
                                    ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black))
                                    : Text(
                                        tempSelectedRider.isNotEmpty &&
                                                tempSelectedRiders.isNotEmpty &&
                                                eligibleRiders.isNotEmpty
                                            ? getLocale("Add selected rider")
                                            : getLocale("Dismiss"),
                                        style: tFontW5())))))
              ]);
            });
          });
    }

    return BlocListener<ChooseProductBloc, ChooseProductState>(
        listener: (context, state) {
      if (state is BasicPlanChosen) {
        _firstTimeScreenLoaded = 1;

        if (state.vpmsMappingFile != null) {
          vpmsMappingFile = state.vpmsMappingFile;
        }
        liAnb = state.age + 1;
        liDob = state.dob;
        if ((liDob ?? "").isNotEmpty) {
          int? age = getAgeString(liDob!, false,
              additionalMonth: (state.deductSalary ?? false) ? 2 : 0);
          liAnb = age + 1;
        }
        List<int?> listOfMaturityTerm =
            getTermList(state.selectedPlan.maturityTermList!, state.age + 1);
        if (getMinPolicyTerm(listOfMaturityTerm) != null) {
          sustainabilityOptionVal = getMinPolicyTerm(listOfMaturityTerm)!;
        }

        basicPlan = state.selectedPlan;
        eligibleRiders = state.eligibleRiders;

        List<ProductPlan?> pp = [];
        for (var rider in selectedRiders) {
          var riderData = eligibleRiders.firstWhereOrNull((element) =>
              element.productSetup!.prodCode == rider!.productSetup!.prodCode);
          if (riderData != null) {
            pp.add(rider);
          }
        }
        selectedRiders = pp;

        List<RiderOutputData>? newRiderOutputData = [];
        for (var element in riderOutputData!) {
          dynamic riderData = eligibleRiders.firstWhereOrNull((eligiblerider) =>
              eligiblerider.productSetup!.prodCode == element.riderCode);
          if (riderData != null) {
            newRiderOutputData.add(element);
            // Change CMB rider plan value
            if (element.riderPlan != null) {
              if (basicPlan!.productSetup!.prodCode == "PCWA01" &&
                  element.riderCode!.contains("RFNA") &&
                  !element.riderPlan!.contains("% of Basic Plan Sum Insured")) {
                element.riderPlan =
                    "${element.riderPlan!}% of Basic Plan Sum Insured";
              } else if (basicPlan!.productSetup!.prodCode == "PCEE01" &&
                  element.riderCode!.contains("RFNA") &&
                  element.riderPlan!.contains("% of Basic Plan Sum Insured")) {
                element.riderPlan = element.riderPlan!
                    .replaceAll("% of Basic Plan Sum Insured", "");
              }
            }
          }
        }
        riderOutputData = newRiderOutputData;

        if (state.selectedPlan.productSetup!.prodCode == "PCHI03" ||
            state.selectedPlan.productSetup!.prodCode == "PCHI04") {
          if (!riderOutputData!
              .any((element) => element.riderCode == "PCHI03")) {
            riderOutputData!.insert(
                0,
                RiderOutputData(
                    riderCode: "PCHI03", riderName: "IL Savings Growth"));
          }
        }

        if (state.selectedPlan.productSetup!.prodCode == "PTHI01" ||
            state.selectedPlan.productSetup!.prodCode == "PTHI02") {
          if (!riderOutputData!
              .any((element) => element.riderCode == "PTHI01")) {
            riderOutputData!.insert(
                0,
                RiderOutputData(
                    riderCode: "PTHI01",
                    riderName: "Takafulink Savings Flexi"));
          }
        }

        for (var element in riderOutputData!) {
          ProductPlan selectedRider = ProductPlan(
              productSetup: ProductSetup(
                  prodName: element.riderName, prodCode: element.riderCode));
          if (!selectedRiders.any((element) =>
              element!.productSetup!.prodCode ==
              selectedRider.productSetup!.prodCode)) {
            selectedRiders.add(selectedRider);
          }
        }

        isSupplementaryRiders = riderOutputData!.isNotEmpty;
      } else if (state is EditingQuotation && _firstTimeScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;

        liAnb = state.age + 1;
        liDob = state.dob;
        if ((liDob ?? "").isNotEmpty) {
          int? age = getAgeString(liDob!, false,
              additionalMonth: (state.deductSalary ?? false) ? 2 : 0);
          liAnb = age + 1;
        }
        basicPlan = state.selectedPlan;
        eligibleRiders = state.quickQuotation.eligibleRiders!;
        if (state.quickQuotation.sustainabilityOption != null &&
            isNumeric(state.quickQuotation.sustainabilityOption)) {
          sustainabilityOptionVal =
              convertStringToInt(state.quickQuotation.sustainabilityOption!);
        } else if (basicPlan != null) {
          List<int?> listOfMaturityTerm =
              getTermList(basicPlan!.maturityTermList!, state.age + 1);
          if (getMinPolicyTerm(listOfMaturityTerm) != null) {
            sustainabilityOptionVal = getMinPolicyTerm(listOfMaturityTerm)!;
          }
        }

        if (state.vpmsMappingFile != null) {
          vpmsMappingFile = state.vpmsMappingFile;
        }

        riderOutputData = state.quickQuotation.riderOutputDataList;
        for (var element in riderOutputData!) {
          // ProductPlan _selectedRider = ProductPlan(names: element.riderName, code: element.riderCode);
          ProductPlan selectedRider = ProductPlan(
              productSetup: ProductSetup(
                  prodName: element.riderName, prodCode: element.riderCode));
          if (element.riderPlan != null) {
            if (basicPlan!.productSetup!.prodCode == "PCWA01" &&
                element.riderCode!.contains("RFNA") &&
                !element.riderPlan!.contains("% of Basic Plan Sum Insured")) {
              element.riderPlan =
                  "${element.riderPlan!}% of Basic Plan Sum Insured";
            } else if (basicPlan!.productSetup!.prodCode == "PCEE01" &&
                element.riderCode!.contains("RFNA") &&
                element.riderPlan!.contains("% of Basic Plan Sum Insured")) {
              element.riderPlan = element.riderPlan!
                  .replaceAll("% of Basic Plan Sum Insured", "");
            }
            if (element.riderCode == "RFNA1") {
              selectedRiderPlan = element.riderPlan;
            }
          }
          selectedRiders.add(selectedRider);
        }
        isSupplementaryRiders = riderOutputData!.isNotEmpty;
        getController();
      } else if (state is SustainabilityOptionChosen) {
        sustainabilityOptionVal = state.sustainabilityOptionTerm;
      } else if (state is ChooseProductInitial) {
        _firstTimeScreenLoaded = 0;
      } else if (state is SumInsuredPremCalculated) {
        if ((liDob ?? "").isNotEmpty && state.deductSalary != null) {
          int? age = getAgeString(liDob!, false,
              additionalMonth: (state.deductSalary ?? false) ? 2 : 0);
          liAnb = age + 1;
        }
      }
    }, child: BlocBuilder<ChooseProductBloc, ChooseProductState>(
            builder: (context, state) {
      if (basicPlan == null || basicPlan!.productSetup!.prodCode == "PCEL01") {
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
                  if (isSupplementaryRiders) {
                    riderOutputData = [];
                    selectedRiders.clear();
                    BlocProvider.of<ChooseProductBloc>(context)
                        .add(SetRidersData(ridersOutputData: riderOutputData));
                    isSupplementaryRiders = false;
                  } else {
                    isSupplementaryRiders = true;
                  }
                });
              }
            },
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
                child: Row(children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: isSupplementaryRiders
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
                      child: Text(getLocale("Supplementary Riders"),
                          style: tFontW5()
                              .copyWith(fontWeight: FontWeight.normal)))
                ]))),
        AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 1),
            height: isSupplementaryRiders && selectedRiders.isNotEmpty
                ? (130 + selectedRiders.length * 82).toDouble()
                : 0,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: (170 + selectedRiders.length * 82).toDouble(),
                padding: const EdgeInsets.only(left: 96, right: 45),
                child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: RichText(
                                  text: TextSpan(
                                      text:
                                          getLocale('Please add a rider below'),
                                      style: bFontWN()))),
                          Row(children: [
                            Expanded(
                                flex: 5,
                                child: Text(getLocale("Rider Type"),
                                    style: bFontWN()
                                        .copyWith(color: greyTextColor))),
                            Expanded(
                                flex: 3,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                        "${getLocale("Sum Insured")}/${getLocale("Units")}",
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)))),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(getLocale("Plan"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)))),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(getLocale("Term"),
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor)))),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text("",
                                        style: bFontWN()
                                            .copyWith(color: greyTextColor))))
                          ]),
                          const SizedBox(height: 20),
                          riderCoverage(selectedRiders, state)
                        ])))),
        AnimatedContainer(
            curve: Curves.easeInOut,
            duration: const Duration(seconds: 1),
            height: isSupplementaryRiders ? 120 : 0,
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          selectedRiders.isEmpty
                              ? basicPlan != null &&
                                      _firstTimeScreenLoaded == 1 &&
                                      eligibleRiders.isEmpty
                                  ? Text(
                                      getLocale("No eligible rider available"))
                                  : Text(getLocale("Please add a rider below"))
                              : const SizedBox(height: 0),
                          SizedBox(height: selectedRiders.isEmpty ? 10 : 0),
                          if (basicPlan != null &&
                              _firstTimeScreenLoaded == 1 &&
                              eligibleRiders.isNotEmpty)
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (basicPlan != null &&
                                        (basicPlan!.productSetup!.prodCode ==
                                                "PCHI03" ||
                                            basicPlan!.productSetup!.prodCode ==
                                                "PCHI04")) {
                                      if (!eligibleRiders.any((element) =>
                                          element.productSetup!.prodCode ==
                                              "PCHI03" ||
                                          element.productSetup!.prodCode ==
                                              "PCHI04")) {
                                        eligibleRiders.insert(
                                            0,
                                            ProductPlan(
                                                productSetup: ProductSetup(
                                                    prodCode: "PCHI03",
                                                    prodName:
                                                        "IL Savings Growth")));
                                      }
                                    } else {
                                      if (eligibleRiders.any((element) =>
                                          element.productSetup!.prodCode ==
                                          "PCHI03")) {
                                        var index = eligibleRiders.indexWhere(
                                            (element) =>
                                                element
                                                    .productSetup!.prodCode ==
                                                "PCHI03");
                                        eligibleRiders.removeAt(index);
                                      }
                                    }

                                    if (basicPlan != null &&
                                        (basicPlan!.productSetup!.prodCode ==
                                                "PTHI01" ||
                                            basicPlan!.productSetup!.prodCode ==
                                                "PTHI02")) {
                                      if (!eligibleRiders.any((element) =>
                                          element.productSetup!.prodCode ==
                                              "PTHI01" ||
                                          element.productSetup!.prodCode ==
                                              "PTHI02")) {
                                        eligibleRiders.insert(
                                            0,
                                            ProductPlan(
                                                productSetup: ProductSetup(
                                                    prodCode: "PTHI01",
                                                    prodName:
                                                        "Takafulink Savings Flexi")));
                                      }
                                    } else {
                                      if (eligibleRiders.any((element) =>
                                          element.productSetup!.prodCode ==
                                          "PTHI01")) {
                                        var index = eligibleRiders.indexWhere(
                                            (element) =>
                                                element
                                                    .productSetup!.prodCode ==
                                                "PTHI01");
                                        eligibleRiders.removeAt(index);
                                      }
                                    }
                                  });

                                  showModalSheet();
                                },
                                child: Container(
                                    color: lightCyanColor,
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0, vertical: 10),
                                        child: Text(
                                            selectedRiders.isEmpty
                                                ? "+ ${getLocale("Add rider")}"
                                                : "+ ${getLocale("Add another rider")}",
                                            style: TextStyle(
                                                color: cyanColor,
                                                fontWeight:
                                                    FontWeight.w500))))),
                          const SizedBox(height: 35)
                        ]))))
      ]);
    }));
  }
}
