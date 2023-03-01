class PremiumSummary {
  final String? anb;
  final String? maturityAge;
  final String? basicContribution;
  final String? totalPremium;
  final String? totalPremiumIOS;
  final String? minSumInsured;
  final String? sam;
  final String? totalFundAlloc;
  final String? occLoad;
  final String? totalPremOccLoad;

  PremiumSummary(
      {this.anb,
      this.maturityAge,
      this.basicContribution,
      this.totalPremium,
      this.totalPremiumIOS,
      this.minSumInsured,
      this.sam,
      this.totalFundAlloc,
      this.occLoad,
      this.totalPremOccLoad});

  factory PremiumSummary.fromMap(Map<String, dynamic> json) => PremiumSummary(
      anb: json["ANB"],
      maturityAge: json["MaturityAge"],
      basicContribution: json["BasicContribution"],
      totalPremium: json["TotalPremium"],
      totalPremiumIOS: json["TotalPremiumIOS"],
      minSumInsured: json["MinSumInsured"],
      sam: json["SAM"],
      totalFundAlloc: json["TotalFundAlloc"],
      occLoad: json["OccLoad"],
      totalPremOccLoad: json["TotalPremOccLoad"]);
}
