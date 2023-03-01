import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:ease/src/screen/new_business/application/input_page.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/radio_dropdown.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/info_card.dart';
import 'package:ease/src/widgets/number_picker.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddInfoContainer extends StatefulWidget {
  final dynamic obj;
  final dynamic nominee;
  final Function(dynamic obj)? onChanged;

  const AddInfoContainer({Key? key, this.obj, this.onChanged, this.nominee})
      : super(key: key);

  @override
  AddInfoContainerState createState() => AddInfoContainerState();
}

class AddInfoContainerState extends State<AddInfoContainer> {
  bool show = false;
  var height = gFontSize * 5;
  dynamic inputList;

  @override
  void initState() {
    super.initState();
    //sample
    // widget.obj = {
    //   "checkSwitch": true,
    //   "label": "wewe",
    //   "buttonLabel": "Click me",
    //   "mainTitleKey": "plan_name",
    //   "subTitleKey": "company",
    //   "infoShowKey": ["policy_owner", "monthly_premium", "dob", "percentage"],
    //   "info": {
    //     "size": {"labelWidth": 40, "valueWidth": 60},
    //     "naText": ""
    //   },
    //   "inputList": {
    //   },
    //   "value": []
    // };

    if (widget.obj == null) {
      throw ("Missing param obj");
    }

    if (widget.obj["inputList"] == null) {
      throw ("Missing param obj inputList");
    }

    if (widget.obj["infoShowKey"] == null) {
      throw ("Missing param obj infoShowKey");
    }

    if (widget.obj != null &&
        widget.obj["value"] != null &&
        widget.obj["value"] != "" &&
        widget.obj["value"] is List) {
      show = true;
    }

    inputList = json.decode(json.encode(widget.obj["inputList"]));
  }

  dynamic getInput({bool isEdit = false}) {
    var identitytype = getObjectByKey(inputList, "identitytype");
    identitytype["options"].forEach((options) {
      options["option_fields"][options["value"]]["isEdit"] = isEdit;
      if (options["option_fields"]["nric"] != null) {
        options["option_fields"]["nric"]["isEdit"] = isEdit;
        options["option_fields"]["oldic"]["isEdit"] = isEdit;
      }
    });

    return json.decode(json.encode(inputList));
  }

  void onDeleteTap(i) async {
    var result = await showConfirmDialog(context, getLocale("Delete"),
        "${getLocale("Are you sure you want to delete")} ${widget.obj["value"][i][widget.obj["mainTitleKey"]]}?");
    if (result != null && result) {
      setState(() {
        widget.obj["value"].removeAt(i);
        if (widget.onChanged != null) {
          widget.onChanged!({"onDeleteChanged": true});
        }
        if (widget.obj["value"].length == 0) height = gFontSize * 5;
      });
    }
  }

  void onEditTap(i) async {
    var input = getInput(isEdit: true);
    generateDataToObjectValue(widget.obj["value"][i], input);

    var occupation = getObjectByKey(input, "occupationDisplay");
    if (occupation != null) {
      if (widget.obj["value"][i]["occupation"] != null) {
        var occJson = json.decode(widget.obj["value"][i]["occupation"]);
        occupation["value"] = occJson["OccupationName"];
      }
    }

    final results = await Navigator.of(context)
        .push(createRoute(InputPage(inputList: input)));

    if (results != null) {
      setState(() {
        widget.obj["value"][i] = results;
        if (widget.onChanged != null) {
          widget.onChanged!({"onEditChanged": true});
        }
      });
    }
  }

