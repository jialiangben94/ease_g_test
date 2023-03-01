import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AssessmentType extends StatefulWidget {
  final List<AssesmentList>? string;
  const AssessmentType({Key? key, this.string}) : super(key: key);
  @override
  AssessmentTypeState createState() => AssessmentTypeState();
}

class AssessmentTypeState extends State<AssessmentType> {
  late bool hideMedCheckType;
  int? showMedCheckType;
  final GlobalKey _key = GlobalKey();
  RenderBox? renderBox;

  @override
  void initState() {
    hideMedCheckType = true;
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _getSizes());
  }

  void _getSizes() {
    renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
  }

  @override
  Widget build(BuildContext context) {
    List<String?> newtext = [];
    for (var element in widget.string!) {
      newtext.add(element.examDesc);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // First list
      Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("1. ", style: bFontW5()),
            Expanded(child: Text(newtext[0]!, style: bFontW5()))
          ])),
      // Animate the rest list here
      AnimatedContainer(
          curve: Curves.easeInOutQuart,
          duration: const Duration(seconds: 1),
          height: hideMedCheckType ? 0 : renderBox!.size.height,
          child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(key: _key, children: [
                for (int i = 1; i < newtext.length; i++)
                  if (newtext[i] != "")
                    Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${i + 1}. ", style: bFontW5()),
                              Expanded(
                                  child: Text(newtext[i]!, style: bFontW5()))
                            ]))
              ]))),
      Visibility(
          visible: newtext.length > 1,
          child: InkWell(
              onTap: () {
                _getSizes();
                setState(() {
                  hideMedCheckType = !hideMedCheckType;
                });
                analyticsSendEvent(
                    hideMedCheckType
                        ? "show_assessment_type"
                        : "hide_assessment_type",
                    {
                      "button_name":
                          hideMedCheckType ? "Show all type" : "Show less"
                    });
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text(
                    hideMedCheckType
                        ? getLocale("Show all type")
                        : getLocale("Show less"),
                    style: bFontWN().copyWith(color: cyanColor, fontSize: 15)),
                Icon(
                    hideMedCheckType
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: cyanColor)
              ])))
    ]);
  }
}
