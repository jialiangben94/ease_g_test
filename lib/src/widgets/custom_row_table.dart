import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';

class CustomRowTable extends StatelessWidget {
  final dynamic arrayObj;
  final Color? headerColor;
  final EdgeInsets? headerPadding;
  final EdgeInsets? rowPadding;
  final TextStyle? headerFontStyle;
  final TextStyle? rowFontStyle;
  final Color? rowColor;
  final Border? headerBorder;
  final Border? rowBorder;
  final bool disableBorder;

  const CustomRowTable(
      {Key? key,
      required this.arrayObj,
      this.headerColor,
      this.headerFontStyle,
      this.headerPadding,
      this.headerBorder,
      this.rowFontStyle,
      this.rowColor,
      this.rowPadding,
      this.rowBorder,
      this.disableBorder = false})
      : assert(arrayObj != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (arrayObj["header"] == null) {
      throw ("Missing header");
    }

    List<Widget> valueRow = [];
    List<Widget> titleRow = [];

    TextStyle? hFontStyle =
        headerFontStyle ?? sFontWN().copyWith(color: greyTextColor);
    TextStyle? rFontStyle = rowFontStyle ?? bFontW5();
    Color? rColor = rowColor ?? Colors.transparent;
    Color hColor = headerColor ?? creamColor;

    EdgeInsets? rPadding = rowPadding is EdgeInsets
        ? rowPadding
        : EdgeInsets.symmetric(
            vertical: gFontSize * 0.7, horizontal: gFontSize * 1.5);
    EdgeInsets? hPadding = headerPadding ?? rPadding;

    Border? hborder = headerBorder;
    Border? rBorder = rowBorder ??
        Border(
            bottom: BorderSide(color: Colors.black, width: gFontSize * 0.01));

    if (disableBorder) {
      hborder = null;
      rBorder = null;
    }

    for (var i = 0; i < arrayObj["value"].length; i++) {
      int? size = 100 ~/ arrayObj["header"].keys.length;
      List<Widget> array = [];
      List<Widget> array2 = [];
      for (var key in arrayObj["header"].keys) {
        if (key == "emptyText") continue;
        if (key == "naText") continue;
        if (arrayObj["header"][key]["size"] != null) {
          size = arrayObj["header"][key]["size"];
        }
        String? append = "";
        if (arrayObj["header"][key]["append"] != null &&
            arrayObj["header"][key]["append"] is String) {
          append = arrayObj["header"][key]["append"];
        }
        if (titleRow.isEmpty) {
          if (arrayObj["header"][key]["value"] is Widget) {
            array2.add(
                Expanded(flex: size!, child: arrayObj["header"][key]["value"]));
          } else {
            array2.add(Expanded(
                flex: size!,
                child: Text(arrayObj["header"][key]["value"].toString(),
                    style: hFontStyle)));
          }
        }
        if (arrayObj["value"][i][key] != null &&
            arrayObj["value"][i][key] is Widget) {
          array.add(Expanded(flex: size!, child: arrayObj["value"][i][key]));
        } else if (arrayObj["value"][i][key] != null) {
          array.add(Expanded(
              flex: size!,
              child: Text(arrayObj["value"][i][key].toString() + append!,
                  style: arrayObj["header"][key]["rowFont"] ?? rFontStyle)));
        } else if (!arrayObj["value"][i].isEmpty &&
            arrayObj["value"][i][key] == null) {
          array.add(Expanded(
              flex: size!,
              child: Text(arrayObj["header"]["naText"] ?? "N/A",
                  style: arrayObj["header"][key]["rowFont"] ?? rFontStyle)));
        }
      }

      if (titleRow.isEmpty) {
        titleRow.add(Container(
            padding: hPadding,
            decoration: BoxDecoration(border: hborder, color: hColor),
            child: Row(children: array2)));
      }

      if (array.isNotEmpty) {
        if (arrayObj["value"].length == i + 1) rBorder = null;
        valueRow.add(Container(
            padding: rPadding,
            decoration: BoxDecoration(border: rBorder, color: rColor),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: array)));
      }
    }

    if (valueRow.isEmpty) {
      valueRow.add(Container(
          padding: rPadding,
          child: Center(
              child: Text(arrayObj["header"]["emptyText"] ?? "No Data",
                  style: bFontWN()))));
    }

    return Column(children: [...titleRow, ...valueRow]);
  }
}
