import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool? value;
  final Color? activeColor;
  final Color inactiveColor;
  final Color? activeTextColor;
  final Color inactiveTextColor;
  final String activeText;
  final String inactiveText;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch(
      {Key? key,
      this.value = false,
      this.onChanged,
      this.activeColor,
      this.inactiveColor = Colors.grey,
      this.activeText = '', //YES
      this.inactiveText = '', //NO
      this.activeTextColor,
      this.inactiveTextColor = Colors.grey})
      : super(key: key);

  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value! ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value! ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    Color? activeColor = widget.activeColor ?? cyanColor;
    Color? activeTextColor = widget.activeTextColor ?? cyanColor;

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return GestureDetector(
              onTap: () {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
                widget.value == false
                    ? widget.onChanged!(true)
                    : widget.onChanged!(false);
              },
              child: Align(
                  alignment: Alignment.center,
                  child: Container(
                      width: gFontSize * 4.8, //4.2
                      height: gFontSize * 2.4,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color:
                                  _circleAnimation.value == Alignment.centerLeft
                                      ? widget.inactiveColor
                                      : activeColor),
                          borderRadius:
                              BorderRadius.circular(gFontSize * 1.15)),
                      child: Padding(
                          padding: EdgeInsets.all(gFontSize * 0.2),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _circleAnimation.value == Alignment.centerRight
                                    ? Expanded(
                                        child: Text(getLocale("Yes"),
                                            textAlign: TextAlign.center,
                                            style: sFontW5().copyWith(
                                                color: activeTextColor)))
                                    : Container(),
                                Align(
                                    alignment: _circleAnimation.value,
                                    child: Container(
                                        width: gFontSize * 2,
                                        height: gFontSize * 2,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _circleAnimation.value ==
                                                    Alignment.centerLeft
                                                ? widget.inactiveColor
                                                : activeColor))),
                                _circleAnimation.value == Alignment.centerLeft
                                    ? Expanded(
                                        child: Text(
                                            getLocale(
                                                "No"), //widget.inactiveText,
                                            textAlign: TextAlign.center,
                                            style: sFontW5().copyWith(
                                                color:
                                                    widget.inactiveTextColor)))
                                    : Container()
                              ])))));
        });
  }
}
