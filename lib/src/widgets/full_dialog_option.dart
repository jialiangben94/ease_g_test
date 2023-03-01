import 'dart:convert';

import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/util/function.dart';
import 'package:flutter/material.dart';
import 'package:sortedmap/sortedmap.dart';

class FullDialog extends StatefulWidget {
  final dynamic obj;
  const FullDialog({Key? key, this.obj}) : super(key: key);
  @override
  FullDialogState createState() => FullDialogState();
}

class FullDialogState extends State<FullDialog> {
  List<Widget> widList = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      widList = generateOption();
    });
  }

  List<Widget> generateOption([search]) {
    List<Widget> widList = [];
    SortedMap<dynamic, dynamic> unsortedData =
        SortedMap(const Ordering.byKey());

    for (var v in widget.obj["options"]) {
      if (v["active"] == null || !v["active"]) {
        continue;
      }

      if (search != null &&
          v["label"].toLowerCase().indexOf(search.toLowerCase()) < 0) {
        continue;
      }

      var name = v["label"];
      var y = jsonEncode(name);
      var x = jsonDecode(y);

      unsortedData.putIfAbsent(x, () => v["value"]);
    }

    unsortedData.forEach((key, value) {
      widList.add(Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1))),
              color: Colors.transparent),
          child: SimpleDialogOption(
              padding:
                  const EdgeInsets.only(top: 18.0, bottom: 18.0, left: 23.0),
              onPressed: () {
                Navigator.pop(context, value);
              },
              child: Text(key as String, style: t1FontWB()))));
    });
    //add lastRow border
    widList.add(Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(235, 235, 235, 1))))));
    return widList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(children: [
          Expanded(
              flex: 10,
              child: Container(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(Icons.adaptive.arrow_back,
                                    color: Colors.black, size: 18))),
                        Expanded(
                            flex: 15,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, top: 0, bottom: 5, right: 40),
                                child: TextField(
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: (value) {
                                      setState(() {
                                        widList = generateOption(value);
                                      });
                                    },
                                    cursorColor: Colors.grey,
                                    style: t1FontWN(),
                                    decoration: InputDecoration(
                                        hintText: getLocale('Search here'),
                                        hintStyle: bFontWN(),
                                        suffixIcon: const Icon(Icons.search,
                                            size: 30, color: Colors.grey),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            borderSide: BorderSide(
                                                color: Colors.grey[500]!,
                                                width: 0.5)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            borderSide: BorderSide(
                                                color: Colors.grey[400]!,
                                                width: 0.5))))))
                      ]))),
          Expanded(flex: 2, child: Container()),
          const Divider(thickness: 1, height: 1),
          Expanded(
              flex: 88,
              child: SingleChildScrollView(child: Column(children: widList)))
        ]));
  }
}
