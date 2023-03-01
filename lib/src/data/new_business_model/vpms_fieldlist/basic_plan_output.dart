class BasicPlanOutput {
  final String? sumInsured;
  final String? premiumTerm;
  final String? policyTerm;
  final String? premium;
  final String? enricherSA;
  final String? enricherPremiumTerm;
  final String? enricherPolicyTerm;
  final String? enricherPremium;
  final String? rtuSA;
  final String? adhocSA;
  final String? rtuSAIOS;
  final String? rtuPremiumTerm;
  final String? rtuPolicyTerm;
  final String? rtuPremium;

  BasicPlanOutput(
      {this.sumInsured,
      this.premiumTerm,
      this.policyTerm,
      this.premium,
      this.enricherSA,
      this.enricherPremiumTerm,
      this.enricherPolicyTerm,
      this.enricherPremium,
      this.rtuSA,
      this.adhocSA,
      this.rtuSAIOS,
      this.rtuPremiumTerm,
      this.rtuPolicyTerm,
      this.rtuPremium});

  factory BasicPlanOutput.fromMap(Map<String, dynamic> json) => BasicPlanOutput(
      sumInsured: json["SumInsured"],
      premiumTerm: json["PremiumTerm"],
      policyTerm: json["PolicyTerm"],
      premium: json["Premium"],
      enricherSA: json["EnricherSA"],
      enricherPremiumTerm: json["EnricherPremiumTerm"],
      enricherPolicyTerm: json["EnricherPolicyTerm"],
      enricherPremium: json["EnricherPremium"],
      rtuSA: json["RTUSA"],
      adhocSA: json["ADHOCSA"],
      rtuSAIOS: json["RTUSAIOS"],
      rtuPremiumTerm: json["RTUPremiumTerm"],
      rtuPolicyTerm: json["RTUPolicyTerm"],
      rtuPremium: json["RTUPremium"]);
}
