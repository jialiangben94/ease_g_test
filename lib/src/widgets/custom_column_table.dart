import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CustomColumnTable extends StatelessWidget {
  final dynamic arrayObj;
  final TextStyle? valueFontStyle;
  final TextStyle? labelFontStyle;
  const CustomColumnTable(
      {Key? key,
      required this.arrayObj,
      this.valueFontStyle,
      this.labelFontStyle})
      : assert(arrayObj != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;
    List<Widget> inWidList = [];
    var length = arrayObj.length;

    for (var i = 0; i < length; i++) {
      List<Widget> array = [];

      int? labelWidth = length > 1 ? 35 : 20;
      int? valueWidth = length > 1 ? 65 : 80;
      if (arrayObj[i]["size"] != null) {
        if (arrayObj[i]["size"]["labelWidth"] != null) {
          labelWidth = arrayObj[i]["size"]["labelWidth"];
        }
        if (arrayObj[i]["size"]["valueWidth"] != null) {
          valueWidth = arrayObj[i]["size"]["valueWidth"];
        }
      }
      int count = 0;
      var check = arrayObj[i].keys.toList();
      for (var key in arrayObj[i].keys) {
        count++;
        if (key == "title") continue;
        if (key == "size") continue;
        if (key == "naText") continue;

        Widget? value;
        if (arrayObj[i][key]["value"] != null &&
            arrayObj[i][key]["value"] is Widget) {
          value = arrayObj[i][key]["value"];
        }

        if (arrayObj[i][key].isEmpty) {
          value = Container();
        }

        if (value == null) {
          var text = arrayObj[i]["naText"] ?? "N/A";
          if (arrayObj[i][key]["value"] != null &&
              arrayObj[i][key]["value"] != "null" &&
              arrayObj[i][key]["value"] != "") {
            text = arrayObj[i][key]["value"];
          }
          value = Padding(
              padding: EdgeInsets.only(left: gFontSize),
              child: Text(text.toString(), style: valueFontStyle ?? bFontWN()));
        }

        Widget? label;
        if (arrayObj[i][key]["label"] != null &&
            arrayObj[i][key]["label"] is Widget) {
          label = arrayObj[i][key]["label"];
        }

        label ??= Text(arrayObj[i][key]["label"] ?? "",
            style: labelFontStyle ?? bFontWN().copyWith(color: greyTextColor));
        EdgeInsets? padding = EdgeInsets.only(bottom: gFontSize * 0.4);
        if (arrayObj[i].keys.length == count ||
            check[count] == "title" ||
            check[count] == "size") {
          padding = null;
        }

        array.add(Container(
            padding: padding,
            child: Row(children: [
              Expanded(flex: labelWidth!, child: label),
              Expanded(flex: valueWidth!, child: value)
            ])));
      }

      inWidList.add(Container(
          padding: EdgeInsets.only(bottom: gFontSize * 0.8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            arrayObj[i]["title"] != null
                ? Text(arrayObj[i]["title"], style: bFontWN())
                : Container(),
            SizedBox(height: gFontSize * 0.8),
            ...array
          ])));
    }

    var count = length > 1 ? 2 : 1;

    return StaggeredGrid.count(crossAxisCount: count, children: inWidList);
  }
}
