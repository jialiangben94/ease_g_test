import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? label;
  final bool? secondary;
  final Color? buttonColor;
  final Color? labelColor;
  final Color? borderColor;
  final double? fontSize;
  final double? iconSize;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final IconData? icon;
  final Widget? image;
  final VoidCallback? onPressed;

  const CustomButton(
      {Key? key,
      this.label,
      this.onPressed,
      this.secondary,
      this.image,
      this.icon,
      this.iconSize,
      this.buttonColor,
      this.labelColor,
      this.borderColor,
      this.fontWeight,
      this.fontSize,
      this.padding,
      this.height,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;
    var color = buttonColor ?? honeyColor;
    if (secondary != null && secondary! && buttonColor == null) {
      color = Colors.transparent;
    }
    var buttonFontWeight = fontWeight ?? FontWeight.bold;
    if (secondary != null && secondary! && fontWeight == null) {
      buttonFontWeight = FontWeight.w500;
    }
    Widget? i = Container();

    if (image != null) {
      i = image;
    }

    if (icon != null) {
      i = Icon(icon, size: iconSize ?? gFontSize * 2, color: labelColor);
    }

    // var rippleColor = disableRipple ? Colors.transparent : Colors.black12;

    var button = TextButton(
        style: TextButton.styleFrom(
            foregroundColor: onPressed == null
                ? Colors.black54
                : (labelColor ?? Colors.black),
            backgroundColor: onPressed != null ? color : Colors.black45,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(gFontSize * 0.4)),
                side: BorderSide(color: borderColor ?? Colors.transparent)),
            padding:
                padding ?? EdgeInsets.symmetric(vertical: gFontSize * 0.8)),
        onPressed: onPressed,
        child: Text(label ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: fontSize ?? gFontSize,
                fontWeight: buttonFontWeight)));

    if (icon != null || image != null) {
      button = TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: onPressed == null
                ? Colors.black54
                : (labelColor ?? Colors.black),
            backgroundColor: onPressed != null ? color : Colors.black45,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(gFontSize * 0.4)),
                side: BorderSide(color: borderColor ?? Colors.transparent)),
            padding: padding ?? EdgeInsets.symmetric(vertical: gFontSize * 0.8),
          ),
          label: Text(label ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fontSize ?? gFontSize,
                  fontWeight: buttonFontWeight)),
          icon: i!,
          onPressed: onPressed);
    }

    return SizedBox(height: height, width: width, child: button);
  }
}
