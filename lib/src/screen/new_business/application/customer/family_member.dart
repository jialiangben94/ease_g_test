import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/input_page.dart';
import 'package:ease/src/screen/new_business/application/obj_mapping.dart';
import 'package:ease/src/screen/new_business/application/utils/lookup_map.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/info_card.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FamilyMember extends StatefulWidget {
  final dynamic obj;
  final Function(dynamic obj) onChanged;
  const FamilyMember({Key? key, required this.onChanged, this.obj})
      : super(key: key);

  @override
  FamilyMemberState createState() => FamilyMemberState();
}

class FamilyMemberState extends State<FamilyMember> {
  var widList = [];
  dynamic inputList;
  dynamic inputList2;
  dynamic obj = {};

  @override
  void initState() {
    super.initState();
    if (widget.obj != null) obj = widget.obj;
    inputList = {
      "familyMember": {"value": []}
    };

    if (obj.isNotEmpty) {
      inputList["familyMember"]["value"] = obj;
    }

    initOrResetInput();
  }

  void initOrResetInput() {
    var standardObject = getGlobalInputJsonFormat();
    inputList2 = {
      "familyMember": {
        "title": getLocale("Add Family Member"),
        "fields": {
          "relationship": standardObject["relationshipPO"],
          // "salutation": standardObject["salutation"],
          "name": standardObject["name"],
          "identitytype": standardObject["identitytype"],
          "gender": standardObject["gender"],
          "dob": standardObject["dob"],
          "yeartosupport": standardObject["yeartosupport"]
        }
      }
    };
    inputList2["familyMember"]["fields"]["identitytype"]["required"] = false;
    inputList2["familyMember"]["fields"]["identitytype"]["options"]
        .forEach((options) {
      options["option_fields"][options["value"]]["required"] = false;
      if (options["option_fields"]["nric"] != null) {
        options["option_fields"]["nric"]["required"] = false;
        options["option_fields"]["oldic"]["required"] = false;
      }
      options["option_fields"].remove("countryofbirth");
      options["option_fields"].remove("nationality");
    });
    fieldValue("column", true);
  }

  void fieldValue(field, value) {
    var o = inputList2["familyMember"]["fields"];
    for (var key in o.keys) {
      if (o[key]["enabled"] != null && !o[key]["enabled"]) {
        continue;
      }
      if (key == "identitytype") {
        if (value != "") {
          o[key][field] = value;
        }
        for (var i = 0; i < o[key]["options"].length; i++) {
          for (var key2 in o[key]["options"][i]["option_fields"].keys) {
            o[key]["options"][i]["option_fields"][key2][field] = value;
          }
        }
      } else {
        o[key][field] = value;
      }
    }
  }

  dynamic generateDetailsContainer(obj, index) {
    String? relation = objMapping[obj["relationship"]];
    var object = {
      "mainTitle": obj["name"],
      "subTitle": relation,
      "info": {
        "size": {"labelWidth": 50, "valueWidth": 50},
        "naText": ""
      }
    };

    for (var key in obj.keys) {
      if (key == "name" ||
          key == "relationship" ||
          key == "salutation" ||
          key == "identitytype") continue;
      var result = getObjectByKey(inputList2, key);
      if (result == null || result["label"] == null || result["label"] == "") {
        continue;
      }
      object["info"][key] = {};

      object["info"][key]["label"] =
          result != null && result["label"] != null ? result["label"] : "";

      if (result["options"] is List) {
        var index = result["options"]
            .indexWhere((option) => option["value"] == result["value"]);
        if (index > -1) {
          object["info"][key]["value"] = result["options"][index]["label"];
        }
      }

      if (key == "dob") {
        object["info"][key]["value"] = DateFormat('dd MMM yyyy')
            .format(DateTime.fromMicrosecondsSinceEpoch(obj[key]));
        continue;
      }
      object["info"][key]["value"] = obj[key];
    }
    return InfoCard(
        obj: object,
        onEditTap: () {
          onEditTap(obj, index);
        },
        onDeleteTap: () {
          onDeleteTap(obj, index);
        });
  }

  void onDeleteTap(obj, index) async {
    var result = await showConfirmDialog(context, getLocale("Delete"),
        "${getLocale("Are you sure you want to delete")} ${obj["name"]}?");
    if (result != null && result) {
      setState(() {
        inputList["familyMember"]["value"].removeAt(index);
        obj = inputList["familyMember"]["value"];
        widget.onChanged(obj);
      });
    }
  }

  dynamic onEditTap(obj, index) async {
    generateDataToObjectValue(obj, inputList2);

    var results = await Navigator.of(context)
        .push(createRoute(InputPage(inputList: inputList2)));

    if (results != null) {
      if (isNumeric(results["relationship"])) {
        var relationship = lookupRelationship.keys.firstWhere(
            (k) => lookupRelationship[k] == results["relationship"]);
        results["relationship"] = relationship;
      }
      setState(() {
        inputList["familyMember"]["value"][index] = results;
        obj = inputList["familyMember"]["value"];
        widget.onChanged(obj);
      });
    }
  }

  void onAddTap() async {
    initOrResetInput();

    var results = await Navigator.of(context)
        .push(createRoute(InputPage(inputList: inputList2)));

    if (results != null) {
      if (isNumeric(results["relationship"])) {
        var relationship = lookupRelationship.keys.firstWhere(
            (k) => lookupRelationship[k] == results["relationship"]);
        results["relationship"] = relationship;
      }
      setState(() {
        inputList["familyMember"]["value"].add(results);
        obj = inputList["familyMember"]["value"];
        widget.onChanged(obj);
      });
    }
  }

  List<Widget> generateList(obj) {
    if (obj != null &&
        obj["value"] != null &&
        obj["value"] != "" &&
        obj["value"].length > 0) {
      List<Widget> list = [];
      for (var i = obj["value"].length - 1; i > -1; i--) {
        list.add(generateDetailsContainer(obj["value"][i], i));
      }
      return list;
    } else {
      return [Container(width: 0)];
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = generateList(inputList["familyMember"]);
    return Container(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
              onTap: () {
                onAddTap();
              },
              child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(gFontSize * 1.5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(gFontSize * 0.8),
                      color: const Color.fromRGBO(227, 244, 242, 1)),
                  child: Text("+ ${getLocale("Add Family Member's Details")}",
                      style: t1FontW5()))),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: gFontSize,
              crossAxisSpacing: gFontSize,
              children: list)
        ]));
  }
}
