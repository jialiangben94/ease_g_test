import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/choice_check.dart';
import 'package:ease/src/screen/new_business/application/questions/question_sub_input.dart';

import 'package:flutter/material.dart';

class QuestionContainer extends StatelessWidget {
  final dynamic obj;
  final String? images;
  final int imageFlex;
  final int questionFlex;
  final Function(dynamic obj) onChanged;
  final ValueNotifier<bool?> _valueNotify = ValueNotifier(null);

  QuestionContainer({
    Key? key,
    this.images,
    this.obj,
    this.imageFlex = 30,
    this.questionFlex = 70,
    required this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const healthQuestions = [
      "1040",
      "1030",
      "1034",
      "1036",
      "1038",
      "1044",
      "1046",
      "1048",
      "1050",
      "1052",
      "1054",
      "1056",
      "1058",
      "1060",
      "1062",
      "1074",
      "1064",
      "1068",
      "1070",
      "1072",
      "1076",
      "1260",
      "1262",
      "1264",
      "1266",
      "1066",
      "1042",
      "1288",
      "1334",
      "1333"
    ];
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    double width = gFontSize * 8;
    Widget imageContainer = Expanded(flex: imageFlex, child: Container());
    var questCode = obj['questionCode'];
    String? image;

    if (healthQuestions.contains(questCode)) {
      image = "assets/images/health_questions/$questCode.png";
    }

    if (image != null) {
      imageContainer = Expanded(
          flex: imageFlex,
          child: Stack(children: [
            Container(
                padding: EdgeInsets.only(
                    right: (obj["imagePaddingRight"] ?? 0.0).toDouble(),
                    left: (obj["imagePaddingLeft"] ?? 0.0).toDouble()),
                child: Image(
                    alignment: Alignment.topCenter,
                    width: width,
                    image: AssetImage(image)))
          ]));
    }

    Widget subQuestionButton() {
      return GestureDetector(
          onTap: () async {
            int index = obj["options"]
                .indexWhere((option) => option["value"] == obj["value"]);
            var ops = index > -1 ? obj["options"][index] : null;
            var results = await Navigator.of(context).push(createRoute(
                QuestionSubInput(
                    inputList: ops["option_fields"],
                    plaintext: obj["plaintext"],
                    subtext: obj["subtext"],
                    qno: obj["qno"],
                    xml: obj["AnswerXML"],
                    questionCode: obj["questionCode"])));

            if (results != null) {
              obj["AnswerXML"] = results;
              onChanged(obj["value"]);
            }
          },
          child: Container(
              width: gFontSize * 2.8,
              height: gFontSize * 2.8,
              decoration:
                  BoxDecoration(color: honeyColor, shape: BoxShape.circle),
              child: Icon(Icons.adaptive.arrow_forward, color: Colors.white)));
    }

    List<Widget> generateSubInputButton() {
      List<Widget> wid = [];
      int index = obj["options"]
          .indexWhere((option) => option["value"] == obj["value"]);
      var ops = index > -1 ? obj["options"][index] : null;

      if (obj["value"] == true &&
          ops != null &&
          ops["option_fields"] != null &&
          ops["option_fields"] is Map &&
          ops["option_fields"].isNotEmpty) {
        wid.add(const Expanded(flex: 20, child: SizedBox()));
        wid.add(Expanded(flex: 15, child: subQuestionButton()));
        wid.add(const Expanded(flex: 5, child: SizedBox()));
      } else {
        obj["AnswerXML"] = "";
        wid.add(const Expanded(flex: 40, child: SizedBox()));
      }
      return wid;
    }

    Row generateOption() {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 0.028 * MediaQuery.of(context).size.width),
            Expanded(
                flex: 60,
                child: ChoiceCheckContainer(
                    obj: obj,
                    displayLabel: false,
                    textColorChange: true,
                    containerPadding: const EdgeInsets.all(0),
                    rowPadding: const EdgeInsets.all(0),
                    mergeOption: true,
                    fontWeight: FontWeight.w600,
                    fontColor: greyTextColor,
                    fontSize: gFontSize * 0.9,
                    confirmBeforeChange: (value, callback) async {
                      if (value == false &&
                          obj["value"] == true &&
                          obj["AnswerXML"] != null) {
                        var result = await showConfirmDialog(
                            context,
                            getLocale("Warning"),
                            getLocale(
                                "This action will remove sub question answer. Are you sure you want to proceed?"));
                        callback(result);
                      } else {
                        callback(true);
                      }
                    },
                    onChanged: (value) async {
                      _valueNotify.value = value;
                      onChanged(value);
                    })),
            ...generateSubInputButton()
          ]);
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imageContainer,
          Expanded(
              flex: questionFlex,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (obj["qno"] != null)
                            Expanded(
                                flex: 6,
                                child: Text(
                                    obj["qno"] != null
                                        ? "${obj["qno"]}."
                                        : "1. ",
                                    style: bFontWN().copyWith(
                                        fontSize: gFontSize,
                                        color: Colors.black))),
                          Expanded(
                              flex: obj["qno"] != null ? 94 : 1,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(obj["plaintext"],
                                        style: obj["qno"] != null
                                            ? bFontWN().copyWith(
                                                fontSize: gFontSize,
                                                color: Colors.black)
                                            : bFontWN().copyWith(
                                                fontSize: gFontSize * 0.93,
                                                color: greyTextColor)),
                                    if (obj["subtext"] != null)
                                      Text("(${obj["subtext"]})",
                                          style: bFontWN().copyWith(
                                              fontSize: gFontSize * 0.93,
                                              color: greyTextColor))
                                  ]))
                        ]),
                    SizedBox(height: gFontSize * 0.5),
                    ValueListenableBuilder(
                        valueListenable: _valueNotify,
                        builder: (BuildContext context, bool? changed,
                            Widget? child) {
                          return generateOption();
                        })
                  ]))
        ]);
  }
}
