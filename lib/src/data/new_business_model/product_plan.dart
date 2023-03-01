import 'package:ease/src/data/new_business_model/funds.dart';
import 'package:ease/src/data/new_business_model/limited_payment_premium_list.dart';
import 'package:ease/src/data/new_business_model/min_premium_list.dart';
import 'package:ease/src/data/new_business_model/policy_term_list.dart';
import 'package:ease/src/data/new_business_model/rider.dart';
import 'package:ease/src/data/new_business_model/sum_assured_list.dart';
import 'package:ease/src/data/new_business_model/term_up_to_maturity.dart';

class ProductPlan {
  final ProductSetup? productSetup;
  final List<PolicyTermList>? policyTermList;
  final List<TermUpToMaturity>? maturityTermList;
  final List<SumAssuredList>? sumAssuredList;
  final List<MinPremiumList>? minPremiumList;
  List<RateScale>? rateScaleList;
  final List<Rider>? riderList;
  final List<Funds>? fundList;
  final List<LimitedPaymentPremium>? limitedPaymentPremiumList;
  final List<Campaign>? campaignList;
  final List<GAProduct>? gaProductList;

  ProductPlan(
      {this.productSetup,
      this.policyTermList,
      this.riderList,
      this.fundList,
      this.maturityTermList,
      this.sumAssuredList,
      this.minPremiumList,
      this.rateScaleList,
      this.limitedPaymentPremiumList,
      this.campaignList,
      this.gaProductList});

  factory ProductPlan.fromMap(Map<String, dynamic> map) {
    return ProductPlan(
        productSetup: ProductSetup.fromMap(map['ProductSetup']),
        policyTermList: List<PolicyTermList>.from(
            map["PolicyTermList"].map((x) => PolicyTermList.fromMap(x))),
        rateScaleList: map["RateScaleList"] != null
            ? List<RateScale>.from(
                map["RateScaleList"].map((x) => RateScale.fromMap(x)))
            : [],
        riderList:
            List<Rider>.from(map["RiderList"].map((x) => Rider.fromMap(x))),
        fundList:
            List<Funds>.from(map["FundList"].map((x) => Funds.fromMap(x))),
        maturityTermList: List<TermUpToMaturity>.from(map["TermUpToMaturityList"]
            .map((x) => TermUpToMaturity.fromMap(x))),
        sumAssuredList: List<SumAssuredList>.from(
            map["SumAssuredList"].map((x) => SumAssuredList.fromMap(x))),
        minPremiumList: List<MinPremiumList>.from(
            map["MinPremiumList"].map((x) => MinPremiumList.fromMap(x))),
        limitedPaymentPremiumList: map["LimitedPaymentPremiumList"] != null
            ? List<LimitedPaymentPremium>.from(map["LimitedPaymentPremiumList"]
                .map((x) => LimitedPaymentPremium.fromMap(x)))
            : [],
        campaignList: map["CampaignList"] != null ? List<Campaign>.from(map["CampaignList"].map((x) => Campaign.fromMap(x))) : [],
        gaProductList: map["GAProductList"] != null ? List<GAProduct>.from(map["GAProductList"].map((x) => GAProduct.fromMap(x))) : []);
  }

  Map<String, dynamic> toJson() => {
        'ProductSetup': productSetup!.toMap(),
        'PolicyTermList': policyTermList != null
            ? policyTermList!
                .map((data) => data.toMap())
                .toList(growable: false)
            : [],
        'RiderList': riderList != null
            ? riderList!.map((data) => data.toMap()).toList(growable: false)
            : [],
        'RateScaleList': rateScaleList != null
            ? rateScaleList!.map((data) => data.toMap()).toList(growable: false)
            : [],
        'FundList': fundList != null
            ? fundList!.map((data) => data.toMap()).toList(growable: false)
            : [],
        'TermUpToMaturityList': maturityTermList != null
            ? maturityTermList!
                .map((data) => data.toMap())
                .toList(growable: false)
            : [],
        'SumAssuredList': sumAssuredList != null
            ? sumAssuredList!
                .map((data) => data.toMap())
                .toList(growable: false)
            : [],
        'MinPremiumList': minPremiumList != null
            ? minPremiumList!
                .map((data) => data.toMap())
                .toList(growable: false)
            : [],
        'LimitedPaymentPremiumList': limitedPaymentPremiumList != null
            ? limitedPaymentPremiumList!
                .map((data) => data.toMap())
                .toList(growable: false)
            : [],
        'CampaignList': campaignList != null
            ? campaignList!.map((data) => data.toMap()).toList(growable: false)
            : [],
        'GAProductList': gaProductList != null
            ? gaProductList!.map((data) => data.toMap()).toList(growable: false)
            : []
      };
}

