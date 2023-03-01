import 'dart:convert';

import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class SITable extends StatefulWidget {
  final String? prodCode;
  final List<List<String>?>? _siData;
  final bool isGSC;
  const SITable(this.prodCode, this._siData, {Key? key, this.isGSC = false})
      : super(key: key);
  @override
  SITableState createState() => SITableState();
}

class SITableState extends State<SITable> {
  late LinkedScrollControllerGroup _controllers;
  ScrollController _myController1 = ScrollController();
  ScrollController _myController2 = ScrollController();
  final formatter = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _myController1 = _controllers.addAndGet();
    _myController2 = _controllers.addAndGet();
  }

  Future<dynamic> getColumn() async {
    String value = await rootBundle.loadString('assets/files/si_column.json');
    return jsonDecode(value);
  }

  @override
  Widget build(BuildContext context) {
    Widget topColHeader(String title, double width) {
      return Container(
          width: width,
          height: 46,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(child: Text(title, style: bFontW5())));
    }

    Widget topColHeader2(String title, double width) {
      return Container(
          width: width,
          height: 40,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(child: Text(title, style: bFontW5())));
    }

    Widget topColHeader3(String title, double width) {
      return Container(
          width: width,
          height: 41,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(child: Text(title, style: bFontW5())));
    }

    Widget topDoubleColHeader(String title, double width) {
      return Container(
          width: width,
          height: 124,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(
              child:
                  Text(title, textAlign: TextAlign.center, style: bFontW5())));
    }

    Widget twoThirdColHeader(String title) {
      return Container(
          width: 102,
          height: 156,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(
              child:
                  Text(title, textAlign: TextAlign.center, style: sFontWN())));
    }

    Widget oneThirdColHeader(String title, double width) {
      return Container(
          width: width,
          height: 81,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(
              child:
                  Text(title, textAlign: TextAlign.center, style: sFontWN())));
    }

    Widget secondColHeader(String title, double width) {
      return Container(
          width: width,
          height: 78,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(child: Text(title, style: sFontWN())));
    }

    Widget thirdColHeader(String title) {
      return Container(
          width: 102,
          height: 78,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(
              child:
                  Text(title, textAlign: TextAlign.center, style: sFontWN())));
    }

    Widget singleColHeader(String title, Color color) {
      return Container(
          width: 102,
          height: 202,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color,
              border: Border(
                  bottom: BorderSide(color: greyBorderTFColor),
                  right: BorderSide(color: greyBorderTFColor))),
          child: Center(
              child:
                  Text(title, textAlign: TextAlign.center, style: sFontWN())));
    }

    // assigning table width and color
    dynamic buildTable(List<dynamic> label) {
      List<Widget> widlist = [];
      double totalWidth = 0;

      for (int x = 0; x < label.length; x++) {
        if (label[x]["type"] == 1) {
          widlist.add(singleColHeader(
              label[x]["label"], x % 2 == 0 ? lightCyanColor : lightPinkColor));
          totalWidth = totalWidth + 102;
        } else if (label[x]["type"] == 2) {
          double width = 0;
          List childWidget = label[x]["child"];
          List<Widget> childWidgetWid = [];
          for (var element in childWidget) {
            if (element["type"] == 3) {
              width = width + 102;
              childWidgetWid.add(twoThirdColHeader(element["label"]));
            } else if (element["type"] == 4) {
              List childWidget2 = element["child"];
              List<Widget> childWidgetWid2 = [];

              width = width + (102 * childWidget2.length).toDouble();

              for (var element in childWidget2) {
                childWidgetWid2.add(thirdColHeader(element["label"]));
              }

              childWidgetWid.add(Column(children: [
                secondColHeader(
                    element["label"], (102 * childWidget2.length).toDouble()),
                Row(children: childWidgetWid2)
              ]));
            }
          }
          widlist.add(Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: x % 2 == 0 ? lightCyanColor : lightPinkColor),
              child: Column(children: [
                topColHeader(label[x]["label"], width),
                Row(children: childWidgetWid)
              ])));
          totalWidth = totalWidth + width;
        } else if (label[x]["type"] == 3) {
          double width = 0;
          List childWidget = label[x]["child"];
          List<Widget> childWidgetWid = [];

          for (var element in childWidget) {
            width = width + 102;
            childWidgetWid.add(thirdColHeader(element["label"]));
          }

          widlist.add(Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: x % 2 == 0 ? lightCyanColor : lightPinkColor),
              child: Column(children: [
                topDoubleColHeader(label[x]["label"], width),
                Row(children: childWidgetWid)
              ])));
          totalWidth = totalWidth + width;
        } else if (label[x]["type"] == 6) {
          double width = 0;
          List childWidget = label[x]["child"];
          List<Widget> childWidgetWid = [];
          for (var element in childWidget) {
            if (element["type"] == 7) {
              List childWidget2 = element["child"];
              List<Widget> childWidgetWid2 = [];

              for (var element in childWidget2) {
                childWidgetWid2.add(oneThirdColHeader(element["label"], 102));
              }

              width = width + (102 * childWidget2.length).toDouble();
              childWidgetWid.add(Column(children: [
                oneThirdColHeader(element["label"], 102),
                Row(children: childWidgetWid2)
              ]));
            } else if (element["type"] == 8) {
              double totalWidth = 0;
              List childWidget2 = element["child"];
              List<Widget> childWidgetWid2 = [];

              for (var element in childWidget2) {
                List childWidget3 = element["child"];
                List<Widget> childWidgetWid3 = [];
                for (var element in childWidget3) {
                  childWidgetWid3.add(oneThirdColHeader(element["label"], 102));
                }
                totalWidth =
                    totalWidth + (102 * childWidget3.length).toDouble();

                childWidgetWid2.add(Column(children: [
                  topColHeader3(
                      element["label"], (102 * childWidget3.length).toDouble()),
                  Row(children: childWidgetWid3)
                ]));
              }

              width = width + totalWidth;
              childWidgetWid.add(Column(children: [
                topColHeader3(
                    element["label"], (102 * childWidget2.length).toDouble()),
                Row(children: childWidgetWid2)
              ]));
            }
          }
          widlist.add(Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: x % 2 == 0 ? lightCyanColor : lightPinkColor),
              child: Column(children: [
                topColHeader2(label[x]["label"], width),
                Row(children: childWidgetWid)
              ])));
          totalWidth = totalWidth + width;
        }
      }

      return {"width": totalWidth, "widget": widlist};
    }

    return FutureBuilder<dynamic>(
        future: getColumn(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (widget._siData == null || widget._siData!.isEmpty) {
              return Container();
            } else {
              List<dynamic>? label = [];
              dynamic dataPlan = snapshot.data;
              if (widget.prodCode == "PCWI03") {
                label = dataPlan["securelink_label"];
              } else if (widget.prodCode == "PCJI01") {
                label = dataPlan["megalink_label"];
              } else if (widget.prodCode == "PCJI02") {
                label = dataPlan["megaplus_label"];
              } else if (widget.prodCode == "PTWI03") {
                label = dataPlan["eliteplus_takafulink_label"];
              } else if (widget.prodCode == "PCTA01") {
                if (widget.isGSC) {
                  label = dataPlan["etiqalifesecure_tcimr_label"];
                } else {
                  label = dataPlan["etiqalifesecure_label"];
                }
              } else if (widget.prodCode == "PTHI01" ||
                  widget.prodCode == "PTHI02") {
                if (widget.isGSC) {
                  label = dataPlan["hadiyyahtakafulink_gsc_label"];
                } else {
                  label = dataPlan["hadiyyahtakafulink_label"];
                }
              } else if (widget.prodCode == "PTJI01") {
                if (widget.isGSC) {
                  label = dataPlan["mahabbah_gsc_label"];
                } else {
                  label = dataPlan["mahabbah_label"];
                }
              } else if (widget.prodCode == "PCWA01") {
                if (widget.isGSC) {
                  label = dataPlan["enrichlifeplan_tcimr_label"];
                } else {
                  label = dataPlan["enrichlifeplan_label"];
                }
              } else if (widget.prodCode == "PCHI03" ||
                  widget.prodCode == "PCHI04") {
                if (widget.isGSC) {
                  label = dataPlan["maxipro_gsc_label"];
                } else {
                  label = dataPlan["maxipro_label"];
                }
              } else if (widget.prodCode == "PCEL01" ||
                  widget.prodCode == "PCEE01") {
                label = dataPlan["tg_aspire_label"];
              }

              var res = buildTable(label!);

              return Row(children: [
                SizedBox(
                    height: (widget._siData![0]!.length * 28.2) + 202,
                    child: Column(children: [
                      Container(
                          height: 202,
                          width: 102,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border(
                                  top: BorderSide(color: greyBorderTFColor),
                                  left: BorderSide(color: greyBorderTFColor))),
                          child: Center(
                              child: Text(getLocale("End of Policy Year"),
                                  textAlign: TextAlign.center,
                                  style: sFontWN()))),
                      Flexible(
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: greyBorderTFColor),
                                      left:
                                          BorderSide(color: greyBorderTFColor),
                                      bottom: BorderSide(
                                          color: greyBorderTFColor))),
                              width: 102,
                              child: ListView(
                                  physics: const ClampingScrollPhysics(),
                                  controller: _myController1,
                                  scrollDirection: Axis.vertical,
                                  children: [
                                    for (int x = 0;
                                        x < widget._siData![0]!.length;
                                        x++)
                                      Container(
                                          width: 102,
                                          padding: const EdgeInsets.all(2),
                                          child: Center(
                                              child: Text(
                                                  widget._siData![0]![x],
                                                  style: const TextStyle(
                                                      color: Colors.black))))
                                  ])))
                    ])),
                Flexible(
                    child: Container(
                        height: (widget._siData![0]!.length * 28.2) + 202,
                        decoration: BoxDecoration(
                            border: Border.all(color: greyBorderTFColor)),
                        child: ListView(
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                  width: res["width"],
                                  child: Column(children: [
                                    Row(children: res["widget"]),
                                    Flexible(
                                        child: ListView(
                                            physics:
                                                const ClampingScrollPhysics(),
                                            controller: _myController2,
                                            scrollDirection: Axis.vertical,
                                            children: [
                                          Row(children: [
                                            for (int i = 1;
                                                i < widget._siData!.length;
                                                i++)
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    for (int a = 0;
                                                        a <
                                                            widget._siData![i]!
                                                                .length;
                                                        a++)
                                                      Container(
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  right: BorderSide(
                                                                      color:
                                                                          greyBorderTFColor))),
                                                          width: 102,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2),
                                                          child: Center(
                                                              child: Text(
                                                                  isNumeric(widget._siData![i]![a])
                                                                      ? formatter
                                                                          .format(
                                                                              num.parse(widget._siData![i]![a]))
                                                                      : widget._siData![i]![a],
                                                                  style: const TextStyle(color: Colors.black))))
                                                  ])
                                          ])
                                        ]))
                                  ]))
                            ])))
              ]);
            }
          } else {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.735,
                child: buildLoading());
          }
        });
  }
}
