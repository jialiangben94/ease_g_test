import 'dart:typed_data';
import 'dart:ui';

import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/bloc/user_profile/user_profile_bloc.dart';
import 'package:ease/src/data/new_business_model/funds.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_main.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/product_summary.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/si_table.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/view_full_si_pds/view_full.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:ease/src/widgets/transparent_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NewQuotationGenerated extends StatefulWidget {
  final int? qtnId;
  final Quotation qtn;
  final QuickQuotation? quickQuotation;
  final Status? status; // Status == "2" (View already generated quotation)

  const NewQuotationGenerated(
      {Key? key,
      this.qtnId,
      required this.qtn,
      this.quickQuotation,
      this.status})
      : super(key: key);
  @override
  NewQuotationGeneratedState createState() => NewQuotationGeneratedState();
}

class NewQuotationGeneratedState extends State<NewQuotationGenerated> {
  int? premium;
  int? policyTerm;
  int? premiumTerm;
  int sumOfFund = 0;
  int totalAllSA = 0;
  bool? isSteppedPrem;
  bool viewQuotationVersion = true;

  String? selectedBuyingFor;
  String? paymentMode;
  String? dateTime;
  String? maturityAge;
  String planName = "";
  String policyTermList = "";
  String sumInsured = "0";
  String rtuSA = "0";
  String totalRiderSA = "0";
  String? totalPremium;
  String? rtuPremium;
  double totalMonthlyPremium = 0;
  QuickQuotation? quickQuoteData;
  QuickQuotation? _quickQuotationData;

  List<Funds>? fundList;
  List<String> fundNames = [];
  List<dynamic> riderTerm = [];
  List<dynamic> riderSA = [];
  List<dynamic> fundsAllocation = [];

  List endOfPolicyYear = []; // P_O_EOY (Table 1 Premium)

  List<ProductPlan>? riderList;
  List<List<String>> tableData = [];

  bool isChecking = false;

  late QuotationBloc _qtnBloc;
  QuotationStatus? quotationStatus;
  // RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d),),');
  // Function mathFunc = (Match match) => '${match[1]},';

  final GlobalKey _quotationImage = GlobalKey();

  @override
  void initState() {
    analyticsSetCurrentScreen(
        widget.status == Status.newQuote
            ? "New Quotation Generated"
            : widget.status == Status.editAge
                ? "Quotation Updated"
                : widget.status == Status.edit
                    ? "Quotation Updated"
                    : widget.status == Status.edit
                        ? "View Quotation Detail"
                        : "New Quotation Generated",
        widget.status == Status.newQuote
            ? "NewQuotationGenerated"
            : widget.status == Status.editAge
                ? "QuotationUpdated"
                : widget.status == Status.edit
                    ? "QuotationUpdated"
                    : widget.status == Status.edit
                        ? "ViewQuotationDetail"
                        : "NewQuotationGenerated");
    super.initState();
    selectedBuyingFor = widget.qtn.buyingFor;
    checkIsQQActive();
  }