class ProductSetup {
  final String? productSetupId;
  String? prodCode;
  final int? prodVersion;
  String? prodName;
  final String? prodShortName;
  final String? prodStatus;
  final String? prodType;
  final String? effDt;
  final String? ceaseDt;
  final int? lob;
  final String? type;
  final bool? isTakaful;
  final int? premiumType;
  final String? premiumBasis;
  final String? gender;
  final String? prodNameBMY;
  final String? prodShortNameBMY;
  final String? ageCalculationBasis;
  final String? currency;
  final bool? isAdvLumpsum;
  final bool? isUnitBasedProd;
  final double? amtPerUnit;
  final bool? isJuvenile;
  final int? childEntryAge;
  final int? maxChildEntryAge;
  final String? ageUnit;
  final bool? isRateScale;
  final bool? isFixedTerm;
  final String? maturityType;
  final bool? isJoinedLife;
  final int? ageCalculation;
  final bool? isParticipating;
  final bool? isWOP;
  final String? premiumTermType;
  final bool? isRiderFixedTerm;
  final bool? isPOMandatory;
  final int? lAMaxAgePOMand;
  final String? fundOption;
  final String? vPMSFileName;
  final bool? isCustomPremVal;
  final String? lastStatusDate;
  final String? ageCalculationBasisDesc;
  final String? prodEffDt;
  final String? prodCloseDt;
  final bool? isPremTopupAllowed;
  final int? maxPremTopupAllowed;
  final double? minPremTopupAmt;
  final String? vPMSVersion;
  final bool? isPremiumFixedTerm;
  final bool? isFixedBasePremiumTerm;
  final bool? isFixedBasePolicyTerm;
  final bool? isSustainability;
  final bool? isExpiry;
  final bool? isShow;
  final String? blockedCountry;

  ProductSetup(
      {this.productSetupId,
      this.prodCode,
      this.prodVersion,
      this.prodName,
      this.prodShortName,
      this.prodStatus,
      this.prodType,
      this.effDt,
      this.ceaseDt,
      this.lob,
      this.type,
      this.isTakaful,
      this.premiumType,
      this.premiumBasis,
      this.gender,
      this.prodNameBMY,
      this.prodShortNameBMY,
      this.ageCalculationBasis,
      this.currency,
      this.isAdvLumpsum,
      this.isUnitBasedProd,
      this.amtPerUnit,
      this.isJuvenile,
      this.childEntryAge,
      this.maxChildEntryAge,
      this.ageUnit,
      this.isRateScale,
      this.isFixedTerm,
      this.maturityType,
      this.isJoinedLife,
      this.ageCalculation,
      this.isParticipating,
      this.isWOP,
      this.premiumTermType,
      this.isRiderFixedTerm,
      this.isPOMandatory,
      this.lAMaxAgePOMand,
      this.fundOption,
      this.vPMSFileName,
      this.isCustomPremVal,
      this.lastStatusDate,
      this.ageCalculationBasisDesc,
      this.prodEffDt,
      this.prodCloseDt,
      this.isPremTopupAllowed,
      this.maxPremTopupAllowed,
      this.minPremTopupAmt,
      this.vPMSVersion,
      this.isPremiumFixedTerm,
      this.isFixedBasePremiumTerm,
      this.isFixedBasePolicyTerm,
      this.isSustainability,
      this.isExpiry,
      this.isShow,
      this.blockedCountry});

