import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/required_file_handler.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:flutter/material.dart';

class ChooseOccupation extends StatefulWidget {
  final int? age;

  const ChooseOccupation({Key? key, this.age}) : super(key: key);
  @override
  ChooseOccupationState createState() => ChooseOccupationState();
}

class ChooseOccupationState extends State<ChooseOccupation> {
  TextEditingController searchController = TextEditingController();
  List<Occupation> occupationResult = [];

  @override
  void initState() {
    super.initState();
  }

  Future<List<Occupation>> searchOccupationList(
      String keyword, int? age) async {
    List<Occupation> occupationList = [];
    final occupationlist = await getOccupationList();
    for (int i = 0; i < occupationlist.length; i++) {
      if (occupationlist[i]
              .occupationClass!
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          occupationlist[i]
              .occupationCode!
              .toLowerCase()
              .contains(keyword.toLowerCase()) ||
          occupationlist[i]
              .occupationName!
              .toLowerCase()
              .contains(keyword.toLowerCase())) {
        if (age != null && occupationlist[i].occupationCode == "JUV001") {
          if (age < 16) {
            occupationList.add(occupationlist[i]);
          }
        } else {
          occupationList.add(occupationlist[i]);
        }
      }
    }
    occupationList.sort((a, b) => a.occupationCode!
        .toUpperCase()
        .compareTo(b.occupationCode!.toUpperCase()));
    return occupationList;
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar() {
      return SizedBox(
          height: 60,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                        controller: searchController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) async {
                          // To restrain when to trigger search
                          if (value.length >= 2) {
                            occupationResult =
                                await searchOccupationList(value, widget.age);
                            setState(() {});
                          }
                        },
                        cursorColor: Colors.grey,
                        style: bFontWN(),
                        decoration: InputDecoration(
                            hintText: getLocale(
                                'Search for occupation, industry or occupation code'),
                            hintStyle: bFontWN(),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.black),
                                    onPressed: () {
                                      searchController.clear();
                                    })
                                : const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: Image(
                                        width: 10,
                                        height: 10,
                                        image: AssetImage(
                                            'assets/images/search_icon.png'))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.grey[500]!, width: 0.5)),
                            border: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Colors.grey[400]!, width: 0.5))))))
          ]));
    }

    Widget searchResultList(Occupation occupation) {
      return Padding(
          padding:
              const EdgeInsets.only(left: 80, top: 20, bottom: 20, right: 40),
          child: Row(children: [
            Expanded(child: Text(occupation.occupationName!, style: sFontW5())),
            Expanded(child: Text(occupation.industryName!, style: sFontWN())),
            Expanded(child: Text(occupation.occupationCode!, style: sFontWN())),
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Text(occupation.occupationClass!, style: sFontWN()),
                  Icon(Icons.adaptive.arrow_forward)
                ]))
          ]));
    }

    Widget searchResult() {
      return SizedBox(
          height: MediaQuery.of(context).size.height * 0.86,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(
                    left: 80, top: 12, bottom: 12, right: 40),
                child: Row(children: [
                  Expanded(
                      child: Text(getLocale("Occupation"), style: sFontWN())),
                  Expanded(
                      child: Text(getLocale("Industry"), style: sFontWN())),
                  Expanded(
                      child:
                          Text(getLocale("Occupation Code"), style: sFontWN())),
                  Expanded(
                      child:
                          Text(getLocale("Occupation Class"), style: sFontWN()))
                ])),
            const Divider(),
            Expanded(
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(children: [
                      if (occupationResult.isNotEmpty)
                        for (int i = 0; i < occupationResult.length; i++)
                          Column(children: [
                            GestureDetector(
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  Navigator.of(context)
                                      .pop(occupationResult[i]);
                                },
                                child: searchResultList(occupationResult[i])),
                            const Divider()
                          ])
                    ])))
          ]));
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(children: [
              progressBar(context, 6, 1),
              const SizedBox(height: 20),
              searchBar(),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5), child: Divider()),
              searchResult()
            ])));
  }
}
