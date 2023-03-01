import 'package:ease/src/data/new_business_model/fund_output_data.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/rider_output_data.dart';

// Quick Quotation Status
// 1 - Active
// 2 - Expired (Cannot proceed to application. Can view)
// 3 - Expired (Cannot proceed to application. Will prompt dialog straightaway at View Quotation)

class QuickQuotation {
  String? quickQuoteId;
  // Input
  String? dateTime;
  bool isCampaign;
  Campaign? campaign;
  String? productPlanLOB;
  String? productPlanCode;
  String? productPlanName;
  bool? isSteppedPremium;
  String? sustainabilityOption;
  String? calcBasedOn;
  String? paymentMode;
  String? premiumTerm;
  String? policyTerm;
  String? planDetail;
  String? sumInsuredAmt;
  String? premAmt;
  String? rtuAmt;
  String? adhocAmt;
  bool deductSalary;
  String? guaranteedCashPayment;
  // Output
  String? vpmsVersion;
  List<ProductPlan>? eligibleRiders;
  String? basicPlanSumInsured;
  String? basicPlanPaymentTerm;
  String? basicPlanPolicyTerm;
  String? basicPlanPremiumAmount;
  String? enricherSumInsured;
  String? enricherPaymentTerm;
  String? enricherPolicyTerm;
  String? enricherPremiumAmount;
  String? rtuSumInsured;
  String? rtuSAIOS;
  String? rtuPaymentTerm;
  String? rtuPolicyTerm;
  String? rtuPremiumAmount;
  String? adhocPremiumAmount;
  String? gcpPremTerm;
  String? gcpPremAmt;
  String? gcpTerm;
  String? anb;
  String? maturityAge;
  String? basicContribution;
  String? totalPremium;
  String? basicPlanTotalPremiumIOS;
  String? minsa;
  String? sam;
  String? totalFundAlloc;
  String? occLoad;
  String? totalPremOccLoad;
  List<RiderOutputData>? riderOutputDataList;
  List<FundOutputData>? fundOutputDataList;
  List<List<String>?>? siTableData;
  List<List<String>?>? siTableGSC;
  List<List<String>?>? siTableWakalah;
  List<List<String>?>? surrenderChargeTableData;
  List<List<String>?>? fundFeeTableData;
  List<List<String>?>? sustainabilityPeriodTableData;
  List<List<String>?>? historicalFundTableData;
  List<List<String?>>? vpmsinput;
  List<List<String?>>? vpmsoutput;
  // Status
  String? existingPolicy;
  String? caseindicator;
  String? lastUpdatedTime;
  String? status;
  String? progress;
  bool? isReadyToUpload;
  bool? isSavedOnServer;
  bool? isDeleted;
  int? quotationHistoryID;
  String? version;

  QuickQuotation(
      {this.quickQuoteId,
      this.dateTime,
      this.isCampaign = false,
      this.campaign,
      this.productPlanLOB,
      this.productPlanCode,
      this.productPlanName,
      this.isSteppedPremium,
      this.sustainabilityOption,
      this.calcBasedOn,
      this.paymentMode,
      this.premiumTerm,
      this.planDetail,
      this.policyTerm,
      this.sumInsuredAmt,
      this.premAmt,
      this.rtuAmt,
      this.adhocAmt,
      this.deductSalary = false,
      this.guaranteedCashPayment,
      this.vpmsVersion,
      this.eligibleRiders,
      this.basicPlanSumInsured,
      this.basicPlanPaymentTerm,
      this.basicPlanPolicyTerm,
      this.basicPlanPremiumAmount,
      this.enricherSumInsured,
      this.enricherPaymentTerm,
      this.enricherPolicyTerm,
      this.enricherPremiumAmount,
      this.rtuSumInsured,
      this.rtuSAIOS,
      this.rtuPaymentTerm,
      this.rtuPolicyTerm,
      this.rtuPremiumAmount,
      this.adhocPremiumAmount,
      this.gcpPremTerm,
      this.gcpPremAmt,
      this.gcpTerm,
      this.anb,
      this.maturityAge,
      this.basicContribution,
      this.totalPremium,
      this.basicPlanTotalPremiumIOS,
      this.minsa,
      this.sam,
      this.totalFundAlloc,
      this.occLoad,
      this.totalPremOccLoad,
      this.riderOutputDataList,
      this.fundOutputDataList,
      this.siTableData,
      this.siTableGSC,
      this.siTableWakalah,
      this.surrenderChargeTableData,
      this.fundFeeTableData,
      this.sustainabilityPeriodTableData,
      this.historicalFundTableData,
      this.vpmsinput,
      this.vpmsoutput,
      this.existingPolicy,
      this.caseindicator,
      this.lastUpdatedTime,
      this.status,
      this.progress,
      this.isReadyToUpload,
      this.isSavedOnServer,
      this.isDeleted,
      this.quotationHistoryID,
      this.version});

