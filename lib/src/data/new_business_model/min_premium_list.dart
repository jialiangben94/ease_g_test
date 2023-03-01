class MinPremiumList {
  // Monthly == "CC12" | Quarterly == "CC4" | Half Yearly == "CC2" | Yearly == "CC1"
  final String? payMode;
  final int? minPremium;

  MinPremiumList({this.payMode, this.minPremium});

  factory MinPremiumList.fromMap(Map<String, dynamic> map) {
    return MinPremiumList(
        payMode: map["PayMode"], minPremium: map["MinPremium"].toInt());
  }

  Map<String, dynamic> toMap() =>
      {"PayMode": payMode, "MinPremium": minPremium};
}
