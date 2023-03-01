class SumAssuredList {
  final int? minAgeMale;
  final int? maxAgeMale;
  final int? minAgeFemale;
  final int? maxAgeFemale;
  final int? minSA;
  final int? maxSA;
  final bool? isMultiply;
  final double? multiplier;
  SumAssuredList(
      {this.minAgeMale,
      this.maxAgeMale,
      this.minAgeFemale,
      this.maxAgeFemale,
      this.minSA,
      this.maxSA,
      this.isMultiply,
      this.multiplier});

  factory SumAssuredList.fromMap(Map<String, dynamic> map) {
    return SumAssuredList(
        minAgeMale: map["MinAgeMale"],
        maxAgeMale: map["MaxAgeMale"],
        minAgeFemale: map["MinAgeFemale"],
        maxAgeFemale: map["MaxAgeFemale"],
        minSA: map["MinSA"].toInt(),
        maxSA: map["MaxSA"].toInt(),
        isMultiply: map["IsMultiply"],
        multiplier:
            map["MultiplyOf"] != null ? map["MultiplyOf"].toDouble() : 0);
  }

  Map<String, dynamic> toMap() => {
        "MinAgeMale": minAgeMale,
        "MaxAgeMale": maxAgeMale,
        "MinAgeFemale": minAgeFemale,
        "MaxAgeFemale": maxAgeFemale,
        "MinSA": minSA,
        "MaxSA": maxSA,
        "IsMultiply": isMultiply,
        "MultiplyOf": multiplier
      };
}