  void checkIsQQActive() async {
    BlocProvider.of<QuotationBloc>(context).add(LoadQuotation());
    quotationStatus = await isQuotationActive(
        context,
        widget.quickQuotation!.productPlanCode,
        widget.quickQuotation!.vpmsVersion,
        widget.qtn.lifeInsured!.dob!,
        widget.qtn.lifeInsured!.age!,
        widget.quickQuotation!.status,
        widget.quickQuotation!.totalPremium ?? '-');
    if (quotationStatus == QuotationStatus.expiredAge) {
      promptNotice(
          "The quotation could not be generated due to the ${getLocale("Life Insured", entity: true)}’s age increase.");
    } else if (quotationStatus == QuotationStatus.expiredVPMS) {
      promptNotice(
          "There seems to be new calculation updates for this quotation.");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void redirectToChooseProduct(Uint8List imageString) {
    ProductPlanState data = BlocProvider.of<ProductPlanBloc>(context).state;

    if (data is ProductPlanLoaded) {
      // update qtn
      _qtnBloc = BlocProvider.of<QuotationBloc>(context);
      _qtnBloc.add(FindQuotation(widget.qtn.uid));

      Quotation updateQtn = widget.qtn;
      updateQtn.lifeInsured!.age =
          getAgeString(updateQtn.lifeInsured!.dob!, false);

      //To handle copy & keep old quick quotation
      QuickQuotation toBeArchivedQuotation =
          QuickQuotation.fromMap(_quickQuotationData!.toMap());
      toBeArchivedQuotation.quickQuoteId = generateQuickQuotationId();
      toBeArchivedQuotation.status = "2";
      updateQtn.listOfQuotation!.add(toBeArchivedQuotation);
      _qtnBloc.add(UpdateQuotation(updateQtn));
      /////////////////////////////////////////////

      Navigator.of(context).push(TransparentRoute(
          builder: (BuildContext context) => ChooseProducts(
              updateQtn.id, updateQtn,
              quickQtnId: _quickQuotationData!.quickQuoteId,
              status: Status.editAge,
              imageString: imageString)));

      //EDIT QUOTE
      Future.delayed(const Duration(milliseconds: 100), () {
        BlocProvider.of<ChooseProductBloc>(context).add(EditQuotation(
            quotation: updateQtn, quickQuotation: _quickQuotationData!));
      });
    }
  }

  Future<Map> takeScreenshot() async {
    Uint8List pngBytes = Uint8List(0);

    var data = {'success': false, 'val': pngBytes};
    RenderRepaintBoundary imageObject = _quotationImage.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    final image = await imageObject.toImage(pixelRatio: 2);
    ByteData? byteData = await (image.toByteData(format: ImageByteFormat.png));

    if (byteData != null) {
      pngBytes = byteData.buffer.asUint8List();
      data['success'] = true;
      data['val'] = pngBytes;
    } else {
      data['success'] = false;
    }

    return data;
  }

  void promptNotice(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SystemPadding(
              child: Center(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.38),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.43,
                          height: MediaQuery.of(context).size.height * 0.36,
                          child: AlertDialog(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              contentPadding: const EdgeInsets.only(
                                  left: 40, right: 40, bottom: 30),
                              title: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  child: Text(
                                      getLocale("Quotation update required"),
                                      style: t1FontW5())),
                              content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: Text(message, style: bFontWN())),
                                    Row(children: [
                                      Expanded(
                                          flex: 2,
                                          child: TextButton(
                                              style: TextButton.styleFrom(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      10.0))),
                                                  backgroundColor: honeyColor,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16)),
                                              onPressed: () async {
                                                //Take Screenshot first
                                                var imageData =
                                                    await takeScreenshot();

                                                if (imageData['success'] ==
                                                    true) {
                                                  if (!mounted) {}
                                                  Navigator.of(context).pop();
                                                  redirectToChooseProduct(
                                                      imageData['val']);
                                                } else {
                                                  if (!mounted) {}
                                                  showAlertDialog(
                                                      context,
                                                      getLocale('Sorry'),
                                                      getLocale(
                                                          'Unexpected error occur during updating quotation. Please try generate a new one'));
                                                }
                                              },
                                              child: Text(
                                                  getLocale(
                                                      'Proceed to Update Quotation'),
                                                  style: t2FontWB())))
                                    ])
                                  ]))))));
        });
  }

  void checkBeforeProceed() async {
    if (quotationStatus == QuotationStatus.expiredAge) {
      promptNotice(
          "${getLocale("The quotation could not be generated due to the")} ${getLocale("Life Insured", entity: true)} ${getLocale("’s age increase.")}");
    } else if (quotationStatus == QuotationStatus.expiredVPMS) {
      promptNotice(getLocale(
          "There seems to be new calculation updates for this quotation."));
    } else {
      await Navigator.of(context).push(createRoute(ApplicationForm(
          quoId: widget.qtnId, qquoId: _quickQuotationData!.quickQuoteId)));
      await analyticsSendEvent(
          "proceed_to_application", {"qoutation_id": widget.qtnId});
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isChecking = false;
      });
    });
  }

  Column tableheader() {
    var color = getColor(widget.qtn.category);

    var header = [
      {"label": getLocale("Requested Date"), "size": 2},
      {"label": getLocale("Selected Product"), "size": 2},
      {"label": getLocale("Sum Insured Amount"), "size": 2},
      {"label": getLocale("Premium Amount"), "size": 2},
      {"label": getLocale("Status"), "size": 1}
    ];
    List<Widget> widList = [];
    widList.add(Container(
        margin: const EdgeInsets.only(right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text("Version",
            overflow: TextOverflow.ellipsis,
            style: sFontWN().copyWith(color: lightGreyColor))));

    for (var element in header) {
      widList.add(Expanded(
          flex: element["size"] as int,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(element["label"] as String,
                  overflow: TextOverflow.ellipsis,
                  style: sFontWN().copyWith(color: lightGreyColor)))));
    }

    return Column(children: [
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 35.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(getLocale("Quotation Version"), style: tFontW5()),
                  const SizedBox(height: 15),
                  Row(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getLocale("Policy Owner", entity: true)),
                          const SizedBox(height: 10),
                          Row(children: [
                            CircleAvatar(
                                radius: 16,
                                backgroundColor: color[1],
                                child: Text(
                                    widget.qtn.policyOwner!.name != null
                                        ? widget.qtn.policyOwner!.name![0]
                                        : "",
                                    style:
                                        t2FontW5().copyWith(color: color[0]))),
                            const SizedBox(width: 15),
                            Text(
                                widget.qtn.policyOwner!.name != null
                                    ? widget.qtn.policyOwner!.name!
                                    : "",
                                style: t2FontWB())
                          ])
                        ]),
                    SizedBox(width: gFontSize * 4),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getLocale("Life Insured", entity: true)),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text(
                                widget.qtn.lifeInsured!.name != null
                                    ? widget.qtn.lifeInsured!.name!
                                    : "",
                                style: t2FontWN())
                          ])
                        ])
                  ])
                ]),
                IconButton(
                    iconSize: 35,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ])),
      Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widList))
    ]);
  }

  GestureDetector quotationversion(QuickQuotation quickQuotation) {
    var content = [
      {
        "label": quickQuotation.dateTime != null
            ? dateTimetoWithoutTime(quickQuotation.dateTime!)
            : "-",
        "size": 2
      },
      {"label": quickQuotation.productPlanName ?? "", "size": 2},
      {
        "label": quickQuotation.basicPlanSumInsured != null
            ? toRM(quickQuotation.basicPlanSumInsured, rm: true)
            : "-",
        "size": 2
      },
      {
        "label": quickQuotation.totalPremium != null
            ? '${toRM(quickQuotation.totalPremium, rm: true)} ${convertPaymentMode(quickQuotation.paymentMode).toLowerCase()}'
            : "-",
        "size": 2
      }
    ];
    List<Widget> widList = [];

    widList.add(Container(
        decoration: BoxDecoration(
            color: lightCyanColorFive,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        margin: const EdgeInsets.only(right: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
            quickQuotation.version != null
                ? "${getLocale("Version")} ${quickQuotation.version}"
                : "-",
            overflow: TextOverflow.ellipsis,
            style: sFontWN().copyWith(color: Colors.white))));

    for (var element in content) {
      widList.add(Expanded(
          flex: element["size"] as int,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(element["label"] as String,
                  overflow: TextOverflow.ellipsis, style: bFontWN()))));
    }

    widList.add(Expanded(
        flex: 1,
        child: FutureBuilder<QuotationStatus>(
            future: isQuotationActive(
                context,
                quickQuotation.productPlanCode,
                quickQuotation.vpmsVersion,
                widget.qtn.lifeInsured!.dob!,
                widget.qtn.lifeInsured!.age!,
                quickQuotation.status,
                quickQuotation.totalPremium ?? '-'),
            builder: (BuildContext context,
                AsyncSnapshot<QuotationStatus> snapshot) {
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: snapshot.hasData
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                              Text(
                                  snapshot.data == QuotationStatus.active
                                      ? getLocale("Active")
                                      : getLocale("Expired"),
                                  textAlign: TextAlign.center,
                                  style: bFontW5().copyWith(
                                      fontSize: 14,
                                      fontWeight: snapshot.data ==
                                              QuotationStatus.active
                                          ? FontWeight.w500
                                          : FontWeight.normal)),
                              Icon(Icons.adaptive.arrow_forward_outlined,
                                  size: 10, color: cyanColor)
                            ])
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Expanded(
                                  child: Text(getLocale("Checking"),
                                      textAlign: TextAlign.center,
                                      style: bFontWN().copyWith(fontSize: 13))),
                              Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color?>(
                                              Colors.grey[500])))
                            ]));
            })));

    return GestureDetector(
        onTap: () {
          setState(() {
            BlocProvider.of<ChooseProductBloc>(context).add(
                ViewGeneratedQuotation(
                    quotation: widget.qtn, quickQuotation: quickQuotation));

            Future.delayed(const Duration(milliseconds: 5), () {
              Navigator.of(context).pop();
            });
          });
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: Colors.grey[200]!),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: widList)))));
  }

  void _showModalSheet() {
    // Need to use try here, in case quotation is incomplete, version is null
    try {
      widget.qtn.listOfQuotation!
          .sort((a, b) => b!.version!.compareTo(a!.version!)); // Just to sort
    } catch (e) {
      rethrow;
    }

    List<QuickQuotation?> listOfQuotation = [];

    var qtn = widget.qtn.listOfQuotation!;

    for (var element in qtn) {
      if ((element!.totalPremium != null &&
          element.totalPremium != "" &&
          element.sumInsuredAmt != null &&
          element.sumInsuredAmt != "")) {
        listOfQuotation.add(element);
      }
    }

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Stack(children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 35, right: 35, bottom: 30),
                      child: ListView.builder(
                          itemCount: listOfQuotation.length,
                          itemBuilder: (BuildContext context, i) {
                            return Column(children: [
                              if (i == 0) tableheader(),
                              quotationversion(listOfQuotation[i]!)
                            ]);
                          })))
            ]);
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Widget col1(String title) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(title, style: bFontWN()));
    }

    Widget col2(String desc) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(desc, style: bFontW5()));
    }

    Widget fundTableSummary() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Column(children: [
            Table(
                border: TableBorder(
                    horizontalInside:
                        BorderSide(width: 1.4, color: greyDividerColor)),
                columnWidths: const {
                  0: FlexColumnWidth(8),
                  1: FlexColumnWidth(2)
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [
                    Container(
                        decoration: BoxDecoration(
                            color: creamColor,
                            border:
                                const Border(bottom: BorderSide(width: 1.0))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Text(getLocale('Fund Name'),
                            textAlign: TextAlign.left)),
                    Container(
                        decoration: BoxDecoration(
                            color: creamColor,
                            border:
                                const Border(bottom: BorderSide(width: 1.0))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10),
                        child: Text(getLocale('Investment Allocation'),
                            textAlign: TextAlign.left))
                  ]),
                  for (int i = 0;
                      i < _quickQuotationData!.fundOutputDataList!.length;
                      i++)
                    TableRow(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Text(
                              _quickQuotationData!
                                  .fundOutputDataList![i].fundName!,
                              style: t2FontWN())),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10.0),
                          child: Text(
                              "${_quickQuotationData!.fundOutputDataList![i].fundAlloc}%",
                              style: t2FontWN()))
                    ])
                ]),
            Visibility(
                visible: _quickQuotationData!.fundOutputDataList!.isEmpty,
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(getLocale("- No Fund Selected -")))))
          ]));
    }

    Widget bottomNavButton() {
      return Container(
          decoration: BoxDecoration(
              color: honeyColor, border: Border.all(color: honeyColor)),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          height: 70,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
                flex: 5,
                child: BlocBuilder<QuotationBloc, QuotationBlocState>(
                    builder: (context, state) {
                  if (state is QuotationLoadSuccess) {}
                  return Row(children: [
                    Expanded(
                        flex: 4,
                        child: TextButton(
                            onPressed:
                                _quickQuotationData!.quotationHistoryID != null
                                    ? () {
                                        Navigator.of(context).push(createRoute(
                                            ViewFullDoc(widget.qtn,
                                                _quickQuotationData)));
                                      }
                                    : null,
                            child: Row(children: [
                              Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Image(
                                      width: 20,
                                      height: 20,
                                      color: _quickQuotationData!
                                                  .quotationHistoryID !=
                                              null
                                          ? Colors.black
                                          : Colors.black45,
                                      image: const AssetImage(
                                          'assets/images/view_doc.png'))),
                              Expanded(
                                  child: Text(getLocale("View full SI/MI"),
                                      overflow: TextOverflow.ellipsis,
                                      style: bFontW5().copyWith(
                                          fontSize: 13,
                                          color: _quickQuotationData!
                                                      .quotationHistoryID !=
                                                  null
                                              ? Colors.black
                                              : Colors.black45)))
                            ]))),
                    BlocListener<QuotationBloc, QuotationBlocState>(
                        listener: (context, state) {},
                        child: Expanded(
                            flex: 4,
                            child: TextButton(
                                onPressed: _quickQuotationData!.status == "2"
                                    ? null
                                    : () async {
                                        if (widget.qtn.listOfQuotation!.length >
                                            4) {
                                          showAlertDialog(context, "Oops!",
                                              'You have created 5 quotations for this customer. If you wish to create another quotation, please delete one of the version or click "Create New Quote" in the home page.');
                                        }
                                        if (widget.qtn.listOfQuotation!.length <
                                            4) {
                                          ProductPlan productPlan;
                                          // List<ProductPlan>
                                          //     basicPlanRidersList = [];

                                          ProductPlanState data =
                                              BlocProvider.of<ProductPlanBloc>(
                                                      context)
                                                  .state;

                                          if (data is ProductPlanLoaded) {
                                            List<ProductPlan> plan = data
                                                .props[0] as List<ProductPlan>;
                                            productPlan = plan.firstWhere(
                                                (element) =>
                                                    element.productSetup!
                                                        .prodCode ==
                                                    _quickQuotationData!
                                                        .productPlanCode);

                                            var productPlanRiderCode = [];

                                            for (var element
                                                in productPlan.riderList!) {
                                              productPlanRiderCode
                                                  .add(element.riderCode);
                                            }

                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 100), () {
                                              BlocProvider.of<
                                                          ChooseProductBloc>(
                                                      context)
                                                  .add(DuplicateQuotation(
                                                      quotation: widget.qtn,
                                                      quickQuotationData:
                                                          _quickQuotationData));
                                            });

                                            await Navigator.of(context).push(
                                                createRoute(ChooseProducts(
                                                    widget.qtn.id, widget.qtn,
                                                    quickQtnId: '',
                                                    status: Status.duplicate)));
                                          }
                                        }
                                      },
                                child: Row(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Image(
                                          width: 20,
                                          height: 20,
                                          color:
                                              _quickQuotationData!.status == "2"
                                                  ? Colors.black45
                                                  : Colors.black,
                                          image: const AssetImage(
                                              'assets/images/duplicate_icon.png'))),
                                  Expanded(
                                      child: Text(
                                          getLocale("Duplicate Another Quote"),
                                          overflow: TextOverflow.ellipsis,
                                          style: bFontW5().copyWith(
                                              fontSize: 13,
                                              color:
                                                  _quickQuotationData!.status ==
                                                          "2"
                                                      ? Colors.black45
                                                      : Colors.black)))
                                ])))),
                    Expanded(
                        flex: 4,
                        child: TextButton(
                            onPressed: () {
                              _showModalSheet();
                            },
                            child: Row(children: [
                              const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Image(
                                      width: 20,
                                      height: 20,
                                      color: Colors.black,
                                      image: AssetImage(
                                          'assets/images/version_icon.png'))),
                              Expanded(
                                  child: Text(
                                      getLocale("View Quotation Version"),
                                      overflow: TextOverflow.ellipsis,
                                      style: bFontW5().copyWith(fontSize: 13)))
                            ]))),
                    Expanded(
                        flex: 3,
                        child: TextButton(
                            onPressed: () {
                              //If don't use this, some data still get passed through and messed up with quotation id in choose product section
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Home()),
                                  (route) => false);
                            },
                            child: Row(children: [
                              const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Image(
                                      width: 20,
                                      height: 20,
                                      image: AssetImage(
                                          'assets/images/home.png'))),
                              Expanded(
                                  child: Text(getLocale("Back to Home"),
                                      overflow: TextOverflow.ellipsis,
                                      style: bFontW5().copyWith(fontSize: 13)))
                            ])))
                  ]);
                })),
            Expanded(
                flex: 1,
                child: BlocBuilder<QuotationBloc, QuotationBlocState>(
                    builder: (context, state) {
                  if (state is QuotationLoadSuccess) {
                    // var allQtn = state.quotations;
                  }
                  return isChecking
                      ? Container(
                          decoration: BoxDecoration(
                              color: cyanColor,
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.all(10),
                          height: 50,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Text(getLocale("Validating"),
                                        style: bFontW5()
                                            .copyWith(color: Colors.white))),
                                const SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white)))
                              ]))
                      : Container(
                          decoration: BoxDecoration(
                              color: _quickQuotationData!.status == "2"
                                  ? Colors.black26
                                  : cyanColor,
                              borderRadius: BorderRadius.circular(6)),
                          height: 50,
                          child: TextButton(
                              onPressed: _quickQuotationData!.status == "2"
                                  ? null
                                  : () async {
                                      if (_quickQuotationData!.status != "2") {
                                        checkBeforeProceed();
                                      }
                                    },
                              child: Center(
                                  child: Text(
                                      getLocale("Proceed to Application"),
                                      style: bFontW5().copyWith(
                                          fontSize: 14,
                                          color:
                                              _quickQuotationData!.status == "2"
                                                  ? Colors.black38
                                                  : Colors.white)))));
                }))
          ]));
    }

    Widget personDetails(Person person, String type) {
      Occupation occupation = person.occupation!;
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                  child: Text(
                      type == "lifeInsured"
                          ? selectedBuyingFor == BuyingFor.self.toStr
                              ? "${getLocale("Special Translation 1 for Details")} ${getLocale("Life Insured", entity: true)} ${getLocale("Special Translation 2 for Details")}"
                              : selectedBuyingFor == "Spouse"
                                  ? "${getLocale("Spouse")}/${getLocale("Life Insured", entity: true)} ${getLocale("Details")}"
                                  : "${getLocale("Children")}/${getLocale("Life Insured", entity: true)} ${getLocale("Details")}"
                          : selectedBuyingFor == "Spouse"
                              ? "${getLocale("Spouse")}Spouse/${getLocale("Policy Owner", entity: true)} ${getLocale("Details")}"
                              : "${getLocale("Parent")}/${getLocale("Policy Owner", entity: true)} ${getLocale("Details")}",
                      style: bFontWN().copyWith(color: tealGreenColor)))
            ]),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(children: [
                  CircleAvatar(
                      backgroundColor: lightCyanColor,
                      child: Text(person.name![0],
                          style: t2FontW5().apply(color: cyanColor))),
                  const SizedBox(width: 12),
                  Text(person.name!, style: t2FontW5())
                ])),
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                selectedBuyingFor == BuyingFor.self.toStr
                    ? type == "lifeInsured"
                        ? col1(getLocale("Buying For"))
                        : Container()
                    : type == "policyOwner"
                        ? col1(getLocale("Buying For"))
                        : Container(),
                col1(getLocale("Gender")),
                col1(getLocale("Date of Birth")),
                col1(getLocale("Occupation")),
                col1(getLocale("Occupation Class")),
                type == "lifeInsured" ? col1(getLocale("Smoking")) : Container()
              ]),
              SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                selectedBuyingFor == BuyingFor.self.toStr
                    ? type == "lifeInsured"
                        ? col2(getLocale(BuyingFor.self.toStr))
                        : Container()
                    : type == "policyOwner"
                        ? col2(getLocale(selectedBuyingFor!))
                        : Container(),
                // col2("N/A"),
                col2(getLocale(person.gender!)),
                col2(dateToVpmsInverse(person.dob.toString())),
                col2(occupation.occupationName!),
                col2(occupation.occupationClass!),
                type == "lifeInsured"
                    ? col2(
                        person.isSmoker! ? getLocale("Yes") : getLocale("No"))
                    : Container()
              ])
            ])
          ]));
    }

    Widget buyingForChildren() {
      return Column(children: [
        personDetails(widget.qtn.policyOwner!, "policyOwner"),
        const Divider(thickness: 3),
        personDetails(widget.qtn.lifeInsured!, "lifeInsured")
      ]);
    }

    Widget summaryTable() {
      return Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
              color: lightCyanColor,
              child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(8),
                    1: FlexColumnWidth(2)
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text(getLocale("Total"),
                              textAlign: TextAlign.left, style: t2FontWN())),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 10),
                          child: Text("${_quickQuotationData!.totalFundAlloc}%",
                              textAlign: TextAlign.left, style: t2FontWB()))
                    ])
                  ])));
    }

    Column viewQuotation(String agentName) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
            child: IconButton(
                onPressed: () {
                  if (widget.status == Status.view) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Home(),
                            settings: const RouteSettings(name: 'Home')));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: Icon(Icons.adaptive.arrow_back, size: 20))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getLocale("Quotation Details"), style: tFontWN()),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(
                    flex: 2,
                    child: Row(children: [
                      Text(getLocale("Agent Name")),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Text(agentName,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)))
                    ])),
                Expanded(
                    flex: 2,
                    child: Row(children: [
                      Text(getLocale("Quotation Date")),
                      const SizedBox(width: 20),
                      Text(dateTimetoWithoutTime(dateTime!),
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600))
                    ])),
                Expanded(
                    flex: 2,
                    child: Row(children: [
                      Text(getLocale("Quotation Status")),
                      const SizedBox(width: 20),
                      FutureBuilder<QuotationStatus>(
                          future: isQuotationActive(
                            context,
                            widget.quickQuotation!.productPlanCode,
                            widget.quickQuotation!.vpmsVersion,
                            widget.qtn.lifeInsured!.dob!,
                            widget.qtn.lifeInsured!.age!,
                            widget.quickQuotation!.status,
                            widget.quickQuotation!.totalPremium ?? '',
                          ),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuotationStatus> snapshot) {
                            return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: snapshot.hasData
                                    ? Text(
                                        snapshot.data == QuotationStatus.active
                                            ? getLocale("Active")
                                            : getLocale("Expired"),
                                        textAlign: TextAlign.center,
                                        style: bFontW5().copyWith(
                                            fontSize: 14,
                                            fontWeight: snapshot.data ==
                                                    QuotationStatus.active
                                                ? FontWeight.w500
                                                : FontWeight.normal))
                                    : Text(getLocale("Checking"),
                                        textAlign: TextAlign.center,
                                        style:
                                            bFontWN().copyWith(fontSize: 13)));
                          })
                    ])),
                Visibility(
                    visible: _quickQuotationData!.version != "1",
                    child: Expanded(
                        child: Row(children: [
                      Text(getLocale("Version")),
                      const SizedBox(width: 20),
                      Expanded(
                          child: Text(_quickQuotationData!.version!,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)))
                    ])))
              ])
            ]))
      ]);
    }

    Padding quotationDetails() {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Image(
                  width: 70,
                  height: 70,
                  image: AssetImage('assets/images/submitted_icon.png')),
              const SizedBox(height: 10),
              widget.status == Status.duplicate
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(getLocale("New Quotation Generated"),
                          style: tFontWN()),
                      const SizedBox(width: 10),
                      Container(
                          decoration: BoxDecoration(
                              color: lightCyanColorFive,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5))),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 5),
                              child: Text(
                                  "${getLocale("Version")} ${_quickQuotationData!.version}",
                                  style: const TextStyle(color: Colors.white))))
                    ])
                  : widget.status == Status.editAge
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text("Quotation Updated", style: tFontWN()),
                              const SizedBox(width: 10),
                              Container(
                                  decoration: BoxDecoration(
                                      color: lightCyanColorFive,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5))),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 5),
                                      child: Text(
                                          "${getLocale("Version")} ${_quickQuotationData!.version}",
                                          style: const TextStyle(
                                              color: Colors.white))))
                            ])
                      : Text(
                          widget.status == Status.edit
                              ? getLocale("Quotation Updated")
                              : getLocale("New Quotation Generated"),
                          style: tFontWN()),
              const SizedBox(height: 20),
              Text(
                  "${getLocale("Quotation has been generated and saved in your records at")} ${DateFormat('hh:mm, dd MMM yyyy').format(DateTime.now())}",
                  style: bFontWN().copyWith(color: greyTextColor))
            ]),
            const SizedBox(height: 60)
          ]));
    }

    return Scaffold(
        body: RepaintBoundary(
            key: _quotationImage,
            child: Stack(children: [
              Column(children: [
                progressBar(context, 6, 1),
                BlocListener<ChooseProductBloc, ChooseProductState>(
                    listener: (context, state) async {},
                    child: BlocBuilder<ChooseProductBloc, ChooseProductState>(
                        builder: (context, state) {
                      if (state is QuotationCalculated) {
                        riderList = [];
                        quickQuoteData = state.quickQuotation;
                        _quickQuotationData = state.quickQuotation;

                        selectedBuyingFor = widget.qtn.buyingFor;
                      }

                      if (state is ViewQuotation) {
                        _quickQuotationData = state.quickQuotation;
                        dateTime = state.quickQuotation!.dateTime;
                      }

                      var calcAdhocPrem = double.parse(
                              _quickQuotationData!.totalPremium!) -
                          double.parse(_quickQuotationData!.adhocAmt ?? "0.00");

                      return Expanded(
                          child: ListView(children: [
                        widget.status == Status.view
                            //   "3" // 3 is when user click view in the front page
                            ? BlocBuilder<UserProfileBloc,
                                    UserProfileBlocState>(
                                builder: (context, state) {
                                String? agentName = "";
                                if (state is UserProfileLoaded) {
                                  agentName = state.agent!.fullName;
                                }
                                return viewQuotation(agentName!);
                              })
                            : quotationDetails(),
                        selectedBuyingFor == BuyingFor.self.toStr
                            ? personDetails(
                                widget.qtn.lifeInsured!, "lifeInsured")
                            : buyingForChildren(),
                        const Divider(thickness: 3),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60.0, vertical: 30),
                          child: Column(
                            children: [
                              Row(children: [
                                Expanded(
                                    child: Text(getLocale("Product Details"),
                                        style: bFontWN().apply(
                                            fontSizeFactor: 1.2,
                                            color: tealGreenColor))),
                                OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        side: BorderSide(
                                            color:
                                                _quickQuotationData!.status ==
                                                        "2"
                                                    ? Colors.grey
                                                    : cyanColor)),
                                    onPressed: _quickQuotationData!.status ==
                                            "2"
                                        ? null
                                        : () {
                                            if (_quickQuotationData!.status !=
                                                "2") {
                                              ProductPlanState data =
                                                  BlocProvider.of<
                                                              ProductPlanBloc>(
                                                          context)
                                                      .state;

                                              if (data is ProductPlanLoaded) {
                                                Navigator.of(context).pushReplacement(
                                                    createRoute(ChooseProducts(
                                                        widget.qtn.id,
                                                        widget.qtn,
                                                        quickQtnId:
                                                            _quickQuotationData!
                                                                .quickQuoteId,
                                                        //status: "2" //2 FOR EDIT,),
                                                        status: Status.edit)));

                                                //EDIT QUOTE
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 100), () {
                                                  BlocProvider.of<
                                                              ChooseProductBloc>(
                                                          context)
                                                      .add(EditQuotation(
                                                          quotation: widget.qtn,
                                                          quickQuotation:
                                                              _quickQuotationData!));
                                                });
                                              }
                                            }
                                          },
                                    child: Row(children: [
                                      Text(getLocale("Edit"),
                                          style: bFontWN()
                                              .copyWith(color: cyanColor)
                                              .apply(
                                                  color: _quickQuotationData!
                                                              .status ==
                                                          "2"
                                                      ? Colors.grey
                                                      : cyanColor)),
                                      Icon(Icons.adaptive.arrow_forward,
                                          color:
                                              _quickQuotationData!.status == "2"
                                                  ? Colors.grey
                                                  : cyanColor)
                                    ]))
                              ]),

                              if (_quickQuotationData != null)
                                ProductSummary(
                                    widget.qtn,
                                    _quickQuotationData!,
                                    _quickQuotationData!.totalPremium!,
                                    calcAdhocPrem.toString(),
                                    false)
                              //We set review statement to false, so that we don't show "Premium Last Reviewd on New Quotation Generated" page
                            ],
                          ),
                        ),
                        Visibility(
                            visible: widget.quickQuotation!.productPlanLOB !=
                                "ProductPlanType.traditional",
                            child: Column(children: [
                              const Divider(thickness: 3),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60.0, vertical: 30),
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text(getLocale("Fund"),
                                              style: bFontWN().apply(
                                                  fontSizeFactor: 1.2,
                                                  color: tealGreenColor)))
                                    ]),
                                    const SizedBox(height: 16),
                                    fundTableSummary(),
                                    summaryTable()
                                  ]))
                            ])),
                        Visibility(
                            visible: widget.quickQuotation!.productPlanLOB ==
                                    "ProductPlanType.traditional"
                                ? widget.quickQuotation!.productPlanCode ==
                                        "PCEE01" ||
                                    widget.quickQuotation!.productPlanCode ==
                                        "PCEL01"
                                : true,
                            child: Column(children: [
                              const Divider(thickness: 3),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 40),
                                        Text(
                                            getLocale(
                                                "Illustration of Premium Benefits"),
                                            style: bFontWN().apply(
                                                fontSizeFactor: 1.2,
                                                color: tealGreenColor)),
                                        const SizedBox(height: 10),
                                        SITable(
                                            _quickQuotationData!
                                                .productPlanCode,
                                            _quickQuotationData!.siTableData),
                                        const SizedBox(height: 10),
                                        SITable(
                                            _quickQuotationData!
                                                .productPlanCode,
                                            _quickQuotationData!.siTableGSC,
                                            isGSC: true)
                                      ])),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 60.0),
                                  child: Text(getLocale(
                                      '* Take note that for details SI, please view our downloadable SI'))),
                            ])),
                        const SizedBox(height: 20)
                      ]));
                    }))
              ])
            ])),
        bottomNavigationBar: bottomNavButton());
  }
}
