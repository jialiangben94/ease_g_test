import 'package:flutter/material.dart';

class ChoiceDialog extends StatefulWidget {
  final dynamic list;
  const ChoiceDialog({Key? key, required this.list}) : super(key: key);

  @override
  ChoiceDialogState createState() => ChoiceDialogState();
}

class ChoiceDialogState extends State<ChoiceDialog> {
  List<Widget> widList = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        widList = generateOption();
      });
    });
  }

  List<Widget> generateOption([search]) {
    List<Widget> widList = [];
    for (var v in widget.list["options"]) {
      var color = Colors.transparent;
      if (v["active"] == null || !v["active"]) {
        continue;
      }

      if (search != null &&
          v["value"].toLowerCase().indexOf(search.toLowerCase()) < 0) {
        continue;
      }

      if (widget.list["value"] == v["value"]) {
        color = const Color.fromRGBO(253, 248, 234, 1);
      }
      widList.add(Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: const Border(
                  top: BorderSide(color: Color.fromRGBO(235, 235, 235, 1))),
              color: color),
          child: SimpleDialogOption(
              padding:
                  const EdgeInsets.only(top: 18.0, bottom: 18.0, left: 23.0),
              onPressed: () {
                Navigator.pop(context, v["value"]);
              },
              child: Text(v["title"],
                  style: const TextStyle(fontWeight: FontWeight.bold)))));
    }
    //add lastRow border
    widList.add(Container(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color.fromRGBO(235, 235, 235, 1))))));
    return widList;
  }

  @override
  Widget build(BuildContext context) {
    int listLength() {
      int count = 0;
      for (var v in widget.list["options"]) {
        if (v["active"] == null || !v["active"]) {
          continue;
        }
        count++;
      }
      return count;
    }

    return SimpleDialog(children: [
      Container(
          padding: const EdgeInsets.only(right: 15.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, size: 30.0))),
            Container(
                padding: const EdgeInsets.only(
                    left: 23.0, right: 20.0, bottom: 10.0),
                child: Row(children: [
                  const Icon(Icons.search, size: 20.0),
                  const Padding(padding: EdgeInsets.only(left: 10.0)),
                  Expanded(
                      child: TextField(
                          onChanged: (text) {
                            setState(() {
                              widList = generateOption(text);
                            });
                          },
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: widget.list["label"])))
                ]))
          ])),
      SizedBox(
          height: listLength() > 11
              ? MediaQuery.of(context).size.height * 0.80
              : null,
          child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 35.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widList)))
    ]);
  }
}
