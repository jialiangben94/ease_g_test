import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class CheckCircle extends StatelessWidget {
  final bool? checked;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  const CheckCircle(
      {Key? key, this.checked = false, this.padding, this.alignment})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;
    var radioFont = gFontSize * 1.5;

    return Container(
        alignment: alignment ?? Alignment.center,
        padding: padding ?? EdgeInsets.only(right: gFontSize),
        child: checked == true
            ? Image(
                width: radioFont,
                height: radioFont,
                image: const AssetImage('assets/images/check_circle.png'))
            : Container(
                width: radioFont,
                height: radioFont,
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey))));
  }
}
