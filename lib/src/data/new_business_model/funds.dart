class Funds {
  final String? prodCode;
  final String? fundCode;
  final String? fundDescription;
  final String? minAlloc;
  final String? fundOption;
  final String? vpmsInput;
  final String? riskLevel;
  final String? riskType;

  Funds(
      {this.prodCode,
      this.fundCode,
      this.fundDescription,
      this.minAlloc,
      this.fundOption,
      this.riskLevel,
      this.vpmsInput,
      this.riskType});

  Map<String, dynamic> toMap() => {
        'ProdCode': prodCode,
        'FundCode': fundCode,
        'FundDesc': fundDescription,
        'MinAlloc': minAlloc,
        'FundOption': fundOption,
        'RiskLevel': riskLevel,
        'VPMSInput': vpmsInput,
        'RiskType': riskType
      };

  factory Funds.fromMap(Map<String, dynamic> map) {
    return Funds(
        prodCode: map['ProdCode'],
        fundCode: map['FundCode'],
        fundDescription: map['FundDesc'],
        minAlloc: map['MinAlloc'].toString(),
        fundOption: map['FundOption'],
        riskLevel: map['RiskLevel'].toString(),
        vpmsInput: map["VpmsInput"],
        riskType: map['RiskType']);
  }
}
