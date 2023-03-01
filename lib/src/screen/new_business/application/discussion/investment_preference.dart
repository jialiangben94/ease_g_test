import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/input_json_format.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class InvestmentPreference extends StatefulWidget {
  final VoidCallback callback;

  const InvestmentPreference({Key? key, required this.callback})
      : super(key: key);

  @override
  InvestmentPreferenceState createState() => InvestmentPreferenceState();
}

class InvestmentPreferenceState extends State<InvestmentPreference> {
  late dynamic widList;
  dynamic inputList;
  dynamic obj;

  @override
  void initState() {
    super.initState();
    obj = ApplicationFormData.data["investmentPreference"];
    inputList = {
      "investmentpreference": {
        "type": "sliderInt",
        "min": 1.0,
        "max": 5.0,
        "divisions": 4,
        "required": true,
        "value": 1.0,
        "options": [
          "1\n${getLocale("Secure")}",
          "2\n${getLocale("Stable")}",
          "3\n${getLocale("Neutral")}",
          "4\n${getLocale("Growth")}",
          "5\n${getLocale("High Growth")}"
        ]
      },
      "investmentpreferencemsg": {
        "type": "info",
        "label": getLocale("Check out how this works"),
        "show": true,
        "required": false,
        "text": """<div><br><b>${getLocale("Description")}</b></div><br><br>
<table>
<colgroup><col width="10%" /><col width="80%" /><col width="10%" /></colgroup>
  <tr><td>1.</td><td><b>${getLocale("Low Risk, Low Potential Return")}</b><br>${getLocale("You are seeking better return than time deposits. You want to preserve capital as much as possible but are prepared to accept minimal losses.")}<br></td></tr>
  <tr><td>2.</td><td>${getLocale("You are seeking returns significantly better than time deposits. You are prepared to accept more than minimal losses for potential returns")}.<br></td></tr>
  <tr><td>3.</td><td>${getLocale("You are seeking moderate capital growth. You are willing to accept moderate risks and losses for potential returns")}.<br></td></tr>
  <tr><td>4.</td><td>${getLocale("You are seeking higher capital growth and are willing to accept higher risks and losses, for potential to get higher returns")}.<br></td></tr>
  <tr><td>5.</td><td><b>${getLocale("High Risk, High Potential Return")}</b><br>${getLocale("You are seeking aggresive capital growth and are willing to accept significantly higher risks and losses, for potential maximum returns")}.<br></td></tr>
</table>
"""
      }
    };

    generateDataToObjectValue(obj, inputList);
  }

  @override
  Widget build(BuildContext context) {
    widList = generateInputField(context, inputList, (key) {
      setState(() {
        var result = getInputedData(inputList);
        obj = result;
        ApplicationFormData.data["investmentPreference"] = obj;
        widget.callback();
      });
    });

    return Container(
        height: screenHeight * 0.91,
        padding: EdgeInsets.symmetric(horizontal: gFontSize * 3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: gFontSize * 2),
          Text(getLocale("Customer's Investment Preference"),
              style: t1FontW5()),
          for (var wid in widList) wid["widget"]
        ]));
  }
}
