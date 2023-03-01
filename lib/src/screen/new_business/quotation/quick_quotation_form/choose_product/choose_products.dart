import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ease/main.dart';
import 'package:ease/src/bloc/new_business/product_plan/product_plan_bloc.dart';
import 'package:ease/src/bloc/new_business/quotation_bloc/quotation_bloc.dart';
import 'package:ease/src/data/new_business_model/fund_output_data.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/firebase_analytics/firebase_analytics.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/home.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/questions/question_list.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/bloc/choose_product_bloc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_adhoc.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_basic_plan.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_calculation.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_funds.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_gcp.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_product_plan_type.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_riders.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_rtu.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_stepped_premium.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/widget/choose_sustainability_option.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/new_quotation_generated/new_quotation_generated.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/product_summary.dart';
import 'package:ease/src/service/product_setup_helper.dart';
import 'package:ease/src/util/function.dart';
import 'package:ease/src/util/page_route_animation.dart';
import 'package:ease/src/widgets/colors.dart';
import 'package:ease/src/widgets/custom_button.dart';
import 'package:ease/src/widgets/global_style.dart';
import 'package:ease/src/widgets/main_widget.dart';
import 'package:ease/src/widgets/snackbar.dart';
import 'package:ease/src/widgets/system_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

// To keep track current status of quotation. New, Duplicate etc. EditAge when age increase.
// Got some loophole, if 'Use new insted of Duplicate'. For totally new quoation, don't need to pass anything.
enum Status {
  newQuote,
  duplicate,
  edit,
  view,
  editAge,
  newFromApplication,
  editFromApp,
  editAgeFromApp
}

// Future feature. Keep track for now
enum ChooseProductBy { selfCustomise, productRecommender }

// Two types of plan. investment or traditional. Not yet sure how to distinguish takaful
enum ProductPlanType { investmentLink, traditional }

// Previously we have 3 types of calculation. But now stick to one. Maintain it.
enum CalcBasedOn { sumInsured, premium, sumInsuredPremium }

class ChooseProducts extends StatefulWidget {
  // This is qtn id generated from sembast
  final int? qtnId;
  // For Status.edit, we need quickqtnid to get the right quick quotation
  final String? quickQtnId;
  final Quotation qtn;
  final Status? status;
  final Uint8List? imageString;
  final dynamic data;
  // This is to pass image for dummy show on stack from View Quotation

  // Status
  // 1 - Duplicating quotation
  // 2 - Edit Quotation

  const ChooseProducts(this.qtnId, this.qtn,
      {Key? key, this.status, this.quickQtnId, this.imageString, this.data})
      : super(key: key);
  @override
  ChooseProductsState createState() => ChooseProductsState();
}

class ChooseProductsState extends State<ChooseProducts> {
  int _firstTimeScreenLoaded = 0;
  int _firstRoundCheckAnb = 0;

  bool _isLoading = false;
  bool _isGeneratingDoc = false;
  bool _isPremiumCheckLoading = false;
  final double _textFieldHeight = 70.0;

  String? uniqueId;
  int? currentQtnId = 0;

  QuickQuotation quickQtn = QuickQuotation();
  ProductPlan? selectedProductPlan;
  String? totalPremium;
  String? totalPremiumWithoutAdhoc;
  late int age;
  String? dob;
  String? premiumTermString;
  bool showSteppedPremium = false;

  final TextEditingController _sumInsuredAmountCont = TextEditingController();
  final TextEditingController _premiumAmountCont = TextEditingController();

  final _brpKey = GlobalKey<FormState>();
  final _siKey = GlobalKey<FormState>();
  final _siPremKey = GlobalKey<FormState>();
  final _riderFormKey = GlobalKey<FormState>();
  final _fundFormKey = GlobalKey<FormState>();
  final _rtuAmountKey = GlobalKey<FormState>();
  final _adhocAmountKey = GlobalKey<FormState>();
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  late QuotationBloc _qtnBloc;

  ChooseProductBy? productBy; // Self Customise / Product Recommender
  ProductPlanType? productPlanType;

  bool isGcpValdiate = false;
  bool isCampaign = false;
  bool isRTUSelected = false;
  bool isAdhocSelected = false;
  String selectedCampaignStr = "default";
  Campaign? selectedCampaign;
  TextEditingController campaignRemarks = TextEditingController();

