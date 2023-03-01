class LimitedPaymentPremium {
  // 8P25T == premiumTerm + "P" + termFrom + "T"
  // 10P30T == premiumTerm + "P" + termFrom + "T"
  // 10P25T == premiumTerm + "P" + termFrom + "T"
  // 15P30T == premiumTerm + "P" + termFrom + "T"
  // 15P25T == premiumTerm + "P" + termFrom + "T"
  // 20P30T == premiumTerm + "P" + termFrom + "T"
  final int? termFrom;
  final int? termTo;
  final int? premiumTerm;

  LimitedPaymentPremium({this.termFrom, this.termTo, this.premiumTerm});

  factory LimitedPaymentPremium.fromMap(Map<String, dynamic> map) {
    return LimitedPaymentPremium(
      termFrom: map["TermFrom"],
      termTo: map["TermTo"],
      premiumTerm: map["PremiumTerm"],
    );
  }

  Map<String, dynamic> toMap() => {
        "TermFrom": termFrom,
        "TermTo": termTo,
        "PremiumTerm": premiumTerm,
      };
}
