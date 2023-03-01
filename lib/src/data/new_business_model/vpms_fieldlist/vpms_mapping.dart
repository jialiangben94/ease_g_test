import 'package:ease/src/data/new_business_model/vpms_fieldlist/basic_input.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/basic_plan_input.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/basic_plan_output.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/fund_list.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/participant_input.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/premium_summary.dart';
import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_prod_fieldlist.dart';

class VpmsMapping {
  final String? title;
  final String? type;
  final BasicInput? basicInput;
  final ParticipantInput? participantInput;
  final BasicPlanInput? basicPlanInput;
  final List<VpmsProdFieldsList>? vpmsProdFieldsList;
  final List<FundList>? fundList;
  final BasicPlanOutput? basicPlanOutput;
  final PremiumSummary? premiumSummary;
  final List<String>? basicOutput;
  final List<String>? siTableData;
  final List<String>? gsc;
  final List<String>? wakalah;
  final List<String>? surrenderChargeTableData;
  final List<String>? fundFeeTableData;
  final List<String>? sustainabilityPeriodTableData;
  final List<String>? historicalFundTableData;
  final List<String>? wordingSiIllustrationOutput;
  final List<String>? noticeWordingInputSheetOutput;
  final List<String>? pds;

  VpmsMapping(
      {this.title,
      this.type,
      this.basicInput,
      this.participantInput,
      this.basicPlanInput,
      this.vpmsProdFieldsList,
      this.fundList,
      this.basicPlanOutput,
      this.premiumSummary,
      this.basicOutput,
      this.siTableData,
      this.gsc,
      this.wakalah,
      this.surrenderChargeTableData,
      this.fundFeeTableData,
      this.sustainabilityPeriodTableData,
      this.historicalFundTableData,
      this.wordingSiIllustrationOutput,
      this.noticeWordingInputSheetOutput,
      this.pds});

  factory VpmsMapping.fromMap(Map<String, dynamic> json) => VpmsMapping(
      title: json["Title"],
      type: json["Type"],
      basicInput: BasicInput.fromMap(json["BasicInput"]),
      participantInput: ParticipantInput.fromMap(json["ParticipantInput"]),
      basicPlanInput: BasicPlanInput.fromMap(json["BasicPlanInput"]),
      vpmsProdFieldsList: json["VPMSProdFieldsList"] != null
          ? List<VpmsProdFieldsList>.from(json["VPMSProdFieldsList"]
              .map((x) => VpmsProdFieldsList.fromMap(x)))
          : [],
      fundList: json["FundList"] != null
          ? List<FundList>.from(
              json["FundList"].map((x) => FundList.fromMap(x)))
          : [],
      basicPlanOutput: BasicPlanOutput.fromMap(json["BasicPlanOutput"]),
      premiumSummary: json["PremiumSummary"] != null
          ? PremiumSummary.fromMap(json["PremiumSummary"])
          : null,
      basicOutput: List<String>.from(json["BasicOutput"].map((x) => x)),
      siTableData: List<String>.from(json["SITableData"].map((x) => x)),
      gsc: json["SITableGSC"] != null
          ? List<String>.from(json["SITableGSC"].map((x) => x))
          : [],
      wakalah: json["SITableWakalah"] != null
          ? List<String>.from(json["SITableWakalah"].map((x) => x))
          : [],
      surrenderChargeTableData: json["SurrenderChargesTableData"] != null
          ? List<String>.from(json["SurrenderChargesTableData"].map((x) => x))
          : [],
      fundFeeTableData: json["FundManagementFeeTableData"] != null
          ? List<String>.from(json["FundManagementFeeTableData"].map((x) => x))
          : null,
      sustainabilityPeriodTableData: json["SustainabilityPeriodTableData"] != null
          ? List<String>.from(
              json["SustainabilityPeriodTableData"].map((x) => x))
          : [],
      historicalFundTableData: json["HistoricalFundTableData"] != null
          ? List<String>.from(json["HistoricalFundTableData"].map((x) => x))
          : [],
      wordingSiIllustrationOutput: json["WordingSiIlustrationOutput"] != null ? List<String>.from(json["WordingSiIlustrationOutput"].map((x) => x)) : [],
      noticeWordingInputSheetOutput: json["NoticeWordingInputSheetOutput"] != null ? List<String>.from(json["NoticeWordingInputSheetOutput"].map((x) => x)) : [],
      pds: List<String>.from(json["PDS"].map((x) => x)));
}
