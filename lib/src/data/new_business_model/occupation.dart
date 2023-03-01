class Occupation {
  final String? occupationId;
  final String? occupationName;
  final String? occupationCode;
  final String? industryCode;
  final String? industryName;
  final String? occupationClass;
  final String? interfaceValue; // interface value
  final bool? isHouseHoldIncomeRequired;
  final bool? isNatureOfRequired;
  final bool? isGASkipOccupation;
  final String? remarks;

  Occupation(
      {this.occupationId,
      this.occupationName,
      this.occupationCode,
      this.industryCode,
      this.industryName,
      this.occupationClass,
      this.interfaceValue,
      this.isHouseHoldIncomeRequired,
      this.isNatureOfRequired,
      this.isGASkipOccupation,
      this.remarks});

  factory Occupation.fromJson(Map<String, dynamic> json) {
    return Occupation(
        occupationId: json['OccupationId'].toString(),
        occupationName: json['OccupationName'] as String?,
        occupationCode: json['OccupationCode'] as String?,
        industryCode: json['IndustryCode'] as String?,
        industryName: json['IndustryName'] as String?,
        occupationClass: json['OccupationClass'] as String?,
        interfaceValue: json['InterfaceValue'].toString(),
        isHouseHoldIncomeRequired: json['IsHouseHoldIncomeRequired'] as bool?,
        isNatureOfRequired: json['IsNatureOfRequired'] as bool?,
        isGASkipOccupation: json['IsGASkipOccupation'] as bool?,
        remarks: json['Remarks'] as String?);
  }

  Map<String, dynamic> toJson() => {
        'OccupationId': occupationId,
        'OccupationName': occupationName,
        'OccupationCode': occupationCode,
        'IndustryCode': industryCode,
        'IndustryName': industryName,
        'OccupationClass': occupationClass,
        'InterfaceValue': interfaceValue,
        'IsHouseHoldIncomeRequired': isHouseHoldIncomeRequired,
        'IsNatureOfRequired': isNatureOfRequired,
        'IsGASkipOccupation': isGASkipOccupation,
        'Remarks': remarks
      };
}
