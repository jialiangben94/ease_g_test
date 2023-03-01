class RiderOutputData {
  String? riderName;
  String? riderCode;
  String? riderSA;
  String? riderSAIOS;
  String? riderPlan;
  String? riderType;
  String? riderTerm;
  String? riderPaymentTerm;
  String? riderMonthlyPremium;
  String? riderOutputTerm;
  String? riderNotionalPrem;
  bool? requiredSA;
  bool? requiredPlan;
  bool? requiredTerm;
  bool? isUnitBasedProd;
  String? tempSA; // Just to cater for IL Medical Dropdown
  String? tempTerm;
  String? childCode; // If child code exist, use childcode instead of ridercode

  RiderOutputData(
      {this.riderName,
      this.riderCode,
      this.riderSA,
      this.riderSAIOS,
      this.riderPlan,
      this.riderType,
      this.riderTerm,
      this.riderPaymentTerm,
      this.riderMonthlyPremium,
      this.riderOutputTerm,
      this.riderNotionalPrem,
      this.requiredSA,
      this.requiredPlan,
      this.requiredTerm,
      this.isUnitBasedProd,
      this.tempTerm,
      this.tempSA,
      this.childCode});

  factory RiderOutputData.fromMap(Map<String, dynamic> json) {
    return RiderOutputData(
        riderName: json['riderName'] ?? "",
        riderCode: json['riderCode'],
        riderSA: json['riderSA'],
        riderSAIOS: json['riderSAIOS'],
        riderPlan: json['riderPlan'],
        riderTerm: json['riderTerm'],
        riderType: json['riderType'],
        riderPaymentTerm: json['riderPaymentTerm'],
        riderMonthlyPremium: json['riderMonthlyPremium'],
        riderOutputTerm: json['riderOutputTerm'],
        riderNotionalPrem: json['notionalPrem'],
        requiredSA: json['requiredSA'],
        requiredPlan: json['requiredPlan'],
        requiredTerm: json['requiredTerm'],
        isUnitBasedProd: json['isUnitBasedProd'],
        tempSA: json['tempSA'],
        tempTerm: json['tempTerm'],
        childCode: json['childCode']);
  }

  Map<String, dynamic> toMap() => {
        'riderName': riderName ?? "",
        'riderCode': riderCode,
        'riderSA': riderSA,
        'riderSAIOS': riderSAIOS,
        'riderPlan': riderPlan,
        'riderType': riderType,
        'riderTerm': riderTerm,
        'riderPaymentTerm': riderPaymentTerm,
        'riderMonthlyPremium': riderMonthlyPremium,
        'riderOutputTerm': riderOutputTerm,
        'riderNotionalPrem': riderNotionalPrem,
        'requiredSA': requiredSA,
        'requiredPlan': requiredPlan,
        'requiredTerm': requiredTerm,
        'isUnitBasedProd': isUnitBasedProd,
        'tempSA': tempSA,
        'tempTerm': tempTerm,
        'childCode': childCode
      };
}