  List<Widget> generateList() {
    List<Widget> array = [];
    var value = widget.obj["value"];
    if (value == null || value is! List) {
      return [];
    }

    for (dynamic i = value.length - 1; i > -1; i--) {
      var obj = {};
      for (var key in value[i].keys) {
        var mapValue = objMapping[value[i][key]] ?? value[i][key];
        if (key == "relationship") {
          var relationship = lookupRelationship.keys
              .firstWhereOrNull((k) => lookupRelationship[k] == value[i][key]);
          mapValue = objMapping[relationship!] ?? value[i][key];
        }
        if (widget.obj["mainTitleKey"] == key) {
          obj["mainTitle"] = mapValue;
        } else if (widget.obj["subTitleKey"] == key) {
          obj["subTitle"] = mapValue;
        } else if (widget.obj["infoShowKey"].indexOf(key) > -1) {
          if (obj["info"] == null) {
            if (widget.obj["info"] != null) {
              obj["info"] = json.decode(json.encode(widget.obj["info"]));
            } else {
              obj["info"] = {};
            }
          }

          if (key == "identitytype") {
            obj["info"][value[i][key]] = {};
            obj["info"][value[i][key]]["value"] = value[i][value[i][key]];
            obj["info"][value[i][key]]["label"] =
                getObjectByKey(inputList, value[i][key])["label"];
            continue;
          }

          obj["info"][key] = {};

          var result = getObjectByKey(inputList, key);
          obj["info"][key]["label"] =
              result != null && result["label"] != null ? result["label"] : "";
          // if (obj["info"][key]["label"].indexOf("/") > -1) {
          //   obj["info"][key]["label"] = obj["info"][key]["label"]
          //       .substring(0, obj["info"][key]["label"].indexOf("/"));
          // }

          //SPECIAL HANDLING
          if (key == "percentage") {
            var widgetKey = GlobalKey();
            obj["info"][key]["value"] = NumberPicker(
                key: widgetKey,
                obj: {
                  "value": mapValue,
                  "suffix": "%",
                  "max": 100,
                  "textHPadding": gFontSize * 0.6,
                },
                onChanged: (value) {
                  widget.obj["value"][i]["percentage"] = value;
                  if (widget.onChanged != null) {
                    widget.onChanged!({"onNumberChanged": true});
                  }
                });
            continue;
          }

          if (key == "dob") {
            obj["info"][key]["value"] = DateFormat('dd MMM yyyy')
                .format(DateTime.fromMicrosecondsSinceEpoch(mapValue));
            continue;
          }

          if (key == "mobileno") {
            obj["info"][key]["value"] = "+60 $mapValue";
            continue;
          }

          if (obj["mainTitle"] == null &&
              widget.obj["mainTitleLabel"] != null) {
            obj["mainTitle"] = widget.obj["mainTitleLabel"];
          } else if (obj["subTitle"] == null &&
              widget.obj["subTitleLabel"] != null) {
            obj["subTitle"] = widget.obj["subTitleLabel"];
          }

          //normal
          obj["info"][key]["value"] = mapValue;
        }
      }

      array.add(InfoCard(
          obj: obj,
          onEditTap: () {
            onEditTap(i);
          },
          onDeleteTap: () {
            onDeleteTap(i);
          }));

      if (i != 0) {
        array.add(SizedBox(width: gFontSize));
      }
    }

    return array;
  }

  Future<void> onAddTap() async {
    try {
      if (widget.nominee != null &&
          (widget.nominee.length == 0 || widget.nominee == "")) {
        showAlertDialog(
            context,
            "Notice",
            getLocale(
                "Please add at least one nominee if you want to appoint a trustee"));
      } else {
        final results = await Navigator.of(context)
            .push(createRoute(InputPage(inputList: getInput())));

        if (results != null) {
          setState(() {
            if (widget.obj["value"] is String) {
              widget.obj["value"] = [];
            }
            widget.obj["value"].add(results);
            if (widget.onChanged != null) {
              widget.onChanged!({"onAddChanged": true});
            }
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    var list = generateList();

    Widget addButton = CustomButton(
        label: widget.obj["buttonLabel"] ?? "+ ${getLocale("Add more")}",
        labelColor: cyanColor,
        height: height,
        width: gFontSize * 12,
        fontWeight: FontWeight.w500,
        padding:
            EdgeInsets.symmetric(vertical: gFontSize, horizontal: gFontSize),
        buttonColor: lightCyanColor,
        onPressed: () {
          onAddTap();
        });
    if (widget.obj["maximum"] != null &&
        widget.obj["maximum"] is int &&
        list.length >= widget.obj["maximum"]) {
      addButton = Container();
    }

    return RadioDropdown(
        obj: widget.obj,
        onChanged: (enabled) {
          widget.obj["value"] = enabled ? [] : "";
          if (widget.onChanged != null) {
            widget.onChanged!({"onRadioChanged": enabled});
          }
          height = gFontSize * 5;
          setState(() {});
        },
        child: Container(
            padding: EdgeInsets.only(bottom: gFontSize),
            child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: MeasureSize(
                    onChange: (size) {
                      setState(() {
                        height = size!.height;
                      });
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          addButton,
                          SizedBox(width: gFontSize),
                          ...list
                        ])))));
  }
}
