// ignore_for_file: unrelated_type_equality_checks

import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/qtn_form_widget.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseAdhoc extends StatefulWidget {
  final GlobalKey<FormState> adhocAmountKey;
  final Function onAdhocSelected;

  const ChooseAdhoc(this.adhocAmountKey, this.onAdhocSelected, {Key? key})
      : super(key: key);
  @override
  ChooseAdhocState createState() => ChooseAdhocState();
}

class ChooseAdhocState extends State<ChooseAdhoc> {
  int _firstTimeScreenLoaded = 0;
  int _firstTimeEditingScreenLoaded = 0;
  // Y is to check if Editing Quotation has been called

  TextEditingController adhocAmountCont = TextEditingController();
  bool isAdhocTopUp = false;
  String paymentMode = getLocale('Monthly');
  @override
  void initState() {
    super.initState();
    widget.onAdhocSelected(isAdhocTopUp);
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
        if (widget.adhocAmountKey.currentState != null) {
          widget.adhocAmountKey.currentState!.validate();
        }
      } else if (state is EditingQuotation &&
          _firstTimeEditingScreenLoaded == 0) {
        _firstTimeScreenLoaded = 1;
        _firstTimeEditingScreenLoaded = 1;

        if (state.quickQuotation.adhocAmt == null ||
            state.quickQuotation.adhocAmt == "" ||
            state.quickQuotation.adhocAmt == "0" ||
            state.quickQuotation.adhocAmt == "0.00") {
          adhocAmountCont.text = "0";
          isAdhocTopUp = false;
        } else {
          adhocAmountCont.text = state.quickQuotation.adhocAmt!;
          isAdhocTopUp = true;
        }
        paymentMode = convertPaymentModeInt(state.quickQuotation.paymentMode);
        widget.onAdhocSelected(isAdhocTopUp);
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            onTap: () {
              if (_firstTimeScreenLoaded == 0) {
                showSnackBarError(getLocale("Please select basic plan first"));
              } else {
                setState(() {
                  isAdhocTopUp = !isAdhocTopUp;
                  if (!isAdhocTopUp) {
                    adhocAmountCont.text = "";
                  }
                  var data = adhocAmountCont.text.replaceAll(RegExp(','), "");
                  //REMOVE ANY DECIMAL POINT
                  var x = data.split('.');

                  BlocProvider.of<ChooseProductBloc>(context).add(
                      SetAdhocAmount(
                          adhocAmount: x == isNumeric ? int.parse(x[0]) : 0));

                  widget.onAdhocSelected(isAdhocTopUp);
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
                      child: isAdhocTopUp
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
                  Text("Ad hoc Top-Up",
                      style: tFontW5().copyWith(fontWeight: FontWeight.normal)),
                  const SizedBox(width: 10),
                  // Icon(Icons.info, size: 28, color: cyanColor)
                ]))),
        AnimatedContainer(
            curve: Curves.easeInOutQuart,
            duration: const Duration(seconds: 1),
            height: isAdhocTopUp ? 160 : 0,
            child: Container(
                height: 260,
                padding: const EdgeInsets.only(left: 96),
                child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                              key: widget.adhocAmountKey,
                              child: Container(
                                  width: 400,
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: TextFormField(
                                      cursorColor: Colors.grey,
                                      style: textFieldStyle(),
                                      decoration: textFieldInputDecoration()
                                          .copyWith(prefixText: 'RM '),
                                      controller: adhocAmountCont,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      onChanged: (data) {
                                        data = data.replaceAll(RegExp(','), "");
                                        //REMOVE ANY DECIMAL POINT
                                        var x = data.split('.');

                                        if (widget.adhocAmountKey.currentState!
                                            .validate()) {
                                          BlocProvider.of<ChooseProductBloc>(
                                                  context)
                                              .add(SetAdhocAmount(
                                                  adhocAmount:
                                                      int.parse(x[0])));
                                        }
                                      },
                                      onFieldSubmitted: (data) async {
                                        FocusScope.of(context).unfocus();
                                      },
                                      onEditingComplete: () async {},
                                      validator: (value) {
                                        var data =
                                            validateAdhoc(value, paymentMode);

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
