class Rider {
  final String? prodCode;
  final String? riderCode;
  final int? version;
  final String? riderOption;
  final String? clientType;
  final int? lifeSeq;
  final String? conditionType;

  Rider(
      {this.prodCode,
      this.riderCode,
      this.version,
      this.riderOption,
      this.clientType,
      this.lifeSeq,
      this.conditionType});

  factory Rider.fromMap(Map<String, dynamic> json) {
    return Rider(
        prodCode: json["ProdCode"],
        riderCode: json['RiderCode'],
        version: json['RIderVersion'],
        riderOption: json['RiderOption'],
        clientType: json['ClientType'],
        lifeSeq: json['LifeSeq'],
        conditionType: json['ConditionType']);
  }

  Map<String, dynamic> toMap() => {
        'ProdCode': prodCode,
        'RiderCode': riderCode,
        'Version': version,
        'RiderOption': riderOption,
        'ClientType': clientType,
        'LifeSeq': lifeSeq,
        'ConditionType': conditionType
      };
}
