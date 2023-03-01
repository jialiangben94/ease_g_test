import 'package:ease/src/bloc/medical_exam/panel_lists_bloc/panel_lists_bloc.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoosePanel extends StatefulWidget {
  final String? postcode;
  final String facilityCode;
  const ChoosePanel(this.postcode, this.facilityCode, {Key? key})
      : super(key: key);
  @override
  ChoosePanelState createState() => ChoosePanelState();
}

class ChoosePanelState extends State<ChoosePanel>
    with SingleTickerProviderStateMixin {
  //Layout Setting
  double minPanelColHeight = 150.0;
  TabController? _tabController;

  int currentIndex = 0;
  Panel? _selectedPanel;
  double? lat;
  double? lng;

  String? keyword;
  final TextEditingController _searchKeyword = TextEditingController();
  List<String> _clinicType = ["Hospital", "Clinic", "Mobile Paramedic"];
  String? facilityCode;

  int x = 0;

  @override
  void initState() {
    _checkFacilityCode();
    super.initState();
    analyticsSetCurrentScreen("Choose A Panel", "MedicalCheckAppointment");
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    BlocProvider.of<PanelListsBloc>(context)
        .add(GetPanelList(_clinicType[currentIndex], keyword, facilityCode));
  }

  void _checkFacilityCode() {
    bool haveOTH = false;
    facilityCode = widget.facilityCode;
    List<String> facilityCodeList = facilityCode!.split(";");
    for (int i = 0; i < facilityCodeList.length; i++) {
      if (facilityCodeList[i].length > 2 &&
          facilityCodeList[i].substring(0, 3) == "OTH") {
        setState(() {
          haveOTH = true;
        });
        break;
      }
    }

    if (haveOTH) {
      setState(() {
        _clinicType = ["Mobile Paramedic"];
      });
    } else {
      setState(() {
        _clinicType = ["Hospital", "Clinic"];
      });
    }

    keyword ??= widget.postcode;
    _tabController = TabController(vsync: this, length: _clinicType.length);
    _tabController!.addListener(_setActiveTabIndex);
  }

  void _setActiveTabIndex() {
    setState(() {
      currentIndex = _tabController!.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget checkSelectedPanel() {
      return AnimatedContainer(
          height: _selectedPanel != null ? 60 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Visibility(
              visible: _selectedPanel != null,
              child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 0))
                  ]),
                  child: TextButton(
                      style: TextButton.styleFrom(backgroundColor: honeyColor),
                      onPressed: () {
                        analyticsSendEvent("confirm_selected_panel", {
                          "button_name": "SELECT",
                          "selectedPanelCode": _selectedPanel!.providerCode,
                          "selectedPanelName": _selectedPanel!.name
                        });
                        if (_selectedPanel != null) {
                          Navigator.of(context).pop(_selectedPanel);
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(getLocale("SELECT"),
                              style: tFontWN().copyWith(fontSize: 22)))))));
    }

    Widget buildInitialInput() {
      return Center(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
            const Image(
                width: 140,
                height: 150,
                image: AssetImage('assets/images/no_hospital_icon.png')),
            const SizedBox(height: 10),
            Text(
                "${getLocale("Special No for Tiada")} ${_clinicType[currentIndex]} ${getLocale("found near you")}", //Looi to look into "No " to "Tiada "
                style: bFontWN()),
            Text(getLocale("Please try to search other location or name."),
                style: bFontWN())
          ])));
    }

    Widget buildError(String message) {
      return Center(
          child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
            const Image(
                width: 140,
                height: 150,
                image: AssetImage('assets/images/no_hospital_icon.png')),
            const SizedBox(height: 10),
            Text("No ${_clinicType[currentIndex]} found", style: bFontWN()),
            Text(message, style: bFontWN())
          ])));
    }

    Widget buildPanelTable(BuildContext context, PanelListsLoaded loadedState,
        String selectedPanelType) {
      final listOfPanel = loadedState.panelList;

      return listOfPanel.isNotEmpty
          ? SingleChildScrollView(
              child: Column(children: [
              Visibility(
                  visible: listOfPanel.isNotEmpty,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Text(
                                _searchKeyword.text == ""
                                    ? "${_clinicType[currentIndex]} ${getLocale("nearby customer's house")}"
                                    : "${getLocale("Total")} ${listOfPanel.length} ${getLocale(_clinicType[currentIndex])}${getLocale("(s) found")}",
                                style:
                                    bFontW5().copyWith(color: greyTextColor))),
                        const SizedBox(height: 10),
                        Container(
                            width: double.infinity,
                            color: greyDividerColor,
                            height: 1),
                      ])),
              for (int i = 0; i < listOfPanel.length; i++)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPanel = listOfPanel[i];
                        });
                        analyticsSendEvent("panel_selected", {
                          "panelCode": _selectedPanel!.providerCode,
                          "panelName": _selectedPanel!.name
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey[200]!))),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50.0, vertical: 20.0),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(listOfPanel[i].name!, style: t2FontW5()),
                                  const SizedBox(height: 5),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 40),
                                                child: Text(
                                                    cleanPanelAddress(
                                                        listOfPanel[i]
                                                            .address!),
                                                    style: sFontWN().copyWith(
                                                        color:
                                                            greyTextColor)))),
                                        Expanded(
                                            child: Text(
                                                "${getLocale("Open at")} ${listOfPanel[i].bizHrs},\n${listOfPanel[i].contact},",
                                                style: sFontWN().copyWith(
                                                    color: greyTextColor)))
                                      ])
                                ])),
                            _selectedPanel == listOfPanel[i]
                                ? const Image(
                                    width: 25,
                                    height: 25,
                                    image: AssetImage(
                                        'assets/images/check_circle.png'))
                                : Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey)))
                          ])))
                ])
            ]))
          : _searchKeyword.text != ""
              ? buildError("Please try to search other location or name.")
              : buildInitialInput();
    }

    Widget leftRow() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: TextField(
                controller: _searchKeyword,
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _searchKeyword.text = value;
                  if (_searchKeyword.text != "") {
                    keyword = _searchKeyword.text;
                  } else {
                    keyword = widget.postcode;
                  }
                  analyticsSendEvent("search_panel", {"keyword": keyword});
                  BlocProvider.of<PanelListsBloc>(context).add(GetPanelList(
                      _clinicType[currentIndex], keyword, facilityCode));
                },
                cursorColor: Colors.grey,
                style: t1FontWN(),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    hintText: getLocale('Search by location / panel name'),
                    hintStyle: bFontWN().copyWith(color: Colors.grey[800]),
                    suffixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Image(
                            width: 10,
                            height: 10,
                            image:
                                AssetImage('assets/images/search_icon.png'))),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.grey, width: 0.5)),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide:
                            BorderSide(color: Colors.grey, width: 0.5))))),
        Padding(
            padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 20),
            child: SizedBox(
                width: double.infinity,
                child: SizedBox(
                    height: 52,
                    child: TabBar(
                        isScrollable: true,
                        onTap: (index) {
                          setState(() {
                            currentIndex = index;
                            _tabController!.animateTo(index);
                          });
                          analyticsSendEvent("change_panel_type",
                              {"button_name": _clinicType[index]});
                          if (_searchKeyword.text != "") {
                            keyword = _searchKeyword.text;
                          } else {
                            keyword = widget.postcode;
                          }

                          BlocProvider.of<PanelListsBloc>(context).add(
                              GetPanelList(_clinicType[currentIndex], keyword,
                                  facilityCode));
                        },
                        labelColor: Colors.black,
                        indicatorColor: Colors.transparent,
                        tabs: [
                          for (int i = 0; i < _clinicType.length; i++)
                            Stack(children: [
                              Center(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                          _clinicType[i] == "Clinic"
                                              ? getLocale("Clinic")
                                              : _clinicType[i],
                                          style: t2FontWN().copyWith(
                                              fontWeight: i == currentIndex
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)))),
                              Visibility(
                                  visible: i == currentIndex,
                                  child: Positioned(
                                      right: 0,
                                      bottom: 0,
                                      left: 0,
                                      child: Container(
                                          color: honeyColor, height: 2.8)))
                            ])
                        ])))),
        Expanded(
            child: BlocListener<PanelListsBloc, PanelListsState>(
                listener: (context, state) {
          if (state is PanelListsError) {
            showSnackBarError(state.message!);
          }
        }, child: BlocBuilder<PanelListsBloc, PanelListsState>(
                    builder: (context, state) {
          if (state is PanelListsInitial) {
            return buildInitialInput();
          } else if (state is PanelListsLoading) {
            return buildLoading();
          } else if (state is PanelListsLoaded) {
            return TabBarView(
                controller: _tabController,
                children: _clinicType.length > 1
                    ? [
                        buildPanelTable(context, state, "Hospital"),
                        buildPanelTable(context, state, getLocale("Clinic"))
                      ]
                    : [buildPanelTable(context, state, "Paramedic")]);
          } else if (state is PanelListsError) {
            return buildError(state.message!);
          } else {
            return buildInitialInput();
          }
        })))
      ]);
    }

    return DefaultTabController(
        length: _clinicType.length,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(75),
                child: Column(children: [
                  progressBar(context, 0.6, 1),
                  normalAppBar(context, getLocale("Choose a panel"))
                ])),
            body: leftRow(),
            bottomNavigationBar: checkSelectedPanel()));
  }
}