  @override
  void initState() {
    analyticsSetCurrentScreen("Choose Product", "ChooseProduct");
    super.initState();
    setState(() {
      productBy = ChooseProductBy.selfCustomise;
      productPlanType = ProductPlanType.traditional;
      _qtnBloc = BlocProvider.of<QuotationBloc>(context);
    });
    initializeData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void initializeData() {
    if (widget.status == Status.duplicate && _firstTimeScreenLoaded == 0) {
      uniqueId = generateQuickQuotationId();
      _firstTimeScreenLoaded = 1;
    }
    if (widget.status != Status.duplicate &&
        widget.status != Status.edit &&
        widget.status != Status.editAge &&
        widget.status != Status.editAgeFromApp &&
        _firstTimeScreenLoaded == 0) {
      _firstTimeScreenLoaded = 1;
      currentQtnId = widget.qtnId;
      uniqueId = generateQuickQuotationId();

      // DON'T PUT THIS OUTSIDE. IF NOT PAGE WILL FLICKER
      // Change quotation state. If not, might problematic later on.
      BlocProvider.of<QuotationBloc>(context).add(LoadQuotation());
      // Set product plan type to default: investment link
      BlocProvider.of<ChooseProductBloc>(context)
          .add(const SetPlanType(ProductPlanType.traditional));
      // Find plan
      BlocProvider.of<ProductPlanBloc>(context)
          .add(FilterProductPlanList(type: productPlanType));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onRTUSelected(val) {
    isRTUSelected = val;
  }

  void onAdhocSelected(val) {
    isAdhocSelected = val;
  }

  Future<void> deleteQuotation(String? quickQtnId) async {
    var listOfQuotation = widget.qtn.listOfQuotation!;

    try {
      var index = listOfQuotation
          .indexWhere((element) => element!.quickQuoteId == quickQtnId);
      if (index == -1) {
      } else {
        listOfQuotation.removeAt(index);

        widget.qtn.listOfQuotation = listOfQuotation;
        BlocProvider.of<QuotationBloc>(context)
            .add(UpdateQuotation(widget.qtn));

        return;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuotation(QuickQuotation? quickQtn) async {
    int y = 0;

    // Quotation quotation = widget.qtn;
    widget.qtn.id = widget.qtnId;

    // _qtnBloc.add(FindQuotation(widget.qtn.uid));
    var listOfQuotation = widget.qtn.listOfQuotation;

    if (listOfQuotation == null) {
      listOfQuotation = [];
      listOfQuotation.add(quickQtn);
    } else {
      try {
        var index = listOfQuotation.indexWhere(
            (element) => element!.quickQuoteId == quickQtn!.quickQuoteId);
        if (index == -1) {
          listOfQuotation.add(quickQtn);
        } else {
          listOfQuotation[index] = quickQtn;
        }
      } catch (e) {
        listOfQuotation.add(quickQtn);
      }
    }

    widget.qtn.listOfQuotation = listOfQuotation;

    if (y == 0) {
      y = 1;
      BlocProvider.of<QuotationBloc>(context).add(UpdateQuotation(widget.qtn));
    }
    return;
  }

  void refreshQuickQtn({bool clearData = false}) async {
    quickQtn.quickQuoteId =
        (widget.status == Status.edit) ? widget.quickQtnId : uniqueId;
    // Add 2 month if deduct from salary is selected
    DateTime qtnDate;
    if (quickQtn.deductSalary) {
      var jiffy = Jiffy()..add(months: 2);
      qtnDate = jiffy.dateTime;
    } else {
      qtnDate = DateTime.now();
    }
    quickQtn.dateTime = DateFormat('dd MMM yyyy').format(qtnDate).toString();

    if (selectedProductPlan != null &&
        selectedProductPlan!.productSetup != null) {
      if (selectedProductPlan!.productSetup!.premiumBasis != null &&
          selectedProductPlan!.productSetup!.premiumBasis == "7") {
        if (quickQtn.riderOutputDataList != null) {
          var iloption = quickQtn.riderOutputDataList!.indexWhere(
              (element) => element.riderName == "IL Savings Growth");
          if (iloption > -1) {
            selectedProductPlan!.productSetup?.prodCode = selectedProductPlan!
                .productSetup?.prodCode!
                .replaceAll("02", "01")
                .replaceAll("04", "03");
          } else {
            selectedProductPlan!.productSetup?.prodCode = selectedProductPlan!
                .productSetup?.prodCode!
                .replaceAll("01", "02")
                .replaceAll("03", "04");
          }
        }
      }
      quickQtn.productPlanCode = selectedProductPlan!.productSetup!.prodCode;
    }

    if (selectedProductPlan != null &&
        selectedProductPlan!.productSetup != null) {
      if (selectedProductPlan!.productSetup!.premiumBasis != null &&
          selectedProductPlan!.productSetup!.premiumBasis == "7") {
        if (quickQtn.riderOutputDataList != null) {
          var tsfoption = quickQtn.riderOutputDataList!.indexWhere(
              (element) => element.riderName == "Takafulink Savings Flexi");
          if (tsfoption > -1) {
            selectedProductPlan!.productSetup?.prodCode = selectedProductPlan!
                .productSetup?.prodCode!
                .replaceAll("02", "01");
          } else {
            selectedProductPlan!.productSetup?.prodCode = selectedProductPlan!
                .productSetup?.prodCode!
                .replaceAll("01", "02");
          }
        }
      }
      quickQtn.productPlanCode = selectedProductPlan!.productSetup!.prodCode;
    }

    List<dynamic> campaigns =
        await ProductPlanRepositoryImpl().getCampaignList();
    var sCampaign = campaigns
        .where((element) => element.id.toString() == selectedCampaignStr)
        .toList();
    if (sCampaign.isNotEmpty) {
      selectedCampaign = sCampaign[0] as Campaign?;
      selectedCampaign!.campaignRemarks = campaignRemarks.text;
    } else {
      selectedCampaign = Campaign(prodCode: "default");
    }
    quickQtn.campaign = selectedCampaign;
    quickQtn.campaign!.campaignRemarks = selectedCampaign!.campaignRemarks;

    if (clearData) {
      if (selectedProductPlan != null &&
          selectedProductPlan!.productSetup != null &&
          selectedProductPlan!.productSetup!.prodCode != "PCJI02" &&
          selectedProductPlan!.productSetup!.prodCode != "PCWA01" &&
          selectedProductPlan!.productSetup!.prodCode != "PTJI01" &&
          selectedProductPlan!.productSetup!.prodCode != "PTHI02") {
        quickQtn.premiumTerm = null;
      }
      if (selectedProductPlan != null &&
          selectedProductPlan!.productSetup != null &&
          selectedProductPlan!.productSetup!.prodCode != "PCTA01" &&
          selectedProductPlan!.productSetup!.prodCode != "PCEL01") {
        quickQtn.policyTerm = null;
      }
      if (selectedProductPlan != null &&
          selectedProductPlan!.productSetup != null &&
          selectedProductPlan!.productSetup!.prodCode != "PCHI03" &&
          selectedProductPlan!.productSetup!.prodCode != "PCHI04" &&
          selectedProductPlan!.productSetup!.prodCode != "PTHI01" &&
          selectedProductPlan!.productSetup!.prodCode != "PTHI02") {
        quickQtn.planDetail = null;
      }
      quickQtn.basicPlanPaymentTerm = null;
      quickQtn.basicPlanPolicyTerm = null;
      quickQtn.basicPlanPremiumAmount = null;
      quickQtn.basicPlanSumInsured = null;

      quickQtn.enricherPaymentTerm = null;
      quickQtn.enricherPolicyTerm = null;
      quickQtn.enricherPremiumAmount = null;
      quickQtn.enricherSumInsured = null;

      quickQtn.rtuPaymentTerm = null;
      quickQtn.rtuPolicyTerm = null;
      quickQtn.rtuPremiumAmount = null;
      quickQtn.adhocPremiumAmount = null;
      quickQtn.rtuSAIOS = null;
      quickQtn.rtuSumInsured = null;

      quickQtn.gcpPremAmt = null;
      quickQtn.gcpPremTerm = null;
      quickQtn.gcpTerm = null;

      quickQtn.anb = null;
      quickQtn.maturityAge = null;
      quickQtn.basicContribution = null;
      quickQtn.totalPremium = null;
      quickQtn.basicPlanTotalPremiumIOS = null;
      quickQtn.minsa = null;
      quickQtn.sam = null;
      quickQtn.totalFundAlloc = null;
      quickQtn.occLoad = null;
      quickQtn.totalPremOccLoad = null;

      quickQtn.siTableData = null;
      quickQtn.siTableGSC = null;
      quickQtn.surrenderChargeTableData = null;
      quickQtn.fundFeeTableData = null;
      quickQtn.sustainabilityPeriodTableData = null;
      quickQtn.historicalFundTableData = null;
      quickQtn.vpmsinput = null;
      quickQtn.vpmsoutput = null;
      quickQtn.sustainabilityPeriodTableData = null;
    }
    await updateQuotation(quickQtn);
  }

  Future<List<Campaign>> getCampaignList() async {
    List<Campaign> data = [];
    List<dynamic> campaigns =
        await ProductPlanRepositoryImpl().getCampaignList();
    if (campaigns.isNotEmpty) {
      for (var campaign in campaigns) {
        if (campaign.isActive != null && campaign.isActive!) {
          DateTime start = DateTime.parse(campaign.startDate!);
          DateTime end = DateTime.parse(campaign.endDate!);
          if (DateTime.now().isAfter(start) && DateTime.now().isBefore(end)) {
            data.add(campaign);
          }
        }
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    Row row(title, details) {
      return Row(children: [
        Expanded(child: Text(title, style: t2FontWN())),
        Expanded(child: Text(details, style: t2FontW5()))
      ]);
    }

    Widget customerDetailsData() {
      Person lifeInsured = widget.qtn.lifeInsured!;
      Person? policyOwner = widget.qtn.policyOwner;
      Occupation occ = lifeInsured.occupation!;
      Occupation? poOcc = Occupation();
      if (widget.qtn.buyingFor != BuyingFor.self.toStr) {
        poOcc = policyOwner!.occupation;
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getLocale("Create another version")),
        const SizedBox(height: 5),
        Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: silverGreyColor),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(getLocale("Customer details"), style: t1FontW5()),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Text(getLocale("Buying for"), style: t2FontWN())),
                Expanded(
                    flex: 3,
                    child: Text(
                        /* widget.qtn!.buyingFor![0].toUpperCase() +
                            widget.qtn!.buyingFor!.substring(1) */
                        getLocale(widget.qtn.buyingFor!),
                        style: t2FontW5()))
              ]),
              const SizedBox(height: 20),
              if (widget.qtn.buyingFor != BuyingFor.self.toStr)
                Row(children: [
                  if (widget.qtn.buyingFor != BuyingFor.self.toStr)
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                              "${getLocale("Policy Owner", entity: true)}${getLocale("'s Details")}",
                              style: t2FontW5().copyWith(color: cyanColor)),
                          row(getLocale("Name"), policyOwner!.name!),
                          row(getLocale("Gender"),
                              getLocale(policyOwner.gender!)),
                          row(
                              getLocale("Date of Birth"),
                              DateFormat("d MMMM y")
                                  .format(DateFormat('dd.MM.yyyy')
                                      .parse(policyOwner.dob!))
                                  .toString()),
                          row(getLocale("Occupation"), poOcc!.occupationName!)
                        ])),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            widget.qtn.buyingFor == BuyingFor.self.toStr
                                ? getLocale(
                                    "Policy Owner/Life Insured's Details",
                                    entity: true)
                                : getLocale("Life Insured's Details",
                                    entity: true),
                            style: t2FontW5().copyWith(color: cyanColor)),
                        row(getLocale("Name"), lifeInsured.name!),
                        row(getLocale("Gender"),
                            getLocale(lifeInsured.gender!)),
                        row(
                            getLocale("Date of Birth"),
                            DateFormat("d MMMM y")
                                .format(DateFormat('dd.MM.yyyy')
                                    .parse(lifeInsured.dob!))
                                .toString()),
                        row(getLocale("Occupation"), occ.occupationName!)
                      ]))
                ])
              else
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      "${getLocale("Policy Owner", entity: true)}/${getLocale("Life Insured", entity: true)}${getLocale("'s Details")}",
                      style: t2FontW5().copyWith(color: cyanColor)),
                  row(getLocale("Name"), lifeInsured.name!),
                  row(getLocale("Gender"), getLocale(lifeInsured.gender!)),
                  row(
                      "Date of Birth",
                      DateFormat("d MMMM y")
                          .format(
                              DateFormat('dd.MM.yyyy').parse(lifeInsured.dob!))
                          .toString()),
                  row(getLocale("Occupation"), occ.occupationName!)
                ])
            ]))
      ]);
    }

    Widget header() {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getLocale("Create New Quote"), style: bFontWN()),
                      Row(children: [
                        Text(getLocale("Choose Product"),
                            style: tFontW5().copyWith(fontSize: 35))
                      ]),
                      Text(
                          getLocale(
                              "Next, let's determine a suitable product to recommend your \ncustomer by filling in the details below."),
                          style: sFontW5())
                    ]))
          ]));
    }

    Widget chooseCampaign() {
      return FutureBuilder<dynamic>(
          future: getCampaignList(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              List<Campaign> campaigns = snapshot.data;

              List<DropdownMenuItem<String>> campaignList = [];
              if (campaigns.isNotEmpty) {
                campaignList.add((DropdownMenuItem(
                    value: "default",
                    child: Text(getLocale('Default Campaign')))));
                for (var element in campaigns) {
                  // campaignList.add((DropdownMenuItem(
                  //     value: element.id.toString(),
                  //     child: Text(element.campaignName ?? ""))));

                  var campaignProdCode = element.prodCode;
                  if (campaignProdCode ==
                      selectedProductPlan?.productSetup?.prodCode) {
                    campaignList.add((DropdownMenuItem(
                        value: element.id.toString(),
                        child: Text(element.campaignName ?? ""))));
                  }
                }
              }

              selectedCampaignStr = campaignList.indexWhere(
                          (element) => element.value == selectedCampaignStr) !=
                      -1
                  ? selectedCampaignStr
                  : "default";

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    Text(getLocale("Please select a campaign"),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: Container(
                              height: commonTextFieldHeight - 2.5,
                              width: MediaQuery.of(context).size.width,
                              decoration: textFieldBoxDecoration(),
                              child: DropdownButtonHideUnderline(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: DropdownButton(
                                          value: selectedCampaignStr,
                                          style: t2FontW5(),
                                          icon: Transform.scale(
                                              scale: 0.8,
                                              child: const Icon(
                                                  Icons.keyboard_arrow_down)),
                                          items: campaignList,
                                          onChanged: (dynamic value) async {
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              selectedCampaignStr = value;
                                              if (selectedCampaignStr !=
                                                  "default") {
                                                selectedCampaign = campaigns
                                                    .firstWhere((elements) =>
                                                        elements.id ==
                                                        int.parse(
                                                            selectedCampaignStr));
                                              }
                                            });

                                            isCampaign = selectedCampaignStr !=
                                                "default";

                                            String? prodcode;
                                            if (selectedProductPlan != null) {
                                              prodcode = selectedProductPlan!
                                                  .productSetup!.prodCode;
                                            }

                                            BlocProvider.of<ChooseProductBloc>(
                                                    context)
                                                .add(SetCampaign(isCampaign,
                                                    selectedCampaign,
                                                    prodCode: prodcode));

                                            refreshQuickQtn();

                                            FocusScope.of(context).unfocus();
                                          }))))),
                      Expanded(child: Container())
                    ]),
                    selectedCampaign?.campaignName == "BRP Code"
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const SizedBox(height: 20),
                                RichText(
                                    text: TextSpan(
                                        text: selectedCampaign!.campaignName!,
                                        style: bFontW5().copyWith(fontSize: 18),
                                        children: <TextSpan>[
                                      TextSpan(
                                          text: "*",
                                          style: bFontWN()
                                              .copyWith(color: scarletRedColor))
                                    ])),
                                const SizedBox(height: 14),
                                Form(
                                    key: _brpKey,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 730),
                                        child: TextFormField(
                                            autovalidateMode:
                                                AutovalidateMode.always,
                                            cursorColor: Colors.grey,
                                            style: bFontW5(),
                                            decoration:
                                                textFieldInputDecoration()
                                                    .copyWith(
                                                        prefixStyle: bFontW5(),
                                                        errorMaxLines: 2,
                                                        counterText: ""),
                                            maxLength: 20,
                                            controller: campaignRemarks,
                                            onChanged: (data) {
                                              String? prodcode;
                                              if (selectedProductPlan != null) {
                                                prodcode = selectedProductPlan!
                                                    .productSetup!.prodCode;
                                              }
                                              selectedCampaign!
                                                      .campaignRemarks =
                                                  campaignRemarks.toString();
                                              BlocProvider.of<
                                                          ChooseProductBloc>(
                                                      context)
                                                  .add(SetCampaign(isCampaign,
                                                      selectedCampaign,
                                                      prodCode: prodcode));

                                              refreshQuickQtn();
                                            },
                                            onEditingComplete: () {
                                              FocusScope.of(context).unfocus();
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return "${getLocale("BRP Code")} ${getLocale("cannot be empty")}";
                                              }
                                              return null;
                                            })))
                              ])
                        : Container()
                  ]);
            } else {
              return Container();
            }
          });
    }

    Widget chooseProductBy() {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 30),
        Text(getLocale("How would you like to proceed?"), style: t2FontW5()),
        const SizedBox(height: 10),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Row(children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        setState(() {
                          productBy = ChooseProductBy.selfCustomise;
                        });
                      },
                      child: Container(
                          height: _textFieldHeight,
                          decoration: BoxDecoration(
                              color: productBy == ChooseProductBy.selfCustomise
                                  ? Colors.white
                                  : Colors.grey[400],
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  width: 2,
                                  color:
                                      productBy == ChooseProductBy.selfCustomise
                                          ? cyanColor
                                          : Colors.grey[400]!)),
                          child: Center(
                              child: Text(getLocale("Customise a plan"),
                                  style: bFontW5().copyWith(
                                      color: productBy ==
                                              ChooseProductBy.selfCustomise
                                          ? cyanColor
                                          : Colors.grey[600])))))),
              const SizedBox(width: 20),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   productBy = ChooseProductBy.ProductRecommender;
                        // });
                      },
                      child: Container(
                          height: _textFieldHeight,
                          decoration: BoxDecoration(
                              color: productBy ==
                                      ChooseProductBy.productRecommender
                                  ? Colors.white
                                  : greyDividerColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  width: 1.4, color: greyBorderColor)),
                          child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(getLocale("Product Recommender"),
                                              style: bFontW5().copyWith(
                                                  height: 1,
                                                  color: productBy ==
                                                          ChooseProductBy
                                                              .productRecommender
                                                      ? Colors.black
                                                      : Colors.grey[500])),
                                          Text("(${getLocale("Coming Soon")})",
                                              style: sFontW5().copyWith(
                                                  height: 1,
                                                  color: productBy ==
                                                          ChooseProductBy
                                                              .productRecommender
                                                      ? Colors.black
                                                      : Colors.grey[500]))
                                        ])
                                    // Icon(Icons.info, color: cyanColor)
                                  ])))))
            ]))
      ]);
    }

    void navigateToNextPage(QuickQuotation? qq,
        {bool? failed, String? message}) async {
      if (widget.status == Status.editAgeFromApp && failed != null && failed) {
        Navigator.of(navigatorKey.currentContext!)
            .pop({"isSuccess": !failed, "message": message});
      } else {
        if (mounted) {
          await updateQuotation(qq).then((_) {
            _isGeneratingDoc = false;
            if (widget.status == Status.newFromApplication ||
                widget.status == Status.editFromApp ||
                widget.status == Status.editAgeFromApp) {
              Navigator.of(context).pop(qq);
            } else {
              Navigator.of(context).pushReplacement(createRoute(
                  NewQuotationGenerated(
                      qtnId: widget.qtnId,
                      qtn: widget.qtn,
                      quickQuotation: qq,
                      status: widget.status)));
            }
          });
        }
      }
    }

    void validateAndSave(BuildContext context) async {
      int x = 0;
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(milliseconds: 1000), () async {
        BlocProvider.of<ChooseProductBloc>(context).add(CalculateQuotation(
            totalPremium: totalPremium!, quickQuotation: quickQtn));
      });

      BlocProvider.of<ChooseProductBloc>(context).stream.listen((state) async {
        if (state is QuotationCalculated && x == 0) {
          x = x + 1;
          quickQtn.totalPremium = state.totalPremium;
          _isGeneratingDoc = true;
          quickQtn.isReadyToUpload = true;
          String action =
              quickQtn.isSavedOnServer != null && quickQtn.isSavedOnServer!
                  ? "U"
                  : "A";

          await savetoserver(widget.qtn, quickQtn, action)
              .then((response) async {
            if (response != null && response["IsSuccess"]) {
              quickQtn.isSavedOnServer = response["IsSuccess"];
              quickQtn.quotationHistoryID = response["QuotationHistoryID"];
            } else {
              quickQtn.isSavedOnServer =
                  response != null && response["IsSuccess"] != null
                      ? response["IsSuccess"]
                      : false;
            }
            navigateToNextPage(quickQtn);
          }).catchError((onError) {
            navigateToNextPage(quickQtn);
          });
        }
      });
    }

    void validateAndCheckPremium() {
      String error = "";

      if (selectedProductPlan == null) {
        error += getLocale("Please select basic plan");
      }

      if (quickQtn.isSteppedPremium == null && showSteppedPremium) {
        error += "\n${getLocale("Please select stepped premium")}";
      }

      if (quickQtn.sustainabilityOption == null &&
          !(selectedProductPlan!.productSetup!.prodCode == "PCHI03" ||
              selectedProductPlan!.productSetup!.prodCode == "PCHI04" ||
              selectedProductPlan!.productSetup!.prodCode == "PCTA01" ||
              selectedProductPlan!.productSetup!.prodCode == "PCWA01" ||
              selectedProductPlan!.productSetup!.prodCode == "PCEE01" ||
              selectedProductPlan!.productSetup!.prodCode == "PCEL01" ||
              selectedProductPlan!.productSetup!.prodCode == "PTHI01" ||
              selectedProductPlan!.productSetup!.prodCode == "PTHI02")) {
        error += "\n${getLocale("Please select sustainability option")}";
      }

      if (quickQtn.paymentMode == null) {
        error += "\n${getLocale("Please select a payment frequency")}";
      }

      if (selectedProductPlan!.productSetup!.prodCode == "PCJI02" ||
          selectedProductPlan!.productSetup!.prodCode == "PTJI01") {
        if (quickQtn.premiumTerm == null) {
          error += "\n${getLocale("Please select a Premium Term")}";
        } else {
          if (quickQtn.isSteppedPremium == true &&
              int.parse(quickQtn.premiumTerm!) <= 20) {
            error +=
                "\n${getLocale("Stepped premium is not allowed for limited premium payment term")}.";
          }
        }
      }

      if ((selectedProductPlan!.productSetup!.prodCode == "PCHI03" ||
              selectedProductPlan!.productSetup!.prodCode == "PCHI04" ||
              selectedProductPlan!.productSetup!.prodCode == "PTHI01" ||
              selectedProductPlan!.productSetup!.prodCode == "PTHI02") &&
          (quickQtn.planDetail == null || quickQtn.planDetail == "0")) {
        error +=
            "\n${getLocale("Please select a")} ${getLocale("Policy Term", entity: true)}";
      }

      if (selectedProductPlan!.productSetup!.prodCode == "PCEL01" &&
          (quickQtn.policyTerm == null || quickQtn.policyTerm == "0")) {
        error +=
            "\n${getLocale("Please select a")} ${getLocale("Policy Term", entity: true)}";
      }

      if (_siPremKey.currentState!.validate()) {
      } else {
        if (widget.status != Status.editAge &&
            widget.status != Status.editAgeFromApp) {
          if (_sumInsuredAmountCont.text == "" &&
              _premiumAmountCont.text == "") {
            error +=
                "\n${getLocale("Please input sum insured & premium amount")}";
          } else if (_sumInsuredAmountCont.text == "") {
            error += "\n${getLocale("Please input sum insured amount")}";
          } else if (_premiumAmountCont.text == "") {
            error += "\n${getLocale("Please input sum premium amount")}";
          }
        }
        return;
      }

      if ((selectedProductPlan!.productSetup!.prodCode == "PTHI01" ||
              selectedProductPlan!.productSetup!.prodCode == "PTHI02" ||
              selectedProductPlan!.productSetup!.prodCode == "PCHI03" ||
              selectedProductPlan!.productSetup!.prodCode == "PCEL01" ||
              selectedProductPlan!.productSetup!.prodCode == "PCEE01") &&
          (quickQtn.guaranteedCashPayment == null ||
              quickQtn.guaranteedCashPayment == "")) {
        error += "\n${getLocale("Please select a Guaranteed Cash Payment")}";
      }

      List<int> riderSA = [];
      for (var element in quickQtn.riderOutputDataList!) {
        try {
          if (element.riderSA is String && isNumeric(element.riderSA)) {
            var x = element.riderSA!.split('.');
            riderSA.add(int.parse(x[0]));
          }
        } catch (e) {
          riderSA = [];
          return;
        }
      }

      if (_riderFormKey.currentState != null) {
        if (_riderFormKey.currentState!.validate()) {
          var passSA = 1;
          var passPlan = 1;
          var passTerm = 1;
          for (var element in quickQtn.riderOutputDataList!) {
            //Check sum insured required && exist
            if (element.requiredPlan == true && element.riderPlan == null) {
              passPlan = passPlan * 0;
            } else if (element.requiredPlan == true &&
                element.riderPlan != "") {
              passPlan = passPlan * 1;
            }

            // Hardcode Medical Plus, because it require SA, but the SA is not in integer value
            if (element.requiredSA == true &&
                element.riderSA == null &&
                !element.riderName!.contains("Medical Plus")) {
              passSA = passSA * 0;
            } else if (element.requiredSA == true && element.riderSA != "") {
              passSA = passSA * 1;
            }

            if (element.requiredTerm == true &&
                (element.riderTerm == null ||
                    element.riderTerm == "0" ||
                    element.riderTerm == "")) {
              passTerm = passTerm * 0;
            } else if (element.requiredTerm == true &&
                element.riderTerm != "") {
              passTerm = passTerm * 1;
            }
          }

          if (quickQtn.riderOutputDataList!.isNotEmpty && passSA == 0) {
            error +=
                "\n${getLocale("Please double check rider's sum insured")}";
          }
          if (quickQtn.riderOutputDataList!.isNotEmpty && passPlan == 0) {
            error += "\n${getLocale("Please double check rider's plan")}";
          }
          if (quickQtn.riderOutputDataList!.isNotEmpty && passTerm == 0) {
            error += "\n${getLocale("Please double check rider's term")}";
          }
        } else {
          error +=
              "\n${getLocale("Please double check rider sum insured and term")}";
          return;
        }
      }

      if (isRTUSelected &&
          quickQtn.rtuAmt != '-' &&
          num.parse(quickQtn.rtuAmt!) != 0) {
        if (_rtuAmountKey.currentState != null &&
            !_rtuAmountKey.currentState!.validate()) {
          error += "\n${getLocale("Please check Regular Top-Up amount")}";
        }
      }

      if (isAdhocSelected &&
          quickQtn.adhocAmt != '-' &&
          num.parse(quickQtn.adhocAmt!) != 0) {
        if (_adhocAmountKey.currentState != null &&
            !_adhocAmountKey.currentState!.validate()) {
          error += "Please check Ad Hoc Top-Up amount";
        }
      }

      if (quickQtn.campaign != null) {
        var campaign = quickQtn.campaign;
        if (campaign!.campaignName == "BRP Code") {
          if (!(_brpKey.currentState!.validate())) {
            error += "\n${getLocale("Please input BRP Code")}";
          }
        }
      }

      if (quickQtn.productPlanLOB == "ProductPlanType.investmentLink") {
        if (_fundFormKey.currentState != null &&
            _fundFormKey.currentState!.validate()) {
          List<int> fundOutputAlloc = [];
          for (var element in quickQtn.fundOutputDataList!) {
            try {
              fundOutputAlloc.add(int.parse(element.fundAlloc!));
            } catch (e) {
              fundOutputAlloc = [];
            }
          }

          if (quickQtn.fundOutputDataList!.isEmpty) {
            error += "\n${getLocale("Please select at least one fund")}";
          } else if (fundOutputAlloc.length !=
              quickQtn.fundOutputDataList!.length) {
            error +=
                "\n${getLocale("Please double check your fund investment allocation")}";
          } else if (fundOutputAlloc.isNotEmpty &&
              fundOutputAlloc.length == quickQtn.fundOutputDataList!.length) {
            var sum = fundOutputAlloc.reduce((a, b) => a + b);
            if (sum != 100) {
              error +=
                  "\n${getLocale("Fund allocation must be between 10% to 100% only and no decimal point allowed. Total fund allocation must be equal to 100%")}";
            }
          }
        } else {
          error += "\n${getLocale("Please select at least one fund")}";
          return;
        }

        if (_fundFormKey.currentState!.validate()) {
          if (_siPremKey.currentState!.validate() &&
              _riderFormKey.currentState!.validate()) {
            setState(() {
              _isPremiumCheckLoading = true;
            });
          }
        }
      }

      if (error != "") {
        setState(() {
          isGcpValdiate = true;
          _isPremiumCheckLoading = false;
        });
        showSnackBarError("${getLocale("Error")} \n$error");
        return;
      } else {
        quickQtn.lastUpdatedTime =
            DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()).toString();
        quickQtn.status = "1";

        setQuickQuotationVersion(widget.qtn, quickQtn, widget.status);

        if (widget.status == Status.newFromApplication ||
            widget.status == Status.editFromApp ||
            widget.status == Status.editAgeFromApp) {
          BlocProvider.of<ChooseProductBloc>(context).add(CheckPremium(
              prodSetup: selectedProductPlan!.productSetup!,
              qtn: widget.qtn,
              quickQuotation: quickQtn,
              callTSAR: quickQtn.productPlanCode == "PCHI03" ||
                  quickQtn.productPlanCode == "PCHI04",
              data: widget.data));
        } else {
          BlocProvider.of<ChooseProductBloc>(context).add(CheckPremium(
              prodSetup: selectedProductPlan!.productSetup!,
              qtn: widget.qtn,
              quickQuotation: quickQtn));
        }
      }
    }

    Widget buttonCheckOnPremium() {
      return BlocBuilder<ChooseProductBloc, ChooseProductState>(
          builder: (context, state) {
        bool disabledButton = (state is EditingQuotation &&
            (widget.status == Status.duplicate ||
                widget.status == Status.newQuote ||
                widget.status == Status.edit ||
                widget.status == Status.editFromApp));
        return AnimatedContainer(
            duration: const Duration(seconds: 3),
            child: state is! PremiumChecked && state is! QuotationCalculated
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 55, bottom: 10),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: TextButton(
                                onPressed: disabledButton
                                    ? null
                                    : _isPremiumCheckLoading
                                        ? () {}
                                        : () async {
                                            validateAndCheckPremium();
                                          },
                                // padding: EdgeInsets.all(0),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: honeyColor),
                                child: Container(
                                    height:
                                        disabledButton ? _textFieldHeight : 50,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: disabledButton
                                            ? Colors.black12
                                            : honeyColor),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              _isPremiumCheckLoading
                                                  ? getLocale(
                                                      "Calculating Premium..",
                                                      entity: true)
                                                  : getLocale(
                                                      "Calculate Premium",
                                                      entity: true),
                                              style: bFontW5().copyWith(
                                                  fontSize: 20,
                                                  color: disabledButton
                                                      ? Colors.black38
                                                      : Colors.black)),
                                          AnimatedSwitcher(
                                              duration:
                                                  const Duration(seconds: 1),
                                              child: _isPremiumCheckLoading
                                                  ? const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20),
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors
                                                                      .black)))
                                                  : const Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: Colors.black))
                                        ]))))))
                : Container());
      });
    }

    Widget buttonGenerateQuotation(BuildContext xContext) {
      return Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0),
          child: TextButton(
              onPressed: () async {
                validateAndSave(xContext);
              },
              // padding: EdgeInsets.all(0),
              style: ElevatedButton.styleFrom(backgroundColor: honeyColor),
              child: Container(
                  decoration: textFieldBoxDecoration().copyWith(
                      color: honeyColor, border: Border.all(color: honeyColor)),
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            _isGeneratingDoc
                                ? getLocale("Generating Document")
                                : _isLoading
                                    ? getLocale("Generating Quotation")
                                    : widget.status == Status.newQuote
                                        ? getLocale("Generate Quotation")
                                        : (widget.status ==
                                                    Status.newFromApplication ||
                                                widget.status ==
                                                    Status.editFromApp)
                                            ? getLocale("Recommend")
                                            : getLocale("Generate Quotation"),
                            style: bFontW5().copyWith(fontSize: 20)),
                        _isLoading
                            ? const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black)))
                            : Icon(Icons.adaptive.arrow_forward,
                                color: Colors.black)
                      ]))));
    }

    Widget buildForm(ChooseProductState currentState) {
      return SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Form(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //header(),
                                widget.status == Status.duplicate
                                    ? customerDetailsData()
                                    : header(),
                                chooseProductBy(),
                                ChooseProductPlanType(productPlanType)
                              ])),
                      ChooseBasicPlan(widget.qtn, quickQtn),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: chooseCampaign()),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                showSteppedPremium
                                    ? const ChooseSteppedPremium()
                                    : Container(),
                                const ChooseSustainabilityOption(),
                                ChooseCalculation(
                                    premiumController: _premiumAmountCont,
                                    sumInsuredController: _sumInsuredAmountCont,
                                    siKey: _siKey,
                                    siPremKey: _siPremKey),
                                ChooseGCPAndSalaryDeduct(
                                    isValidate: isGcpValdiate)
                              ]))
                    ])),
            ChooseRiders(riderFormKey: _riderFormKey),
            Visibility(
                visible: productPlanType == ProductPlanType.investmentLink,
                child: Column(children: [
                  const Divider(thickness: 4),
                  ChooseRTU(_rtuAmountKey, onRTUSelected),
                  quickQtn.productPlanCode != "PTWI03"
                      ? Container()
                      : Column(children: [
                          const Divider(thickness: 4),
                          ChooseAdhoc(_adhocAmountKey, onAdhocSelected)
                        ])
                ])),
            ChooseFunds(_fundFormKey),
            const Divider(thickness: 4),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                child: buttonCheckOnPremium()),
            BlocBuilder<ChooseProductBloc, ChooseProductState>(
                builder: (context, state) {
              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  child: (state is PremiumChecked ||
                              state is QuotationCalculated) &&
                          !_isPremiumCheckLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30, bottom: 3),
                                    child: Text(
                                        getLocale("Summary & Confirmation"),
                                        style: bFontWN().copyWith(
                                            fontSize: 24, color: cyanColor))),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30, bottom: 0),
                                    child: Text(
                                        getLocale(
                                            "Kindly review the details below."),
                                        style: sFontW5())),
                                widget.status != Status.editAgeFromApp
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30.0),
                                        child: ProductSummary(
                                            widget.qtn,
                                            quickQtn,
                                            totalPremium ?? "",
                                            totalPremiumWithoutAdhoc ?? "",
                                            true))
                                    : Container(),
                                // summaryAndConfirm(),
                                buttonGenerateQuotation(context)
                              ]))
                      : const SizedBox(height: 0));
            })
          ])
        ]))
      ]));
    }

    void handleEditAge() {
      if ((widget.status == Status.editAge ||
              widget.status == Status.editAgeFromApp) &&
          _firstRoundCheckAnb == 0 &&
          selectedProductPlan != null) {
        _firstRoundCheckAnb = 1;

        Timer(const Duration(seconds: 2), () {
          validateAndCheckPremium();
        });
        BlocProvider.of<ChooseProductBloc>(context)
            .stream
            .listen((state) async {
          if (state is PremiumChecked) {
            validateAndSave(context);
          } else if (state is ChooseProductError) {
            navigateToNextPage(quickQtn, failed: true, message: state.message);
          } else if (state is ChooseProductErrorDialog) {
            if (state.data != null) {
              if (state.data["saLimit"] != null) {
                double salimit = state.data["saLimit"] is double
                    ? state.data["saLimit"]
                    : double.parse(state.data["saLimit"].toString());
                if (salimit > 0) {
                  await confirmDialogFullUW(
                          context,
                          getLocale(
                              "Oops, the proposal exceeded the MaxiPro GIO limit!"),
                          getLocale("requote_editcontinue")
                              .replaceAll("%s", toRM(salimit, rm: true)),
                          true)
                      .then((value) {
                    if (value) {
                      BlocProvider.of<ChooseProductBloc>(context).add(
                          CheckPremiumUW(
                              totalPremium: totalPremium!,
                              quickqtn: state.quickQuotation,
                              caseindicator: "uw"));
                    }
                  });
                } else {
                  var res = await confirmDialogFullUW(
                      context,
                      getLocale(
                          "Oops, the proposal exceeded the MaxiPro GIO limit!"),
                      getLocale("requote_continue").replaceAll("%s", "RM 0.00"),
                      false);
                  if (res) {
                    if (!mounted) {}
                    BlocProvider.of<ChooseProductBloc>(context).add(
                        CheckPremiumUW(
                            totalPremium: state.totalPremium,
                            quickqtn: state.quickQuotation,
                            caseindicator: "uw"));
                  }
                }
              } else {
                var res = await confirmDialogFullUW(
                    context,
                    "Notice",
                    getLocale(state.message) == "err"
                        ? state.message
                        : getLocale(state.message),
                    false);
                if (res) {
                  if (!mounted) {}
                  BlocProvider.of<ChooseProductBloc>(context).add(
                      CheckPremiumUW(
                          totalPremium: totalPremium!,
                          quickqtn: state.quickQuotation,
                          caseindicator: "uw"));
                }
              }
            }
          }
        });
      }
    }

    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        body: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            progressBar(context, 6, 2 / 4),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.status == null ||
                              // widget.status == Status.edit ||
                              widget.status == Status.newQuote ||
                              widget.status == Status.duplicate
                          ? IconButton(
                              onPressed: () {
                                BlocProvider.of<ChooseProductBloc>(context)
                                    .add(SetInitial());
                                if (widget.status == Status.duplicate) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).maybePop({
                                    'qtnid': widget.qtnId,
                                    'qtn': widget.qtn
                                  });
                                }
                              },
                              icon: Icon(Icons.adaptive.arrow_back, size: 30))
                          : widget.status != Status.edit
                              ? IconButton(
                                  onPressed: () async {
                                    // if (widget.status !=
                                    //     Status.newFromApplication) {
                                    // First, remove all quick qtn;
                                    await deleteQuotation(uniqueId);

                                    _qtnBloc.add(FindQuotation(widget.qtn.uid));
                                    // }
                                    if (!mounted) {}
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.adaptive.arrow_back,
                                      color: Colors.black))
                              : Container(),
                      Visibility(
                          visible: widget.status != Status.newFromApplication,
                          child: IconButton(
                              onPressed: () {
                                if (widget.status == Status.editFromApp) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home()),
                                      (route) => false);
                                }
                              },
                              icon: const Icon(Icons.close, size: 40)))
                    ])),
            Expanded(
                child: BlocListener<ChooseProductBloc, ChooseProductState>(
                    listener: (context, state) async {
              if (state is PremiumChecked ||
                  state is ChooseProductError ||
                  state is ChooseProductErrorDialog) {
                _isPremiumCheckLoading = false;
              }

              if (state is ChooseProductFieldRequired) {
                showSnackBarCustom(
                    "${getLocale("This field is required:")} ${state.message}",
                    Colors.grey);
              }

              if (state is ChooseProductError) {
                if (widget.status != Status.editAgeFromApp) {
                  showSnackBarError(state.message, dismiss: true);
                }
              }

              if (state is ChooseProductErrorDialog) {
                if (widget.status != Status.editAgeFromApp) {
                  if (state.data != null) {
                    if (state.data["saLimit"] != null) {
                      double salimit = state.data["saLimit"] is double
                          ? state.data["saLimit"]
                          : double.parse(state.data["saLimit"].toString());
                      if (salimit > 0) {
                        await confirmDialogFullUW(
                                context,
                                getLocale(
                                    "Oops, the proposal exceeded the MaxiPro GIO limit!"),
                                getLocale("requote_editcontinue")
                                    .replaceAll("%s", toRM(salimit, rm: true)),
                                true)
                            .then((value) {
                          if (value) {
                            BlocProvider.of<ChooseProductBloc>(context).add(
                                CheckPremiumUW(
                                    totalPremium: totalPremium!,
                                    quickqtn: state.quickQuotation,
                                    caseindicator: "uw"));
                          }
                        });
                      } else {
                        var res = await confirmDialogFullUW(
                            context,
                            getLocale(
                                "Oops, the proposal exceeded the MaxiPro GIO limit!"),
                            getLocale("requote_continue")
                                .replaceAll("%s", "RM 0.00"),
                            false);
                        if (res) {
                          if (!mounted) {}
                          BlocProvider.of<ChooseProductBloc>(context).add(
                              CheckPremiumUW(
                                  totalPremium: state.totalPremium,
                                  quickqtn: state.quickQuotation,
                                  caseindicator: "uw"));
                        }
                      }
                    } else {
                      var res = await confirmDialogFullUW(
                          context,
                          "Notice",
                          getLocale(state.message) == "err"
                              ? state.message
                              : getLocale(state.message),
                          false);
                      if (res) {
                        if (!mounted) {}
                        BlocProvider.of<ChooseProductBloc>(context).add(
                            CheckPremiumUW(
                                totalPremium: totalPremium!,
                                quickqtn: state.quickQuotation,
                                caseindicator: "uw"));
                      }
                    }
                  }
                }
              }

              if (state is SetProductPlanType) {
                // productPlanType = state.productPlanType;
                productPlanType = state.productPlanType;
                List<String> blockedCountry = state.blockedCountry!;

                String warning = '0';

                if (widget.status == Status.newFromApplication ||
                    widget.status == Status.editFromApp ||
                    widget.status == Status.editAgeFromApp) {
                  var appData = ApplicationFormData.data;
                  var poData = appData['lifeInsured'] ?? {};
                  String nationality = '';
                  if (poData != null &&
                      poData != {} &&
                      poData['nationality'] != null) {
                    nationality = poData['nationality'];
                  }

                  if (blockedCountry.contains(nationality)) {
                    warning = "1";
                  } else {
                    warning = "0";
                  }
                }

                if ((widget.status == Status.newFromApplication ||
                        widget.status == Status.editFromApp) &&
                    warning == "1") {
                  if (!mounted) {}
                  handleBlockCountryInfo(blockedCountry, context,
                      warning: warning);
                  productPlanType = ProductPlanType.traditional;

                  BlocProvider.of<ChooseProductBloc>(context)
                      .add(const SetPlanType(ProductPlanType.traditional));
                  BlocProvider.of<ProductPlanBloc>(context)
                      .add(FilterProductPlanList(type: productPlanType));
                  BlocProvider.of<ChooseProductBloc>(context).add(SetInitial());
                } else if (widget.status == Status.newFromApplication &&
                    warning == "0") {
                  // if it is new from application and the nationality
                  // of the customer is not within the block country
                  // do nothing. do not show dialog.
                } else {
                  Future.delayed(const Duration(milliseconds: 800), () {
                    handleBlockCountryInfo(blockedCountry, context,
                        warning: "0");
                  });
                }
              }
            }, child: BlocBuilder<ChooseProductBloc, ChooseProductState>(
                        builder: (context, state) {
              if (state is SetProductPlanType) {
                productPlanType = state.productPlanType;
              } else if (state is CampaignSelected) {
                quickQtn.isCampaign = state.isCampaign;
                quickQtn.campaign = state.campaign;
                refreshQuickQtn(clearData: true);
              } else if (state is BasicPlanChosen) {
                quickQtn.productPlanLOB = productPlanType.toString();
                selectedProductPlan = state.selectedPlan;
                showSteppedPremium = state.haveEnricher;
                age = state.age;
                dob = state.dob;

                quickQtn.productPlanName =
                    state.selectedPlan.productSetup!.prodName;
                quickQtn.eligibleRiders = state.eligibleRiders;
                quickQtn.vpmsVersion = state.vpmsVersion;

                if (showSteppedPremium) {
                  quickQtn.isSteppedPremium =
                      quickQtn.isSteppedPremium ?? false;
                }

                var prodCode = selectedProductPlan!.productSetup!.prodCode;
                if (prodCode == "PCHI03" ||
                    prodCode == "PCHI04" ||
                    prodCode == "PTHI01" ||
                    prodCode == "PTHI02" ||
                    prodCode == "PCTA01" ||
                    prodCode == "PCWA01" ||
                    prodCode == "PCEL01") {
                  quickQtn.sustainabilityOption = null;
                } else {
                  var terms = getTermList(
                      selectedProductPlan!.maturityTermList!, state.age + 1);
                  var minTerm = getMinPolicyTerm(terms);
                  if (minTerm != null) {
                    quickQtn.sustainabilityOption = minTerm.toString();
                  }
                }

                if (quickQtn.riderOutputDataList != null) {
                  List<RiderOutputData>? newRiderOutputData = [];
                  for (var element in quickQtn.riderOutputDataList!) {
                    dynamic riderData = quickQtn.eligibleRiders!
                        .firstWhereOrNull((eligiblerider) =>
                            eligiblerider.productSetup!.prodCode ==
                            element.riderCode);
                    if (riderData != null) {
                      newRiderOutputData.add(element);
                    }
                  }
                  quickQtn.riderOutputDataList = newRiderOutputData;
                } else {
                  quickQtn.riderOutputDataList = [];
                }

                if (quickQtn.fundOutputDataList != null) {
                  List<FundOutputData>? newFundOutputData = [];
                  for (var element in quickQtn.fundOutputDataList!) {
                    dynamic fundData = selectedProductPlan!.fundList!
                        .firstWhereOrNull(
                            (fund) => fund.fundCode == element.fundCode);
                    if (fundData != null) {
                      newFundOutputData.add(element);
                    }
                  }
                  quickQtn.fundOutputDataList = newFundOutputData;
                } else {
                  quickQtn.fundOutputDataList = [];
                }
                refreshQuickQtn(clearData: true);
              } else if (state is SteppedPremiumChosen) {
                quickQtn.isSteppedPremium = state.isSteppedPremium;
                refreshQuickQtn(clearData: true);
              } else if (state is SustainabilityOptionChosen) {
                quickQtn.sustainabilityOption =
                    state.sustainabilityOptionTerm.toString();
                refreshQuickQtn(clearData: true);
                if (premiumTermString != null) {
                  if (isNumeric(premiumTermString)) {
                    quickQtn.premiumTerm = (int.parse(premiumTermString!) > 5)
                        ? premiumTermString
                        : "5";
                  } else {
                    int sustainabilityOption =
                        int.parse(quickQtn.sustainabilityOption!);
                    if ((dob ?? "").isNotEmpty) {
                      var liAge = getAgeString(dob!, false,
                          additionalMonth: quickQtn.deductSalary ? 2 : 0);
                      quickQtn.premiumTerm =
                          (sustainabilityOption - liAge - 1).toString();
                    } else {
                      quickQtn.premiumTerm =
                          (sustainabilityOption - age - 1).toString();
                    }
                  }
                }
              } else if (state is SumInsuredPremCalculated) {
                if (state.paymentMode != null) {
                  quickQtn.paymentMode = state.paymentMode;
                }
                if (_sumInsuredAmountCont.text != "") {
                  quickQtn.sumInsuredAmt = convertCurrencyStringToGeneralNumber(
                      _sumInsuredAmountCont.text);
                }
                if (_premiumAmountCont.text != "") {
                  quickQtn.premAmt = convertCurrencyStringToGeneralNumber(
                      _premiumAmountCont.text);
                }
                if (state.deductSalary != null) {
                  quickQtn.deductSalary = state.deductSalary!;
                }
                if (state.premiumTerm != null || premiumTermString != null) {
                  var premiumTerm = state.premiumTerm ?? premiumTermString;
                  if (isNumeric(premiumTerm)) {
                    quickQtn.premiumTerm =
                        (int.parse(premiumTerm!) > 5) ? premiumTerm : "5";
                  } else {
                    if (quickQtn.sustainabilityOption != null) {
                      int sustainabilityOption =
                          int.parse(quickQtn.sustainabilityOption!);
                      if ((dob ?? "").isNotEmpty) {
                        var liAge = getAgeString(dob!, false,
                            additionalMonth: quickQtn.deductSalary ? 2 : 0);
                        quickQtn.premiumTerm =
                            (sustainabilityOption - liAge - 1).toString();
                      } else {
                        quickQtn.premiumTerm =
                            (sustainabilityOption - age - 1).toString();
                      }
                    }
                  }
                  premiumTermString = state.premiumTerm ?? premiumTermString;
                }

                if (state.planDetail != null) {
                  quickQtn.planDetail = state.planDetail;
                }
                if (state.policyTerm != null) {
                  quickQtn.policyTerm = state.policyTerm;
                }
                if (state.guaranteedCashPayment != null) {
                  quickQtn.guaranteedCashPayment = state.guaranteedCashPayment;
                }
                refreshQuickQtn(clearData: true);
              } else if (state is RidersChosen) {
                quickQtn.riderOutputDataList = state.riderOutputDataList;
                refreshQuickQtn(clearData: true);
              } else if (state is RidersDeleted) {
                quickQtn.riderOutputDataList = state.riderOutputDataList;
                refreshQuickQtn(clearData: true);
              } else if (state is RTUChosen) {
                quickQtn.rtuAmt = state.regularTopUp.toString();
                refreshQuickQtn(clearData: true);
              } else if (state is AdhocChosen) {
                quickQtn.adhocAmt = state.adhocTopUp.toString();
                refreshQuickQtn(clearData: true);
              } else if (state is FundsChosen) {
                quickQtn.fundOutputDataList = state.outputFundData;
                refreshQuickQtn(clearData: true);
              }
              if (state is PremiumChecked) {
                totalPremium = state.totalPremium;

                if (state.quickQuotation.adhocAmt != null ||
                    state.quickQuotation.adhocAmt != "0") {
                  var calcPremAdhoc = double.parse(state.totalPremium) -
                      double.parse(state.quickQuotation.adhocAmt ?? "0.00");
                  totalPremiumWithoutAdhoc = calcPremAdhoc.toString();
                }

                quickQtn = state.quickQuotation;
                quickQtn.caseindicator = state.caseindicator;

                if (state.caseindicator != null &&
                    state.caseindicator == "uw") {
                  ApplicationFormData.data["tsarqtype"] =
                      questionType["IsFullQuest"].toString();
                  ApplicationFormData.data["qtype"] =
                      questionType["IsFullQuest"].toString();
                }
                refreshQuickQtn();
              } else if (state is EditingQuotation) {
                quickQtn = state.quickQuotation;
                selectedProductPlan = state.selectedPlan;
                age = state.age;
                dob = state.dob;
                showSteppedPremium = state.haveEnricher ?? false;
                if (quickQtn.productPlanLOB != null) {
                  var tempProductPlanType =
                      convertProductPlan(state.quickQuotation.productPlanLOB);
                  BlocProvider.of<ProductPlanBloc>(context)
                      .add(FilterProductPlanList(type: tempProductPlanType));
                  productPlanType = tempProductPlanType;
                }

                isCampaign = state.quickQuotation.isCampaign;
                selectedCampaign = state.quickQuotation.campaign;

                if (selectedCampaign != null && selectedCampaign!.id != null) {
                  selectedCampaignStr = selectedCampaign!.id.toString();
                  if (selectedCampaign!.campaignRemarks != null) {
                    campaignRemarks.text =
                        selectedCampaign!.campaignRemarks.toString();
                  }
                }

                quickQtn.sustainabilityOption =
                    state.quickQuotation.sustainabilityOption;
              }
              // Check if the status is Edit Age, then automate the process
              handleEditAge();

              return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  child: state is BasicPlanChosen ||
                          state is SteppedPremiumChosen ||
                          state is SustainabilityOptionChosen ||
                          state is SumInsuredPremCalculated ||
                          state is RidersChosen ||
                          state is RTUChosen ||
                          state is FundsChosen
                      ? buildForm(state)
                      : state is ChooseProductLoading
                          ? buildLoading()
                          : buildForm(state));
            })))
          ]),
          ...updateEditAge(context, widget.imageString, widget.status)
        ]));
  }
}

