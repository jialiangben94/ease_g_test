class AgentProduct {
  final String? agentCode;
  final String? prodCode;
  final String? prodName;
  final String? result;
  final String? trainingDate;

  AgentProduct(
      {this.agentCode,
      this.prodCode,
      this.prodName,
      this.result,
      this.trainingDate});

  Map<String, dynamic> toJson() {
    return {
      'AgentCode': agentCode,
      'ProductCode': prodCode,
      'ProductName': prodName,
      'Result': result,
      'TrainingDate': trainingDate
    };
  }

  factory AgentProduct.fromMap(Map<String, dynamic> map, {String? agentCode}) {
    return AgentProduct(
        agentCode: agentCode ?? map['AgentCode'] ?? "",
        prodCode: map['ProductCode'],
        prodName: map['ProductName'],
        result: map['Result'],
        trainingDate: map['TrainingDate']);
  }
}
