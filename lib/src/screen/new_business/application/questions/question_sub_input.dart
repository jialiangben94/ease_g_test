import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/utils/api_format.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/row_container.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class QuestionSubInput extends StatefulWidget {
  final String? plaintext;
  final String? subtext;
  final String? qno;
  final dynamic inputList;
  final dynamic xml;
  final String questionCode;
  const QuestionSubInput(
      {Key? key,
      required this.inputList,
      this.plaintext,
      this.subtext,
      this.qno,
      this.xml,
      required this.questionCode})
      : super(key: key);
  @override
  QuestionSubInputState createState() => QuestionSubInputState();
}

class QuestionSubInputState extends State<QuestionSubInput> {
  String currentNumber = "1";
  dynamic widList;
  dynamic result;
  dynamic multiple;
  dynamic xml;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    multiple = widget.inputList["multiple"];
    if (widget.xml != null) {
      xml = xml2json(widget.xml);
    }
    if (xml == null || xml is! Map || xml["Answer"] == null) {
      xml = {
        "Answer": [{}]
      };
    }
    generateDataToObjectValue(
        xml["Answer"][int.parse(currentNumber) - 1], widget.inputList,
        specialConvert: true);
  }

  void setAllField(o, field, value) {
    for (var key in o.keys) {
      if (o[key] is! Map) continue;
      if (o[key]["enabled"] != null && !o[key]["enabled"]) {
        continue;
      }
      if (o[key]["options"] != null) {
        o[key][field] = value;
        for (var i = 0; i < o[key]["options"].length; i++) {
          if (o[key]["options"][i] is! Map) {
            continue;
          }
          if (o[key]["options"][i]["option_fields"] != null) {
            setAllField(o[key]["options"][i]["option_fields"], field, value);
          }
        }
      } else {
        if (field == "error") {
          o[key].remove(field);
        } else {
          o[key][field] = value;
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, widget.inputList, (key) {
      setState(() {});
    });

    void onNumberPressed(number) {
      setAllField(widget.inputList, "error", null);
      var result = getInputedData(widget.inputList);
      xml["Answer"][int.parse(currentNumber) - 1] = result;
      generateDataToObjectValue(
          xml["Answer"][int.parse(number) - 1], widget.inputList);
      currentNumber = number.toString();
      setState(() {});
    }

    List<Widget> generateContent(widList, inputList) {
      List<Widget> inWidList = [];
      if (xml["Answer"].length > 0) {
        for (var wid in widList) {
          inWidList.add(wid["widget"]);
        }
      }
      return inWidList;
    }

    Widget button() {
      var obj = [
        {
          "size": 100,
          "value": CustomButton(
              label: getLocale("Save"),
              onPressed: () {
                if (xml["Answer"].length > 0) {
                  var result =
                      getInputedData(widget.inputList, specialConvert: true);
                  xml["Answer"][int.parse(currentNumber) - 1] = result;
                  int? found;
                  for (var i = 0; i < xml["Answer"].length; i++) {
                    if (checkRequiredField(xml["Answer"][i]) == false) {
                      found = i;
                      break;
                    }
                  }

                  if (found != null) {
                    String? foundKey;
                    for (var key in xml["Answer"][found].keys) {
                      if (xml["Answer"][found][key] == null) {
                        foundKey = key;
                        break;
                      }
                    }
                    String label = "";
                    var obj = getObjectByKey(widget.inputList, foundKey);
                    label =
                        obj != null && obj["label"] != null ? obj["label"] : "";
                    showSnackBarError(
                        "Please insert the required fields tab ${(found + 1).toString()} field $label");
                    return;
                  } else {
                    if (widget.questionCode == "1288") {
                      xml["Answer"][0]["IsSticks"] = "false";
                      xml["Answer"][0]["IsHours"] = "false";
                      if (xml["Answer"][0]["Sticks"] != null &&
                          xml["Answer"][0]["Sticks"] != "") {
                        xml["Answer"][0]["IsSticks"] = "true";
                      }
                      if (xml["Answer"][0]["Hours"] != null &&
                          xml["Answer"][0]["Hours"] != "") {
                        xml["Answer"][0]["IsHours"] = "true";
                      }
                      xml = json2xml(xml);
                    } else {
                      for (var e = 0; e < xml["Answer"].length; e++) {
                        for (var key2 in xml["Answer"][e].keys) {
                          if (key2 == "IssueDate") {
                            if (xml["Answer"][e][key2] is int) {
                              xml["Answer"][e][key2] =
                                  formatAPIDate(xml["Answer"][e][key2]);
                            } else {
                              int? issuedate = isNumeric(xml["Answer"][e][key2])
                                  ? xml["Answer"][e][key2]
                                  : int.tryParse(xml["Answer"][e][key2]);
                              if (issuedate != null) {
                                xml["Answer"][e][key2] =
                                    formatAPIDate(issuedate);
                              }
                            }
                          }
                        }
                      }
                      xml = json2xml(xml);
                    }
                  }
                } else {
                  xml = "";
                }
                Navigator.pop(context, xml);
              })
        }
      ];

      return RowContainer(
          arrayObj: obj,
          padding: const EdgeInsets.all(0),
          color: honeyColor,
          height: gFontSize * 3);
    }

    Widget backButton() {
      return Container(
          padding: EdgeInsets.symmetric(
              vertical: gFontSize * 1.5, horizontal: gFontSize * 1.5),
          child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.adaptive.arrow_back, size: gFontSize)));
    }

    Widget addButton() {
      return IconButton(
          onPressed: () {
            if (xml["Answer"].length == 0) {
              xml["Answer"].add({});
              currentNumber = xml["Answer"].length.toString();
              setAllField(widget.inputList, "value", "");
            } else {
              var result = getInputedData(widget.inputList);
              if (checkRequiredField(result) == true) {
                xml["Answer"][int.parse(currentNumber) - 1] = result;
                xml["Answer"].add({});
                setAllField(widget.inputList, "value", "");
                scrollController.jumpTo(0.0);
                currentNumber = xml["Answer"].length.toString();
              } else {
                showSnackBarError(getLocale(
                    "Please fill in all answer before adding a new form."));
              }
            }
            setState(() {});
          },
          icon: Icon(Icons.add, size: gFontSize * 1.3));
    }

    Widget deleteButton() {
      return IconButton(
          onPressed: () {
            if (xml["Answer"].length > 0) {
              xml["Answer"].removeAt(int.parse(currentNumber) - 1);
              currentNumber = xml["Answer"].length.toString();
              if (xml["Answer"].length > 0) {
                generateDataToObjectValue(
                    xml["Answer"][int.parse(currentNumber) - 1],
                    widget.inputList);
              }
              setState(() {});
            }
          },
          icon: Icon(Icons.remove, size: gFontSize * 1.3));
    }

    Widget generateNumber(number) {
      var color = lightGreyColor2;
      var textColor = greyTextColor;

      if (currentNumber == number) {
        color = cyanColor;
        textColor = Colors.white;
      }
      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize),
          child: GestureDetector(
              onTap: () {
                onNumberPressed(number);
              },
              child: CircleAvatar(
                  radius: gFontSize * 1.2,
                  backgroundColor: color,
                  child: Text(number.toString(),
                      style: t1FontW5().copyWith(color: textColor)))));
    }

    Widget numberList() {
      if (multiple != true) {
        return const SizedBox();
      }
      List<Widget> list = [];
      if (xml["Answer"].length > 0) {
        for (var i = 0; i < xml["Answer"].length; i++) {
          list.add(generateNumber((i + 1).toString()));
        }
      } else if (currentNumber != "0") {
        list.add(generateNumber("1"));
      }
      return Container(
          padding: EdgeInsets.symmetric(horizontal: gFontSize * 3),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(flex: 5, child: deleteButton()),
            Expanded(
                flex: 90,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: list))),
            Expanded(flex: 5, child: addButton())
          ]));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: gFontSize * 0.35,
              width: screenWidth,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [yellowColor, honeyColor]))),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [backButton()]),
          Container(
              width: screenWidth,
              padding: EdgeInsets.symmetric(horizontal: gFontSize * 3),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (widget.qno != null)
                  Expanded(
                      flex: 4,
                      child: Text(widget.qno != null ? "${widget.qno}." : "1. ",
                          style: bFontWN().copyWith(
                              fontSize: gFontSize, color: Colors.black))),
                Expanded(
                    flex: widget.qno != null ? 96 : 1,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.plaintext!,
                              style: widget.qno != null
                                  ? bFontWN().copyWith(
                                      fontSize: gFontSize, color: Colors.black)
                                  : bFontWN().copyWith(
                                      fontSize: gFontSize * 0.93,
                                      color: greyTextColor)),
                          if (widget.subtext != null)
                            Text("(${widget.subtext})",
                                style: bFontWN().copyWith(
                                    fontSize: gFontSize * 0.93,
                                    color: greyTextColor))
                        ]))
              ])),
          SizedBox(height: gFontSize * 1.5),
          numberList(),
          Expanded(
              child: SingleChildScrollView(
                  key: scaffoldKey,
                  controller: scrollController,
                  padding: EdgeInsets.only(
                      top: multiple ? gFontSize : 0.0,
                      bottom: gFontSize * 2,
                      right: gFontSize * 4,
                      left: gFontSize * 4),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...generateContent(widList, widget.inputList)
                      ])))
        ]),
        bottomNavigationBar: button());
  }
}