Future confirmDialogFullUW(
    BuildContext context, String title, String message, bool allowEdit) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SystemPadding(
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight * 0.38),
                    child: SizedBox(
                        width: screenWidth * 0.45,
                        height: screenHeight * 0.45,
                        child: AlertDialog(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: gFontSize * 2,
                                vertical: gFontSize * 0.5),
                            title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: gFontSize * 0.7,
                                    vertical: gFontSize * 0.5),
                                child: Text(title, style: t1FontWN())),
                            content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(message, style: bFontWN())),
                                  Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.symmetric(
                                          vertical: gFontSize),
                                      child: Row(children: [
                                        if (allowEdit)
                                          Expanded(
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: gFontSize * 0.5),
                                                  child: CustomButton(
                                                      label: getLocale(
                                                          "Edit Quotation"),
                                                      secondary: true,
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(false);
                                                      }))),
                                        Expanded(
                                            child: CustomButton(
                                                label: getLocale("Continue"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                }))
                                      ]))
                                ]))))));
      });
}

////////// THIS IS THE STACK VIEW FOR UPDATING QUOTATION WITHOUT SHOWING CHOOSE PRODUCT PAGE //////////
///
/// The flow : From New Quotation Generated page, when current user age has increased, first we will sreenshot that screen.
/// Then we will update the Life Insured's age, and pass that screenshot to choose product
/// Then we show stack, and put that screenshot as background image (So user will not feel like they are being transferred to other screen)
/// Once VPMS is already generated, we navigate to quotation updated page
///
/// This is the screenshot as background. It will not add menu bar at the bottom somehow. So we adjust it on top