  static QuickQuotation fromMap(Map<String, dynamic> map) {
    return QuickQuotation(
        quickQuoteId: map['quickQuoteId'],
        dateTime: map['dateTime'],
        isCampaign: map['isCampaign'] ?? false,
        campaign: map['campaign'] != null && map['campaign'].isNotEmpty
            ? Campaign.fromMap(map['campaign'])
            : Campaign(prodCode: "default"),
        productPlanLOB: map['productPlanLOB'],
        productPlanCode: map['productPlanCode'],
        productPlanName: map['productPlanName'],
        isSteppedPremium: map['isSteppedPremium'] ?? false,
        sustainabilityOption: map['sustainabilityOption'] as String?,
        calcBasedOn: map['calcBasedOn'],
        paymentMode: map['paymentMode'] as String?,
        premiumTerm: map['premiumTerm'] as String?,
        planDetail: map['planDetail'] as String?,
        policyTerm: map['policyTerm'] as String?,
        sumInsuredAmt: map['sumInsuredAmt'] as String?,
        premAmt: map['premAmt'] as String?,
        rtuAmt: map['rtuAmt'] as String?,
        adhocAmt: map['adhocAmt'] as String?,
        deductSalary: map['deductSalary'],
        guaranteedCashPayment: map['guaranteedCashPayment'],
        vpmsVersion: map['vpmsVersion'],
        eligibleRiders: map['eligibleRiders'] != null
            ? map['eligibleRiders']
                .map((mapping) => ProductPlan.fromMap(mapping))
                .toList()
                .cast<ProductPlan>()
            : [],
        basicPlanSumInsured: map['basicPlanSumInsured'],
        basicPlanPaymentTerm: map['basicPlanPaymentTerm'],
        basicPlanPolicyTerm: map['basicPlanPolicyTerm'],
        basicPlanPremiumAmount: map['basicPlanPremiumAmount'],
        enricherSumInsured: map['enricherSumInsured'],
        enricherPaymentTerm: map['enricherPaymentTerm'],
        enricherPolicyTerm: map['enricherPolicyTerm'],
        enricherPremiumAmount: map['enricherPremiumAmount'],
        rtuSumInsured: map['rtuSumInsured'],
        rtuSAIOS: map['rtuSAIOS'],
        rtuPaymentTerm: map['rtuPaymentTerm'],
        rtuPolicyTerm: map['rtuPolicyTerm'],
        rtuPremiumAmount: map['rtuPremiumAmount'],
        adhocPremiumAmount: map['adhocPremiumAmount'],
        gcpPremTerm: map['gcpPremTerm'],
        gcpPremAmt: map['gcpPremAmt'],
        gcpTerm: map['gcpTerm'],
        anb: map['anb'],
        maturityAge: map['maturityAge'],
        basicContribution: map['basicContribution'],
        totalPremium: map['totalPremium'],
        basicPlanTotalPremiumIOS: map['basicPlanTotalPremiumIOS'],
        minsa: map['minsa'],
        sam: map['sam'],
        totalFundAlloc: map['totalFundAlloc'],
        occLoad: map['occLoad'],
        totalPremOccLoad: map['totalPremOccLoad'],
        riderOutputDataList: map['riderOutputDataList']
            .map((mapping) => RiderOutputData.fromMap(mapping))
            .toList()
            .cast<RiderOutputData>(),
        fundOutputDataList: map['fundOutputDataList']
            .map((mapping) => FundOutputData.fromMap(mapping))
            .toList()
            .cast<FundOutputData>(),
        siTableData: List<List<String>>.from(
            map["siTableData"].map((x) => List<String>.from(x.map((x) => x)))),
        siTableGSC: map["siTableGSC"] != null
            ? List<List<String>>.from(map["siTableGSC"]
                .map((x) => List<String>.from(x.map((x) => x))))
            : [],
        siTableWakalah: map["siTableWakalah"] != null
            ? List<List<String>>.from(map["siTableWakalah"]
                .map((x) => List<String>.from(x.map((x) => x))))
            : [],
        surrenderChargeTableData:
            List<List<String>>.from(map["surrenderChargeTableData"].map((x) => List<String>.from(x.map((x) => x)))),
        fundFeeTableData: List<List<String>>.from(map["fundFeeTableData"].map((x) => List<String>.from(x.map((x) => x)))),
        sustainabilityPeriodTableData: List<List<String>>.from(map["sustainabilityPeriodTableData"].map((x) => List<String>.from(x.map((x) => x)))),
        historicalFundTableData: List<List<String>>.from(map["historicalFundTableData"].map((x) => List<String>.from(x.map((x) => x)))),
        vpmsinput: List<List<String>>.from(map["vpmsinput"].map((x) => List<String>.from(x != null ? x.map((x) => x) : []))),
        vpmsoutput: List<List<String>>.from(map["vpmsoutput"].map((x) => List<String>.from(x.map((x) => x)))),
        existingPolicy: map['existingPolicy'],
        caseindicator: map['caseindicator'],
        lastUpdatedTime: map['lastUpdatedTime'],
        status: map['status'],
        progress: map['progress'],
        isReadyToUpload: map['isReadyToUpload'] ?? false,
        isSavedOnServer: map['isSavedOnServer'] ?? false,
        isDeleted: map['isDeleted'] ?? false,
        quotationHistoryID: map['QuotationHistoryID'],
        version: map['version']);
  }

