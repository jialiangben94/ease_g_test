import 'dart:convert';

class VpmsProdFieldsList {
  final String? riderCode;
  final int? riderVersion;
  final String? indicator;
  final String? inputTerm;
  final bool isUnit;
  final String? inputSa;
  final String? inputSaValue;
  final String? inputSaValueOption;
  final String? inputPlan;
  final String? inputPlanValue;
  final String? inputPremium;
  final String? outputTerm;
  final String? outputSa;
  final String? outputSAIOS;
  final String? outputSaValue;
  final String? outputPremium;
  final String? notionalPremium;
  final String? outputGst;
  final String? outputTotalPayable;
  final String? outputAnnualizedGst;
  final String? outputAnnualizedTotalPayable;
  final String? outputRiderType;
  final String? outputPremPaymentTerm;

  VpmsProdFieldsList(
      {this.riderCode,
      this.riderVersion,
      this.indicator,
      this.inputTerm,
      this.isUnit = false,
      this.inputSa,
      this.inputSaValue,
      this.inputSaValueOption,
      this.inputPlan,
      this.inputPlanValue,
      this.inputPremium,
      this.outputTerm,
      this.outputSa,
      this.outputSAIOS,
      this.outputSaValue,
      this.outputPremium,
      this.notionalPremium,
      this.outputGst,
      this.outputTotalPayable,
      this.outputAnnualizedGst,
      this.outputAnnualizedTotalPayable,
      this.outputRiderType,
      this.outputPremPaymentTerm});

  factory VpmsProdFieldsList.fromJson(String str) =>
      VpmsProdFieldsList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VpmsProdFieldsList.fromMap(Map<String, dynamic> json) =>
      VpmsProdFieldsList(
          riderCode: json["RiderCode"],
          riderVersion: json["RiderVersion"],
          indicator: json["Indicator"],
          inputTerm: json["InputTerm"],
          isUnit: json["IsUnit"] ?? false,
          inputSa: json["InputSA"],
          inputSaValue: json["InputSAValue"],
          inputSaValueOption: json["InputSAValueOption"],
          inputPremium: json["InputPremium"],
          inputPlan: json["InputPlan"],
          inputPlanValue: json["InputPlanValue"],
          outputTerm: json["OutputTerm"],
          outputSa: json["OutputSA"],
          outputSAIOS: json["OutputSAIOS"],
          outputSaValue: json["OutputSAValue"],
          notionalPremium: json["NotionalPremium"],
          outputPremium: json["OutputPremium"],
          outputGst: json["OutputGST"],
          outputTotalPayable: json["OutputTotalPayable"],
          outputAnnualizedGst: json["OutputAnnualizedGST"],
          outputAnnualizedTotalPayable: json["OutputAnnualizedTotalPayable"],
          outputRiderType: json["OutputRiderType"],
          outputPremPaymentTerm: json["OutputPremPaymentTerm"]);

  Map<String, dynamic> toMap() => {
        "RiderCode": riderCode,
        "RiderVersion": riderVersion,
        "Indicator": indicator,
        "InputTerm": inputTerm,
        "IsUnit": isUnit,
        "InputSA": inputSa,
        "InputSAValue": inputSaValue,
        "InputSAValueOption": inputSaValueOption,
        "InputPlan": inputPlan,
        "InputPlanValue": inputPlanValue,
        "InputPremium": inputPremium,
        "OutputTerm": outputTerm,
        "OutputSA": outputSa,
        "OutputSAIOS": outputSAIOS,
        "OutputSAValue": outputSaValue,
        "NotionalPremium": notionalPremium,
        "OutputPremium": outputPremium,
        "OutputGST": outputGst,
        "OutputTotalPayable": outputTotalPayable,
        "OutputAnnualizedGST": outputAnnualizedGst,
        "OutputAnnualizedTotalPayable": outputAnnualizedTotalPayable,
        "OutputRiderType": outputRiderType,
        "OutputPremPaymentTerm": outputPremPaymentTerm
      };
}




// import 'dart:convert';

// class VpmsProdFieldsList {
//     VpmsProdFieldsList({
//         this.riderCode,
//         this.riderVersion,
//         this.indicator,
//         this.inputTerm,
//         this.inputSa,
//         this.inputSaValue,
//         this.inputPremium,
//         this.outputTerm,
//         this.outputSa,
//         this.outputSaValue,
//         this.outputPremium,
//         this.outputGst,
//         this.outputTotalPayable,
//         this.outputAnnualizedGst,
//         this.outputAnnualizedTotalPayable,
//         this.outputRiderType,
//         this.outputPremPaymentTerm,
//     });

//     final String riderCode;
//     final int riderVersion;
//     final String indicator;
//     final String inputTerm;
//     final String inputSa;
//     final String inputSaValue;
//     final String inputPremium;
//     final String outputTerm;
//     final String outputSa;
//     final String outputSaValue;
//     final String outputPremium;
//     final String outputGst;
//     final String outputTotalPayable;
//     final String outputAnnualizedGst;
//     final String outputAnnualizedTotalPayable;
//     final String outputRiderType;
//     final String outputPremPaymentTerm;

//     factory VpmsProdFieldsList.fromJson(String str) => VpmsProdFieldsList.fromMap(json.decode(str));

//     String toJson() => json.encode(toMap());

//     factory VpmsProdFieldsList.fromMap(Map<String, dynamic> json) => VpmsProdFieldsList(
//         riderCode: json["RiderCode"],
//         riderVersion: json["RiderVersion"],
//         indicator: json["Indicator"],
//         inputTerm: json["InputTerm"],
//         inputSa: json["InputSA"],
//         inputSaValue: json["InputSAValue"],
//         inputPremium: json["InputPremium"],
//         outputTerm: json["OutputTerm"],
//         outputSa: json["OutputSA"],
//         outputSaValue: json["OutputSAValue"],
//         outputPremium: json["OutputPremium"],
//         outputGst: json["OutputGST"],
//         outputTotalPayable: json["OutputTotalPayable"],
//         outputAnnualizedGst: json["OutputAnnualizedGST"],
//         outputAnnualizedTotalPayable: json["OutputAnnualizedTotalPayable"],
//         outputRiderType: json["OutputRiderType"],
//         outputPremPaymentTerm: json["OutputPremPaymentTerm"],
//     );

//     Map<String, dynamic> toMap() => {
//         "RiderCode": riderCode,
//         "RiderVersion": riderVersion,
//         "Indicator": indicator,
//         "InputTerm": inputTerm,
//         "InputSA": inputSa,
//         "InputSAValue": inputSaValue,
//         "InputPremium": inputPremium,
//         "OutputTerm": outputTerm,
//         "OutputSA": outputSa,
//         "OutputSAValue": outputSaValue,
//         "OutputPremium": outputPremium,
//         "OutputGST": outputGst,
//         "OutputTotalPayable": outputTotalPayable,
//         "OutputAnnualizedGST": outputAnnualizedGst,
//         "OutputAnnualizedTotalPayable": outputAnnualizedTotalPayable,
//         "OutputRiderType": outputRiderType,
//         "OutputPremPaymentTerm": outputPremPaymentTerm,
//     };
// }