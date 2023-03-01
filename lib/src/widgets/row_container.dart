import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class RowContainer extends StatelessWidget {
  final dynamic arrayObj;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const RowContainer(
      {Key? key,
      required this.arrayObj,
      this.color,
      this.padding,
      this.height,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.mainAxisAlignment = MainAxisAlignment.start})
      : assert(arrayObj != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    Color? colorr = color ?? lightCyanColor;
    EdgeInsetsGeometry? ppadding = padding ??
        EdgeInsets.symmetric(vertical: gFontSize, horizontal: gFontSize * 1.7);

    List<Widget> row = [];
    for (var i = 0; i < arrayObj.length; i++) {
      var size = arrayObj[i]["size"] ?? 100 ~/ arrayObj.length;
      if (arrayObj[i]["value"] is Widget) {
        row.add(Expanded(flex: size, child: arrayObj[i]["value"]));
      } else {
        var text = arrayObj[i]["value"] ?? "";
        row.add(Expanded(
            flex: size,
            child: Text(text.toString(),
                style: arrayObj[i]["font"] ?? bFontWN())));
      }
    }
    return Container(
        height: height,
        color: colorr,
        padding: ppadding,
        child: Row(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: row));
  }
}
