import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberPicker extends StatefulWidget {
  final dynamic obj;
  final Function(num value)? onChanged;

  const NumberPicker({Key? key, this.obj, this.onChanged}) : super(key: key);

  @override
  NumberPickerState createState() => NumberPickerState();
}

class NumberPickerState extends State<NumberPicker> {
  dynamic obj;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    //sample
    // obj = {
    //   "value": 150,
    //   // "height": 9,
    //   // "plusColor": "",
    //   // "minusColor": "",
    //   // "fontStyle": "",
    //   // "color": "",
    //   "suffix": "kg",
    //   "max": 350,
    //   "min": 0,
    //   // "prefix": "cm",
    // };

    obj = widget.obj;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    gFontSize = (screenWidth + screenHeight) * 0.01;

    Color color = obj["color"] ?? creamColor;

    // Color minusColor = obj["minusColor"];

    // Color plusColor = obj["plusColor"];

    int min = obj["min"] ?? 0;

    int? max = obj["max"];
    if (obj["height"] != null) obj["height"] = obj["height"].toInt();
    var padding =
        EdgeInsets.symmetric(vertical: obj["height"] ?? gFontSize * 0.5);

    var textAlign = TextAlign.center;
    if (obj["prefix"] != null) textAlign = TextAlign.right;
    if (obj["suffix"] != null) textAlign = TextAlign.left;

    Widget content() {
      return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.all(Radius.circular(gFontSize * 0.3))),
          child: IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                Expanded(
                    flex: 25,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (obj != null &&
                              obj["vtype"] != null &&
                              obj["vtype"].indexOf("int") > -1 &&
                              obj["value"] is String) {
                            obj["value"] = int.parse(obj["value"]);
                          }
                          obj["value"] = obj["value"] - 1;
                          if (obj["value"] <= min) {
                            obj["value"] = min;
                          }
                          if (widget.onChanged != null) {
                            widget.onChanged!(obj["value"].toInt());
                          }
                        });
                      },
                      child: Center(
                          child: Icon(Icons.remove, size: gFontSize * 1.2)),
                    )),
                Expanded(
                    flex: 50,
                    child: Container(
                        padding: padding,
                        decoration: BoxDecoration(
                            color: color,
                            border: const Border(
                                right: BorderSide(color: Colors.black54),
                                left: BorderSide(color: Colors.black54))),
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Center(
                            child: TextField(
                                controller: TextEditingController.fromValue(
                                    TextEditingValue(
                                        text: obj["value"].toString(),
                                        selection: TextSelection.collapsed(
                                            offset: obj["value"]
                                                .toString()
                                                .length))),
                                textAlign: textAlign,
                                maxLength: 3,
                                keyboardType:
                                    const TextInputType.numberWithOptions(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onTap: () {
                                  setState(() {
                                    if (obj["value"] == 0.00 ||
                                        obj["value"] == 0) {
                                      obj["value"] = "";
                                    }
                                  });
                                },
                                onChanged: (value) {
                                   try {
                                    obj["value"] = int.parse(value.replaceAll(RegExp(r'[^0-9]'),''));
                                  } catch (e) {
                                    obj["value"] = 0;
                                  }                             
                                  
                                  if (max != null && obj["value"] > max) {
                                    setState(() {
                                      errorMsg = '${obj["label"]} cannot be above ${obj["max"]}${obj["suffix"]}';
                                    });
                                  } else if (obj["value"] < min) {
                                     setState(() { 
                                      errorMsg = '${obj["label"]} cannot be below ${obj["min"]}${obj["suffix"]}';
                                     });
                                  } else {
                                    setState(() {
                                      errorMsg = '';
                                    });
                                  }

                                  if (widget.onChanged != null) {
                                    widget.onChanged!(obj["value"]);
                                  }
                                },
                                cursorColor: Colors.grey,
                                style: obj["fontStyle"] ??
                                    t2FontW5().copyWith(fontFamily: "Lato"),
                                decoration: InputDecoration(
                                    suffixText: obj["suffix"] ?? "",
                                    prefixText: obj["prefix"] ?? "",
                                    counterText: "",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: obj["textHPadding"] ??
                                            gFontSize * 0.7)))))),
                Expanded(
                    flex: 25,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (obj != null &&
                              obj["vtype"] != null &&
                              obj["vtype"].indexOf("int") > -1 &&
                              obj["value"] is String) {
                            obj["value"] = int.parse(obj["value"]);
                          }
                          obj["value"] = obj["value"] + 1;
                          if (max != null && obj["value"] >= max) {
                            obj["value"] = max;
                          }
                          if (widget.onChanged != null) {
                            widget.onChanged!(obj["value"].toInt());
                          }
                        });
                      },
                      child:
                          Center(child: Icon(Icons.add, size: gFontSize * 1.2)),
                    ))
              ])));
    }

    Widget label() {
      if (obj["label"] != null) {
        return Container(
            padding: EdgeInsets.only(bottom: gFontSize * 0.8),
            child: Text(obj["label"] ?? "",
                style: obj["labelFont"] ??
                    bFontWN().copyWith(color: greyTextColor)));
      }
      return Container();
    }

    Widget error() {
      if (errorMsg != '') {
        return Container(
          padding: EdgeInsets.only(top: gFontSize * 0.8),
          child: Text(errorMsg, 
                style: obj["labelFont"] ??
                    bFontWN().copyWith(color: scarletRedColor))
        );
      }

      return Container();
    }


    if (obj["column"] == null || obj["column"]) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [label(), content(), error()]);
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      obj["label"] != null ? Expanded(flex: 20, child: label()) : Container(),
      Expanded(flex: 80, child: content())
    ]);
  }
}
