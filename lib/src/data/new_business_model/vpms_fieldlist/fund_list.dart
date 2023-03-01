class FundList {
  final String? code;
  final String? vpmsInput;
  final String? vpmsOutput;

  FundList({this.code, this.vpmsInput, this.vpmsOutput});

  factory FundList.fromMap(Map<String, dynamic> json) => FundList(
      code: json["Code"],
      vpmsInput: json["VPMSInput"],
      vpmsOutput: json["VPMSOutput"]);
}
