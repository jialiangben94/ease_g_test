import 'dart:collection';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:ease/src/data/new_business_model/fund_output_data.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';
import 'package:ease/src/data/new_business_model/occupation.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_mapping.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/screen/new_business/application/application_enum.dart';
import 'package:ease/src/screen/new_business/application/application_global.dart';
import 'package:ease/src/screen/new_business/application/utils/helpers.dart';
import 'package:ease/src/screen/new_business/application/utils/tsarvalidation.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/service/vpms_helper.dart';
import 'package:ease/src/service/vpms_mapping_helper.dart';
import 'package:ease/src/util/function.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'choose_product_event.dart';
part 'choose_product_state.dart';

class ChooseProductBloc extends Bloc<ChooseProductEvent, ChooseProductState> {
  ChooseProductBloc() : super(ChooseProductInitial()) {
    on<SetCampaign>(_mapSetCampaignToState);
    on<SetPlanType>(_mapSetPlanTypeToState);
    on<SetBasicPlan>(_mapSetBasicPlanToState);
    on<SetSteppedPremium>(_mapSteppedPremToState);
    on<SetSustainabilityOption>(_mapSustainabilityOptionToState);
    on<SetSumInsuredAndPrem>(_mapSumInsuredAndPremToState);
    on<AddRiders>(_mapAddRidersToState);
    on<DeleteRiders>(_mapDeleteRidersDataToState);
    on<SetRidersData>(_mapSetRidersDataToState);
    on<SetRTUAmount>(_mapSetRTUAmountToState);
    on<SetAdhocAmount>(_mapSetAdhocAmountToState);
    on<DeleteFunds>(_mapAddDeleteFundsToState);
    on<SetFunds>(_mapSetFundsToState);
    on<CalculateQuotation>(_mapCalculateQuotationToState);
    on<GenerateSIPDF>(_mapGeneratePDFToState);
    on<DuplicateQuotation>(_mapDuplicateQuotationToState);
    on<ViewGeneratedQuotation>(_mapViewGeneratedQtnToState);
    on<CheckPremium>(_mapCheckPremiumToState);
    on<CheckPremiumUW>(_setStateToPremiumChecked);
    on<EditQuotation>(_mapEditQuotationToState);
    on<SetInitial>(mapSetInitialEventToState);
  }
}

void mapSetInitialEventToState(
    SetInitial event, Emitter<ChooseProductState> emit) async {
  emit(ChooseProductInitial());
}

void _mapSetCampaignToState(
    SetCampaign event, Emitter<ChooseProductState> emit) async {
  emit(CampaignSelected(event.isCampaign, event.campaign));
}

void _mapSetPlanTypeToState(
    SetPlanType event, Emitter<ChooseProductState> emit) async {
  List<ProductPlan> data = await ProductPlanRepositoryImpl()
      .getProductPlanSetup(type: event.productPlanType);
  List<String> blockedCountries = [];
  if (data.isNotEmpty) {
    String blockCountry = '';
    for (var element in data) {
      ProductPlan? plan = element;
      if (plan.productSetup!.blockedCountry != null) {
        blockCountry = plan.productSetup!.blockedCountry!;
      }
    }

    if (blockCountry != "") {
      blockedCountries = blockCountry.split(',');
    }
  }

  emit(SetProductPlanType(
      productPlanType: event.productPlanType,
      blockedCountry: blockedCountries));
}

dynamic getBasicInput(String prodCode, Quotation qtn,
    {bool deductSalary = false, String paymentMode = "0"}) async {
  Person? lifeInsured = qtn.lifeInsured;
  Person? policyOwner = qtn.policyOwner;
  VpmsMapping? vpmsMapping = await getVPMSMappingData(prodCode);
  String? prefLang = lifeInsured!.preferlanguage;
  var basicVPMSKey = vpmsMapping.basicInput!;
  DateTime qtnDate;

  // Add 2 month if deduct from salary is selected
  if (deductSalary) {
    var jiffy = Jiffy()..add(months: 2);
    qtnDate = jiffy.dateTime;
  } else {
    qtnDate = DateTime.now();
  }

  String formattedDate = DateFormat('d.M.yyyy').format(qtnDate);
  DateTime newdob = DateFormat('dd.MM.yyyy').parse(lifeInsured.dob!);
  String formattedDOB = DateFormat('d.M.yyyy').format(newdob);
  DateTime newdobpo = DateFormat('dd.MM.yyyy').parse(policyOwner!.dob!);
  String formattedDOBPO = DateFormat('d.M.yyyy').format(newdobpo);
  Occupation occ = lifeInsured.occupation!;

  if (prefLang == null || prefLang.isEmpty) {
    var pref = await SharedPreferences.getInstance();
    var lang = pref.getString('language_code');
    prefLang = lang != null
        ? lang == "en"
            ? "E"
            : lang == "ms"
                ? "B"
                : "E"
        : "E";
  } else {
    prefLang = prefLang == "ENG"
        ? "E"
        : prefLang == "BMY"
            ? "B"
            : "E";
  }

  var basicInput = {
    basicVPMSKey.language: prefLang,
    basicVPMSKey.quotationDate: formattedDate,
    basicVPMSKey.dateOfBirth: formattedDOB,
    basicVPMSKey.gender: lifeInsured.gender,
    basicVPMSKey.occupational: occ.occupationCode,
    basicVPMSKey.staff: "C",
    basicVPMSKey.smoker: convertVPMSBool(lifeInsured.isSmoker!),
    basicVPMSKey.paymentFrequency: isNumeric(paymentMode)
        ? paymentMode
        : convertPaymentModeToNumber(paymentMode)
  };

  bool diffPolicyOwner = qtn.buyingFor != BuyingFor.self.toStr;
  if (prodCode.contains("PTHI") ||
      prodCode.contains("PCHI") ||
      prodCode == "PCEE01" ||
      prodCode == "PCJI02" ||
      prodCode == "PCWI03" ||
      prodCode == "PTJI01" ||
      prodCode == "PTWI01" ||
      prodCode == "PTWI03" ||
      prodCode == "PTWE04" ||
      prodCode == "PTWE05") {
    basicInput[basicVPMSKey.participantApplicable] =
        convertVPMSBool(diffPolicyOwner);
  }

  basicInput.addAll({
    basicVPMSKey.participantDateOfBirth: formattedDOBPO,
    basicVPMSKey.participantGender: policyOwner.gender ?? ""
  });

  return basicInput;
}

Future<bool> checkSteppedPremium(ProductPlan? selectedProductPlan) async {
  bool haveEnricher = false;
  if (selectedProductPlan != null) {
    var riderList = selectedProductPlan.riderList;
    List<String> riderCodes = [];
    for (var element in riderList!) {
      riderCodes.add(element.riderCode!);
    }
    haveEnricher = await ProductPlanRepositoryImpl().checkEnricher(riderCodes);
  }
  return haveEnricher;
}

void _mapSetBasicPlanToState(
    SetBasicPlan event, Emitter<ChooseProductState> emit) async {
  ProductPlan? productPlan = await ProductPlanRepositoryImpl()
      .getProductPlanSetupByProdCode(event.prodCode);
  ProductSetup productSetup = productPlan!.productSetup!;

  String? fileName = productSetup.vPMSFileName?.replaceAll(".vpm", "");
  String? vpmsVersion = await getVPMSVersion(fileName: fileName);

  final setBasicInput = await getBasicInput(event.prodCode, event.qtn);
  setBasicInput.forEach((key, value) async {
    if (key != null && key != "") {
      await setVPMSData(vpmsField: key, value: value);
    }
  });

  //FOR RIDER, WE NEED TO GET RIDER CODE BY TRIGGERING VPMS
  //THEN, FIND RIDER DATA FROM ALL RIDER LIBRARY (DATA RIDER)
  var vpmsdata = await setVPMSData(vpmsField: "P_EligibleRiders", value: "");

  List<String> eligibleRiderCode = [];
  String? vpmsRider;
  if (vpmsdata[2] != "") {
    vpmsRider = vpmsdata[2];
  }
  if (vpmsRider != null) {
    int? liAge = event.qtn.lifeInsured!.age;
    int? poAge = event.qtn.policyOwner!.age;
    var riderList = vpmsRider.split("#");
    for (var element in riderList) {
      var ridercode = element.split("|");

      if (ridercode[0] == "RCIWP8") {
        if (event.qtn.buyingFor == "spouse" && poAge! >= 16 && poAge <= 64) {
          eligibleRiderCode.add(ridercode[0]);
        }
      } else if (ridercode[0] == "RCIWP7") {
        if (event.qtn.buyingFor == "children" && liAge! < 16) {
          eligibleRiderCode.add(ridercode[0]);
        }
      } else {
        eligibleRiderCode.add(ridercode[0]);
      }
    }
  }

  List<ProductPlan> eligibleRiders = [];
  for (var riderCode in eligibleRiderCode) {
    if (riderCode != "") {
      var riderPlan =
          await ProductPlanRepositoryImpl().getRiderSetupByProdCode(riderCode);
      if (riderPlan != null &&
          !riderPlan.productSetup!.prodName!.contains("Plan") &&
          !riderPlan.productSetup!.prodName!.contains("Benefit 2") &&
          !riderPlan.productSetup!.prodName!.contains("Benefit 3")) {
        if (riderPlan.productSetup!.prodName!.contains("Benefit 1")) {
          riderPlan.productSetup!.prodName =
              riderPlan.productSetup!.prodName!.replaceAll("(Benefit 1)", "");
        }
        eligibleRiders.add(riderPlan);
      }
    }
  }

  if (productSetup.premiumBasis != null && productSetup.premiumBasis == "7") {
    if (productSetup.prodCode!.contains("PTHI")) {
      eligibleRiders.insert(
          0,
          ProductPlan(
              productSetup: ProductSetup(
                  prodCode: "PTHI01", prodName: "Takafulink Savings Flexi"),
              policyTermList: [],
              riderList: [],
              fundList: [],
              maturityTermList: [],
              sumAssuredList: [],
              minPremiumList: [],
              limitedPaymentPremiumList: []));
    } else if (productSetup.prodCode!.contains("PCHI")) {
      eligibleRiders.insert(
          0,
          ProductPlan(
              productSetup: ProductSetup(
                  prodCode: "PCHI03", prodName: "IL Savings Growth"),
              policyTermList: [],
              riderList: [],
              fundList: [],
              maturityTermList: [],
              sumAssuredList: [],
              minPremiumList: [],
              limitedPaymentPremiumList: []));
    }
  }

  FirebaseAnalytics.instance.logSelectItem(items: [
    AnalyticsEventItem(
        itemName: productSetup.prodName, itemId: productSetup.prodCode)
  ], itemListId: productSetup.prodCode, itemListName: productSetup.prodName);

  int age = getAgeString(event.qtn.lifeInsured!.dob!, false);
  String? dob = event.qtn.lifeInsured!.dob!;
  String? gender = event.qtn.lifeInsured!.gender;
  bool? deductSalary = event.quickQtn.deductSalary;

  if (productSetup.prodCode == "PCEL01" || productSetup.prodCode == "PCEE01") {
    if (event.qtn.buyingFor != BuyingFor.self.toStr) {
      age = getAgeString(event.qtn.policyOwner!.dob!, false);
      dob = event.qtn.policyOwner!.dob!;
      gender = event.qtn.policyOwner!.gender;
    }
  }
  VpmsMapping vpmsMapping = await getVPMSMappingData(event.prodCode);

  bool haveEnricher = await checkSteppedPremium(productPlan);

  emit(BasicPlanChosen(
      age: age,
      gender: gender!,
      dob: dob,
      deductSalary: deductSalary,
      selectedPlan: productPlan,
      eligibleRiders: eligibleRiders,
      quickQtn: event.quickQtn,
      vpmsMappingFile: vpmsMapping,
      vpmsVersion: vpmsVersion!,
      haveEnricher: haveEnricher));
}

