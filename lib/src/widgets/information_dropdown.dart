import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/expandable_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

class InformationDropdown extends StatefulWidget {
  final dynamic obj;
  final String? html;
  final dynamic style;
  final String? label;
  final bool? show;
  final EdgeInsets? padding;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingTop;
  final double? paddingBottom;

  const InformationDropdown(
      {Key? key,
      this.obj,
      this.html,
      this.style,
      this.label,
      this.show = false,
      this.padding,
      this.paddingLeft,
      this.paddingRight,
      this.paddingTop,
      this.paddingBottom})
      : super(key: key);

  @override
  InformationDropdownState createState() => InformationDropdownState();
}

class InformationDropdownState extends State<InformationDropdown> {
  bool? show;

  @override
  void initState() {
    super.initState();
    show = widget.show;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    dynamic obj = widget.obj ?? {};

    EdgeInsets padding = obj["padding"] ??
        widget.padding ??
        EdgeInsets.symmetric(vertical: gFontSize * 2);

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
          .toDouble(),
    );

    return Container(
        padding: padding,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
              onTap: () {
                setState(() {
                  show = !show!;
                });
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Icon(Icons.info_outline,
                    size: gFontSize * 1.5, color: cyanColor),
                SizedBox(width: gFontSize * 0.5),
                Text(widget.label!,
                    style: bFontWN().copyWith(color: cyanColor)),
                SizedBox(width: gFontSize * 0.5),
                Icon(
                    !show!
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: cyanColor,
                    size: gFontSize * 1.2)
              ])),
          ExpandableContainer(
              expanded: show,
              child: Html(
                  data: widget.html,
                  customRenders: {
                    tagMatcher("table"): CustomRender.widget(
                        widget: (context, buildChildren) =>
                            SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: tableRender
                                    .call()
                                    .widget!
                                    .call(context, buildChildren)))
                  },
                  style: widget.style ??
                      {
                        "html": Style(
                            fontSize: FontSize(gFontSize * 0.85),
                            color: Colors.black),
                        "td": Style(alignment: Alignment.topLeft)
                      }))
        ]));
  }
}
