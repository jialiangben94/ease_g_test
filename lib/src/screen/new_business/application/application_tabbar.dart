import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';

import 'package:flutter/material.dart';

class ApplicationTabBar extends StatelessWidget {
  final dynamic tabList;
  final Function(dynamic obj) onTap;

  const ApplicationTabBar({Key? key, this.tabList, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tabItem(obj) {
      var borderColor = Colors.transparent;

      var textColor = const Color.fromRGBO(135, 135, 135, 1);
      var iconColor = const Color.fromRGBO(170, 170, 170, 1);
      FontWeight titleFontWeight = FontWeight.normal;

      if (obj["completed"]) {
        textColor = const Color.fromRGBO(72, 158, 147, 1);
        iconColor = const Color.fromRGBO(72, 158, 147, 1);
      } else if (obj["active"]) {
        textColor = Colors.black;
      }
      if (obj["active"]) {
        titleFontWeight = FontWeight.w500;
      }

      if (obj["active"]) {
        borderColor = honeyColor;
      }

      return GestureDetector(
          onTap: () {
            onTap(obj);
          },
          child: Container(
              padding: EdgeInsets.all(gFontSize * 0.5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: borderColor, width: gFontSize * 0.2))),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(obj["label"],
                    overflow: TextOverflow.ellipsis,
                    style: bFontWN().copyWith(
                        color: textColor, fontWeight: titleFontWeight)),
                obj["required"] != null && obj["required"]
                    ? Icon(Icons.check, size: gFontSize * 0.9, color: iconColor)
                    : Text(getLocale("(Optional)"), style: ssFontWN())
              ])));
    }

    List<Widget> tabs = [];
    var size = 100;
    for (var key in tabList.keys) {
      if (tabList[key]["enabled"] == false) continue;
      size = size - tabList[key]["size"] as int;
      tabs.add(
          Expanded(flex: tabList[key]["size"], child: tabItem(tabList[key])));
    }

    tabs.add(Expanded(flex: size, child: Container()));
    return Row(children: tabs);
  }
}
