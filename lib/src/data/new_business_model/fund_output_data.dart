class FundOutputData {
  String? fundName;
  String? fundCode;
  String? fundAlloc;
  String? fundRiskLevel;
  String? fundRiskType;
  String? fundOption;

  FundOutputData(
      {this.fundName,
      this.fundCode,
      this.fundAlloc,
      this.fundRiskLevel,
      this.fundRiskType,
      this.fundOption});

  factory FundOutputData.fromMap(Map<String, dynamic> json) {
    return FundOutputData(
        fundName: json['fundName'],
        fundCode: json['fundCode'],
        fundAlloc: json['fundAlloc'],
        fundRiskLevel: json['fundRiskLevel'],
        fundRiskType: json['fundRiskType'],
        fundOption: json['fundOption']);
  }

  Map<String, dynamic> toMap() => {
        'fundName': fundName,
        'fundCode': fundCode,
        'fundAlloc': fundAlloc,
        'fundRiskLevel': fundRiskLevel,
        'fundRiskType': fundRiskType,
        'fundOption': fundOption
      };
}