void _mapSteppedPremToState(
    SetSteppedPremium event, Emitter<ChooseProductState> emit) async {
  emit(SteppedPremiumChosen(event.isSteppedPremium));
}

void _mapSustainabilityOptionToState(
    SetSustainabilityOption event, Emitter<ChooseProductState> emit) async {
  emit(SustainabilityOptionChosen(
      sustainabilityOptionTerm: event.sustainabilityOption));
}

void _mapSumInsuredAndPremToState(
    SetSumInsuredAndPrem event, Emitter<ChooseProductState> emit) async {
  emit(SumInsuredPremCalculated(
      sumInsuredAmount: int.parse("0"),
      premAmount: int.parse("0"),
      paymentMode: event.paymentMode,
      premiumTerm: event.premiumTerm,
      deductSalary: event.deductSalary,
      calcBasedOn: event.calcBasedOn,
      planDetail: event.planDetail,
      policyTerm: event.policyTerm,
      guaranteedCashPayment: event.guaranteedCashPayment));
}

void _mapAddRidersToState(
    AddRiders event, Emitter<ChooseProductState> emit) async {
  emit(RidersChosen(riderOutputDataList: event.ridersOutputData));
}

void _mapSetRidersDataToState(
    SetRidersData event, Emitter<ChooseProductState> emit) async {
  emit(RidersChosen(riderOutputDataList: event.ridersOutputData));
}

void _mapDeleteRidersDataToState(
    DeleteRiders event, Emitter<ChooseProductState> emit) async {
  emit(RidersDeleted(riderOutputDataList: event.ridersOutputData));
  emit(RidersChosen(riderOutputDataList: event.ridersOutputData));
}

void _mapSetRTUAmountToState(
    SetRTUAmount event, Emitter<ChooseProductState> emit) async {
  emit(RTUChosen(regularTopUp: event.rtuAmount));
}

void _mapSetAdhocAmountToState(
    SetAdhocAmount event, Emitter<ChooseProductState> emit) async {
  emit(AdhocChosen(adhocTopUp: event.adhocAmount));
}

void _mapAddDeleteFundsToState(
    DeleteFunds event, Emitter<ChooseProductState> emit) async {
  emit(FundsChosen(outputFundData: event.outputFundData));
}

void _mapSetFundsToState(
    SetFunds event, Emitter<ChooseProductState> emit) async {
  emit(FundsChosen(outputFundData: event.outputFundData));
}

void _mapCalculateQuotationToState(
    CalculateQuotation event, Emitter<ChooseProductState> emit) async {
  List<AnalyticsEventItem> items = [];
  items.add(AnalyticsEventItem(
      itemId: event.quickQuotation.productPlanCode,
      itemName: event.quickQuotation.productPlanName,
      price:
          double.tryParse(event.quickQuotation.basicPlanPremiumAmount ?? "0")));
  if (event.quickQuotation.enricherPremiumAmount != "0.00") {
    items.add(AnalyticsEventItem(
        itemId: "RCTE02",
        itemName: "Enricher",
        price: event.quickQuotation.enricherPremiumAmount != null
            ? double.tryParse(event.quickQuotation.enricherPremiumAmount!)
            : 0));
  }
  if (event.quickQuotation.rtuAmt != "0" &&
      event.quickQuotation.rtuAmt != "0.00") {
    items.add(AnalyticsEventItem(
        itemId: "RCITU4",
        itemName: "Regular Top-Up",
        price: double.tryParse(event.quickQuotation.rtuAmt ?? "0")));
  }
  if (event.quickQuotation.riderOutputDataList != null) {
    for (var element in event.quickQuotation.riderOutputDataList!) {
      items.add(AnalyticsEventItem(
          itemId: element.riderName,
          itemName: element.riderName,
          price: isNumeric(element.riderMonthlyPremium)
              ? double.parse(element.riderMonthlyPremium!)
              : 0));
    }
  }

  emit(QuotationCalculated(
      totalPremium: event.totalPremium, quickQuotation: event.quickQuotation));
}

void _mapViewGeneratedQtnToState(
    ViewGeneratedQuotation event, Emitter<ChooseProductState> emit) async {
  emit(ViewQuotation(
      quotation: event.quotation, quickQuotation: event.quickQuotation));
}

List<RiderOutputData> sortRider(riderOutputData) {
  List<RiderOutputData> sortedRiderOutputData = [];
  List<RiderOutputData> noWaiver = [];
  List<RiderOutputData> withWaiver = [];
  List<RiderOutputData> femaleRider = [];
  List<RiderOutputData> hcb = [];
  List<RiderOutputData> medicalPlus = [];
  List<RiderOutputData> cmb = [];
  List<RiderOutputData> tpd = [];
  // RIDER FIRST, WAIVER LAST /////

  for (var element in riderOutputData) {
    if (element.riderName!.contains("Waiver")) {
      withWaiver.add(element);
    } else if (element.riderName!.contains("Female")) {
      femaleRider.add(element);
    } else if (element.riderName!.contains("Child Maintenance Benefit")) {
      cmb.add(element);
    } else if (element.riderName!.contains("Medical Plus")) {
      medicalPlus.add(element);
    } else if (element.riderName!.contains("Hospital Cash Benefit")) {
      hcb.add(element);
    } else if (element.riderName!.contains("TPD")) {
      tpd.add(element);
    } else {
      noWaiver.add(element);
    }
  }

  noWaiver.sort((a, b) =>
      a.riderName!.toUpperCase().compareTo(b.riderName!.toUpperCase()));

  sortedRiderOutputData.addAll(femaleRider);
  sortedRiderOutputData.addAll(noWaiver);
  sortedRiderOutputData.addAll(tpd);
  sortedRiderOutputData.addAll(hcb);
  sortedRiderOutputData.addAll(medicalPlus);
  sortedRiderOutputData.addAll(cmb);
  sortedRiderOutputData.addAll(withWaiver);
  // For some case, hcb cannot be selected first, might get different result
  // And medical plus need to be at the bottom, if not might get different result too
  return sortedRiderOutputData;
}

