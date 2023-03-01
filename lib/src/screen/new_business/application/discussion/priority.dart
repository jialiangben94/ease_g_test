import 'dart:collection';

import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/custom_switch.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class Priority extends StatefulWidget {
  final VoidCallback callback;

  const Priority({Key? key, required this.callback}) : super(key: key);

  @override
  PriorityState createState() => PriorityState();
}

class PriorityState extends State<Priority> {
  late dynamic widList;
  late dynamic inputList;
  dynamic obj;

  double containerHeight = gFontSize * 4.2;

  @override
  void initState() {
    super.initState();
    obj = ApplicationFormData.data["priority"];
    inputList = {
      "protection": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("priorityprotection"), "value": 1}
        }
      },
      "retirement": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("priorityretirement"), "value": 2}
        }
      },
      "education": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("priorityeducation"), "value": 3}
        }
      },
      "saving": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("prioritysaving"), "value": 4}
        }
      },
      "investment": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("priorityinvestment"), "value": 5}
        }
      },
      "medical": {
        "titleAsKey": true,
        "fields": {
          "planned": {"value": false},
          "priority": {"label": getLocale("prioritymedical"), "value": 6}
        }
      }
    };

    if (obj != null && !obj.isEmpty) {
      for (var key in obj.keys) {
        inputList[key]["fields"]["planned"]["value"] = obj[key]["planned"];
        inputList[key]["fields"]["priority"]["value"] = obj[key]["priority"];
      }
    }
    widList = generateDragableItem(0, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var result = getInputedData(inputList);
      obj = result;
      ApplicationFormData.data["priority"] = obj;
      widget.callback();
    });
  }

  dynamic generateDragableItem(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    int compareSort(k1, k2) {
      return inputList[k1]["fields"]["priority"]["value"] <
              inputList[k2]["fields"]["priority"]["value"]
          ? -1
          : 1;
    }

    var keys = inputList.keys.toList();
    keys = keys..sort((k1, k2) => compareSort(k1, k2));
    var wid = keys.removeAt(oldIndex);
    keys.insert(newIndex, wid);
    for (var i = 0; i < keys.length; i++) {
      inputList[keys[i]]["fields"]["priority"]["value"] = i + 1;
    }
    LinkedHashMap sortedMap = LinkedHashMap.fromIterable(keys,
        key: (k) => k, value: (k) => inputList[k]);
    inputList = sortedMap;
    var inWidList = [];
    for (var key in inputList.keys) {
      inWidList.add(SizedBox(
          key: UniqueKey(),
          height: containerHeight,
          child: Row(children: [
            Expanded(
                flex: 10,
                child: Container(
                    alignment: Alignment.center,
                    height: gFontSize * 3.8,
                    decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(gFontSize * 0.3)),
                        color: const Color.fromRGBO(242, 242, 242, 1)),
                    child: Text(
                        (inputList[key]["fields"]["priority"]["value"])
                            .toString(),
                        textAlign: TextAlign.center,
                        style: tFontW5().copyWith(
                            fontFamily: "Lato,Regular",
                            fontWeight: FontWeight.normal)))),
            Expanded(
                flex: 65,
                child: Container(
                    height: gFontSize * 3.8,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: greyBorderTFColor),
                        borderRadius:
                            BorderRadius.all(Radius.circular(gFontSize * 0.3))),
                    child: ReorderableDragStartListener(
                        index: inputList[key]["fields"]["priority"]["value"],
                        child: Row(children: [
                          Icon(Icons.swap_vert,
                              size: gFontSize * 2, color: tealGreenColor),
                          Padding(
                              padding: EdgeInsets.only(right: gFontSize * 0.8)),
                          Expanded(
                              child: Text(
                                  inputList[key]["fields"]["priority"]["label"],
                                  style: t2FontWN()))
                        ])))),
            Expanded(
                flex: 17,
                child: Container(
                    color: const Color.fromRGBO(227, 244, 242, 1),
                    child: CustomSwitch(
                        value: inputList[key]["fields"]["planned"]["value"],
                        onChanged: (value) {
                          setState(() {
                            inputList[key]["fields"]["planned"]["value"] =
                                value;
                          });
                          var result = getInputedData(inputList);
                          obj = result;
                          ApplicationFormData.data["priority"] = obj;
                          widget.callback();
                        })))
          ])));
    }
    return inWidList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2, left: gFontSize * 3, right: gFontSize * 3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Define Your Client's Current Priority"),
              style: t1FontW5()),
          Text(getLocale("Tell us what you'd like to prioritise."),
              style: sFontWN().copyWith(color: greyTextColor)),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
              width: double.infinity,
              height: 70,
              child: Row(children: [
                Expanded(
                    flex: 10,
                    child: Center(
                        child: Text(getLocale("Priority"),
                            style: sFontWN().copyWith(color: greyTextColor)))),
                Expanded(
                    flex: 61,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(getLocale("Drag to arrange sequence"),
                            style: sFontWN().copyWith(color: tealGreenColor)))),
                Expanded(
                    flex: 16,
                    child: Container(
                        padding: const EdgeInsets.all(13),
                        height: 70,
                        color: const Color.fromRGBO(227, 244, 242, 1),
                        child: Text(getLocale("Already Planned"),
                            textAlign: TextAlign.center,
                            style: sFontWN().copyWith(color: greyTextColor))))
              ])),
          Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.68),
              // height: screenHeight * 0.7,
              child: ReorderableListView(
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      widList = generateDragableItem(oldIndex, newIndex);
                      var result = getInputedData(inputList);
                      obj = result;
                      ApplicationFormData.data["priority"] = obj;
                      widget.callback();
                    });
                  },
                  children: [...widList]))
        ]));
  }
}
