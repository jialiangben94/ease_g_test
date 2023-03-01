import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseSteppedPremium extends StatefulWidget {
  const ChooseSteppedPremium({Key? key}) : super(key: key);

  @override
  ChooseSteppedPremiumState createState() => ChooseSteppedPremiumState();
}

class ChooseSteppedPremiumState extends State<ChooseSteppedPremium> {
  // double textFieldHeight = 80.0;
  bool _steppedPremium = false;
  int? _firstTimeScreenLoaded;

  @override
  void initState() {
    super.initState();
    _firstTimeScreenLoaded = 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChooseProductBloc, ChooseProductState>(
        listener: (context, state) {},
        child: BlocBuilder<ChooseProductBloc, ChooseProductState>(
            builder: (context, state) {
          if (state is BasicPlanChosen) {
            _firstTimeScreenLoaded = 1;
            _steppedPremium = state.quickQtn.isSteppedPremium ?? false;
          } else if (state is EditingQuotation) {
            _steppedPremium = state.quickQuotation.isSteppedPremium ?? false;
            _firstTimeScreenLoaded = 1;
          }
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(getLocale("Stepped Premium"),
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),
                Text(
                    getLocale(
                        "(Premium starts off cheaper and will be adjusted accordingly as your age increases)"),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 10),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                //If _firstTimeScreenLoaded == 0, means user hasn't choose basic plan yet.
                                if (_firstTimeScreenLoaded == 0) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  showSnackBarError(getLocale(
                                      "Please select basic plan first"));
                                } else {
                                  setState(() {
                                    _steppedPremium = true;
                                  });

                                  BlocProvider.of<ChooseProductBloc>(context)
                                      .add(SetSteppedPremium(_steppedPremium));
                                }
                              },
                              child: Container(
                                  height: commonTextFieldHeight,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          width: 2,
                                          color: _steppedPremium == true
                                              ? cyanColor
                                              : Colors.grey[400]!)),
                                  child: Center(
                                      child: Text(getLocale("Yes"),
                                          style: bFontW5().copyWith(
                                              color: _steppedPremium == true
                                                  ? cyanColor
                                                  : Colors.grey[600])))))),
                      const SizedBox(width: 20),
                      Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                //If _firstTimeScreenLoaded == 0, means user hasn't choose basic plan yet.
                                if (_firstTimeScreenLoaded == 0) {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  showSnackBarError(getLocale(
                                      "Please select basic plan first"));
                                } else {
                                  setState(() {
                                    _steppedPremium = false;
                                  });

                                  BlocProvider.of<ChooseProductBloc>(context)
                                      .add(SetSteppedPremium(_steppedPremium));
                                }
                              },
                              child: Container(
                                  height: commonTextFieldHeight,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          width: 2,
                                          color: _steppedPremium == false
                                              ? cyanColor
                                              : Colors.grey[400]!)),
                                  child: Center(
                                      child: Text(getLocale("No"),
                                          style: bFontW5().copyWith(
                                              color: _steppedPremium == false
                                                  ? cyanColor
                                                  : Colors.grey[600]))))))
                    ]))
              ]);
        }));
  }
}
