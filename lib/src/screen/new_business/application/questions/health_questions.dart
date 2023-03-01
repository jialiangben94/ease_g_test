import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/questions/question_container.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/application/questions/questionbloc/question_bloc.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/number_picker.dart';
import 'package:ease/src/widgets/custom_column_table.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/radio_check.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthQuestions extends StatefulWidget {
  final String? clientType;
  final dynamic obj;
  final dynamic product;
  final dynamic info;
  final String title;
  final Function(dynamic obj) onChanged;

  const HealthQuestions(
      {Key? key,
      this.product,
      required this.clientType,
      this.obj,
      this.info,
      required this.title,
      required this.onChanged})
      : super(key: key);
  @override
  HealthQuestionsState createState() => HealthQuestionsState();
}

class HealthQuestionsState extends State<HealthQuestions> {
  String? qtype;
  dynamic obj;
  var inputList = {};
  @override
  void initState() {
    obj = widget.obj;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var paddingV = EdgeInsets.symmetric(vertical: gFontSize * 2);
    var paddingH = EdgeInsets.symmetric(horizontal: gFontSize * 3);

    Widget details() {
      var l = widget.info;
      var p = widget.product;

      String riderList = "";
      var riders = p["riderOutputDataList"];
      if (riders.length > 0) {
        for (int i = 0; i < riders.length; i++) {
          if (i == riders.length - 1) {
            riderList = riderList + riders[i]["riderName"];
          } else {
            riderList = "$riderList${riders[i]["riderName"]}, ";
          }
        }
      } else {
        riderList = "-";
      }

      l ??= {};
      String? age;
      if (l["age"] != null) age = (l["age"] + 1).toString();
      var obj = [
        {
          "size": {"labelWidth": 30, "valueWidth": 70},
          "a": {
            "label": getLocale("Age next birthday"),
            "value": "${(age ?? "")}/${getLocale((l["gender"] ?? ""))}"
          },
          "p": {"label": getLocale("Product"), "value": p["productPlanName"]},
          "r": {"label": getLocale("Rider(s)"), "value": riderList},
          "o": {
            "label": getLocale("Occupation"),
            "value": l["occupationDisplay"]
          }
        }
      ];
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            "${getLocale("Special Translation 1 for Details")} ${widget.title} ${getLocale("Special Translation 2 for Details")}",
            style: t2FontW5()),
        Text(
            getLocale(
                "Go through these questions with your client to get to know them even better."),
            style: sFontWN().copyWith(color: greyTextColor)),
        SizedBox(height: gFontSize * 0.8),
        Container(
            padding: EdgeInsets.only(left: gFontSize * 1.5, right: gFontSize),
            color: creamColor,
            child: CustomColumnTable(arrayObj: obj))
      ]);
    }

    Widget heightAndWeight() {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        inputList["1078h"] != null
            ? Expanded(
                child: NumberPicker(
                    obj: inputList["1078h"],
                    onChanged: (value) {
                      if (value != inputList["1078h"]["max"]) {
                        inputList["1078h"]["value"] = value;
                      }
                      var result = getInputedData(inputList);
                      widget.onChanged(result);
                    }))
            : const SizedBox(),
        inputList["1078h"] != null
            ? SizedBox(width: gFontSize * 2.5)
            : const SizedBox(),
        inputList["1078w"] != null
            ? Expanded(
                child: NumberPicker(
                    obj: inputList["1078w"],
                    onChanged: (value) {
                      if (value != inputList["1078w"]["max"]) {
                        inputList["1078w"]["value"] = value;
                      }
                      var result = getInputedData(inputList);
                      if (result["readAndAgree"] != null &&
                          !result["readAndAgree"]) {
                        result["empty"] = null;
                      }
                      widget.onChanged(result);
                    }))
            : const SizedBox()
      ]);
    }

    Widget infoInput() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        heightAndWeight(),
        SizedBox(
            height: inputList["1078w"] != null || inputList["1078h"] != null
                ? gFontSize * 2
                : 0),
        inputList["1032"] != null
            ? QuestionContainer(
                obj: inputList["1032"],
                imageFlex: 0,
                questionFlex: 100,
                onChanged: (value) {
                  inputList["1032"]["value"] = value;
                  var result = getInputedData(inputList);
                  if (result["readAndAgree"] != null &&
                      !result["readAndAgree"]) {
                    result["empty"] = null;
                  }
                  widget.onChanged(result);
                })
            : const SizedBox()
      ]);
    }

    Widget genderImage() {
      return Image(
          alignment: Alignment.topCenter,
          height: gFontSize * 16,
          width: gFontSize * 8,
          image: const AssetImage('assets/images/silhouette.png'));
    }

    Widget heightAndWeightContainer() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Height & Weight"), style: t2FontW5()),
        SizedBox(height: gFontSize * 1.5),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 20, child: genderImage()),
          Expanded(flex: 10, child: Container()),
          Expanded(flex: 70, child: infoInput())
        ])
      ]);
    }

    String getSection(question) {
      var replace = ["1333", "1334", "1335"];
      var coverage = ["1040", "1042"];
      var life = ["1288", "1034", "1036", "1038"];
      var hw = ["1078h", "1078w", "1032"];
      if (life.contains(question)) {
        return "life";
      } else if (coverage.contains(question)) {
        return "coverage";
      } else if (replace.contains(question)) {
        return "replace";
      } else if (hw.contains(question)) {
        return "hw";
      } else {
        return "health";
      }
    }

    Widget allQuestion() {
      List<Widget> health = [];
      List<Widget> life = [];
      List<Widget> coverage = [];
      List<Widget> replace = [];

      if (qtype == null) {
        var p = widget.product;
        dynamic qsetup = questionSetup.firstWhere(
            (element) => element["ProdCode"] == p["productPlanCode"]);
        var riders = p["riderOutputDataList"];
        if (riders.length > 0) {
          qtype = qsetup["Type"][0]["riderQuest"];
        } else {
          qtype = qsetup["Type"][0]["gpQuest"];
        }
      }

      var nqtype = questionType.keys
          .firstWhere((k) => questionType[k] == int.parse(qtype!));

      var fq = getQuestionIndex()[nqtype];
      var femaleQ = ["2d1", "2d2", "2d3", "1062", "1064", "1074", "1266"];
      bool isFemale = widget.info["gender"] == "Female";

      if (!isFemale) {
        for (var q in femaleQ) {
          if (fq.indexOf(q) > -1) {
            fq.remove(q);
          }
        }
      }

      var p = widget.product;
      var riders = p["riderOutputDataList"];
      List<dynamic> ridersCode =
          riders.map((value) => value["riderCode"]).toList();

      bool hasMaternityRider = ridersCode.contains("RCFB02");
      bool hasJuvenileRider = ridersCode.contains("RCCI01");

      bool hasRCIFB1 = ridersCode.contains("RCIFB1");
      bool hasRCIFB2 = ridersCode.contains("RCIFB2");

      bool hasRCICI4 = ridersCode.contains("RCICI4");
      bool hasRTICI4 = ridersCode.contains("RTICI4");

      if (isFemale) {
        if (!hasRCIFB1 && !hasRCIFB2 && !hasMaternityRider) {
          if (fq.indexOf("1266") > -1) {
            fq.remove("1266");
          }
        }
      }
      // juvenile questions
      var childQ = ["1260", "1262", "1264"];
      if (widget.clientType == "1" ||
          (!hasRCICI4 && !hasRTICI4 && !hasJuvenileRider)) {
        for (var element in childQ) {
          if (fq.indexOf(element) > -1) {
            fq.remove(element);
          }
        }
      } else {
        for (var element in childQ) {
          if (fq.indexOf(element) > -1) {
            //fq.remove(element);
          }
        }
      }

      var questions = getQuestions(fq);

      for (var i = 0; i < fq.length; i++) {
        if (questions[fq[i]] == null) {
          continue;
        }

        if (widget.info["smoking"] && questions["1288"] != null) {
          questions["1288"]["readOnly"] = true;
          questions["1288"]["value"] = true;
        }

        if (questions[fq[i]]["questionCode"] == "1334") {
          if (obj != null &&
              obj["1334"] != null &&
              obj["1334"]["AnswerValue"] != null &&
              obj["1334"]["AnswerValue"]) {
            questions[fq[i + 1]]["disabled"] = false;
            questions[fq[i + 1]]["value"] = false;
          } else {
            questions[fq[i + 1]]["disabled"] = true;
            questions[fq[i + 1]]["value"] = false;
          }
        }
      }

      // print(questions["1030"]);
      var healthIndex = 1;
      for (var i = 0; i < fq.length; i++) {
        if (questions[fq[i]] == null) {
          continue;
        }
        List<Widget> array = [];
        dynamic image;
        String? title;

        if (getSection(fq[i]) == "coverage") {
          array = coverage;
          title = getLocale("Existing Coverage");
        } else if (getSection(fq[i]) == "life") {
          array = life;
          title = getLocale("Lifestyle");
        } else if (getSection(fq[i]) == "replace") {
          array = replace;
          title = getLocale("Policy or Certificate Replacement");
        } else if (getSection(fq[i]) == "health") {
          array = health;
          questions[fq[i]]["label"] = questions[fq[i]]["label"]
              .replaceAll("{{number}}", "${healthIndex.toString()}.");
          questions[fq[i]]["qno"] = healthIndex.toString();
          healthIndex++;
          title = getLocale("Health & Medical Questions");
        }

        if (getSection(fq[i]) != "hw") {
          if (array.isEmpty) {
            array.addAll([
              Text(title ?? "", style: t2FontW5()),
              SizedBox(height: gFontSize * 2)
            ]);
            if (image != null) questions[fq[i]].addAll(image);
          }

          var wid = [
            QuestionContainer(
                obj: questions[fq[i]],
                images: questions[fq[i]]["image"],
                onChanged: (value) {
                  questions[fq[i]]["value"] = value;
                  var result = getInputedData(inputList);
                  if (result["readAndAgree"] != null &&
                      !result["readAndAgree"]) {
                    result["empty"] = null;
                  }
                  obj = result;
                  setState(() {});
                  widget.onChanged(result);
                }),
            SizedBox(height: gFontSize * 4)
          ];
          if (questions[fq[i]]["disabled"] == null ||
              (questions[fq[i]]["disabled"] != null &&
                  !questions[fq[i]]["disabled"])) {
            array.addAll(wid);
          }
        }

        inputList[fq[i]] = questions[fq[i]];
      }

      inputList["readAndAgree"] = {
        "type": "radiocheck",
        "label": getLocale(
            "I hereby confirm that all of the information disclosed in this Application, Sales Illustration & Product Disclosure Sheet are all in order and accurate."),
        "value": false,
        "required": true
      };

      generateDataToObjectValue(obj, inputList);

      Widget containerHW = const SizedBox();
      if (inputList["1078w"] != null ||
          inputList["1078h"] != null ||
          inputList["1032"] != null) {
        containerHW =
            Container(padding: paddingH, child: heightAndWeightContainer());
      }

      var containerH = health.isNotEmpty
          ? Column(children: [
              SizedBox(height: gFontSize * 2),
              Divider(thickness: gFontSize * 0.2, height: gFontSize * 2),
              SizedBox(height: gFontSize * 2),
              Container(
                  padding: paddingH,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: health))
            ])
          : Container();
      var containerL = life.isNotEmpty
          ? Column(children: [
              SizedBox(height: gFontSize * 2),
              Divider(thickness: gFontSize * 0.2, height: gFontSize * 2),
              SizedBox(height: gFontSize * 2),
              Container(
                  padding: paddingH,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: life))
            ])
          : Container();
      var containerC = coverage.isNotEmpty
          ? Column(children: [
              SizedBox(height: gFontSize * 2),
              Divider(thickness: gFontSize * 0.2, height: gFontSize * 2),
              SizedBox(height: gFontSize * 2),
              Container(
                  padding: paddingH,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: coverage))
            ])
          : Container();
      var containerR = replace.isNotEmpty
          ? Column(children: [
              SizedBox(height: gFontSize * 2),
              Divider(thickness: gFontSize * 0.2, height: gFontSize * 2),
              SizedBox(height: gFontSize * 2),
              Container(
                  padding: paddingH,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: replace))
            ])
          : Container();

      Widget readandagree() {
        return Padding(
            padding: paddingH,
            child: RadioCheckContainer(
                checked: inputList["readAndAgree"]["value"],
                label: inputList["readAndAgree"]["label"],
                onChanged: (value) {
                  inputList["readAndAgree"]["value"] = value;
                  var result = getInputedData(inputList);
                  if (result["readAndAgree"] != null &&
                      !result["readAndAgree"]) {
                    result["empty"] = null;
                  }
                  obj = result;
                  widget.onChanged(obj);
                }));
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        containerHW,
        containerH,
        containerL,
        containerC,
        containerR,
        readandagree()
      ]);
    }

    return BlocBuilder<QuestionBloc, QuestionTypeState>(
        builder: (context, state) {
      if (state is QuestionTypeLoaded) {
        qtype = state.questionType;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          var result = getInputedData(inputList);
          if (result["readAndAgree"] != null && !result["readAndAgree"]) {
            result["empty"] = null;
          }
          obj = result;
          widget.onChanged(obj);
        });
      }
      return Container(
          padding: paddingV,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: paddingH, child: details()),
            SizedBox(height: gFontSize * 2),
            allQuestion()
          ]));
    });
  }
}