  Map<String, dynamic> toMap() => {
        "ProductSetupId": productSetupId ?? "0",
        "ProdCode": prodCode,
        "ProdVersion": prodVersion,
        "ProdName": prodName,
        "ProdShortName": prodShortName,
        "ProdStatus": prodStatus,
        "ProdType": prodType,
        "EffDt": effDt,
        "CeaseDt": ceaseDt,
        "LOB": lob,
        "Type": type,
        "IsTakaful": isTakaful,
        "PremiumType": premiumType,
        "PremiumBasis": premiumBasis,
        "Gender": gender,
        "ProdNameBMY": prodNameBMY,
        "ProdShortNameBMY": prodShortNameBMY,
        "AgeCalculationBasis": ageCalculationBasis,
        "Currency": currency,
        "IsAdvLumpsum": isAdvLumpsum,
        "IsUnitBasedProd": isUnitBasedProd,
        "AmtPerUnit": amtPerUnit,
        "IsJuvenile": isJuvenile,
        "ChildEntryAge": childEntryAge,
        "MaxChildEntryAge": maxChildEntryAge,
        "AgeUnit": ageUnit,
        "IsRateScale": isRateScale,
        "IsFixedTerm": isFixedTerm,
        "MaturityType": maturityType,
        "IsJoinedLife": isJoinedLife,
        "AgeCalculation": ageCalculation,
        "IsParticipating": isParticipating,
        "IsWOP": isWOP,
        "PremiumTermType": premiumTermType,
        "IsRiderFixedTerm": isRiderFixedTerm,
        "IsPOMandatory": isPOMandatory,
        "LAMaxAgePOMand": lAMaxAgePOMand,
        "FundOption": fundOption,
        "VPMSFileName": vPMSFileName,
        "IsCustomPremVal": isCustomPremVal,
        "LastStatusDate": lastStatusDate,
        "AgeCalculationBasisDesc": ageCalculationBasisDesc,
        "ProdEffDt": prodEffDt,
        "ProdCloseDt": prodCloseDt,
        "IsPremTopupAllowed": isPremTopupAllowed,
        "MaxPremTopupAllowed": maxPremTopupAllowed,
        "MinPremTopupAmt": minPremTopupAmt,
        "VPMSVersion": vPMSVersion,
        "IsPremiumFixedTerm": isPremiumFixedTerm,
        "IsFixedBasePremiumTerm": isFixedBasePremiumTerm,
        "IsFixedBasePolicyTerm": isFixedBasePolicyTerm,
        "IsSustainability": isSustainability,
        "IsExpiry": isExpiry,
        "IsShow": isShow,
        "BlockCountry": blockedCountry
      };

  factory ProductSetup.fromMap(Map<String, dynamic> map) {
    return ProductSetup(
        productSetupId: map["ProductSetupID"],
        prodCode: map["ProdCode"],
        prodVersion: map["ProdVersion"],
        prodName: map["ProdName"],
        prodShortName: map["ProdShortName"],
        prodStatus: map["ProdStatus"],
        prodType: map["ProdType"],
        effDt: map["EffDt"],
        ceaseDt: map["CeaseDt"],
        lob: map["LOB"],
        type: map["Type"],
        isTakaful: map["IsTakaful"],
        premiumType: map["PremiumType"],
        premiumBasis: map["PremiumBasis"],
        gender: map["Gender"],
        prodNameBMY: map["ProdNameBMY"],
        prodShortNameBMY: map["ProdShortNameBMY"],
        ageCalculationBasis: map["AgeCalculationBasis"],
        currency: map["Currency"],
        isAdvLumpsum: map["IsAdvLumpsum"],
        isUnitBasedProd: map["IsUnitBasedProd"],
        amtPerUnit: map["AmtPerUnit"],
        isJuvenile: map["IsJuvenile"],
        childEntryAge: map["ChildEntryAge"],
        maxChildEntryAge: map["MaxChildEntryAge"],
        ageUnit: map["AgeUnit"],
        isRateScale: map["IsRateScale"],
        isFixedTerm: map["IsFixedTerm"],
        maturityType: map["MaturityType"],
        isJoinedLife: map["IsJoinedLife"],
        ageCalculation: map["AgeCalculation"],
        isParticipating: map["IsParticipating"],
        isWOP: map["IsWOP"],
        premiumTermType: map["PremiumTermType"],
        isRiderFixedTerm: map["IsRiderFixedTerm"],
        isPOMandatory: map["IsPOMandatory"],
        lAMaxAgePOMand: map["LAMaxAgePOMand"],
        fundOption: map["FundOption"],
        vPMSFileName: map["VPMSFileName"],
        isCustomPremVal: map["IsCustomPremVal"],
        lastStatusDate: map["LastStatusDate"],
        ageCalculationBasisDesc: map["AgeCalculationBasisDesc"],
        prodEffDt: map["ProdEffDt"],
        prodCloseDt: map["ProdCloseDt"],
        isPremTopupAllowed: map["IsPremTopupAllowed"],
        maxPremTopupAllowed: map["MaxPremTopupAllowed"],
        minPremTopupAmt: map["MinPremTopupAmt"],
        vPMSVersion: map["VPMSVersion"],
        isPremiumFixedTerm: map["IsPremiumFixedTerm"],
        isFixedBasePremiumTerm: map["IsFixedBasePremiumTerm"],
        isFixedBasePolicyTerm: map["IsFixedBasePolicyTerm"],
        isSustainability: map["IsSustainability"],
        isExpiry: map["IsExpiry"],
        isShow: map["IsShow"],
        blockedCountry: map["BlockCountry"]);
  }
}

