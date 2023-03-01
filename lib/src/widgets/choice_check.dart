import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_border.dart';
import 'package:ease/src/widgets/check_circle.dart';
import 'package:flutter/material.dart';

class ChoiceCheckContainer extends StatefulWidget {
  final bool disableBorder;
  final bool displayLabel;
  final bool textColorChange;
  final bool mergeOption;
  final bool? setHeight;
  final Color? fontColor;
  final double? fontSize;
  final double? optionHeight;
  final dynamic obj;
  final EdgeInsets? columnPadding;
  final EdgeInsets? containerPadding;
  final FontWeight? fontWeight;
  final EdgeInsets? labelPadding;
  final EdgeInsets? optionPadding;
  final EdgeInsets? rowPadding;
  final Function(dynamic value, dynamic val)? confirmBeforeChange;
  final Function(dynamic value)? onChanged;

  const ChoiceCheckContainer(
      {Key? key,
      this.obj,
      this.onChanged,
      this.rowPadding,
      this.columnPadding,
      this.textColorChange = false,
      this.optionPadding,
      this.optionHeight,
      this.containerPadding,
      this.fontWeight,
      this.fontSize,
      this.mergeOption = false,
      this.fontColor,
      this.disableBorder = false,
      this.labelPadding,
      this.displayLabel = true,
      this.setHeight,
      this.confirmBeforeChange})
      : super(key: key);

  // {
  //   "size": {"textWidth": 85, "fieldWidth": 45, "emptyWidth": 50},
  //   "label": "",
  //   "type": "option2",
  //   "options": [],
  //   "value": "",
  //   "required": true,
  //   "column": true,
  //   "optionColumn": true,
  //   "check": true,
  //   "checkBack": true,
  // }

  @override
  ChoiceCheckContainerState createState() => ChoiceCheckContainerState();
}

class ChoiceCheckContainerState extends State<ChoiceCheckContainer> {
  bool readOnly = false;
  EdgeInsets? rowPadding;
  EdgeInsets? columnPadding;
  EdgeInsets? optionPadding;
  double? optionHeight;

