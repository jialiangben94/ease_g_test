import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/check_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

class RadioCheckContainer extends StatefulWidget {
  final bool? checked;
  final String? label;
  final String? html;
  final Color? bgColor;
  final Map<String, Style>? style;
  final Function(bool?) onChanged;

  const RadioCheckContainer(
      {Key? key,
      this.checked,
      this.label,
      this.html,
      this.bgColor,
      this.style,
      required this.onChanged})
      : super(key: key);

  @override
  RadioCheckContainerState createState() => RadioCheckContainerState();
}

class RadioCheckContainerState extends State<RadioCheckContainer> {
  bool? checked;
  late Color bgColor;

  @override
  void initState() {
    super.initState();
    checked = widget.checked;
    if (widget.bgColor != null) {
      bgColor = widget.bgColor!;
    } else {
      bgColor = lightCyanColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    late Widget label;
    var fontSize = gFontSize * 0.9;
    Color fontColor = Colors.black;

    if (widget.label != null && widget.label!.isNotEmpty) {
      label = Text(widget.label!,
          style: TextStyle(fontSize: fontSize, color: fontColor));
    } else if (widget.html != null && widget.html!.isNotEmpty) {
      label = Html(
          data: widget.html,
          customRenders: {
            tagMatcher("table"): CustomRender.widget(
                widget: (context, buildChildren) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: tableRender
                        .call()
                        .widget!
                        .call(context, buildChildren)))
          },
          style: widget.style ??
              {"html": Style(fontSize: FontSize(fontSize), color: fontColor)});
    }

    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.all(gFontSize),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(gFontSize * 0.5)),
        child: GestureDetector(
            onTap: () {
              setState(() {
                if (checked != null) {
                  checked = !checked!;
                } else {
                  checked = true;
                }

                widget.onChanged(checked);
              });
            },
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CheckCircle(checked: checked, alignment: Alignment.topLeft),
              Expanded(child: label)
            ])));
  }
}
