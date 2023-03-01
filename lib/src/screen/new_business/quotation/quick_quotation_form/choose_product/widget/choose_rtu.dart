// ignore_for_file: unrelated_type_equality_checks

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/qtn_form_widget.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseRTU extends StatefulWidget {
  final GlobalKey<FormState> rtuAmountKey;
  final Function onRTUSelected;

  const ChooseRTU(this.rtuAmountKey, this.onRTUSelected, {Key? key})
      : super(key: key);
  @override
  ChooseRTUState createState() => ChooseRTUState();
}

class ChooseRTUState extends State<ChooseRTU> {
  int _firstTimeScreenLoaded = 0;
  int _firstTimeEditingScreenLoaded = 0;
  // Y is to check if Editing Quotation has been called

  TextEditingController rtuAmountCont = TextEditingController();
  bool isRegularTopUp = false;
  String paymentMode = getLocale('Monthly');
  @override
  void initState() {
    super.initState();
    widget.onRTUSelected(isRegularTopUp);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChooseProductBloc, ChooseProductState>(
        builder: (context, state) {
      if (state is BasicPlanChosen) {
        _firstTimeScreenLoaded = 1;
      } else if (state is SumInsuredPremCalculated) {
        if (state.paymentMode != null) {
          paymentMode = convertPaymentModeInt(state.paymentMode!);
        }
        if (widget.rtuAmountKey.currentState != null) {
          widget.rtuAmountKey.currentState!.validate();
        }
      } else if (state is EditingQuotation &&
          _firstTimeEditingScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;
        _firstTimeEditingScreenLoaded = 1;

        if (state.quickQuotation.rtuAmt == null ||
            state.quickQuotation.rtuAmt == "" ||
            state.quickQuotation.rtuAmt == "0" ||
            state.quickQuotation.rtuAmt == "0.00") {
          rtuAmountCont.text = "0.00";
          isRegularTopUp = false;
        } else {
          if (state.quickQuotation.rtuAmt!.contains(".00")) {
            rtuAmountCont.text = state.quickQuotation.rtuAmt!;
          } else {
            rtuAmountCont.text = "${state.quickQuotation.rtuAmt!}.00";
          }
          isRegularTopUp = true;
        }
        paymentMode = convertPaymentModeInt(state.quickQuotation.paymentMode);
        widget.onRTUSelected(isRegularTopUp);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            onTap: () {
              if (_firstTimeScreenLoaded == 0) {
                showSnackBarError(getLocale("Please select basic plan first"));
              } else {
                setState(() {
                  isRegularTopUp = !isRegularTopUp;
                  if (!isRegularTopUp) {
                    rtuAmountCont.text = "0.00";
                  }
                  var data = rtuAmountCont.text.replaceAll(RegExp(','), "");
                  //REMOVE ANY DECIMAL POINT
                  var x = data.split('.');

                  BlocProvider.of<ChooseProductBloc>(context).add(SetRTUAmount(
                      rtuAmount: x == isNumeric ? int.parse(x[0]) : 0));

                  widget.onRTUSelected(isRegularTopUp);
                });
              }
            },
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
                color: Colors.white,
                child: Row(children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: isRegularTopUp
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
                  Text("Regular Top-Up",
                      style: tFontW5().copyWith(fontWeight: FontWeight.normal)),
                  const SizedBox(width: 10),
                  // Icon(Icons.info, size: 28, color: cyanColor)
                ]))),
        AnimatedContainer(
            curve: Curves.easeInOutQuart,
            duration: const Duration(seconds: 1),
            height: isRegularTopUp ? 160 : 0,
            child: Container(
                height: 260,
                padding: const EdgeInsets.only(left: 96),
                child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Text(
                                  "${getLocale("Premium")} ${getLocale(paymentMode)}",
                                  style: bFontWN())),
                          Form(
                              key: widget.rtuAmountKey,
                              child: Container(
                                  width: 400,
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: TextFormField(
                                      cursorColor: Colors.grey,
                                      style: textFieldStyle(),
                                      decoration: textFieldInputDecoration()
                                          .copyWith(prefixText: 'RM '),
                                      controller: rtuAmountCont,
                                      inputFormatters: [
                                        CurrencyTextInputFormatter(
                                            locale: 'ms', symbol: '')
                                      ],
                                      keyboardType: TextInputType.number,
                                      onChanged: (data) {
                                        data = data.replaceAll(RegExp(','), "");
                                        //REMOVE ANY DECIMAL POINT
                                        var x = data.split('.');

                                        if (widget.rtuAmountKey.currentState!
                                            .validate()) {
                                          BlocProvider.of<ChooseProductBloc>(
                                                  context)
                                              .add(SetRTUAmount(
                                                  rtuAmount: int.parse(x[0])));
                                        }
                                      },
                                      onFieldSubmitted: (data) async {
                                        FocusScope.of(context).unfocus();
                                      },
                                      onEditingComplete: () async {},
                                      validator: (value) {
                                        var data =
                                            validateRTU(value, paymentMode);

                                        if (data['success'] == true) {
                                          return null;
                                        } else {
                                          return data['message'];
                                        }
                                      })))
                        ]))))
      ]);
    });
  }
}