  Map<String, dynamic> toMap() {
    return {
      'quickQuoteId': quickQuoteId,
      'dateTime': dateTime,
      'isCampaign': isCampaign,
      'campaign': campaign != null && campaign!.prodCode != null
          ? campaign!.toMap()
          : {
              "Id": null,
              "ProdCode": "default",
              "ProdVersion": null,
              "MinPremiumTermFrom": null,
              "StartDate": null,
              "EndDate": null,
              "IsActive": null
            },
      'productPlanLOB': productPlanLOB,
      'productPlanCode': productPlanCode,
      'productPlanName': productPlanName,
      'isSteppedPremium': isSteppedPremium,
      'sustainabilityOption': sustainabilityOption,
      'calcBasedOn': calcBasedOn,
      'paymentMode': paymentMode,
      'premiumTerm': premiumTerm,
      'planDetail': planDetail,
      'policyTerm': policyTerm,
      'sumInsuredAmt': sumInsuredAmt,
      'premAmt': premAmt,
      'rtuAmt': rtuAmt,
      'adhocAmt': adhocAmt,
      'deductSalary': deductSalary,
      'guaranteedCashPayment': guaranteedCashPayment ?? "",
      'vpmsVersion': vpmsVersion,
      'eligibleRiders': eligibleRiders != null
          ? eligibleRiders!.map((data) => data.toJson()).toList(growable: false)
          : [],
      'basicPlanSumInsured': basicPlanSumInsured,
      'basicPlanPaymentTerm': basicPlanPaymentTerm,
      'basicPlanPolicyTerm': basicPlanPolicyTerm,
      'basicPlanPremiumAmount': basicPlanPremiumAmount,
      'enricherSumInsured': enricherSumInsured,
      'enricherPaymentTerm': enricherPaymentTerm,
      'enricherPolicyTerm': enricherPolicyTerm,
      'enricherPremiumAmount': enricherPremiumAmount,
      'rtuSumInsured': rtuSumInsured,
      'rtuSAIOS': rtuSAIOS,
      'rtuPaymentTerm': rtuPaymentTerm,
      'rtuPolicyTerm': rtuPolicyTerm,
      'rtuPremiumAmount': rtuPremiumAmount,
      'adhocPremiumAmount': adhocPremiumAmount,
      'gcpPremTerm': gcpPremTerm,
      'gcpPremAmt': gcpPremAmt,
      'gcpTerm': gcpTerm,
      'anb': anb,
      'maturityAge': maturityAge,
      'basicContribution': basicContribution,
      'totalPremium': totalPremium,
      'basicPlanTotalPremiumIOS': basicPlanTotalPremiumIOS,
      'minsa': minsa,
      'sam': sam,
      'totalFundAlloc': totalFundAlloc,
      'occLoad': occLoad,
      'totalPremOccLoad': totalPremOccLoad,
      'riderOutputDataList': riderOutputDataList != null
          ? riderOutputDataList!
              .map((data) => data.toMap())
              .toList(growable: false)
          : [],
      'fundOutputDataList': fundOutputDataList != null
          ? fundOutputDataList!
              .map((data) => data.toMap())
              .toList(growable: false)
          : [],
      "siTableData": siTableData != null
          ? List<dynamic>.from(
              siTableData!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "siTableGSC": siTableGSC != null
          ? List<dynamic>.from(
              siTableGSC!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
          "siTableWakalah": siTableWakalah != null
          ? List<dynamic>.from(
              siTableWakalah!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "surrenderChargeTableData": surrenderChargeTableData != null
          ? List<dynamic>.from(surrenderChargeTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "fundFeeTableData": fundFeeTableData != null
          ? List<dynamic>.from(fundFeeTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "sustainabilityPeriodTableData": sustainabilityPeriodTableData != null
          ? List<dynamic>.from(sustainabilityPeriodTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "historicalFundTableData": historicalFundTableData != null
          ? List<dynamic>.from(historicalFundTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "vpmsinput": vpmsinput != null
          ? List<dynamic>.from(
              vpmsinput!.map((x) => List<dynamic>.from(x.map((x) => x))))
          : [],
      "vpmsoutput": vpmsoutput != null
          ? List<dynamic>.from(
              vpmsoutput!.map((x) => List<dynamic>.from(x.map((x) => x))))
          : [],
      'existingPolicy': existingPolicy,
      "caseindicator": caseindicator,
      'lastUpdatedTime': lastUpdatedTime,
      "status": status,
      'progress': progress,
      'isReadyToUpload': isReadyToUpload ?? false,
      'isSavedOnServer': isSavedOnServer ?? false,
      'isDeleted': isDeleted ?? false,
      'QuotationHistoryID': quotationHistoryID,
      "version": version
    };
  }

  Map<String, dynamic> toJsonServer() {
    return {
      'quickQuoteId': quickQuoteId,
      'dateTime': dateTime,
      'isCampaign': isCampaign,
      'campaign': campaign != null ? campaign!.toMap() : {},
      'productPlanLOB': productPlanLOB,
      'productPlanCode': productPlanCode,
      'productPlanName': productPlanName,
      'isSteppedPremium': isSteppedPremium,
      'sustainabilityOption': sustainabilityOption,
      'calcBasedOn': calcBasedOn,
      'paymentMode': paymentMode,
      'premiumTerm': premiumTerm,
      'planDetail': planDetail,
      'policyTerm': policyTerm,
      'sumInsuredAmt': sumInsuredAmt,
      'premAmt': premAmt,
      'rtuAmt': rtuAmt,
      'adhocAmt': adhocAmt,
      'deductSalary': deductSalary,
      'guaranteedCashPayment': guaranteedCashPayment ?? "",
      'vpmsVersion': vpmsVersion,
      'eligibleRiders': eligibleRiders != null
          ? eligibleRiders!.map((data) => data.toJson()).toList(growable: false)
          : [],
      'basicPlanSumInsured': basicPlanSumInsured,
      'basicPlanPaymentTerm': basicPlanPaymentTerm,
      'basicPlanPolicyTerm': basicPlanPolicyTerm,
      'basicPlanPremiumAmount': basicPlanPremiumAmount,
      'enricherSumInsured': enricherSumInsured,
      'enricherPaymentTerm': enricherPaymentTerm,
      'enricherPolicyTerm': enricherPolicyTerm,
      'enricherPremiumAmount': enricherPremiumAmount,
      'rtuSumInsured': rtuSumInsured,
      'rtuSAIOS': rtuSAIOS,
      'rtuPaymentTerm': rtuPaymentTerm,
      'rtuPolicyTerm': rtuPolicyTerm,
      'rtuPremiumAmount': rtuPremiumAmount,
      'adhocPremiumAmount': adhocPremiumAmount,
      'gcpPremTerm': gcpPremTerm,
      'gcpPremAmt': gcpPremAmt,
      'gcpTerm': gcpTerm,
      'anb': anb,
      'maturityAge': maturityAge,
      'basicContribution': basicContribution,
      'totalPremium': totalPremium,
      'basicPlanTotalPremiumIOS': basicPlanTotalPremiumIOS,
      'minsa': minsa,
      'sam': sam,
      'totalFundAlloc': totalFundAlloc,
      'occLoad': occLoad,
      'totalPremOccLoad': totalPremOccLoad,
      'riderOutputDataList': riderOutputDataList != null
          ? riderOutputDataList!
              .map((data) => data.toMap())
              .toList(growable: false)
          : [],
      'fundOutputDataList': fundOutputDataList != null
          ? fundOutputDataList!
              .map((data) => data.toMap())
              .toList(growable: false)
          : [],
      "siTableData": siTableData != null
          ? List<dynamic>.from(
              siTableData!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "siTableGSC": siTableGSC != null
          ? List<dynamic>.from(
              siTableGSC!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
          "siTableWakalah": siTableWakalah != null
          ? List<dynamic>.from(
              siTableWakalah!.map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "surrenderChargeTableData": surrenderChargeTableData != null
          ? List<dynamic>.from(surrenderChargeTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "fundFeeTableData": fundFeeTableData != null
          ? List<dynamic>.from(fundFeeTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "sustainabilityPeriodTableData": sustainabilityPeriodTableData != null
          ? List<dynamic>.from(sustainabilityPeriodTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "historicalFundTableData": historicalFundTableData != null
          ? List<dynamic>.from(historicalFundTableData!
              .map((x) => List<dynamic>.from(x!.map((x) => x))))
          : [],
      "vpmsinput": vpmsinput != null
          ? List<dynamic>.from(
              vpmsinput!.map((x) => List<dynamic>.from(x.map((x) => x))))
          : [],
      "vpmsoutput": vpmsoutput != null
          ? List<dynamic>.from(
              vpmsoutput!.map((x) => List<dynamic>.from(x.map((x) => x))))
          : [],
      'existingPolicy': existingPolicy,
      "caseindicator": caseindicator,
      'lastUpdatedTime': lastUpdatedTime,
      "status": status,
      'progress': progress,
      'isReadyToUpload': isReadyToUpload ?? false,
      'isSavedOnServer': isSavedOnServer ?? false,
      'isDeleted': isDeleted ?? false,
      'QuotationHistoryID': quotationHistoryID,
      "version": version
    };
  }
}

class VPMSINOUTPUT {
  String? riderName;
  String? riderCode;

  VPMSINOUTPUT({this.riderName, this.riderCode});

  factory VPMSINOUTPUT.fromMap(Map<String, dynamic> json) {
    return VPMSINOUTPUT(
        riderName: json['riderName'] ?? "", riderCode: json['riderCode']);
  }
  Map<String, dynamic> toMap() =>
      {'riderName': riderName ?? "", 'riderCode': riderCode};
}
