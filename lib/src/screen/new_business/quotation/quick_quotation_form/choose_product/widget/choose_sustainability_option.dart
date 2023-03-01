import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/service/product_setup_helper.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChooseSustainabilityOption extends StatefulWidget {
  const ChooseSustainabilityOption({Key? key}) : super(key: key);

  @override
  ChooseSustainabilityOptionState createState() =>
      ChooseSustainabilityOptionState();
}

class ChooseSustainabilityOptionState
    extends State<ChooseSustainabilityOption> {
  List<int?> terms = [];
  int? minTerm;
  int? maxTerm;
  int? _firstTimeScreenLoaded;

  int? division;
  double? sustainabilityOptionVal;
  String? prodcode;

  @override
  void initState() {
    super.initState();
    _firstTimeScreenLoaded = 0;
    minTerm = 0;
    maxTerm = 100;
    sustainabilityOptionVal = 0.0;
    //To get the list of term (66,88,100 etc)
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChooseProductBloc, ChooseProductState>(
        builder: (context, state) {
      bool hidden = false;
      if (state is BasicPlanChosen) {
        _firstTimeScreenLoaded = 1;
        prodcode = state.selectedPlan.productSetup!.prodCode;
        terms =
            getTermList(state.selectedPlan.maturityTermList!, state.age + 1);
        minTerm = getMinPolicyTerm(terms);
        maxTerm = getMaxPolicyTerm(terms);
        if (minTerm != null) {
          sustainabilityOptionVal = minTerm!.toDouble();
        }
        // CHECK HOW MANY DIVISION
        if (terms.isNotEmpty) {
          division = terms.length - 1;
        } else {
          division = 0;
        }
      } else if (state is EditingQuotation) {
        _firstTimeScreenLoaded = 1;
        var basicPlan = state.selectedPlan;
        if (basicPlan != null) {
          prodcode = basicPlan.productSetup!.prodCode;
          terms = getTermList(basicPlan.maturityTermList!, state.age + 1);
          minTerm = getMinPolicyTerm(terms);
          maxTerm = getMaxPolicyTerm(terms);
          if (minTerm != null) {
            sustainabilityOptionVal = minTerm!.toDouble();
          }
        }
        // CHECK HOW MANY DIVISION
        if (terms.isNotEmpty) {
          division = terms.length - 1;
        } else {
          division = 0;
        }

        if (state.quickQuotation.sustainabilityOption != null) {
          sustainabilityOptionVal =
              double.tryParse(state.quickQuotation.sustainabilityOption!);
        }
      }

      hidden = prodcode == "PCHI03" ||
          prodcode == "PCHI04" ||
          prodcode == "PTHI01" ||
          prodcode == "PTHI02" ||
          prodcode == "PCTA01" ||
          prodcode == "PCEL01";

      return hidden || division == null || division == 0
          ? Container()
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 40),
              Text(getLocale("Basic Plan Expiry Age Option"),
                  style: t2FontW5()),
              SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      activeTickMarkColor: Colors.grey,
                      inactiveTickMarkColor: Colors.grey,
                      activeTrackColor: greyDividerColor,
                      inactiveTrackColor: greyDividerColor,
                      trackShape: const RectangularSliderTrackShape(),
                      trackHeight: 10.0,
                      thumbColor: cyanColor,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 20.0),
                      overlayColor: cyanColor.withAlpha(32),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 30.0)),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          flex: 10,
                          child: Slider(
                              divisions: division,
                              min: minTerm != null ? minTerm!.toDouble() : 0,
                              max: maxTerm != null ? maxTerm!.toDouble() : 0,
                              value: sustainabilityOptionVal!,
                              onChanged: (value) async {
                                if (_firstTimeScreenLoaded != 0) {
                                  // Normalize the value to within range

                                  if (value >= 86 && value <= 89.9) {
                                    // TODO: FIND WAY TO GET 78 OUT OF SLIDER
                                    value = 88;
                                  }

                                  setState(() {
                                    sustainabilityOptionVal = value;
                                  });

                                  BlocProvider.of<ChooseProductBloc>(context)
                                      .add(SetSustainabilityOption(
                                          sustainabilityOptionVal!.toInt()));
                                }
                              })),
                      Expanded(
                          flex: 1,
                          child: Container(
                              height: 45,
                              decoration: textFieldBoxDecoration(),
                              child: Center(
                                  child: Text(
                                      sustainabilityOptionVal!
                                          .toInt()
                                          .toStringAsFixed(0),
                                      textAlign: TextAlign.center,
                                      style: t1FontWN()
                                          .copyWith(color: cyanColor)))))
                    ]),
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 100, bottom: 0, top: 20),
                        child: Column(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                  terms.length,
                                  (index) => Text(
                                      terms.isNotEmpty
                                          ? terms[index].toString()
                                          : "",
                                      style:
                                          const TextStyle(fontFamily: "Lato"))))
                        ]))
                  ]))
            ]);
    });
  }
}
