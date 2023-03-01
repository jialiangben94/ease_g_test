import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ease/src/bloc/new_business/master_lookup/master_lookup_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/screen/new_business/application/application_main.dart';
import 'package:ease/src/screen/new_business/application/application_list/application_list_home.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/create_new_quote.dart';
import 'package:ease/src/screen/new_business/quotation/quotation_table/generated_quotation.dart';
import 'package:ease/src/util/comm_error_handler.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/util/required_file_handler.dart';
import 'package:ease/src/util/validation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewBusinessHome extends StatefulWidget {
  final Function? hideModule;
  final Function? unhideModule;
  const NewBusinessHome({Key? key, this.hideModule, this.unhideModule})
      : super(key: key);
  @override
  NewBusinessHomeState createState() => NewBusinessHomeState();
}

class NewBusinessHomeState extends State<NewBusinessHome>
    with SingleTickerProviderStateMixin {
  List<String> serviceTitle = [
    getLocale("Generated Quotation"),
    getLocale("Incomplete Application"),
    getLocale("Submitted Application")
  ];

  List<DropdownMenuItem<String>> sortBy = [
    (DropdownMenuItem(value: "Latest", child: Text(getLocale('Latest')))),
    (DropdownMenuItem(
        value: "High Potential", child: Text(getLocale('High Potential')))),
    (DropdownMenuItem(
        value: "Follow Up Required",
        child: Text(getLocale('Follow Up Required')))),
    (DropdownMenuItem(
        value: "Low Potential", child: Text(getLocale('Low Potential')))),
    (DropdownMenuItem(
        value: "High to Low Premium (Monthly)",
        child: Text(getLocale('High to Low Premium (Monthly)')))),
    (DropdownMenuItem(
        value: "High to Low Premium (Yearly)",
        child: Text(getLocale('High to Low Premium (Yearly)')))),
    (DropdownMenuItem(
        value: "Low to High Premium (Monthly)",
        child: Text(getLocale('Low to High Premium (Monthly)')))),
    (DropdownMenuItem(
        value: "Low to High Premium (Yearly)",
        child: Text(getLocale('Low to High Premium (Yearly)'))))
  ];

  int x = 0;
  int? currentIndex;
  int? dayValid;
  String? selectedSortBy;
  TabController? _nbTabController;
  bool isReady = false;

  int max = 6;
  int currentProgress = 0;

  @override
  void initState() {
    _downloadResource();
    super.initState();
    BlocProvider.of<MasterLookupBloc>(context).add(const GetMasterLookUpList());
    currentIndex = 0;
    selectedSortBy = "Latest";
    _nbTabController = TabController(vsync: this, length: serviceTitle.length);
    _nbTabController!.addListener(_setActiveTabIndex);
    checkDayValid();
  }

  // @override
  void checkDayValid() async {
    BlocProvider.of<QuotationBloc>(context).add(LoadQuotation());
    if (dayValid == null) {
      await getDayValid();
    }
  }

  Future getDayValid() async {
    bool haveConn = await checkConnectivity();
    if (haveConn) {
      await NewBusinessAPI().getConfig("QuickQuotationValidity").then((res) {
        if (res != null) dayValid = int.parse(res["ParamValue"]);
      }).catchError((error) {
        if (error is AppCustomException) {
          showSnackBarError("${error.message}. Please try again.");
        } else {
          showSnackBarError("$error. Please try again.");
        }
      });
    }
  }

  void _setActiveTabIndex() {
    setState(() {
      currentIndex = _nbTabController!.index;
      _nbTabController!.animateTo(_nbTabController!.index);
    });
  }

  void updateProgress({int? value}) {
    setState(() {
      currentProgress = value ?? (currentProgress + 1);
    });
  }

  Future<void> _downloadResource() async {
    final pref = await SharedPreferences.getInstance();
    bool resourcesdownloadedafterlogin = false;
    if (pref.getBool("resourcesdownloadedafterlogin") != null) {
      resourcesdownloadedafterlogin =
          pref.getBool("resourcesdownloadedafterlogin")!;
    }

    if (!resourcesdownloadedafterlogin) {
      for (final prodCode in availableProductCode.keys) {
        checkVPMSData(prodCode, availableProductCode[prodCode]!);
      }
    }

    final output = await getTemporaryDirectory();
    final fileOcc = File("${output.path}/occ.json");
    final fileProdPlan = File("${output.path}/product_setup_plan.json");
    final fileRiderPLan = File("${output.path}/product_setup_rider.json");
    final fileMaster = await optionListFile();
    final fileMasterType = await optionTypeFile();
    final bankList = await bankListFile();
    final translation = await translationFile();

    ConnectivityResult conn = await (Connectivity().checkConnectivity());

    if (conn != ConnectivityResult.none) {
      if (!fileOcc.existsSync()) {
        await downloadOccupationList();
      } else {
        if (!resourcesdownloadedafterlogin) await updateOccupationList();
      }
      updateProgress();
      if (!fileProdPlan.existsSync()) {
        await downloadProductSetupPlan();
      } else {
        if (!resourcesdownloadedafterlogin) await updateProductSetupPlan();
      }
      updateProgress();
      if (!fileRiderPLan.existsSync()) {
        await downloadProductSetupRider();
      } else {
        if (!resourcesdownloadedafterlogin) await updateProductSetupRider();
      }
      updateProgress();
      await downloadAgentDetail(!resourcesdownloadedafterlogin);
      updateProgress();
      await downloadDynamicFieldsFile();
      updateProgress();
      if (!fileMaster.existsSync() ||
          !fileMasterType.existsSync() ||
          !bankList.existsSync() ||
          !translation.existsSync()) {
        await downloadMasterData().then((data) {
          isReady = true;
        }).catchError((onError) {
          isReady = true;
        });
      } else {
        if (!resourcesdownloadedafterlogin) {
          await updateMasterData().then((data) {
            isReady = true;
          }).catchError((onError) {
            isReady = true;
          });
        } else {
          isReady = true;
        }
      }
    } else {
      isReady = true;
    }
    updateProgress(value: max);
    if (mounted) setState(() {});
    await pref.setBool("resourcesdownloadedafterlogin", true);
  }

  @override
  Widget build(BuildContext context) {
    Widget tabBar() {
      return Stack(children: [
        Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
                color: greyDividerColor, height: 1, width: double.infinity)),
        Column(children: [
          Stack(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 0),
                  child: Row(children: [
                    Padding(
                        padding: const EdgeInsets.only(right: 22),
                        child: GestureDetector(
                            onTap: () {
                              analyticsSendEvent("create_new_quote",
                                  {"button_name": "+ Create New Quote"});
                              analyticsSendEvent(
                                  "create_new_quote_and_application",
                                  {"button_name": "+ Create New Quote"});
                              Navigator.of(context)
                                  .push(createRoute(const CreateNewQuote()));
                            },
                            child: Text("+ ${getLocale("Create New Quote")}",
                                style: t2FontW5().copyWith(color: cyanColor)))),
                    Padding(
                        padding: const EdgeInsets.only(right: 22),
                        child: GestureDetector(
                            onTap: () {
                              analyticsSendEvent("create_new_application",
                                  {"button_name": "+ New Application"});
                              analyticsSendEvent(
                                  "create_new_quote_and_application",
                                  {"button_name": "+ New Application"});
                              Navigator.of(context)
                                  .push(createRoute(const ApplicationForm()));
                            },
                            child: Text("+ ${getLocale("New Application")}",
                                style: t2FontW5().copyWith(color: cyanColor)))),
                    Expanded(
                        flex: 10,
                        child: Container(
                            color: Colors.white,
                            width: double.infinity,
                            height: 62,
                            child: TabBar(
                                controller: _nbTabController,
                                isScrollable: true,
                                indicator: UnderlineTabIndicator(
                                    borderSide: BorderSide(
                                        width: 4.0, color: honeyColor),
                                    insets: const EdgeInsets.symmetric(
                                        horizontal: 16.0)),
                                onTap: (index) {
                                  setState(() {
                                    currentIndex = index;
                                    _nbTabController!.animateTo(currentIndex!);
                                  });
                                },
                                labelColor: Colors.black,
                                indicatorColor: honeyColor,
                                tabs: [
                                  for (int i = 0; i < serviceTitle.length; i++)
                                    Stack(children: [
                                      Center(
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: Row(children: [
                                                Text(
                                                    //serviceTitle[i],
                                                    i == 0
                                                        ? getLocale(
                                                            "Generated Quotation")
                                                        : i == 1
                                                            ? getLocale(
                                                                "Incomplete Application")
                                                            : i == 2
                                                                ? getLocale(
                                                                    "Submitted Application")
                                                                : "",
                                                    style: bFontWN().copyWith(
                                                        fontWeight: i ==
                                                                currentIndex
                                                            ? FontWeight.w600
                                                            : FontWeight
                                                                .normal)),
                                                SizedBox(width: i == 0 ? 8 : 0)
                                              ])))
                                    ])
                                ])))
                  ]))
            ]),
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    color: creamColor, height: 10, width: double.infinity)),
            Positioned(
                right: 0,
                bottom: 0,
                left: 0,
                child: Container(
                    color: greyDividerColor, height: 1, width: double.infinity))
          ])
        ])
      ]);
    }

    Widget buildGeneratedQuotationTable() {
      if (currentIndex != 0) {
        return const SizedBox();
      }

      Row sortByHeader() {
        var numOfQtn = 0;

        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<QuotationBloc, QuotationBlocState>(
                  builder: (context, state) {
                if (state is QuotationLoadSuccess) {
                  numOfQtn = state.quotations.length;
                }
                //getLocale("Generated Quotation"),
                //Text("${getLocale("Life Insured", entity: true)}'s Home Address",
                return Text(
                    "${getLocale("We found a total of")} $numOfQtn ${getLocale("quotation(s)")}",
                    style: t2FontWN().copyWith(color: greyTextColor));
              }),
              Row(children: [
                Text(getLocale("Sort by"),
                    style: t2FontWN().copyWith(color: greyTextColor)),
                const SizedBox(width: 20),
                Container(
                    height: 60,
                    decoration: BoxDecoration(
                        border: Border.all(color: greyBorderColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5))),
                    child: DropdownButtonHideUnderline(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton(
                                value: selectedSortBy,
                                style: t2FontWN(),
                                icon: Transform.scale(
                                    scale: 0.8,
                                    child:
                                        const Icon(Icons.keyboard_arrow_down)),
                                hint: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Text(getLocale("Latest"))),
                                items: [
                                  (DropdownMenuItem(
                                      value: "Latest",
                                      child: Text(getLocale('Latest')))),
                                  (DropdownMenuItem(
                                      value: "High Potential",
                                      child:
                                          Text(getLocale('High Potential')))),
                                  (DropdownMenuItem(
                                      value: "Low Potential",
                                      child: Text(getLocale('Low Potential')))),
                                  (DropdownMenuItem(
                                      value: "High to Low Premium (Monthly)",
                                      child: Text(getLocale(
                                          'High to Low Premium (Monthly)')))),
                                  (DropdownMenuItem(
                                      value: "High to Low Premium (Yearly)",
                                      child: Text(getLocale(
                                          'High to Low Premium (Yearly)')))),
                                  (DropdownMenuItem(
                                      value: "Low to High Premium (Monthly)",
                                      child: Text(getLocale(
                                          'Low to High Premium (Monthly)')))),
                                  (DropdownMenuItem(
                                      value: "Low to High Premium (Yearly)",
                                      child: Text(getLocale(
                                          'Low to High Premium (Yearly)'))))
                                ], //sortBy,
                                onChanged: (dynamic value) {
                                  setState(() {
                                    selectedSortBy = value;
                                    BlocProvider.of<QuotationBloc>(context)
                                        .add(SortQuotation(selectedSortBy));
                                  });
                                }))))
              ])
            ]);
      }

      Widget colorCategoryHeader() {
        return Row(children: [
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: lightCyanColorFour, shape: BoxShape.circle)),
            const SizedBox(width: 15),
            Text(getLocale("High Potential"),
                style: sFontWN().copyWith(color: lightCyanColorFive))
          ]),
          const SizedBox(width: 30),
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: orangeRedColor, shape: BoxShape.circle)),
            const SizedBox(width: 15),
            Text(getLocale("Follow Up Required"),
                style: sFontWN().copyWith(color: orangeRedColor))
          ]),
          const SizedBox(width: 30),
          Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: lightBrownColor, shape: BoxShape.circle)),
            const SizedBox(width: 15),
            Text(getLocale("Low Potential"),
                style: sFontWN().copyWith(color: lightGreyColor))
          ]),
          // SizedBox(width: 30),
          // Row(children: [
          //   Container(
          //       width: 10,
          //       height: 10,
          //       decoration: BoxDecoration(
          //           color: lightGreyColor, shape: BoxShape.circle)),
          //   SizedBox(width: 15),
          //   Text("Uncategorised",
          //       style: sFontWN().copyWith(color: lightGreyColor))
          // ])
        ]);
      }

      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: Column(children: [
            sortByHeader(),
            const SizedBox(height: 30),
            colorCategoryHeader()
          ]));
    }

    Widget buildQtnTable(int? dayValid) {
      return NotificationListener<UserScrollNotification>(
          onNotification: (userScrollNotification) {
            if (userScrollNotification.direction == ScrollDirection.reverse &&
                userScrollNotification.metrics.axisDirection ==
                    AxisDirection.down) {
              widget.hideModule!();
            } else if (userScrollNotification.direction ==
                ScrollDirection.forward) {
              widget.unhideModule!();
            }
            return true;
          },
          child: TabBarView(controller: _nbTabController, children: [
            GeneratedQuotation(dayValid: dayValid),
            ApplicationListHome(
                appStatus: AppStatus.incomplete, dayValid: dayValid),
            ApplicationListHome(
                appStatus: AppStatus.completed, dayValid: dayValid)
          ]));
    }

    return DefaultTabController(
        length: serviceTitle.length,
        child: isReady
            ? Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.white,
                body: Column(children: [
                  tabBar(),
                  buildGeneratedQuotationTable(),
                  Expanded(
                      child: BlocListener<QuotationBloc, QuotationBlocState>(
                          listener: (context, state) {
                            if (state is QuotationLoadError) {
                              showSnackBarError(state.message);
                            }
                          },
                          child: buildQtnTable(dayValid)))
                ]))
            : Column(children: [
                Container(
                    color: creamColor, height: 10, width: double.infinity),
                Expanded(
                    child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        tween: Tween<double>(
                          begin: 0,
                          end: currentProgress / max,
                        ),
                        builder: (context, value, _) {
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 80),
                                  child: buildLinearProgress(value),
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text("${(value * 100).toInt()}%",
                                        style: t2FontWN()
                                            .copyWith(color: greyTextColor))),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(
                                        getLocale("Downloading resources"),
                                        style: t2FontWN()
                                            .copyWith(color: greyTextColor)))
                              ]);
                        }))
              ]));
  }
}
