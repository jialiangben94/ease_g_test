class TermUpToMaturity {
  final int? termUpToMaturityId;
  final String? maturityType;
  final String? gender;
  final String? clientType;
  final int? maturityYear;

  TermUpToMaturity(
      {this.termUpToMaturityId,
      this.maturityType,
      this.gender,
      this.clientType,
      this.maturityYear});

  factory TermUpToMaturity.fromMap(Map<String, dynamic> map) {
    return TermUpToMaturity(
        termUpToMaturityId: map['TermUpToMaturityId'],
        maturityType: map['MaturityType'],
        gender: map['Gender'],
        clientType: map['ClientType'],
        maturityYear: map['MaturityYear']);
  }

  Map<String, dynamic> toMap() => {
        'TermUpToMaturityId': termUpToMaturityId,
        'MaturityType': maturityType,
        'Gender': gender,
        'ClientType': clientType,
        'MaturityYear': maturityYear
      };
}
