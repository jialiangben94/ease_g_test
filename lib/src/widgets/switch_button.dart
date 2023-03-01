import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_cupertino_switch.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class SwitchButton extends StatefulWidget {
  final dynamic obj;
  final ValueChanged<bool> onChanged;

  const SwitchButton({Key? key, this.obj, required this.onChanged})
      : super(key: key);

  @override
  SwitchButtonState createState() => SwitchButtonState();
}

class SwitchButtonState extends State<SwitchButton> {
  dynamic obj;
  @override
  void initState() {
    super.initState();
    obj = widget.obj;
  }

  @override
  Widget build(BuildContext context) {
    Widget labelWidget;
    if (obj["required"] != null && obj["required"]) {
      labelWidget = RichText(
          text: TextSpan(
              text: obj["label"],
              style: bFontWN(),
              children: <TextSpan>[
            TextSpan(
                text: "*", style: bFontWN().copyWith(color: scarletRedColor))
          ]));
    } else {
      labelWidget = Text(obj["label"], style: bFontWN());
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          flex: obj["column"] != null && obj["column"] ? 5 : 1,
          child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: gFontSize * 0.6),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 90, child: labelWidget),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          obj["value"] ? getLocale("Yes") : getLocale("No"),
                          style: bFontWN())),
                  Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: CustomCupertinoSwitch(
                          value: obj["value"],
                          activeColor: cyanColor,
                          bgColor: lightGreyColor2,
                          bgActiveColor: lightCyanColor,
                          onChanged: (bool value) {
                            setState(() {
                              obj["value"] = value;
                              widget.onChanged(value);
                            });
                          }))
                ]),
                Expanded(flex: 11, child: Container()),
              ])))
    ]);
  }
}