class RateScale {
  final int? rateScaleId;
  final String? prodCode;
  final int? prodVersion;
  final String? rateScale;
  final String? startYear;

  RateScale(
      {this.rateScaleId,
      this.prodCode,
      this.prodVersion,
      this.rateScale,
      this.startYear});

  factory RateScale.fromMap(Map<String, dynamic> json) {
    return RateScale(
        rateScaleId: json["RateScalesId"],
        prodCode: json['ProdCode'],
        prodVersion: json['ProdVersion'],
        rateScale: json['RateScale'],
        startYear: json['StartYear']);
  }

  Map<String, dynamic> toMap() => {
        'RateScalesId': rateScaleId,
        'ProdCode': prodCode,
        'ProdVersion': prodVersion,
        'RateScale': rateScale,
        'StartYear': startYear
      };
}

class Campaign {
  final int? id;
  final String? campaignName;
  final String? prodCode;
  final int? prodVersion;
  final String? minPremiumTermFrom;
  final List<String>? limitedPaymentPremiumList;
  final String? startDate;
  final String? endDate;
  final bool? isActive;
  String? campaignRemarks;

  Campaign(
      {this.id,
      this.campaignName,
      this.prodCode,
      this.prodVersion,
      this.minPremiumTermFrom,
      this.limitedPaymentPremiumList,
      this.startDate,
      this.endDate,
      this.isActive,
      this.campaignRemarks});

  factory Campaign.fromMap(Map<String, dynamic> map) {
    List<String>? limitedPaymentPremiumList = [];
    if (map["MinPremiumTermFrom"] != null) {
      final regex = RegExp(r'\[(.*?)\]');
      final regex2 = RegExp(r'\{(.*?)\}');
      String? minprem = map["MinPremiumTermFrom"];

      final match = regex.firstMatch(minprem!);

      if (match != null) {
        final everything = match.group(0);
        limitedPaymentPremiumList = regex2
            .allMatches(everything!)
            .map((z) => z.group(0))
            .cast<String>()
            .toList();
      }
    }

    return Campaign(
        id: map["Id"],
        campaignName: map["CampaignName"],
        prodCode: map["ProdCode"],
        prodVersion: map["ProdVersion"],
        minPremiumTermFrom: map["MinPremiumTermFrom"],
        limitedPaymentPremiumList: limitedPaymentPremiumList,
        startDate: map["StartDate"],
        endDate: map["EndDate"],
        isActive: map["IsActive"],
        campaignRemarks: map["CampaignRemarks"]);
  }

  Map<String, dynamic> toMap() => {
        "Id": id,
        "CampaignName": campaignName,
        "ProdCode": prodCode,
        "ProdVersion": prodVersion,
        "MinPremiumTermFrom": minPremiumTermFrom,
        "StartDate": startDate,
        "EndDate": endDate,
        "IsActive": isActive,
        "CampaignRemarks": campaignRemarks
      };
}

class GAProduct {
  final int? id;
  final String? prodCode;
  final int? prodVersion;
  final double? prodLimit;
  final bool? isUseETLPerLife;
  final bool? isUseSARGrp1;
  final bool? isUseSARGrp2;

  GAProduct(
      {this.id,
      this.prodCode,
      this.prodVersion,
      this.prodLimit,
      this.isUseETLPerLife,
      this.isUseSARGrp1,
      this.isUseSARGrp2});

  factory GAProduct.fromMap(Map<String, dynamic> map) {
    return GAProduct(
        id: map["Id"],
        prodCode: map["ProdCode"],
        prodVersion: map["ProdVersion"],
        prodLimit: map["ProdLimit"],
        isUseETLPerLife: map["IsUseETLPerLife"],
        isUseSARGrp1: map["IsUseSARGrp1"],
        isUseSARGrp2: map["IsUseSARGrp2"]);
  }

  Map<String, dynamic> toMap() => {
        "Id": id,
        "ProdCode": prodCode,
        "ProdVersion": prodVersion,
        "ProdLimit": prodLimit,
        "IsUseETLPerLife": isUseETLPerLife,
        "IsUseSARGrp1": isUseSARGrp1,
        "IsUseSARGrp2": isUseSARGrp2
      };
}
