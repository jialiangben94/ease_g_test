import 'package:ease/src/widgets/colors.dart';
// import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

enum IndicatorSide { start, end }

/// A vertical tab widget for flutter
class VerticalTabs extends StatefulWidget {
  final int initialIndex;
  final double tabsWidth;
  final double indicatorWidth;
  final IndicatorSide? indicatorSide;
  final List<String> titles;
  final List<Widget> contents;
  final TextDirection direction;
  final bool disabledChangePageFromContentView;
  final Axis contentScrollAxis;
  final TextStyle selectedTabTextStyle;
  final TextStyle tabTextStyle;
  final Duration changePageDuration;
  final Curve changePageCurve;
  final double tabsElevation;
  final Function(int? tabIndex)? onSelect;

  const VerticalTabs(
      {Key? key,
      required this.titles,
      required this.contents,
      this.tabsWidth = 200,
      this.indicatorWidth = 3,
      this.indicatorSide,
      this.initialIndex = 0,
      this.direction = TextDirection.ltr,
      this.disabledChangePageFromContentView = false,
      this.contentScrollAxis = Axis.vertical,
      this.selectedTabTextStyle = const TextStyle(color: Colors.black),
      this.tabTextStyle = const TextStyle(color: Colors.black38),
      this.changePageCurve = Curves.easeInOut,
      this.changePageDuration = const Duration(milliseconds: 300),
      this.tabsElevation = 2.0,
      this.onSelect})
      : assert(titles.length == contents.length),
        super(key: key);

  @override
  VerticalTabsState createState() => VerticalTabsState();
}

class VerticalTabsState extends State<VerticalTabs>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  bool? _changePageByTapView;

  AnimationController? animationController;
  Animation<double>? animation;
  Animation<RelativeRect>? rectAnimation;

  PageController pageController = PageController();

  List<AnimationController> animationControllers = [];

  ScrollPhysics pageScrollPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    for (int i = 0; i < widget.titles.length; i++) {
      animationControllers.add(AnimationController(
          duration: const Duration(milliseconds: 400), vsync: this));
    }
    _selectTab(widget.initialIndex);

    if (widget.disabledChangePageFromContentView == true) {
      pageScrollPhysics = const NeverScrollableScrollPhysics();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(widget.initialIndex);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: widget.direction,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          //   CustomButton(
          //       label: "View Full Proposal",
          //       image: Image.asset('assets/images/view_doc_cyan.png',
          //           width: gFontSize * 0.9),
          //       fontSize: gFontSize * 0.9,
          //       labelColor: cyanColor,
          //       secondary: true,
          //       onPressed: () {})
          // ]),
          Expanded(
              child: Row(children: [
            Material(
                child: Container(
                    color: Colors.white,
                    width: widget.tabsWidth,
                    child: ListView.builder(
                        itemCount: widget.titles.length,
                        itemBuilder: (context, index) {
                          String tab = widget.titles[index];

                          Alignment alignment = Alignment.centerLeft;
                          if (widget.direction == TextDirection.rtl) {
                            alignment = Alignment.centerRight;
                          }

                          Widget child = Tab(
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: gFontSize),
                                  child: Row(children: [
                                    Expanded(
                                        child: Text(tab,
                                            style: _selectedIndex == index
                                                ? t2FontWB()
                                                    .copyWith(color: cyanColor)
                                                : t2FontW5().copyWith(
                                                    color: Colors.black))),
                                    Icon(Icons.adaptive.arrow_forward,
                                        size: 14,
                                        color: _selectedIndex == index
                                            ? cyanColor
                                            : Colors.black)
                                  ])));

                          return GestureDetector(
                              onTap: () {
                                _changePageByTapView = true;
                                setState(() {
                                  _selectTab(index);
                                });

                                pageController.animateToPage(index,
                                    duration: widget.changePageDuration,
                                    curve: widget.changePageCurve);
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: _selectedIndex == index
                                          ? lightCyanColor
                                          : Colors.white),
                                  alignment: alignment,
                                  padding: const EdgeInsets.all(5),
                                  child: child));
                        }))),
            Expanded(
                child: PageView.builder(
                    scrollDirection: widget.contentScrollAxis,
                    physics: pageScrollPhysics,
                    onPageChanged: (index) {
                      if (_changePageByTapView == false ||
                          _changePageByTapView == null) {
                        _selectTab(index);
                      }
                      if (_selectedIndex == index) {
                        _changePageByTapView = null;
                      }
                      setState(() {});
                    },
                    controller: pageController,
                    itemCount: widget.contents.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: gFontSize * 2,
                                  vertical: gFontSize),
                              child: widget.contents[index]));
                    }))
          ]))
        ]));
  }

  void _selectTab(index) {
    _selectedIndex = index;
    for (AnimationController animationController in animationControllers) {
      animationController.reset();
    }
    animationControllers[index].forward();

    if (widget.onSelect != null) {
      widget.onSelect!(_selectedIndex);
    }
  }
}