  @override
  void initState() {
    super.initState();
    rowPadding = widget.rowPadding;
    columnPadding = widget.columnPadding;
    optionPadding = widget.optionPadding;
    optionHeight = widget.optionHeight;
    readOnly = widget.obj["readOnly"] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    bool enabled = widget.obj["enabled"] ?? true;
    if (!enabled) {
      return const SizedBox();
    }
    if (rowPadding == null &&
        (widget.obj["optionColumn"] == null || !widget.obj["optionColumn"])) {
      rowPadding = EdgeInsets.only(right: gFontSize * 0.5);
    }
    if (rowPadding == null &&
        widget.obj["optionColumn"] != null &&
        widget.obj["optionColumn"]) {
      rowPadding = EdgeInsets.only(bottom: gFontSize * 0.5);
    }

    optionPadding ??= EdgeInsets.symmetric(
        horizontal: gFontSize * 0.8, vertical: gFontSize * 0.5);

    optionHeight ??= gFontSize * 3.5;

    bool column = false;
    if (widget.obj["column"] != null && widget.obj["column"]) {
      column = true;
    }

    if (column && (widget.obj["size"] == null || widget.obj["size"].isEmpty)) {
      widget.obj["size"] = {
        "textWidth": 85,
        "fieldWidth": 70,
        "emptyWidth": 30
      };
    }

    bool isExpanded = false;
    if (widget.obj["expand"] != null && widget.obj["expand"]) {
      isExpanded = true;
    }

    if (isExpanded &&
        (widget.obj["size"] == null || widget.obj["size"].isEmpty)) {
      widget.obj["size"] = {
        "textWidth": 86,
        "fieldWidth": 80,
        "emptyWidth": 16
      };
    }

    if (widget.obj["size"] == null || widget.obj["size"].isEmpty) {
      widget.obj["size"] = {
        "textWidth": 22,
        "fieldWidth": 70,
        "emptyWidth": 10
      };
    }

    var radius = Radius.circular(gFontSize * 0.3);

    var borderRadius = BorderRadius.all(radius);

    Widget generateTextContainer(v, isLast, isFirst) {
      var textColor = widget.fontColor ?? Colors.black;
      var borderColor = greyBorderTFColor;
      // var radioFont = gFontSize * 1.5;
      Widget checked =
          const CheckCircle(checked: false, padding: EdgeInsets.all(0));
      if (v["active"] != null && !v["active"]) {
        return Container();
      }
      BorderSide? top, bottom, left, right;

      // var border = Border.all(width: gFontSize * 0.1, color: borderColor);

      if (widget.obj["value"] == v["value"]) {
        textColor = widget.textColorChange ? cyanColor : Colors.black;
        borderColor = cyanColor;
        checked = const CheckCircle(checked: true, padding: EdgeInsets.all(0));
      }

      top = bottom =
          left = right = BorderSide(width: gFontSize * 0.1, color: borderColor);
      if (widget.mergeOption) {
        if (widget.obj["value"] != v["value"]) {
          if (isLast) {
            left = null;
          } else {
            right = null;
          }
        }
        if (widget.obj["value"] == null || widget.obj["value"] == "") {
          if (isFirst) right = top;
        }
      }

      Widget? label;
      if (v["label"] is Widget) {
        label = v["label"];
      } else {
        label = Text(v["label"].toString(),
            style: bFontWN().copyWith(
                fontSize: widget.fontSize,
                color: textColor,
                fontWeight: widget.fontWeight));
      }

      if (widget.obj["check"] == null && widget.obj["checkBack"] == null) {
        label = Expanded(child: Center(child: label));
      } else {
        label = Expanded(child: label!);
      }

      if (widget.mergeOption) {
        if (isFirst) borderRadius = BorderRadius.horizontal(left: radius);
        if (isLast) borderRadius = BorderRadius.horizontal(right: radius);
      }

      return GestureDetector(
          onTap: () {
            if (!readOnly) {
              if (widget.confirmBeforeChange != null) {
                widget.confirmBeforeChange!(v["value"], (change) {
                  if (change) {
                    widget.obj["value"] = v["value"];
                    if (widget.onChanged != null) widget.onChanged!(v["value"]);
                    setState(() {});
                  }
                });
              } else {
                widget.obj["value"] = v["value"];
                if (widget.onChanged != null) widget.onChanged!(v["value"]);
                setState(() {});
              }
            }
          },
          child: Container(
              height: widget.setHeight != null && !widget.setHeight!
                  ? null
                  : optionHeight,
              padding: optionPadding,
              decoration: widget.disableBorder
                  ? null
                  : ShapeDecoration(
                      shape: CustomBorder(
                          borderRadius: borderRadius,
                          left: left,
                          top: top,
                          bottom: bottom,
                          right: right,
                          topLeftCorner: top,
                          topRightCorner: top,
                          bottomLeftCorner: top,
                          bottomRightCorner: top)),
              // BoxDecoration(
              //     border: border,
              //     // borderRadius: borderRadius
              //     ),
              child: Row(children: [
                widget.obj["check"] != null && widget.obj["check"]
                    ? Container(
                        padding: widget.labelPadding ??
                            EdgeInsets.only(right: gFontSize),
                        child: checked)
                    : const SizedBox(),
                label,
                widget.obj["checkBack"] != null && widget.obj["checkBack"]
                    ? Container(child: checked)
                    : const SizedBox()
              ])));
    }

    List<Widget> generateOption() {
      List<Widget> widList = [];
      var count = 0;
      for (var v in widget.obj["options"]) {
        var isFirst = count == 0;
        count++;
        var isLast = count == widget.obj["options"].length;
        var label = generateTextContainer(v, isLast, isFirst);

        EdgeInsets? padding;
        if (widget.obj["optionColumn"] != null && widget.obj["optionColumn"]) {
          widList.add(Container(child: label));
          padding = rowPadding;
        } else {
          widList.add(Expanded(child: label));
          padding = rowPadding;
        }
        if (!isLast) {
          widList.add(Container(padding: padding));
        }
      }
      return widList;
    }

    Widget fieldLayout;
    if (widget.obj["optionColumn"] != null && widget.obj["optionColumn"]) {
      fieldLayout = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: generateOption());
    } else {
      fieldLayout =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: generateOption()),
        if (widget.obj["notice"] != null)
          Padding(
              padding: EdgeInsets.symmetric(vertical: gFontSize * 0.5),
              child: Text(widget.obj["notice"],
                  style: ssFontWN().copyWith(color: scarletRedColor)))
      ]);
    }

    var field = Expanded(
        flex: widget.obj["size"]["fieldWidth"],
        child: Container(child: fieldLayout));

    Widget labelWidget;
    if (widget.obj["required"] == true) {
      labelWidget = RichText(
          text: TextSpan(
              text: widget.obj["label"] ?? "",
              style: bFontWN(),
              children: <TextSpan>[
            TextSpan(
                text: "*", style: bFontWN().copyWith(color: scarletRedColor))
          ]));
    } else {
      labelWidget = Text(widget.obj["label"] ?? "", style: bFontWN());
    }

    return Container(
        padding: widget.containerPadding ??
            EdgeInsets.symmetric(vertical: gFontSize * 0.5),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            widget.obj["label"] != null && widget.displayLabel != false
                ? Expanded(
                    flex: widget.obj["size"]["textWidth"], child: labelWidget)
                : Container(),
            !column ? field : Container(),
            Expanded(flex: widget.obj["size"]["emptyWidth"], child: Container())
          ]),
          column ? Container(height: gFontSize) : Container(),
          column
              ? Row(children: [
                  field,
                  Expanded(
                      flex: widget.obj["size"]["emptyWidth"],
                      child: Container())
                ])
              : Container()
        ]));
  }
}
