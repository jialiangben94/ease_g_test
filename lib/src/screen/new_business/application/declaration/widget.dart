import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

List<Widget> signatureContent(widList, inputList) {
  List<Widget> inWidList = [];

  for (var key in widList.keys) {
    if (key.indexOf("Identity") > -1) {
      inWidList.add(Text(inputList[key]["fields"]["signature"]["headerLabel"],
          style: bFontW5()));
      inWidList.add(widList[key][0]["widget"]);
      if (inputList[key]["fields"]["remote"] != null &&
          !inputList[key]["fields"]["remote"]["value"]) {
        Widget? identityCam1;
        Widget? identityCam2;
        if (widList[key].length > 1) {
          identityCam1 =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inputList[key]["fields"][widList[key][2]["key"]]["label"],
                style: bFontWN().copyWith(color: greyTextColor)),
            SizedBox(height: gFontSize * 0.6),
            SizedBox(height: gFontSize * 7, child: widList[key][2]["widget"])
          ]);
        }
        if (widList[key].length > 2) {
          identityCam2 =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inputList[key]["fields"][widList[key][3]["key"]]["label"],
                style: bFontWN().copyWith(color: greyTextColor)),
            SizedBox(height: gFontSize * 0.6),
            SizedBox(height: gFontSize * 7, child: widList[key][3]["widget"])
          ]);
        }
        inWidList.add(Row(children: [
          SizedBox(
              height: gFontSize * 15,
              width: gFontSize * 23,
              child: widList[key][1]["widget"]),
          Expanded(flex: 3, child: Container()),
          Expanded(flex: 17, child: identityCam1 ?? Container()),
          Expanded(flex: 3, child: Container()),
          Expanded(flex: 17, child: identityCam2 ?? Container())
        ]));
      }

      inWidList.add(SizedBox(height: gFontSize * 1.5));
    }
  }
  return inWidList;
}
