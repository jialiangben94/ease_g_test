import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_cupertino_switch.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';

class SwitchRemote extends StatefulWidget {
  final dynamic obj;
  final ValueChanged<bool> onChanged;

  const SwitchRemote({Key? key, this.obj, required this.onChanged})
      : super(key: key);

  @override
  SwitchRemoteState createState() => SwitchRemoteState();
}

class SwitchRemoteState extends State<SwitchRemote> {
  dynamic obj;
  @override
  void initState() {
    super.initState();
    obj = widget.obj;
  }

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          flex: obj["column"] != null && obj["column"] ? 5 : 1,
          child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(vertical: gFontSize * 0.6),
              padding: EdgeInsets.symmetric(
                  horizontal: gFontSize * 1.2, vertical: gFontSize * 0.6),
              decoration: BoxDecoration(
                  color: creamColor,
                  borderRadius: BorderRadius.circular(gFontSize * 0.5)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(obj["label"], style: bFontW5()),
                      Visibility(
                          visible: obj["value"],
                          child: Text(
                              getLocale(
                                  "You will need to setup the remote signature at the 'Remote' Tab"),
                              style:
                                  sFontWN().copyWith(color: scarletRedColor)))
                    ])),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                        obj["enabled"]
                            ? obj["value"]
                                ? getLocale("Yes")
                                : getLocale("No")
                            : getLocale("No"),
                        style: bFontWN().copyWith(
                            color: !obj["enabled"]
                                ? greyTextColor
                                : Colors.black))),
                CustomCupertinoSwitch(
                    disabled: !obj["enabled"],
                    value: obj["enabled"] ? obj["value"] : false,
                    activeColor: cyanColor,
                    onChanged: (bool value) {
                      setState(() {
                        obj["value"] = value;
                      });
                      if (obj["enabled"]) widget.onChanged(value);
                    }),
              ]))),
      if (obj["column"] != null && obj["column"])
        Expanded(flex: 2, child: Container())
    ]);
  }
}