List<Widget> updateEditAge(context, Uint8List? imageString, Status? status) {
  List<Widget> listWid = [];
  if (imageString != null) {
    listWid.add(Positioned(
        top: -35,
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black.withOpacity(0.5),
            child: Container(
                color: Colors.white, child: Image.memory(imageString)))));

    listWid.add(Positioned(
        top: -35,
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            // color: Colors.black.withOpacity(0.1),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.black.withOpacity(0.2))))));

    listWid.add(Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            decoration: BoxDecoration(
                color: honeyColor, border: Border.all(color: honeyColor)),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            height: 70,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 5,
                      child: BlocBuilder<QuotationBloc, QuotationBlocState>(
                          builder: (context, state) {
                        if (state is QuotationLoadSuccess) {
                          // var allQtn = state.quotations;
                        }
                        return Row(children: [
                          Expanded(
                              flex: 3,
                              child: TextButton(
                                  onPressed: () {},
                                  child: Row(children: [
                                    const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Image(
                                            width: 20,
                                            height: 20,
                                            color: Colors.black,
                                            image: AssetImage(
                                                'assets/images/view_doc.png'))),
                                    Expanded(
                                        child: Text(
                                            getLocale("View full SI/MI"),
                                            overflow: TextOverflow.ellipsis,
                                            style: bFontW5().copyWith(
                                                fontSize: 13,
                                                color: Colors.black)))
                                  ]))),
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                  onPressed: () {},
                                  child: Row(children: [
                                    const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Image(
                                            width: 20,
                                            height: 20,
                                            color: Colors.black,
                                            image: AssetImage(
                                                'assets/images/share_logo.png'))),
                                    Expanded(
                                        child: Text(getLocale("Share"),
                                            overflow: TextOverflow.ellipsis,
                                            style: bFontW5().copyWith(
                                                fontSize: 13,
                                                color: Colors.black)))
                                  ]))),
                          Expanded(
                              flex: 4,
                              child: TextButton(
                                  onPressed: () {},
                                  child: Row(children: [
                                    const Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Image(
                                            width: 20,
                                            height: 20,
                                            color: Colors.black,
                                            image: AssetImage(
                                                'assets/images/duplicate_icon.png'))),
                                    Expanded(
                                        child: Text(
                                            getLocale("View Quotation Version"),
                                            overflow: TextOverflow.ellipsis,
                                            style: bFontW5().copyWith(
                                                fontSize: 13,
                                                color: Colors.black)))
                                  ]))),
                          BlocListener<QuotationBloc, QuotationBlocState>(
                              listener: (context, state) {},
                              child: Expanded(
                                  flex: 4,
                                  child: TextButton(
                                      onPressed: () {},
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
                                                getLocale(
                                                    "Duplicate Another Version"),
                                                overflow: TextOverflow.ellipsis,
                                                style: bFontW5().copyWith(
                                                    fontSize: 13,
                                                    color: Colors.black)))
                                      ])))),
                          Expanded(
                              flex: 3,
                              child: TextButton(
                                  onPressed: () {
                                    //If don't use this, some data still get passed through and messed up with quotation id in choose product section
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
                                            style: bFontW5()
                                                .copyWith(fontSize: 13)))
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
                        return TextButton(
                            // padding: EdgeInsets.only(right: 10),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: honeyColor),
                            onPressed: () {},
                            child: Container(
                                decoration: BoxDecoration(
                                    color: cyanColor,
                                    borderRadius: BorderRadius.circular(6)),
                                height: 50,
                                child: Center(
                                    child: Text(
                                        getLocale("Proceed to Application"),
                                        style: bFontW5().copyWith(
                                            fontSize: 14,
                                            color: Colors.white)))));
                      }))
                ]))));
  }
  // This is to give a darker opacity to distinguish between dialog and background
  listWid.add(Visibility(
      visible: status == Status.editAge || status == Status.editAgeFromApp,
      child: Center(
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5)))));

  // The dialog itself
  listWid.add(Visibility(
      visible: status == Status.editAge || status == Status.editAgeFromApp,
      child: Center(
          child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(honeyColor)),
                    const SizedBox(height: 30),
                    Text(getLocale("Updating Quotation..."))
                  ]))))));

  return listWid;
}
