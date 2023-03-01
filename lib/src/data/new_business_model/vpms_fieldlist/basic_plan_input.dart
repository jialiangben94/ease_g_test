class BasicPlanInput {
  final String? campaign;
  final String? planName;
  final String? steppedPremium;
  final String? basicPeriodOption;
  final String? uwProductCode;
  final String? topUpPremium;
  final String? planDetail;
  final String? premium;
  final String? premiumTerm;
  final String? premiumPaymentType;
  final String? sumInsured;
  final String? rtuPremium;
  final String? prodHistory;
  final String? aggregateSA;
  final String? gscoption;
  final String? tsf;
  final String? tucontr;
  final String? basiccashopt;
  final String? tucontrpolyear;
  final String? tucontrpolyear1;
  final String? tucontrpolyear2;
  final String? tucontrpolyear3;
  final String? tucontrpolyear4;
  final String? tucontrpolyear5;
  final String? tucontramt;
  final String? tucontramt1;
  final String? tucontramt2;
  final String? tucontramt3;
  final String? tucontramt4;
  final String? tucontramt5;

  BasicPlanInput(
      {this.campaign,
      this.planName,
      this.steppedPremium,
      this.basicPeriodOption,
      this.uwProductCode,
      this.topUpPremium,
      this.planDetail,
      this.premium,
      this.premiumTerm,
      this.premiumPaymentType,
      this.sumInsured,
      this.rtuPremium,
      this.prodHistory,
      this.aggregateSA,
      this.gscoption,
      this.tsf,
      this.tucontr,
      this.basiccashopt,
      this.tucontrpolyear,
      this.tucontrpolyear1,
      this.tucontrpolyear2,
      this.tucontrpolyear3,
      this.tucontrpolyear4,
      this.tucontrpolyear5,
      this.tucontramt,
      this.tucontramt1,
      this.tucontramt2,
      this.tucontramt3,
      this.tucontramt4,
      this.tucontramt5});

  factory BasicPlanInput.fromMap(Map<String, dynamic> json) => BasicPlanInput(
      campaign: json["Campaign"],
      planName: json["PlanName"],
      steppedPremium: json["SteppedPremium"],
      basicPeriodOption: json["BasicPeriodOption"],
      uwProductCode: json["UWProductCode"],
      topUpPremium: json["TopUpPremium"],
      planDetail: json["PlanDetail"],
      premium: json["Premium"],
      premiumTerm: json["PremiumTerm"],
      premiumPaymentType: json["PremiumPaymentType"],
      sumInsured: json["SumInsured"],
      rtuPremium: json["RTUPremium"],
      prodHistory: json["ProductHistory"],
      aggregateSA: json["AggregateSumInsured"],
      gscoption: json["GSCOption"],
      tsf: json["tsf"],
      tucontr: json["TUContr"],
      basiccashopt: json["BasicCashOpt"],
      tucontrpolyear: json["TUContrPolYear"],
      tucontrpolyear1: json["TUContrPolYear1"],
      tucontrpolyear2: json["TUContrPolYear2"],
      tucontrpolyear3: json["TUContrPolYear3"],
      tucontrpolyear4: json["TUContrPolYear4"],
      tucontrpolyear5: json["TUContrPolYear5"],
      tucontramt: json["TUContrAmt"],
      tucontramt1: json["TUContrAmt1"],
      tucontramt2: json["TUContrAmt2"],
      tucontramt3: json["TUContrAmt3"],
      tucontramt4: json["TUContrAmt4"],
      tucontramt5: json["TUContrAmt5"]);
}
