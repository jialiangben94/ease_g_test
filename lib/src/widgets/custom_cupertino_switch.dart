// https://pub.dev/packages/custom_switch
import 'package:ease/src/widgets/colors.dart';
import 'package:flutter/material.dart';

class CustomCupertinoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? bgColor;
  final Color? bgActiveColor;
  final bool? disabled;

  const CustomCupertinoSwitch(
      {Key? key,
      required this.value,
      this.onChanged,
      this.activeColor,
      this.inactiveColor,
      this.bgColor,
      this.bgActiveColor,
      this.disabled})
      : super(key: key);

  @override
  CustomSwitchState createState() => CustomSwitchState();
}

class CustomSwitchState extends State<CustomCupertinoSwitch>
    with SingleTickerProviderStateMixin {
  late Animation _circleAnimation;
  late AnimationController _animationController;
  late Color inactiveColor;
  late Color bgColor;
  late Color bgActiveColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
            begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.linear));
    if (widget.inactiveColor != null) {
      inactiveColor = widget.inactiveColor!;
    } else {
      inactiveColor = lightGreyColor;
    }
    if (widget.bgColor != null) {
      bgColor = widget.bgColor!;
    } else {
      bgColor = Colors.white;
    }
    if (widget.bgActiveColor != null) {
      bgActiveColor = widget.bgActiveColor!;
    } else {
      bgActiveColor = Colors.white;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                !widget.value
                    ? widget.onChanged!(true)
                    : widget.onChanged!(false);
              },
              child: Container(
                  width: 60.0,
                  height: 35.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: widget.value ? bgActiveColor : bgColor),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 4.0, bottom: 4.0, right: 4.0, left: 4.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _circleAnimation.value == Alignment.centerRight
                                ? Container(
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 20.0))
                                : Container(),
                            Align(
                                alignment: _circleAnimation.value,
                                child: Container(
                                    width: 25.0,
                                    height: 25.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.disabled != null &&
                                                widget.disabled!
                                            ? lightGreyColor2
                                            : widget.value
                                                ? widget.activeColor
                                                : inactiveColor))),
                            _circleAnimation.value == Alignment.centerLeft
                                ? Container(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 4.0))
                                : Container()
                          ]))));
        });
  }
}
