import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';

import 'package:flutter/material.dart';

class Witness extends StatefulWidget {
  final Function(dynamic obj) onChanged;
  const Witness({Key? key, required this.onChanged}) : super(key: key);
  @override
  WitnessState createState() => WitnessState();
}

class WitnessState extends State<Witness> {
  dynamic inputList;
  dynamic obj;
  bool isSignRemote = false;
  late dynamic widList;

  @override
  void initState() {
    super.initState();
    obj = ApplicationFormData.data["witness"];
    var standardObject = getGlobalInputJsonFormat();

    inputList = {
      "witness": {
        "fields": {"witness": standardObject["witness"]}
      }
    };
    inputList["witness"]["fields"]["witness"]["options"][1]["option_fields"]
        ["identitytype"]["clientType"] = "8";

    generateDataToObjectValue(obj, inputList);

    var gender = getObjectByKey(inputList, "gender");
    var salutation = getObjectByKey(inputList, "salutation");
    if (gender != null && gender["value"] != "" && salutation != null) {
      salutation["options"] = getMasterlookup(
          type: "Salutation", remark: ["E", gender["value"][0].toUpperCase()]);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInput();
      var result = getInputedData(inputList);
      obj = result;
      checkAllInfoValid(context);
      widget.onChanged(obj);
    });
    fieldValue("column", true, inputList["witness"]["fields"]);
  }

  void fieldValue(field, value, list) {
    var o = list;
    for (var key in o.keys) {
      if (o[key]["enabled"] != null && !o[key]["enabled"]) {
        continue;
      }
      if (o[key]["options"] != null) {
        for (var i = 0; i < o[key]["options"].length; i++) {
          if (o[key]["options"][i]["option_fields"] != null) {
            o[key][field] = value;
            fieldValue(field, value, o[key]["options"][i]["option_fields"]);
          } else {
            o[key][field] = value;
          }
        }
      } else {
        o[key][field] = value;
      }
    }
  }

  void checkAllInfoValid(context) {
    var temp = obj;
    if (temp["dob"] != null && temp["dob"] != "") {
      var date = DateTime.fromMicrosecondsSinceEpoch(temp["dob"]);
      if (getAge(date) < 18) {
        obj["error"] = getLocale("Age must be 18 and above");
        obj["empty"] = null;
      }
    }
  }

  void checkInput() {
    for (var item in (inputList["witness"]["fields"]["witness"]["options"]
        as List<dynamic>)) {
      if (item["label"] == "Others") {
        var remote = item["option_fields"]["remote"];
        setState(() {
          isSignRemote = remote["value"];
        });
        if (remote["value"]) {
          item["option_fields"]["signature"]["required"] = false;
        } else {
          item["option_fields"]["signature"]["required"] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      setState(() {
        checkInput();
        var result = getInputedData(inputList);
        obj = result;
        checkAllInfoValid(context);
        widget.onChanged(obj);
      });
    });

    List<Widget> generateWid() {
      List<Widget> inWidList = [];
      for (var wid in widList["witness"]) {
        if (wid["key"] == "signature") {
          inWidList.add(Visibility(
              visible: !isSignRemote,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: gFontSize * 1.5),
                    Text("Signature", style: bFontWN()),
                    SizedBox(height: gFontSize),
                    SizedBox(
                        height: gFontSize * 15,
                        child: Row(children: [
                          Expanded(flex: 70, child: wid["widget"]),
                          Expanded(flex: 30, child: Container())
                        ]))
                  ])));
          continue;
        }
        inWidList.add(wid["widget"]);
      }
      return inWidList;
    }

    return SingleChildScrollView(
        padding: EdgeInsets.only(
            top: gFontSize * 2,
            left: gFontSize * 3,
            right: gFontSize * 3,
            bottom: gFontSize * 2.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(getLocale("Declaration for Witness"), style: t1FontW5()),
          SizedBox(height: gFontSize * 1.5),
          Text(
              "* ${getLocale("Witness must be at least 18 years old, sound mind and cannot be a named nominee")}.",
              style: sFontWN().copyWith(color: Colors.red)),
          ...generateWid()
        ]));
  }
}