void _mapCheckPremiumToState(
    CheckPremium event, Emitter<ChooseProductState> emit) async {
  List<List<String?>> vpmsinput = [];
  List<List<String?>> vpmsoutput = [];
  List<String> errorData = [];
  List<String> fieldRequiredData = [];
  List<String> inputToValidate = [];
  List<dynamic> riders = [];
  String? totalPremium;

  QuickQuotation quickQtn = event.quickQuotation;

  String? fileName = event.prodSetup.vPMSFileName!.replaceAll(".vpm", "");
  await getVPMSVersion(fileName: fileName);
  VpmsMapping? vpmsMapping = await getVPMSMappingData(event.prodSetup.prodCode);

  var basicVPMSKey = vpmsMapping.basicInput!;
  var participantVPMSKey = vpmsMapping.participantInput!;
  var fundVPMSKey = vpmsMapping.fundList!;
  var riderVPMSKey = vpmsMapping.vpmsProdFieldsList;
  var basicPlanInput = vpmsMapping.basicPlanInput!;
  var basicPlanOutput = vpmsMapping.basicPlanOutput!;

  if (quickQtn.productPlanCode == "PCHI03" ||
      quickQtn.productPlanCode == "PCHI04") {
    vpmsinput.add(["A_Campaign", quickQtn.isCampaign ? "Campaign" : "BAU"]);
    await setVPMSData(
        vpmsField: "A_Campaign",
        value: quickQtn.isCampaign ? "Campaign" : "BAU");
  }

  if (quickQtn.productPlanCode == "PTHI01" ||
      quickQtn.productPlanCode == "PTHI02") {
    if (quickQtn.productPlanCode == "PTHI01") {
      vpmsinput.add([basicPlanInput.tsf, "Y"]);
      await setVPMSData(vpmsField: basicPlanInput.tsf, value: "Y");
    } else {
      if (quickQtn.productPlanCode == "PTHI02") {
        vpmsinput.add([basicPlanInput.tsf, "N"]);
        await setVPMSData(vpmsField: basicPlanInput.tsf, value: "N");
      }
    }
    vpmsinput.add([basicPlanInput.tucontr, "N"]); //no need ad hoc tu
    await setVPMSData(
        vpmsField: basicPlanInput.tucontr, value: "N"); //no need ad hoc tu
    vpmsinput.add([
      basicPlanInput.basiccashopt,
      quickQtn.guaranteedCashPayment == "1" ? "Y" : "N"
    ]);
    await setVPMSData(
        vpmsField: basicPlanInput.basiccashopt,
        value: quickQtn.guaranteedCashPayment == "1" ? "Y" : "N");

    /*vpmsinput.add([basicPlanInput.tucontrpolyear, "5"]); //no need ad hoc tu
    await setVPMSData(
        vpmsField: basicPlanInput.tucontrpolyear,
        value: "5"); //no need ad hoc tu
    vpmsinput.add([basicPlanInput.tucontrpolyear1, "5"]); //no need ad hoc tu
    await setVPMSData(
        vpmsField: basicPlanInput.tucontrpolyear1,
        value: "5"); //no need ad hoc tu
    vpmsinput.add([basicPlanInput.tucontrpolyear2, "5"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontrpolyear2, value: "5");
    vpmsinput.add([basicPlanInput.tucontrpolyear3, "5"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontrpolyear3, value: "5");
    vpmsinput.add([basicPlanInput.tucontrpolyear4, "5"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontrpolyear4, value: "5");
    vpmsinput.add([basicPlanInput.tucontrpolyear5, "5"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontrpolyear5, value: "5");
    vpmsinput.add([basicPlanInput.tucontramt, "500"]); //no need ad hoc tu
    await setVPMSData(
        vpmsField: basicPlanInput.tucontramt, value: "500"); //no need ad hoc tu
    vpmsinput.add([basicPlanInput.tucontramt1, "100"]); //no need ad hoc tu
    await setVPMSData(
        vpmsField: basicPlanInput.tucontramt1,
        value: "100"); //no need ad hoc tu
    vpmsinput.add([basicPlanInput.tucontramt2, "100"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontramt2, value: "100");
    vpmsinput.add([basicPlanInput.tucontramt3, "100"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontramt3, value: "100");
    vpmsinput.add([basicPlanInput.tucontramt4, "100"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontramt4, value: "100");
    vpmsinput.add([basicPlanInput.tucontramt5, "100"]);
    await setVPMSData(vpmsField: basicPlanInput.tucontramt5, value: "100");*/
  }

  final setBasicInput = await getBasicInput(
      quickQtn.productPlanCode!, event.qtn,
      deductSalary: quickQtn.deductSalary, paymentMode: quickQtn.paymentMode!);
  setBasicInput.forEach((key, value) async {
    if (key != null && key != "") {
      vpmsinput.add([key, value]);
      await setVPMSData(vpmsField: key, value: value);
    }
  });

  String relationship = "Self";
  String porelationship = "Self";
  if (event.qtn.buyingFor == BuyingFor.spouse.toStr) {
    relationship = event.qtn.lifeInsured!.gender == "Male" ? "Husband" : "Wife";
    porelationship =
        event.qtn.lifeInsured!.gender == "Male" ? "Wife" : "Husband";
  } else if (event.qtn.buyingFor == BuyingFor.children.toStr) {
    relationship = "Child";
    porelationship =
        event.qtn.lifeInsured!.gender == "Male" ? "Father" : "Mother";
  }

  Occupation poOcc = event.qtn.policyOwner!.occupation!;
  final setBasicInput2 = <String?, dynamic>{
    participantVPMSKey.relationship: relationship,
    participantVPMSKey.participantOccupational: poOcc.occupationCode,
    participantVPMSKey.participantRelationship: porelationship,
    participantVPMSKey.participantSmoker:
        event.qtn.policyOwner!.isSmoker != null
            ? convertVPMSBool(event.qtn.policyOwner!.isSmoker!)
            : 'N'
  };

  setBasicInput2.forEach((key, value) async {
    if (key != null && key != "") {
      vpmsinput.add([key, value]);
      await setVPMSData(vpmsField: key, value: value);
    }
  });

  var premiumterm = quickQtn.premiumTerm;
  if (quickQtn.productPlanCode == "PCTA01" ||
      quickQtn.productPlanCode == "PCEL01") {
    premiumterm = quickQtn.policyTerm;
  }

  final setBasicPlanInput = <String?, dynamic>{
    basicPlanInput.basicPeriodOption: quickQtn.sustainabilityOption ?? "",
    basicPlanInput.uwProductCode: "",
    basicPlanInput.steppedPremium: quickQtn.isSteppedPremium != null
        ? convertVPMSBool(quickQtn.isSteppedPremium!)
        : null,
    basicPlanInput.topUpPremium: quickQtn.adhocAmt ?? "0",
    basicPlanInput.planDetail: quickQtn.planDetail,
    basicPlanInput.sumInsured: quickQtn.sumInsuredAmt ?? "",
    basicPlanInput.premiumTerm: premiumterm,
    basicPlanInput.premium: quickQtn.premAmt ?? "",
    basicPlanInput.rtuPremium: quickQtn.rtuAmt ?? "0",
    basicPlanInput.prodHistory: "N",
    basicPlanInput.aggregateSA: "0",
    basicPlanInput.planName: quickQtn.productPlanName,
    basicPlanInput.premiumPaymentType: "C003"
  };

  setBasicPlanInput.forEach((key, value) async {
    if (key != null && key != "" && value != null) {
      vpmsinput.add([key, value]);
      await setVPMSData(vpmsField: key, value: value);
    }
  });

  var fundOutputData = event.quickQuotation.fundOutputDataList;
  for (var fundVPMS in fundVPMSKey) {
    var fund = fundOutputData!
        .firstWhereOrNull((element) => element.fundCode == fundVPMS.code);
    String? fundalloc = "0";
    if (fund != null) {
      fundalloc = fund.fundAlloc;
    }
    vpmsinput.add([fundVPMS.vpmsInput, fundalloc]);
    var vpmsdata =
        await setVPMSData(vpmsField: fundVPMS.vpmsInput, value: fundalloc);
    if (vpmsdata[0] != "") {
      errorData.add(vpmsdata[0]);
    }
  }

  if (basicVPMSKey.dateOfBirth != null && basicVPMSKey.dateOfBirth != "") {
    if (!inputToValidate.contains(basicVPMSKey.dateOfBirth)) {
      inputToValidate.add(basicVPMSKey.dateOfBirth!);
    }
  }

  if (event.qtn.buyingFor != BuyingFor.self.toStr) {
    if (basicVPMSKey.participantDateOfBirth != null &&
        basicVPMSKey.participantDateOfBirth != "") {
      if (!inputToValidate.contains(basicVPMSKey.participantDateOfBirth)) {
        inputToValidate.add(basicVPMSKey.participantDateOfBirth!);
      }
    }
  }

  if (quickQtn.productPlanCode == "PTJI01") {
    if (!inputToValidate.contains(basicVPMSKey.occupational)) {
      inputToValidate.add(basicVPMSKey.occupational!);
    }
  }

  var basic = getRiderByInputSA(basicPlanInput.sumInsured, null, null);
  riders.add(basic);

  if (basicPlanOutput.enricherPremium != "") {
    String inputSA = "";
    if (quickQtn.productPlanCode == "PCWI03" ||
        quickQtn.productPlanCode == "PCJI02") {
      inputSA = "N/A|${basicPlanOutput.enricherPremium}";
    }
    var enr = getRiderByInputSA(inputSA, basicPlanOutput.enricherPremiumTerm,
        basicPlanOutput.enricherPremium);
    riders.add(enr);
  }

  List<RiderOutputData> riderOutputData =
      sortRider(event.quickQuotation.riderOutputDataList);
  for (var riderVPMS in riderVPMSKey!) {
    if (riderVPMS.riderCode != "" &&
        riderVPMS.riderCode != quickQtn.productPlanCode &&
        riderVPMS.inputSa != basicPlanInput.sumInsured &&
        !riderVPMS.riderCode!.contains("RCTE") &&
        !riderVPMS.riderCode!.contains("RCITU") &&
        !riderVPMS.riderCode!.contains("RFNA2") &&
        !riderVPMS.riderCode!.contains("RFNA3")) {
      var riderInd = getRiderByIndicator(riderVPMS.indicator, riderVPMS.inputSa,
          riderVPMS.inputTerm, riderVPMS.inputPremium, null);
      riders.add(riderInd);
      if (riderVPMS.indicator != "") {
        await setVPMSData(vpmsField: riderVPMS.indicator, value: "N");
      }
      if (riderVPMS.inputSa != "" &&
          riderVPMS.inputSa != basicPlanInput.sumInsured) {
        await setVPMSData(vpmsField: riderVPMS.inputSa, value: "0");
      }
      if (riderVPMS.inputTerm != "") {
        await setVPMSData(vpmsField: riderVPMS.inputTerm, value: "0");
      }
    }
  }

  for (var rider in riderOutputData) {
    var riderVPMS = riderVPMSKey
        .firstWhereOrNull((element) => element.riderCode == rider.riderCode);
    if (riderVPMS != null) {
      if (riderVPMS.riderCode != "" &&
          riderVPMS.riderCode != quickQtn.productPlanCode &&
          riderVPMS.inputSa != basicPlanInput.sumInsured &&
          !riderVPMS.riderCode!.contains("RCTE") &&
          !riderVPMS.riderCode!.contains("RCITU")) {
        if (isNumeric(rider.riderSA)) {
          int.tryParse(rider.riderSA!);
        } else {
          //IF we can't parse it and tempSA != null, meaning the data is inside tempSA.
          if (rider.tempSA == null) {
            rider.riderSA = null;
          } else {
            if (rider.riderName == "IL Medical Plus" ||
                rider.riderName == "Takafulink Medical Plus") {
              rider.riderSA =
                  rider.tempSA == "Full Coverage" ? "0" : rider.tempSA;
            } else if (rider.riderName!.contains("Waiver")) {
              rider.riderSA = null;
            }
          }
        }

        var setRiderInput = <String?, dynamic>{};

        if ((riderVPMS.inputTerm != null && riderVPMS.inputTerm != "") &&
            (rider.riderTerm != null && rider.riderTerm != "")) {
          setRiderInput.putIfAbsent(riderVPMS.inputTerm, () => rider.riderTerm);
        }

        if (riderVPMS.indicator == "A_CMB_IND") {
          setRiderInput.putIfAbsent(riderVPMS.indicator, () => "Y");
          if (rider.riderSA == null) {
            setRiderInput.putIfAbsent(
                "A_CMB_Monthly_Benefit", () => rider.riderPlan);
          }
        }

        if (riderVPMS.indicator == "A_ACI_IND") {
          setRiderInput.putIfAbsent(riderVPMS.indicator, () => "Y");
          if (rider.riderSA != null) {
            setRiderInput.putIfAbsent(riderVPMS.inputSa, () => rider.riderSA);
          }
        } else {
          if ((riderVPMS.inputPlan != null && riderVPMS.inputPlan != "") &&
              (rider.riderPlan != null && rider.riderPlan != "")) {
            setRiderInput.putIfAbsent(
                riderVPMS.inputPlan, () => rider.riderPlan);
          }
          setRiderInput.putIfAbsent(riderVPMS.indicator, () => "Y");
          if ((rider.riderSA != null && rider.riderSA != "") &&
              (riderVPMS.inputSa != null && riderVPMS.inputSa != "")) {
            setRiderInput.putIfAbsent(riderVPMS.inputSa, () => rider.riderSA);
          }
        }

        setRiderInput.forEach((key, value) async {
          if (key != "") {
            vpmsinput.add([key, value]);
            await setVPMSData(vpmsField: key, value: value);
          }
        });
      }
    }
  }

  if (quickQtn.productPlanCode == "PCHI03" ||
      quickQtn.productPlanCode == "PCHI04") {
    var ilsavingVPMS = riderVPMSKey
        .firstWhereOrNull((element) => element.riderCode == "PCHI03");
    if (ilsavingVPMS != null) {
      var riderInd = getRiderByIndicator(
          ilsavingVPMS.indicator,
          ilsavingVPMS.inputSa,
          ilsavingVPMS.inputTerm,
          ilsavingVPMS.inputPremium,
          null);
      riders.add(riderInd);

      String indicator =
          riderOutputData.any((element) => element.riderCode == "PCHI03")
              ? "Y"
              : "N";
      if (ilsavingVPMS.indicator != "") {
        vpmsinput.add([ilsavingVPMS.indicator, indicator]);
        var vpmsdata = await setVPMSData(
            vpmsField: ilsavingVPMS.indicator, value: indicator);
        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        }
      }
      if (basicPlanInput.gscoption != "") {
        vpmsinput.add([
          basicPlanInput.gscoption,
          indicator == "N"
              ? "N"
              : quickQtn.guaranteedCashPayment == "1"
                  ? "Y"
                  : "N"
        ]);
        var vpmsdata = await setVPMSData(
            vpmsField: basicPlanInput.gscoption,
            value: indicator == "N"
                ? "N"
                : quickQtn.guaranteedCashPayment == "1"
                    ? "Y"
                    : "N");
        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        }
      }
    }
  }

  if (basicPlanInput.gscoption != null && basicPlanInput.gscoption != "") {
    if (quickQtn.productPlanCode == "PCEL01" ||
        quickQtn.productPlanCode == "PCEE01") {
      vpmsinput.add([basicPlanInput.gscoption, quickQtn.guaranteedCashPayment]);
      var vpmsdata = await setVPMSData(
          vpmsField: basicPlanInput.gscoption,
          value: quickQtn.guaranteedCashPayment);
      if (vpmsdata[0] != "") {
        errorData.add(vpmsdata[0]);
      }
    }
  }

  // vpmsinput.add(
  //     [basicPlanVPMSKey.regularTopupAmount, quickQtn.rtuPremiumAmount ?? ""]);
  // var vpmsdata = await setVPMSData(
  //     vpmsField: basicPlanVPMSKey.regularTopupAmount,
  //     value: quickQtn.rtuPremiumAmount ?? "");
  // if (vpmsdata[0] != "") {
  //   errorData.add(vpmsdata[0]);
  // }

  if (basicPlanInput.rtuPremium != null) {
    String rtuInput = "N/A";
    if (quickQtn.productPlanCode == "PCWI03" ||
        quickQtn.productPlanCode == "PCJI02") {
      rtuInput = "N/A|${basicPlanInput.rtuPremium}";
    }

    var rtu = getRiderByInputSA(rtuInput, null, basicPlanInput.rtuPremium);
    riders.add(rtu);
  }

  var inputs = constructValidationField(riders, quickQtn.productPlanCode!);
  var inputMap = inputs.split("|");
  for (var element in inputMap) {
    if (element != null && element != "") {
      if (!inputToValidate.contains(element)) {
        inputToValidate.add(element);
      }
    }
  }

  // To set missing validation on certain parameter.
  var inputs2 = "";

  // Securelink
  if (quickQtn.productPlanCode == "PCWI03") {
    inputs2 =
        "$inputs2|A_Medic_Plus_Coverage|A_Basic_Period_Option|A_Stepped_Premium_IND|A_Premium|A_Medic_Plus_IND";
  }
  // Megaplus
  else if (quickQtn.productPlanCode == "PCJI02") {
    inputs2 =
        "$inputs2|A_Sustainability_Period|A_Basic_Premium_Term|A_SteppedPrem_IND";
  }
  // Maxipro
  else if (quickQtn.productPlanCode == "PCHI03" ||
      quickQtn.productPlanCode == "PCHI04") {
    inputs2 = "$inputs2|A_Basic_PremiumAmt";
  }
  // Eliteplus
  else if (quickQtn.productPlanCode == "PTWI03") {
    inputs2 =
        "$inputs2|A_Medical_Plus_Coverage|A_SteppedContr_IND|A_Contribution|A_Topup_Premium|A_HCB_Plan";
  }
  // Mahabbah
  else if (quickQtn.productPlanCode == "PTJI01") {
    inputs2 =
        "$inputs2|A_Sustainability_Period|A_Basic_Contribution_Term|A_SteppedPrem_IND";
  }
  // Hadiyyah
  else if (quickQtn.productPlanCode == "PTHI01" ||
      quickQtn.productPlanCode == "PTHI02") {
    inputs2 = "$inputs2|A_Basic_ContrAmt";
  }

  var inputMap2 = inputs2.split("|");
  for (var element in inputMap2) {
    if (element != "") {
      if (!inputToValidate.contains(element)) {
        inputToValidate.add(element);
      }
    }
  }

  inputToValidate = LinkedHashSet<String>.from(inputToValidate).toList();

  for (var element in inputToValidate) {
    if (element != "") {
      var vpmsdata = await getAnyway(vpmsField: element);
      if (vpmsdata[0] != "") {
        errorData.add(vpmsdata[0]);
      }
    }
  }

  if (errorData.isNotEmpty || fieldRequiredData.isNotEmpty) {
    String message = "";
    errorData = LinkedHashSet<String>.from(errorData).toList();
    fieldRequiredData = LinkedHashSet<String>.from(fieldRequiredData).toList();

    List<String> e = [];
    for (var error in errorData) {
      var index = errorData.firstWhereOrNull(
          (element) => element != error && element.contains(error));
      if (index != null) {
        e.add(error);
      }
    }
    for (var error in e) {
      errorData.removeWhere((element) => element == error);
    }

    final errorString = errorData.isNotEmpty
        ? errorData.reduce((value, element) => '$value \n\n$element')
        : "";
    final fieldString = fieldRequiredData.isNotEmpty
        ? fieldRequiredData.reduce((value, element) => '$value \n\n$element')
        : "";

    if (errorString == "") {
      message = "Field required: \n\n$fieldString\n";
    } else if (fieldString == "") {
      message = "${getLocale('Error:')}\n\n$errorString\n";
    } else {
      message =
          "${getLocale('Error:')}\n\n$errorString \n\nField required \n$fieldString\n";
    }
    emit(ChooseProductError(message));
  } else {
    /////////////////////////////////////////////////////
    /// GET VPMS OUTPUT ///
    /////////////////////////////////////////////////////

    var getBasicPlanOutput = [
      basicPlanOutput.sumInsured,
      basicPlanOutput.premiumTerm,
      basicPlanOutput.policyTerm,
      basicPlanOutput.premium,
      basicPlanOutput.enricherSA,
      basicPlanOutput.enricherPremiumTerm,
      basicPlanOutput.enricherPolicyTerm,
      basicPlanOutput.enricherPremium,
      basicPlanOutput.rtuSA,
      basicPlanOutput.rtuSAIOS,
      basicPlanOutput.rtuPremiumTerm,
      basicPlanOutput.rtuPolicyTerm,
      basicPlanOutput.rtuPremium,
      basicPlanOutput.adhocSA,
    ];

    for (int x = 0; x < getBasicPlanOutput.length; x++) {
      if (getBasicPlanOutput[x] != null && getBasicPlanOutput[x] != "") {
        var vpmsdata =
            await (setVPMSData(vpmsField: getBasicPlanOutput[x], value: ""));
        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          fieldRequiredData.add(vpmsdata[1]);
        } else {
          vpmsoutput.add([getBasicPlanOutput[x], vpmsdata[2]]);
          switch (x) {
            case (0):
              {
                quickQtn.basicPlanSumInsured = vpmsdata[2];
              }
              break;
            case (1):
              {
                quickQtn.basicPlanPaymentTerm = vpmsdata[2];
              }
              break;
            case (2):
              {
                quickQtn.basicPlanPolicyTerm = vpmsdata[2];
              }
              break;
            case (3):
              {
                quickQtn.basicPlanPremiumAmount = vpmsdata[2];
              }
              break;
            case (4):
              {
                quickQtn.enricherSumInsured = vpmsdata[2];
              }
              break;
            case (5):
              {
                quickQtn.enricherPaymentTerm = vpmsdata[2];
              }
              break;
            case (6):
              {
                quickQtn.enricherPolicyTerm = vpmsdata[2];
              }
              break;
            case (7):
              {
                quickQtn.enricherPremiumAmount = vpmsdata[2];
              }
              break;
            case (8):
              {
                quickQtn.rtuSumInsured = vpmsdata[2];
              }
              break;
            case (9):
              {
                quickQtn.rtuSAIOS = vpmsdata[2];
              }
              break;
            case (10):
              {
                quickQtn.rtuPaymentTerm = vpmsdata[2];
              }
              break;
            case (11):
              {
                quickQtn.rtuPolicyTerm = vpmsdata[2];
              }
              break;
            case (12):
              {
                quickQtn.rtuPremiumAmount = vpmsdata[2];
              }
              break;
            case (13):
              {
                quickQtn.adhocPremiumAmount = vpmsdata[2];
              }
              break;
            default:
              {
                break;
              }
          }
        }
      }
    }
    ///////////////////////////////////////////////
    // GETTING TOTAL PREMIUM
    var premiumSummary = vpmsMapping.premiumSummary;
    if (premiumSummary != null) {
      var totalPrem = [
        premiumSummary.anb,
        premiumSummary.maturityAge,
        premiumSummary.basicContribution,
        premiumSummary.totalPremium,
        premiumSummary.totalPremiumIOS,
        premiumSummary.minSumInsured,
        premiumSummary.sam,
        premiumSummary.totalFundAlloc,
        premiumSummary.occLoad,
        premiumSummary.totalPremOccLoad
      ];

      for (int x = 0; x < totalPrem.length; x++) {
        if (totalPrem[x] != null && totalPrem[x]!.isNotEmpty) {
          var vpmsdata =
              await (setVPMSData(vpmsField: totalPrem[x], value: ""));
          vpmsoutput.add([totalPrem[x], vpmsdata[2]]);
          if (vpmsdata[0] != "") {
            errorData.add(vpmsdata[0]);
          } else if (vpmsdata[1] != "") {
            fieldRequiredData.add(vpmsdata[1]);
          } else {
            if (x == 0) {
              quickQtn.anb = vpmsdata[2];
            } else if (x == 1) {
              quickQtn.maturityAge = vpmsdata[2];
            } else if (x == 2) {
              quickQtn.basicContribution = vpmsdata[2];
            } else if (x == 3) {
              if (quickQtn.adhocAmt != null || quickQtn.adhocAmt != "0") {
                var calculatePremiumAdhoc = double.parse(vpmsdata[2]) +
                    double.parse(quickQtn.adhocAmt ?? "0.00");
                totalPremium = calculatePremiumAdhoc.toString();
              } else {
                totalPremium = vpmsdata[2];
              }
            } else if (x == 4) {
              quickQtn.basicPlanTotalPremiumIOS = vpmsdata[2];
            } else if (x == 5) {
              quickQtn.minsa = vpmsdata[2];
            } else if (x == 6) {
              quickQtn.sam = vpmsdata[2];
            } else if (x == 7) {
              quickQtn.totalFundAlloc = vpmsdata[2];
            } else if (x == 8) {
              quickQtn.occLoad = vpmsdata[2];
            } else if (x == 9) {
              quickQtn.totalPremOccLoad = vpmsdata[2];
            }
          }
        }
      }

      if (quickQtn.productPlanCode == "PCEE01" ||
          quickQtn.productPlanCode == "PCEL01" ||
          quickQtn.productPlanCode == "PCWA01" ||
          quickQtn.productPlanCode == "PCTA01") {
        int anb = event.qtn.lifeInsured!.age! + 1;
        quickQtn.anb ??= anb.toString();

        var anb2 = int.parse(quickQtn.anb!);
        quickQtn.basicPlanPolicyTerm ??= quickQtn.policyTerm;
        var policyterm = int.parse(quickQtn.basicPlanPolicyTerm!);

        int maturityage = anb2 + policyterm;
        quickQtn.maturityAge ??= maturityage.toString();
      }
    }
    ///////////////////////////////////////////////
    // GETTING RIDER DATA

    var outRiderData = vpmsMapping.vpmsProdFieldsList;
    for (var rider in riderOutputData) {
      if (rider.tempSA != null) {
        rider.riderSA = rider.tempSA;
      }

      var riderOutputVPMS = outRiderData!.firstWhereOrNull((element) =>
          element.riderCode == rider.riderCode ||
          element.riderCode == rider.childCode);
      if (riderOutputVPMS != null) {
        var setRiderOutput = [
          riderOutputVPMS.outputPremPaymentTerm, // Rider Payment Term
          riderOutputVPMS.outputTerm, // Rider output term
          riderOutputVPMS.outputRiderType, // Rider type
          riderOutputVPMS.outputSa, // Rider out sum insured
          riderOutputVPMS.outputPremium, // Rider Premium
          riderOutputVPMS.notionalPremium, // Notional Premium
          riderOutputVPMS.outputSAIOS
        ];

        if (rider.riderCode!.contains("RCIMP")) {
          setRiderOutput
              .addAll(["P_EMR_Plus_SA_Plan", "P_EMR_Plus_SA_Coverage"]);
        }

        if (rider.riderCode!.contains("RTIMP")) {
          setRiderOutput
              .addAll(["P_EMR_Plus_SA_Plan", "P_EMR_Plus_SA_Coverage"]);
        }

        for (int x = 0; x < setRiderOutput.length; x++) {
          if (setRiderOutput[x] != null && setRiderOutput[x] != "") {
            var vpmsdata =
                await (setVPMSData(vpmsField: setRiderOutput[x], value: ""));

            vpmsoutput.add([setRiderOutput[x], vpmsdata[2]]);
            if (vpmsdata[0] != "") {
              errorData.add(vpmsdata[0]);
            } else if (vpmsdata[1] != "") {
              fieldRequiredData.add(vpmsdata[1]);
            } else {
              if (x == 0) {
                if (rider.riderCode == "PCHI03") {
                  quickQtn.gcpPremTerm = vpmsdata[2];
                }
                if (rider.riderCode == "PTHI01") {
                  quickQtn.gcpPremAmt = vpmsdata[2];
                }
                rider.riderPaymentTerm = vpmsdata[2];
              } else if (x == 1) {
                if (rider.riderCode == "PCHI03") {
                  quickQtn.gcpTerm = vpmsdata[2];
                }
                rider.riderOutputTerm = vpmsdata[2];
              } else if (x == 2) {
                rider.riderType = vpmsdata[2];
              } else if (x == 3) {
                rider.riderSA = vpmsdata[2];
              } else if (x == 4) {
                if (rider.riderCode == "PCHI03") {
                  quickQtn.gcpPremAmt = vpmsdata[2];
                }
                if (rider.riderCode == "PTHI01") {
                  quickQtn.gcpTerm = vpmsdata[2];
                }
                rider.riderMonthlyPremium = vpmsdata[2];
              } else if (x == 5) {
                rider.riderNotionalPrem = vpmsdata[2];
              } else if (x == 6) {
                rider.riderSAIOS = vpmsdata[2];
              }
            }
          }
        }
      }
    }
    quickQtn.riderOutputDataList = riderOutputData;
    ///////////////////////////////////////////////
    // GETTING FUND DATA

    var outFundData = vpmsMapping.fundList;

    for (var fund in fundOutputData!) {
      var fundOutputVPMS = outFundData!
          .firstWhereOrNull((element) => element.code == fund.fundCode);

      if (fundOutputVPMS != null) {
        var fundVPMSOutput = fundOutputVPMS.vpmsOutput;
        if (fundVPMSOutput != "") {
          var vpmsdata =
              await (setVPMSData(vpmsField: fundVPMSOutput, value: ""));
          vpmsoutput.add([fundVPMSOutput, vpmsdata[2]]);
          if (vpmsdata[0] != "") {
            errorData.add(vpmsdata[0]);
          } else if (vpmsdata[1] != "") {
            fieldRequiredData.add(vpmsdata[1]);
          } else {
            fund.fundAlloc = vpmsdata[2];
          }
        }
      }
    }
    quickQtn.fundOutputDataList = fundOutputData;
    //////////////////////////////////////////////////
    /// GETTING SI TABLE DATA

    var outTableData = vpmsMapping.siTableData!;
    List<List<String>?> vpmsOutputData = [];

    for (int i = 0; i < outTableData.length; i++) {
      if (outTableData[i] != "") {
        var vpmsdata = await setVPMSData(vpmsField: outTableData[i], value: "");
        vpmsoutput.add([outTableData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (fieldRequiredData.contains(vpmsdata[1])) {
          } else {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          vpmsOutputData.add(data);
        }
      }
    }

    quickQtn.siTableData = vpmsOutputData;

    var outTableGSCData = vpmsMapping.gsc!;
    List<List<String>?> gscoutput = [];

    for (int i = 0; i < outTableGSCData.length; i++) {
      if (outTableGSCData[i] != "") {
        var vpmsdata =
            await setVPMSData(vpmsField: outTableGSCData[i], value: "");
        vpmsoutput.add([outTableGSCData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (fieldRequiredData.contains(vpmsdata[1])) {
          } else {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          gscoutput.add(data);
        }
      }
    }

    quickQtn.siTableGSC = gscoutput;

    var outTableWakalahData = vpmsMapping.wakalah!;
    List<List<String>?> wakalahoutput = [];

    for (int i = 0; i < outTableWakalahData.length; i++) {
      if (outTableWakalahData[i] != "") {
        var vpmsdata =
            await setVPMSData(vpmsField: outTableWakalahData[i], value: "");
        vpmsoutput.add([outTableWakalahData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (fieldRequiredData.contains(vpmsdata[1])) {
          } else {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          wakalahoutput.add(data);
        }
      }
    }

    quickQtn.siTableWakalah = wakalahoutput;

    //////////////////////////////////////////////////
    /// GETTING SURRENDER CHARGE TABLE DATA

    var outSurrenderChargeTableData = vpmsMapping.surrenderChargeTableData!;
    List<List<String>?> surrenderChargeOutputData = [];

    for (int i = 0; i < outSurrenderChargeTableData.length; i++) {
      if (outSurrenderChargeTableData[i] != "") {
        var vpmsdata = await setVPMSData(
            vpmsField: outSurrenderChargeTableData[i], value: "");
        vpmsoutput.add([outSurrenderChargeTableData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (fieldRequiredData.contains(vpmsdata[1])) {
          } else {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          surrenderChargeOutputData.add(data);
        }
      }
    }

    quickQtn.surrenderChargeTableData = surrenderChargeOutputData;

    //////////////////////////////////////////////////
    /// GETTING FUND FEE TABLE DATA

    List<List<String>?> fundFeeOutputData = [];
    var outFundFeeTableData = vpmsMapping.fundFeeTableData;
    if (outFundFeeTableData != null) {
      for (int i = 0; i < outFundFeeTableData.length; i++) {
        if (outFundFeeTableData[i] != "") {
          var vpmsdata =
              await setVPMSData(vpmsField: outFundFeeTableData[i], value: "");
          vpmsoutput.add([outFundFeeTableData[i], vpmsdata[2]]);

          if (vpmsdata[0] != "") {
            errorData.add(vpmsdata[0]);
          } else if (vpmsdata[1] != "") {
            if (fieldRequiredData.contains(vpmsdata[1])) {
            } else {
              fieldRequiredData.add(vpmsdata[1]);
            }
          } else if (vpmsdata[2] != "") {
            final data = vpmsdata[2].split("|");
            fundFeeOutputData.add(data);
          }
        }
      }
    }

    quickQtn.fundFeeTableData = fundFeeOutputData;

    //////////////////////////////////////////////////
    /// GETTING SUSTAINABILITY PERIOD TABLE DATA

    var outSustainabilityPeriodTableData =
        vpmsMapping.sustainabilityPeriodTableData!;

    List<List<String>?> sustainabilityPeriod = [];

    for (int i = 0; i < outSustainabilityPeriodTableData.length; i++) {
      if (outSustainabilityPeriodTableData[i] != "") {
        var vpmsdata = await setVPMSData(
            vpmsField: outSustainabilityPeriodTableData[i], value: "");
        vpmsoutput.add([outSustainabilityPeriodTableData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (fieldRequiredData.contains(vpmsdata[1])) {
          } else {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          sustainabilityPeriod.add(data);
        }
      }
    }

    quickQtn.sustainabilityPeriodTableData = sustainabilityPeriod;

    //////////////////////////////////////////////////
    /// GETTING HISTORICAL FUND TABLE DATA

    var outHistoricalFundTableData = vpmsMapping.historicalFundTableData!;
    List<List<String>?> historicalFundTableData = [];

    for (int i = 0; i < outHistoricalFundTableData.length; i++) {
      if (outHistoricalFundTableData[i] != "") {
        var vpmsdata = await setVPMSData(
            vpmsField: outHistoricalFundTableData[i], value: "");
        vpmsoutput.add([outHistoricalFundTableData[i], vpmsdata[2]]);

        if (vpmsdata[0] != "") {
          errorData.add(vpmsdata[0]);
        } else if (vpmsdata[1] != "") {
          if (!fieldRequiredData.contains(vpmsdata[1])) {
            fieldRequiredData.add(vpmsdata[1]);
          }
        } else if (vpmsdata[2] != "") {
          final data = vpmsdata[2].split("|");
          historicalFundTableData.add(data);
        }
      }
    }

    //////////////////////////////////////////////////
    /// GETTING WORDING IN SI ILLUSTRATION

    var wordingsiillustrationoutput = vpmsMapping.wordingSiIllustrationOutput!;

    for (int x = 0; x < wordingsiillustrationoutput.length; x++) {
      if (wordingsiillustrationoutput[x] != "") {
        var vpmsdata = await (setVPMSData(
            vpmsField: wordingsiillustrationoutput[x], value: ""));
        vpmsoutput.add([wordingsiillustrationoutput[x], vpmsdata[2]]);
      }
    }

    //////////////////////////////////////////////////
    /// GETTING WORDING IN INPUT SHEET

    var noticewordinginputsheetoutput =
        vpmsMapping.noticeWordingInputSheetOutput!;

    for (int x = 0; x < noticewordinginputsheetoutput.length; x++) {
      if (noticewordinginputsheetoutput[x] != "") {
        var vpmsdata = await (setVPMSData(
            vpmsField: noticewordinginputsheetoutput[x], value: ""));
        vpmsoutput.add([noticewordinginputsheetoutput[x], vpmsdata[2]]);
      }
    }

    //////////////////////////////////////////////////
    /// GETTING PDS TABLE DATA

    var pdsvpmsoutput = vpmsMapping.pds!;

    for (int x = 0; x < pdsvpmsoutput.length; x++) {
      if (pdsvpmsoutput[x] != "") {
        var vpmsdata =
            await (setVPMSData(vpmsField: pdsvpmsoutput[x], value: ""));
        vpmsoutput.add([pdsvpmsoutput[x], vpmsdata[2]]);
      }
    }

    var basicOutput = vpmsMapping.basicOutput!;
    for (int x = 0; x < basicOutput.length; x++) {
      if (basicOutput[x] != "") {
        var vpmsdata =
            await (setVPMSData(vpmsField: basicOutput[x], value: ""));
        vpmsoutput.add([basicOutput[x], vpmsdata[2]]);
      }
    }

    quickQtn.historicalFundTableData = historicalFundTableData;
    quickQtn.vpmsinput = vpmsinput;
    quickQtn.vpmsoutput = vpmsoutput;

    if (errorData.isNotEmpty || fieldRequiredData.isNotEmpty) {
      String message = "";
      errorData = LinkedHashSet<String>.from(errorData).toList();
      fieldRequiredData =
          LinkedHashSet<String>.from(fieldRequiredData).toList();

      List<String> e = [];
      for (var error in errorData) {
        var index = errorData.firstWhereOrNull(
            (element) => element != error && element.contains(error));
        if (index != null) {
          e.add(error);
        }
      }
      for (var error in e) {
        errorData.removeWhere((element) => element == error);
      }

      final errorString = errorData.isNotEmpty
          ? errorData.reduce((value, element) => '$value \n$element')
          : "";
      final fieldString = fieldRequiredData.isNotEmpty
          ? fieldRequiredData.reduce((value, element) => '$value \n$element')
          : "";

      if (errorString == "") {
        message = "Field required: \n\n$fieldString\n";
      } else if (fieldString == "") {
        message = "Error \n\n$errorString\n";
      } else {
        message = "Error \n\n$errorString \n\nField required \n$fieldString\n";
      }
      emit(ChooseProductError(message));
    } else {
      if ((quickQtn.productPlanCode == "PCJI02") &&
          quickQtn.isSteppedPremium! &&
          (quickQtn.enricherPremiumAmount == "0.00" ||
              quickQtn.enricherPremiumAmount == "N/A")) {
        emit(const ChooseProductError(
            "Enricher: Please select Level Premium Option for Enricher."));
      } else {
        if (event.callTSAR) {
          var data = event.data;
          data.remove("tsarqtype");
          data.remove("qtype");
          data.remove("caseindicator");
          data.remove("forceRequote");
          data.remove("requoteAmt");

          var res = await submitUnderWritingWS(data, quickQtn,
              totalPremium: totalPremium,
              getQuotationHistoryID: false,
              isCallVPMS: false);
          if (res != null) {
            await tsarValidate2(data, quickQtn, res).then((result) async {
              data = result["data"];
              quickQtn = result["quickqtn"];
              ApplicationFormData.data = data;
              saveData();

              double requoteAmt = 0;
              if (event.data["requoteAmt"] != null) {
                requoteAmt = event.data["requoteAmt"] is double
                    ? event.data["requoteAmt"]
                    : isNumeric(event.data["requoteAmt"])
                        ? double.tryParse(event.data["requoteAmt"])
                        : 0;
              }
              if (requoteAmt > 0) {
                vpmsinput = [];
                vpmsoutput = [];

                if (quickQtn.productPlanCode == "PCHI03" ||
                    quickQtn.productPlanCode == "PCHI04") {
                  vpmsinput.add(
                      ["A_Campaign", quickQtn.isCampaign ? "Campaign" : "BAU"]);
                  await setVPMSData(
                      vpmsField: "A_Campaign",
                      value: quickQtn.isCampaign ? "Campaign" : "BAU");
                }

                final setBasicInput = await getBasicInput(
                    quickQtn.productPlanCode!, event.qtn,
                    deductSalary: quickQtn.deductSalary,
                    paymentMode: quickQtn.paymentMode!);
                setBasicInput.forEach((key, value) async {
                  if (key != "") {
                    vpmsinput.add([key, value]);
                    await setVPMSData(vpmsField: key, value: value);
                  }
                });

                final setBasicPlanInput2 = <String?, dynamic>{
                  basicPlanInput.basicPeriodOption:
                      quickQtn.sustainabilityOption ?? "",
                  "A_UW_ProductCode": "",
                  basicPlanInput.steppedPremium:
                      convertVPMSBool(quickQtn.isSteppedPremium!),
                  "A_Topup_Premium": basicPlanOutput.adhocSA
                };

                setBasicPlanInput2.forEach((key, value) async {
                  if (key != null && key != "") {
                    vpmsinput.add([key, value]);
                    await setVPMSData(vpmsField: key, value: value);
                  }
                });

                final setBasicPlanInput = <String?, dynamic>{
                  basicPlanInput.premiumTerm: quickQtn.premiumTerm ?? "5",
                  basicPlanInput.planDetail: quickQtn.planDetail ?? "",
                  basicPlanInput.sumInsured: quickQtn.sumInsuredAmt ?? "",
                  basicPlanInput.premium: quickQtn.premAmt ?? "",
                  basicPlanInput.prodHistory: "Y",
                  basicPlanInput.aggregateSA: requoteAmt.toString()
                };

                setBasicPlanInput.forEach((key, value) async {
                  if (key != null && key != "") {
                    vpmsinput.add([key, value]);
                    await setVPMSData(vpmsField: key, value: value);
                  }
                });

                var fundOutputData = event.quickQuotation.fundOutputDataList;

                for (var fundVPMS in fundVPMSKey) {
                  var fund = fundOutputData!.firstWhereOrNull(
                      (element) => element.fundCode == fundVPMS.code);
                  String? fundalloc = "0";
                  if (fund != null) {
                    fundalloc = fund.fundAlloc;
                  }
                  vpmsinput.add([fundVPMS.vpmsInput, fundalloc]);
                  var vpmsdata = await setVPMSData(
                      vpmsField: fundVPMS.vpmsInput, value: fundalloc);
                  if (vpmsdata[0] != "") {
                    errorData.add(vpmsdata[0]);
                  }
                }

                for (var riderVPMS in riderVPMSKey) {
                  if (riderVPMS.riderCode != "" &&
                      riderVPMS.riderCode != quickQtn.productPlanCode &&
                      riderVPMS.inputSa != basicPlanInput.sumInsured &&
                      !riderVPMS.riderCode!.contains("RCTE") &&
                      !riderVPMS.riderCode!.contains("RCITU")) {
                    if (riderVPMS.indicator != "") {
                      await setVPMSData(
                          vpmsField: riderVPMS.indicator, value: "N");
                    }
                    if (riderVPMS.inputSa != "" &&
                        riderVPMS.inputSa != basicPlanInput.sumInsured) {
                      await setVPMSData(
                          vpmsField: riderVPMS.inputSa, value: "0");
                    }
                  }
                }

                for (var rider in riderOutputData) {
                  var riderVPMS = riderVPMSKey.firstWhereOrNull(
                      (element) => element.riderCode == rider.riderCode);
                  if (riderVPMS != null) {
                    if (riderVPMS.riderCode != "" &&
                        riderVPMS.riderCode != quickQtn.productPlanCode &&
                        riderVPMS.inputSa != basicPlanInput.sumInsured &&
                        !riderVPMS.riderCode!.contains("RCTE") &&
                        !riderVPMS.riderCode!.contains("RCITU")) {
                      if (isNumeric(rider.riderSA)) {
                        int.parse(rider.riderSA!);
                      } else {
                        //IF we can't parse it and tempSA != null, meaning the data is inside tempSA.
                        if (rider.tempSA == null) {
                          rider.riderSA = null;
                        } else {
                          if (rider.riderName == "IL Medical Plus" ||
                              rider.riderName == "Takafulink Medical Plus") {
                            rider.riderSA = rider.tempSA == "Full Coverage"
                                ? "0"
                                : rider.tempSA;
                          } else if (rider.riderName!.contains("Waiver")) {
                            rider.riderSA = null;
                          }
                        }
                      }

                      var setRiderInput = <String?, dynamic>{};

                      if ((riderVPMS.inputTerm != null &&
                              riderVPMS.inputTerm != "") &&
                          (rider.riderTerm != null && rider.riderTerm != "")) {
                        setRiderInput.putIfAbsent(
                            riderVPMS.inputTerm, () => rider.riderTerm);
                      }

                      if (riderVPMS.indicator == "A_ACI_IND") {
                        setRiderInput.putIfAbsent(
                            riderVPMS.indicator, () => "Y");
                        if (rider.riderSA != null) {
                          setRiderInput.putIfAbsent(
                              riderVPMS.inputSa, () => rider.riderSA);
                        }
                      } else {
                        if ((riderVPMS.inputPlan != null &&
                                riderVPMS.inputPlan != "") &&
                            (rider.riderPlan != null &&
                                rider.riderPlan != "")) {
                          setRiderInput.putIfAbsent(
                              riderVPMS.inputPlan, () => rider.riderPlan);
                        }
                        setRiderInput.putIfAbsent(
                            riderVPMS.indicator, () => "Y");
                        if ((rider.riderSA != null && rider.riderSA != "") &&
                            (riderVPMS.inputSa != null &&
                                riderVPMS.inputSa != "")) {
                          setRiderInput.putIfAbsent(
                              riderVPMS.inputSa, () => rider.riderSA);
                        }
                      }

                      setRiderInput.forEach((key, value) async {
                        if (key != "") {
                          vpmsinput.add([key, value]);
                          await setVPMSData(vpmsField: key, value: value);
                        }
                      });
                    }
                  }
                }

                var ilsavingVPMS = riderVPMSKey.firstWhereOrNull(
                    (element) => element.riderCode == quickQtn.productPlanCode);
                if (ilsavingVPMS != null) {
                  String indicator = riderOutputData
                          .any((element) => element.riderCode == "PCHI03")
                      ? "Y"
                      : "N";
                  if (ilsavingVPMS.indicator != "") {
                    vpmsinput.add([ilsavingVPMS.indicator, indicator]);
                    var vpmsdata = await setVPMSData(
                        vpmsField: ilsavingVPMS.indicator, value: indicator);
                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    }
                  }
                  if (basicPlanInput.gscoption != "") {
                    vpmsinput.add([
                      basicPlanInput.gscoption,
                      indicator == "N"
                          ? "N"
                          : quickQtn.guaranteedCashPayment == "1"
                              ? "Y"
                              : "N"
                    ]);
                    var vpmsdata = await setVPMSData(
                        vpmsField: basicPlanInput.gscoption,
                        value: indicator == "N"
                            ? "N"
                            : quickQtn.guaranteedCashPayment == "1"
                                ? "Y"
                                : "N");
                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    }
                  }
                }

                vpmsinput.add([
                  basicPlanInput.rtuPremium,
                  quickQtn.rtuPremiumAmount ?? ""
                ]);
                var vpmsdata = await setVPMSData(
                    vpmsField: basicPlanInput.rtuPremium,
                    value: quickQtn.rtuPremiumAmount ?? "");
                if (vpmsdata[0] != "") {
                  errorData.add(vpmsdata[0]);
                }

                /////////////////////////////////////////////////////
                /// GET VPMS OUTPUT ///
                /////////////////////////////////////////////////////

                var getBasicPlanOutput = [
                  basicPlanOutput.sumInsured,
                  basicPlanOutput.premiumTerm,
                  basicPlanOutput.policyTerm,
                  basicPlanOutput.premium,
                  basicPlanOutput.enricherSA,
                  basicPlanOutput.enricherPremiumTerm,
                  basicPlanOutput.enricherPolicyTerm,
                  basicPlanOutput.enricherPremium,
                  basicPlanOutput.rtuSA,
                  basicPlanOutput.rtuSAIOS,
                  basicPlanOutput.rtuPremiumTerm,
                  basicPlanOutput.rtuPolicyTerm,
                  basicPlanOutput.rtuPremium,
                  basicPlanOutput.adhocSA,
                ];

                for (int x = 0; x < getBasicPlanOutput.length; x++) {
                  if (getBasicPlanOutput[x] != null &&
                      getBasicPlanOutput[x] != "") {
                    var vpmsdata = await (setVPMSData(
                        vpmsField: getBasicPlanOutput[x], value: ""));
                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      fieldRequiredData.add(vpmsdata[1]);
                    } else {
                      vpmsoutput.add([getBasicPlanOutput[x], vpmsdata[2]]);
                      switch (x) {
                        case (0):
                          {
                            quickQtn.basicPlanSumInsured = vpmsdata[2];
                          }
                          break;
                        case (1):
                          {
                            quickQtn.basicPlanPaymentTerm = vpmsdata[2];
                          }
                          break;
                        case (2):
                          {
                            quickQtn.basicPlanPolicyTerm = vpmsdata[2];
                          }
                          break;
                        case (3):
                          {
                            quickQtn.basicPlanPremiumAmount = vpmsdata[2];
                          }
                          break;
                        case (4):
                          {
                            quickQtn.enricherSumInsured = vpmsdata[2];
                          }
                          break;
                        case (5):
                          {
                            quickQtn.enricherPaymentTerm = vpmsdata[2];
                          }
                          break;
                        case (6):
                          {
                            quickQtn.enricherPolicyTerm = vpmsdata[2];
                          }
                          break;
                        case (7):
                          {
                            quickQtn.enricherPremiumAmount = vpmsdata[2];
                          }
                          break;
                        case (8):
                          {
                            quickQtn.rtuSumInsured = vpmsdata[2];
                          }
                          break;
                        case (9):
                          {
                            quickQtn.rtuSAIOS = vpmsdata[2];
                          }
                          break;
                        case (10):
                          {
                            quickQtn.rtuPaymentTerm = vpmsdata[2];
                          }
                          break;
                        case (11):
                          {
                            quickQtn.rtuPolicyTerm = vpmsdata[2];
                          }
                          break;
                        case (12):
                          {
                            quickQtn.rtuPremiumAmount = vpmsdata[2];
                          }
                          break;
                        case (13):
                          {
                            quickQtn.adhocPremiumAmount = vpmsdata[2];
                          }
                          break;
                        default:
                          {
                            break;
                          }
                      }
                    }
                  }
                }
                ///////////////////////////////////////////////
                // GETTING TOTAL PREMIUM
                var premiumSummary = vpmsMapping.premiumSummary;
                if (premiumSummary != null) {
                  var totalPrem = [
                    premiumSummary.anb,
                    premiumSummary.maturityAge,
                    premiumSummary.basicContribution,
                    premiumSummary.totalPremium,
                    premiumSummary.totalPremiumIOS,
                    premiumSummary.minSumInsured,
                    premiumSummary.sam,
                    premiumSummary.totalFundAlloc,
                    premiumSummary.occLoad,
                    premiumSummary.totalPremOccLoad
                  ];

                  for (int x = 0; x < totalPrem.length; x++) {
                    if (totalPrem[x] != null && totalPrem[x]!.isNotEmpty) {
                      var vpmsdata = await (setVPMSData(
                          vpmsField: totalPrem[x], value: ""));
                      vpmsoutput.add([totalPrem[x], vpmsdata[2]]);
                      if (vpmsdata[0] != "") {
                        errorData.add(vpmsdata[0]);
                      } else if (vpmsdata[1] != "") {
                        fieldRequiredData.add(vpmsdata[1]);
                      } else {
                        if (x == 0) {
                          quickQtn.anb = vpmsdata[2];
                        } else if (x == 1) {
                          quickQtn.maturityAge = vpmsdata[2];
                        } else if (x == 2) {
                          quickQtn.basicContribution = vpmsdata[2];
                        } else if (x == 3) {
                          if (quickQtn.adhocAmt != null ||
                              quickQtn.adhocAmt != "0") {
                            var calculatePremiumAdhoc =
                                double.parse(vpmsdata[2]) +
                                    double.parse(quickQtn.adhocAmt ?? "0.00");
                            totalPremium = calculatePremiumAdhoc.toString();
                          } else {
                            totalPremium = vpmsdata[2];
                          }
                        } else if (x == 4) {
                          quickQtn.basicPlanTotalPremiumIOS = vpmsdata[2];
                        } else if (x == 5) {
                          quickQtn.minsa = vpmsdata[2];
                        } else if (x == 6) {
                          quickQtn.sam = vpmsdata[2];
                        } else if (x == 7) {
                          quickQtn.totalFundAlloc = vpmsdata[2];
                        } else if (x == 8) {
                          quickQtn.occLoad = vpmsdata[2];
                        } else if (x == 9) {
                          quickQtn.totalPremOccLoad = vpmsdata[2];
                        }
                      }
                    }
                  }
                  int anb = event.qtn.lifeInsured!.age! + 1;
                  quickQtn.anb ??= anb.toString();

                  var anb2 = int.parse(quickQtn.anb!);
                  quickQtn.basicPlanPolicyTerm ??= quickQtn.policyTerm;
                  var policyterm = int.parse(quickQtn.basicPlanPolicyTerm!);

                  int maturityage = anb2 + policyterm;

                  if (quickQtn.productPlanCode == "PCEE01" ||
                      quickQtn.productPlanCode == "PCEL01" ||
                      quickQtn.productPlanCode == "PCWA01" ||
                      quickQtn.productPlanCode == "PCTA01") {
                    quickQtn.maturityAge ??= maturityage.toString();
                  }
                }
                ///////////////////////////////////////////////
                // GETTING RIDER DATA

                var outRiderData = vpmsMapping.vpmsProdFieldsList;
                for (var rider in riderOutputData) {
                  if (rider.tempSA != null) {
                    rider.riderSA = rider.tempSA;
                  }

                  var riderOutputVPMS = outRiderData!.firstWhereOrNull(
                      (element) =>
                          element.riderCode == rider.riderCode ||
                          element.riderCode == rider.childCode);
                  if (riderOutputVPMS != null) {
                    var setRiderOutput = [
                      riderOutputVPMS
                          .outputPremPaymentTerm, // Rider Payment Term
                      riderOutputVPMS.outputTerm, // Rider output term
                      riderOutputVPMS.outputRiderType, // Rider type
                      riderOutputVPMS.outputSa, // Rider out sum insured
                      riderOutputVPMS.outputPremium, // Rider Premium
                      riderOutputVPMS.notionalPremium, // Notional Premium
                      riderOutputVPMS.outputSAIOS
                    ];

                    if (rider.riderCode!.contains("RCIMP")) {
                      setRiderOutput.addAll(
                          ["P_EMR_Plus_SA_Plan", "P_EMR_Plus_SA_Coverage"]);
                    }

                    if (rider.riderCode!.contains("RTIMP")) {
                      setRiderOutput.addAll(
                          ["P_EMR_Plus_SA_Plan", "P_EMR_Plus_SA_Coverage"]);
                    }

                    for (int x = 0; x < setRiderOutput.length; x++) {
                      if (setRiderOutput[x] != null &&
                          setRiderOutput[x] != "") {
                        var vpmsdata = await (setVPMSData(
                            vpmsField: setRiderOutput[x], value: ""));

                        vpmsoutput.add([setRiderOutput[x], vpmsdata[2]]);
                        if (vpmsdata[0] != "") {
                          errorData.add(vpmsdata[0]);
                        } else if (vpmsdata[1] != "") {
                          fieldRequiredData.add(vpmsdata[1]);
                        } else {
                          if (x == 0) {
                            if (rider.riderCode == "PCHI03" ||
                                rider.riderCode == "PTHI01") {
                              quickQtn.gcpPremTerm = vpmsdata[2];
                            }
                            rider.riderPaymentTerm = vpmsdata[2];
                          } else if (x == 1) {
                            if (rider.riderCode == "PCHI03" ||
                                rider.riderCode == "PTHI01") {
                              quickQtn.gcpTerm = vpmsdata[2];
                            }
                            rider.riderOutputTerm = vpmsdata[2];
                          } else if (x == 2) {
                            rider.riderType = vpmsdata[2];
                          } else if (x == 3) {
                            rider.riderSA = vpmsdata[2];
                          } else if (x == 4) {
                            if (rider.riderCode == "PCHI03" ||
                                rider.riderCode == "PTHI01") {
                              quickQtn.gcpPremAmt = vpmsdata[2];
                            }
                            rider.riderMonthlyPremium = vpmsdata[2];
                          } else if (x == 5) {
                            rider.riderNotionalPrem = vpmsdata[2];
                          } else if (x == 6) {
                            rider.riderSAIOS = vpmsdata[2];
                          }
                        }
                      }
                    }
                  }
                }
                quickQtn.riderOutputDataList = riderOutputData;
                ///////////////////////////////////////////////
                // GETTING FUND DATA

                var outFundData = vpmsMapping.fundList;

                for (var fund in fundOutputData!) {
                  var fundOutputVPMS = outFundData!.firstWhereOrNull(
                      (element) => element.code == fund.fundCode);

                  if (fundOutputVPMS != null) {
                    var fundVPMSOutput = fundOutputVPMS.vpmsOutput;
                    if (fundVPMSOutput != "") {
                      var vpmsdata = await (setVPMSData(
                          vpmsField: fundVPMSOutput, value: ""));
                      vpmsoutput.add([fundVPMSOutput, vpmsdata[2]]);
                      if (vpmsdata[0] != "") {
                        errorData.add(vpmsdata[0]);
                      } else if (vpmsdata[1] != "") {
                        fieldRequiredData.add(vpmsdata[1]);
                      } else {
                        fund.fundAlloc = vpmsdata[2];
                      }
                    }
                  }
                }
                quickQtn.fundOutputDataList = fundOutputData;
                //////////////////////////////////////////////////
                /// GETTING SI TABLE DATA

                var outTableData = vpmsMapping.siTableData!;
                List<List<String>?> vpmsOutputData = [];

                for (int i = 0; i < outTableData.length; i++) {
                  if (outTableData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outTableData[i], value: "");
                    vpmsoutput.add([outTableData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (fieldRequiredData.contains(vpmsdata[1])) {
                      } else {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      vpmsOutputData.add(data);
                    }
                  }
                }

                quickQtn.siTableData = vpmsOutputData;

                var outTableGHCData = vpmsMapping.gsc!;
                List<List<String>?> gscoutput = [];

                for (int i = 0; i < outTableGHCData.length; i++) {
                  if (outTableGHCData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outTableGHCData[i], value: "");
                    vpmsoutput.add([outTableGHCData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (fieldRequiredData.contains(vpmsdata[1])) {
                      } else {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      gscoutput.add(data);
                    }
                  }
                }

                quickQtn.siTableGSC = gscoutput;

                var outTableWakalahData = vpmsMapping.wakalah!;
                List<List<String>?> wakalahoutput = [];

                for (int i = 0; i < outTableWakalahData.length; i++) {
                  if (outTableWakalahData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outTableWakalahData[i], value: "");
                    vpmsoutput.add([outTableWakalahData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (fieldRequiredData.contains(vpmsdata[1])) {
                      } else {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      wakalahoutput.add(data);
                    }
                  }
                }

                quickQtn.siTableWakalah = wakalahoutput;

                //////////////////////////////////////////////////
                /// GETTING SURRENDER CHARGE TABLE DATA

                var outSurrenderChargeTableData =
                    vpmsMapping.surrenderChargeTableData!;
                List<List<String>?> surrenderChargeOutputData = [];

                for (int i = 0; i < outSurrenderChargeTableData.length; i++) {
                  if (outSurrenderChargeTableData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outSurrenderChargeTableData[i], value: "");
                    vpmsoutput
                        .add([outSurrenderChargeTableData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (fieldRequiredData.contains(vpmsdata[1])) {
                      } else {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      surrenderChargeOutputData.add(data);
                    }
                  }
                }

                quickQtn.surrenderChargeTableData = surrenderChargeOutputData;

                //////////////////////////////////////////////////
                /// GETTING FUND FEE TABLE DATA

                List<List<String>?> fundFeeOutputData = [];
                var outFundFeeTableData = vpmsMapping.fundFeeTableData;
                if (outFundFeeTableData != null) {
                  for (int i = 0; i < outFundFeeTableData.length; i++) {
                    if (outFundFeeTableData[i] != "") {
                      var vpmsdata = await setVPMSData(
                          vpmsField: outFundFeeTableData[i], value: "");
                      vpmsoutput.add([outFundFeeTableData[i], vpmsdata[2]]);

                      if (vpmsdata[0] != "") {
                        errorData.add(vpmsdata[0]);
                      } else if (vpmsdata[1] != "") {
                        if (fieldRequiredData.contains(vpmsdata[1])) {
                        } else {
                          fieldRequiredData.add(vpmsdata[1]);
                        }
                      } else if (vpmsdata[2] != "") {
                        final data = vpmsdata[2].split("|");
                        fundFeeOutputData.add(data);
                      }
                    }
                  }
                }

                quickQtn.fundFeeTableData = fundFeeOutputData;

                //////////////////////////////////////////////////
                /// GETTING SUSTAINABILITY PERIOD TABLE DATA

                var outSustainabilityPeriodTableData =
                    vpmsMapping.sustainabilityPeriodTableData!;

                List<List<String>?> sustainabilityPeriod = [];

                for (int i = 0;
                    i < outSustainabilityPeriodTableData.length;
                    i++) {
                  if (outSustainabilityPeriodTableData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outSustainabilityPeriodTableData[i],
                        value: "");
                    vpmsoutput.add(
                        [outSustainabilityPeriodTableData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (fieldRequiredData.contains(vpmsdata[1])) {
                      } else {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      sustainabilityPeriod.add(data);
                    }
                  }
                }

                quickQtn.sustainabilityPeriodTableData = sustainabilityPeriod;

                //////////////////////////////////////////////////
                /// GETTING HISTORICAL FUND TABLE DATA

                var outHistoricalFundTableData =
                    vpmsMapping.historicalFundTableData!;
                List<List<String>?> historicalFundTableData = [];

                for (int i = 0; i < outHistoricalFundTableData.length; i++) {
                  if (outHistoricalFundTableData[i] != "") {
                    var vpmsdata = await setVPMSData(
                        vpmsField: outHistoricalFundTableData[i], value: "");
                    vpmsoutput
                        .add([outHistoricalFundTableData[i], vpmsdata[2]]);

                    if (vpmsdata[0] != "") {
                      errorData.add(vpmsdata[0]);
                    } else if (vpmsdata[1] != "") {
                      if (!fieldRequiredData.contains(vpmsdata[1])) {
                        fieldRequiredData.add(vpmsdata[1]);
                      }
                    } else if (vpmsdata[2] != "") {
                      final data = vpmsdata[2].split("|");
                      historicalFundTableData.add(data);
                    }
                  }
                }

                //////////////////////////////////////////////////
                /// GETTING WORDING IN SI ILLUSTRATION

                var wordingsiillustrationoutput =
                    vpmsMapping.wordingSiIllustrationOutput!;

                for (int x = 0; x < wordingsiillustrationoutput.length; x++) {
                  if (wordingsiillustrationoutput[x] != "") {
                    var vpmsdata = await (setVPMSData(
                        vpmsField: wordingsiillustrationoutput[x], value: ""));
                    vpmsoutput
                        .add([wordingsiillustrationoutput[x], vpmsdata[2]]);
                  }
                }

                //////////////////////////////////////////////////
                /// GETTING WORDING IN INPUT SHEET

                var noticewordinginputsheetoutput =
                    vpmsMapping.noticeWordingInputSheetOutput!;

                for (int x = 0; x < noticewordinginputsheetoutput.length; x++) {
                  if (noticewordinginputsheetoutput[x] != "") {
                    var vpmsdata = await (setVPMSData(
                        vpmsField: noticewordinginputsheetoutput[x],
                        value: ""));
                    vpmsoutput
                        .add([noticewordinginputsheetoutput[x], vpmsdata[2]]);
                  }
                }

                //////////////////////////////////////////////////
                /// GETTING PDS TABLE DATA

                var pdsvpmsoutput = vpmsMapping.pds!;

                for (int x = 0; x < pdsvpmsoutput.length; x++) {
                  if (pdsvpmsoutput[x] != "") {
                    var vpmsdata = await (setVPMSData(
                        vpmsField: pdsvpmsoutput[x], value: ""));
                    vpmsoutput.add([pdsvpmsoutput[x], vpmsdata[2]]);
                  }
                }

                var basicOutput = vpmsMapping.basicOutput!;
                for (int x = 0; x < basicOutput.length; x++) {
                  if (basicOutput[x] != "") {
                    var vpmsdata = await (setVPMSData(
                        vpmsField: basicOutput[x], value: ""));
                    vpmsoutput.add([basicOutput[x], vpmsdata[2]]);
                  }
                }

                quickQtn.historicalFundTableData = historicalFundTableData;
                quickQtn.vpmsinput = vpmsinput;
                quickQtn.vpmsoutput = vpmsoutput;
              }

              if (result["error"] != null) {
                if (data["saLimit"] != null) {
                  emit(ChooseProductErrorDialog(
                      totalPremium!, quickQtn, data, result["error"]));
                } else {
                  emit(ChooseProductErrorDialog(totalPremium!, quickQtn, data,
                      data["caseindicator"] ?? result["error"]));
                  emit(PremiumChecked(
                      totalPremium: totalPremium!,
                      quickQuotation: quickQtn,
                      caseindicator: data["caseindicator"]));
                }
              } else {
                analytics("viewItem", quickQtn, riderOutputData, totalPremium);
                emit(ChooseProductErrorDialog(totalPremium!, quickQtn, data,
                    data["caseindicator"] ?? result["error"]));
                emit(PremiumChecked(
                    totalPremium: totalPremium!,
                    quickQuotation: quickQtn,
                    caseindicator: data["caseindicator"]));
              }
            });
          }
        } else {
          emit(PremiumChecked(
              totalPremium: totalPremium!, quickQuotation: quickQtn));
        }
      }
    }
  }
}

void analytics(
    String action, QuickQuotation quickQtn, riderOutputData, totalPremium) {
  List<AnalyticsEventItem> items = [];
  items.add(AnalyticsEventItem(
      itemId: quickQtn.productPlanCode,
      itemName: quickQtn.productPlanName,
      price: double.tryParse(quickQtn.premAmt!)));
  if (quickQtn.enricherPremiumAmount != "0.00") {
    items.add(AnalyticsEventItem(
        itemId: "RCTE02",
        itemName: "Enricher",
        price: quickQtn.enricherPremiumAmount != null
            ? double.tryParse(quickQtn.enricherPremiumAmount!)
            : 0));
  }
  if (quickQtn.rtuAmt == null) {
    quickQtn.rtuAmt = "0";
    items.add(AnalyticsEventItem(
        itemId: "RCITU4",
        itemName: "Regular Top-Up",
        price: double.tryParse(quickQtn.rtuAmt!)));
  } else if (quickQtn.rtuAmt != "0" && quickQtn.rtuAmt != "0.00") {
    items.add(AnalyticsEventItem(
        itemId: "RCITU4",
        itemName: "Regular Top-Up",
        price: double.tryParse(quickQtn.rtuAmt!)));
  }
  for (var element in riderOutputData) {
    items.add(AnalyticsEventItem(
        itemId: element.riderName,
        itemName: element.riderName,
        price: isNumeric(element.riderMonthlyPremium)
            ? double.parse(element.riderMonthlyPremium!)
            : 0));
  }

  if (action == "viewItem") {
    FirebaseAnalytics.instance.logViewItem(
        currency: "RM", value: double.parse(totalPremium), items: items);
  } else if (action == "addToCart") {
    FirebaseAnalytics.instance.logAddToCart(
        currency: "RM", value: double.parse(totalPremium), items: items);
  }
}

void _setStateToPremiumChecked(
    CheckPremiumUW event, Emitter<ChooseProductState> emit) async {
  event.quickqtn.caseindicator = event.caseindicator;
  emit(PremiumChecked(
      totalPremium: event.totalPremium,
      quickQuotation: event.quickqtn,
      caseindicator: event.caseindicator));
}

void _mapGeneratePDFToState(
    GenerateSIPDF event, Emitter<ChooseProductState> emit) async {
  emit(PdfGenerated(
      quotation: event.quotation, quickQuotation: event.quickQuotation));
}

void _mapDuplicateQuotationToState(
    DuplicateQuotation event, Emitter<ChooseProductState> emit) async {
  emit(QuotationDuplicated(quickQuotationData: event.quickQuotationData));
}

void _mapEditQuotationToState(
    EditQuotation event, Emitter<ChooseProductState> emit) async {
  int? age = getAgeString(event.quotation.lifeInsured!.dob!, false);
  String? gender = event.quotation.lifeInsured!.gender;
  String dob = event.quotation.lifeInsured!.dob!;
  bool? deductSalary = event.quickQuotation.deductSalary;
  ProductPlan? productPlan;
  VpmsMapping? vpmsMapping;

  String? prodCode = event.quickQuotation.productPlanCode;
  if (prodCode != null) {
    productPlan = await ProductPlanRepositoryImpl()
        .getProductPlanSetupByProdCode(prodCode);
    vpmsMapping = await getVPMSMappingData(prodCode);
    bool haveEnricher = await checkSteppedPremium(productPlan);

    if (prodCode == "PCEL01" || prodCode == "PCEE01") {
      if (event.quotation.buyingFor != BuyingFor.self.toStr) {
        age = getAgeString(event.quotation.policyOwner!.dob!, false);
        gender = event.quotation.policyOwner!.gender;
        dob = event.quotation.policyOwner!.dob!;
      }
    }

    emit(EditingQuotation(
        age: age,
        gender: gender,
        dob: dob,
        deductSalary: deductSalary,
        quotation: event.quotation,
        quickQuotation: event.quickQuotation,
        selectedPlan: productPlan,
        vpmsMappingFile: vpmsMapping,
        haveEnricher: haveEnricher));
  } else {
    emit(EditingQuotation(
        age: age,
        gender: gender,
        dob: dob,
        deductSalary: deductSalary,
        quotation: event.quotation,
        quickQuotation: event.quickQuotation));
  }
}
