import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/check_circle.dart';
import 'package:ease/src/widgets/expandable_container.dart';
import 'package:flutter/material.dart';

class RadioDropdown extends StatefulWidget {
  final dynamic obj;
  final bool radioShow;
  final bool disableDivider;
  final bool disableDividerTop;
  final bool disableDividerBottom;
  final EdgeInsets? padding;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingTop;
  final double? paddingBottom;
  final String label;
  final TextStyle? labelFont;
  final double? labelSize;
  final FontWeight? labelWeight;
  final Color? labelColor;
  final int labelFlex;
  final bool checkCircle;
  final int checkFlex;

  final bool disableAnimation;
  final int animateDuration;
  final Widget? child;
  final Function(bool value) onChanged;

  const RadioDropdown(
      {Key? key,
      this.obj,
      this.radioShow = false,
      this.disableDivider = false,
      this.disableDividerTop = false,
      this.disableDividerBottom = false,
      this.padding,
      this.paddingLeft,
      this.paddingRight,
      this.paddingTop,
      this.paddingBottom,
      this.label = "",
      this.labelFont,
      this.labelSize,
      this.labelWeight,
      this.labelColor,
      this.labelFlex = 93,
      this.checkCircle = false,
      this.checkFlex = 7,
      this.child,
      this.animateDuration = 500,
      this.disableAnimation = false,
      required this.onChanged})
      : super(key: key);

  @override
  RadioDropdownState createState() => RadioDropdownState();
}

class RadioDropdownState extends State<RadioDropdown> {
  late Widget divider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic obj = widget.obj ?? {};

    bool radioShow = obj["radioShow"] ?? widget.radioShow;
    bool disableDivider = obj["disableDivider"] ?? widget.disableDivider;
    bool disableDividerTop =
        obj["disableDividerTop"] ?? widget.disableDividerTop;
    bool disableDividerBottom =
        obj["disableDividerBottom"] ?? widget.disableDividerBottom;

    EdgeInsets padding = obj["padding"] ??
        widget.padding ??
        EdgeInsets.symmetric(vertical: gFontSize * 1.1, horizontal: gFontSize);
    padding = EdgeInsets.only(
        right:
            (obj["paddingRight"] ?? widget.paddingRight ?? padding.right ?? 0.0)
                .toDouble(),
        left: (obj["paddingLeft"] ?? widget.paddingLeft ?? padding.left ?? 0.0)
            .toDouble(),
        top: (obj["paddingTop"] ?? widget.paddingTop ?? padding.top ?? 0.0)
            .toDouble(),
        bottom: (obj["paddingBottom"] ??
                widget.paddingBottom ??
                padding.bottom ??
                0.0)
            .toDouble());

    String label = obj["label"] ?? widget.label ?? "";
    double labelSize =
        obj["labelSize"] ?? widget.labelSize ?? t2FontW5().fontSize;
    Color labelColor =
        obj["labelColor"] ?? widget.labelColor ?? t2FontW5().color;
    FontWeight labelWeight =
        obj["labelWeight"] ?? widget.labelWeight ?? t2FontW5().fontWeight;
    TextStyle labelFont = obj["labelFont"] ??
        widget.labelFont ??
        t2FontW5().copyWith(
            fontSize: labelSize, color: labelColor, fontWeight: labelWeight);

    divider = disableDivider
        ? const SizedBox()
        : Divider(thickness: gFontSize * 0.1, height: 0);

    bool checkCircle = obj["checkCircle"] ?? widget.checkCircle;

    int checkFlex = obj["checkFlex"] ?? widget.checkFlex;
    int labelFlex = obj["labelFlex"] ?? widget.labelFlex;

    bool disableAnimation = obj["disableAnimation"] ?? widget.disableAnimation;
    int animateDuration = obj["animateDuration"] ?? widget.animateDuration;

    var checkCircleContent = checkCircle
        ? Expanded(
            flex: checkFlex,
            child: CheckCircle(
                alignment: Alignment.centerLeft,
                checked: radioShow,
                padding: const EdgeInsets.all(0)))
        : const SizedBox();

    List<Widget> array = [
      checkCircleContent,
      Expanded(flex: labelFlex, child: Text(label, style: labelFont))
    ];

    Widget clickable = GestureDetector(
        onTap: () {
          setState(() {
            radioShow = !radioShow;
            widget.onChanged(radioShow);
          });
        },
        child: Row(children: array));

    Widget content = Container(padding: padding, child: clickable);

    Widget nonAnimateContainer =
        radioShow ? Container(child: widget.child) : const SizedBox();

    Widget wid = disableAnimation
        ? nonAnimateContainer
        : ExpandableContainer(
            expanded: radioShow,
            duration: animateDuration,
            child: widget.child);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      !disableDividerTop ? divider : const SizedBox(),
      content,
      wid,
      !disableDividerBottom ? divider : const SizedBox()
    ]);
  }
}
