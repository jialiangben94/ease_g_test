import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_all/flutter_html_all.dart';

class InformationContainer extends StatefulWidget {
  final String? html;
  final Map<String, Style>? style;
  final bool enableAnimation;

  const InformationContainer(
      {Key? key, this.html, this.style, this.enableAnimation = true})
      : super(key: key);

  @override
  InformationContainerState createState() => InformationContainerState();
}

class InformationContainerState extends State<InformationContainer> {
  bool show = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    Widget buildHtml() {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          height: show ? null : gFontSize * 12,
          child: SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.only(bottom: gFontSize * 1.6),
                  child: Html(
                      data: widget.html,
                      shrinkWrap: true,
                      customRenders: {
                        tagMatcher("table"): CustomRender.widget(
                            widget: (context, buildChildren) =>
                                SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: tableRender
                                        .call()
                                        .widget!
                                        .call(context, buildChildren)))
                      },
                      style: widget.style ??
                          {
                            "html": Style(
                                fontSize: FontSize(font16()),
                                color: Colors.black),
                            "td": Style(alignment: Alignment.topLeft)
                          }))));
    }

    Widget useContainer = show
        ? buildHtml()
        : ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent])
                  .createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
            },
            blendMode: BlendMode.dstIn,
            child: buildHtml());

    return Stack(children: [
      useContainer,
      Positioned(
          bottom: 0,
          right: screenWidth / 3,
          child: Center(
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      show = !show;
                    });
                  },
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(
                              Radius.circular(gFontSize * 1.1))),
                      height: gFontSize * 2.5,
                      width: gFontSize * 8,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                show
                                    ? getLocale("Hide")
                                    : getLocale("See more"),
                                style: bFontW5().copyWith(
                                    fontFamily: "Lato", color: greyTextColor)),
                            Icon(
                                show
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                                size: gFontSize * 1.3)
                          ])))))
    ]);
  }
}
