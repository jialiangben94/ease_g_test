part of 'choose_product_bloc.dart';

abstract class ChooseProductEvent extends Equatable {
  const ChooseProductEvent();
}

class SetInitial extends ChooseProductEvent {
  @override
  List<Object> get props => [];
}

class SetChooseProductBy extends ChooseProductEvent {
  final ChooseProductBy chooseProductBy;

  const SetChooseProductBy(this.chooseProductBy);
  @override
  List<Object> get props => [chooseProductBy];
}

class SetCampaign extends ChooseProductEvent {
  final String? prodCode;
  final bool isCampaign;
  final Campaign? campaign;

  const SetCampaign(this.isCampaign, this.campaign, {this.prodCode});
  @override
  List<Object?> get props => [isCampaign, campaign];
}

class SetPlanType extends ChooseProductEvent {
  final ProductPlanType productPlanType;

  const SetPlanType(this.productPlanType);
  @override
  List<Object> get props => [productPlanType];
}

class SetBasicPlan extends ChooseProductEvent {
  final String prodCode;
  final Quotation qtn;
  final QuickQuotation quickQtn;

  const SetBasicPlan(
      {required this.prodCode, required this.qtn, required this.quickQtn});
  @override
  List<Object> get props => [];
}

class SetSteppedPremium extends ChooseProductEvent {
  final bool isSteppedPremium;

  const SetSteppedPremium(this.isSteppedPremium);
  @override
  List<Object> get props => [];
}

class SetSustainabilityOption extends ChooseProductEvent {
  final int sustainabilityOption;
  const SetSustainabilityOption(this.sustainabilityOption);
  @override
  List<Object> get props => [];
}

class SetSumInsuredAndPrem extends ChooseProductEvent {
  final CalcBasedOn? calcBasedOn;
  final int? sumInsuredAmt;
  final int? premAmt;
  final String? paymentMode;
  final String? premiumTerm;
  final bool? deductSalary;
  final String? planDetail;
  final String? policyTerm;
  final String? guaranteedCashPayment;
  final bool isCampaign;

  const SetSumInsuredAndPrem(
      {this.sumInsuredAmt,
      this.premAmt,
      this.calcBasedOn,
      this.paymentMode,
      this.premiumTerm,
      this.deductSalary,
      this.planDetail,
      this.policyTerm,
      this.guaranteedCashPayment,
      this.isCampaign = false});
  @override
  List<Object?> get props => [
        calcBasedOn,
        sumInsuredAmt,
        premAmt,
        paymentMode,
        premiumTerm,
        planDetail,
        policyTerm,
        guaranteedCashPayment
      ];
}

class AddRiders extends ChooseProductEvent {
  final List<RiderOutputData> ridersOutputData;
  const AddRiders(this.ridersOutputData);
  @override
  List<Object> get props => [ridersOutputData];
}

class DeleteRiders extends ChooseProductEvent {
  final List<RiderOutputData>? ridersOutputData;

  const DeleteRiders({required this.ridersOutputData});
  @override
  List<Object> get props => [ridersOutputData!];
}

class SetRidersData extends ChooseProductEvent {
  final List<RiderOutputData>? ridersOutputData;

  const SetRidersData({required this.ridersOutputData});
  @override
  List<Object> get props => [ridersOutputData!];
}

class SetRTUAmount extends ChooseProductEvent {
  final int? rtuAmount; // Need this to output state

  const SetRTUAmount({this.rtuAmount});
  @override
  List<Object?> get props => [rtuAmount];
}

class SetAdhocAmount extends ChooseProductEvent {
  final int? adhocAmount; // Need this to output state

  const SetAdhocAmount({this.adhocAmount});
  @override
  List<Object?> get props => [adhocAmount];
}

// class AddFunds extends ChooseProductEvent {
//   final List<Funds>? fundsData;
//   final List<FundOutputData>? outputFundData;

//   const AddFunds({this.fundsData, this.outputFundData});
//   @override
//   List<Object> get props => [];
// }

class DeleteFunds extends ChooseProductEvent {
  final List<FundOutputData>? outputFundData;

  const DeleteFunds({this.outputFundData});
  @override
  List<Object?> get props => [outputFundData];
}

class SetFunds extends ChooseProductEvent {
  final List<FundOutputData>? outputFundData;

  const SetFunds({this.outputFundData});
  @override
  List<Object?> get props => [outputFundData];
}

class CheckPremium extends ChooseProductEvent {
  final ProductSetup prodSetup;
  final Quotation qtn;
  final QuickQuotation quickQuotation;
  final dynamic data;
  final bool callTSAR;

  const CheckPremium(
      {required this.prodSetup,
      required this.qtn,
      required this.quickQuotation,
      this.data,
      this.callTSAR = false});
  @override
  List<Object> get props => [prodSetup, qtn, quickQuotation];
}

class CheckPremiumUW extends ChooseProductEvent {
  final String totalPremium;
  final QuickQuotation quickqtn;
  final String? caseindicator;

  const CheckPremiumUW(
      {required this.totalPremium, required this.quickqtn, this.caseindicator});
  @override
  List<Object> get props => [quickqtn];
}

class CalculateQuotation extends ChooseProductEvent {
  final String totalPremium;
  final QuickQuotation quickQuotation;

  const CalculateQuotation(
      {required this.totalPremium, required this.quickQuotation});

  @override
  List<Object?> get props => [totalPremium, quickQuotation];
}

class ViewGeneratedQuotation extends ChooseProductEvent {
  final Quotation? quotation;
  final QuickQuotation? quickQuotation;
  const ViewGeneratedQuotation({this.quotation, this.quickQuotation});

  @override
  List<Object?> get props => [quotation, quickQuotation];
}

class GenerateSIPDF extends ChooseProductEvent {
  final Quotation? quotation;
  final QuickQuotation? quickQuotation;

  const GenerateSIPDF({this.quotation, this.quickQuotation});

  @override
  List<Object?> get props => [quotation, quickQuotation];
}

class DuplicateQuotation extends ChooseProductEvent {
  final Quotation? quotation;
  final QuickQuotation? quickQuotationData;

  const DuplicateQuotation({this.quotation, this.quickQuotationData});

  @override
  List<Object?> get props => [quickQuotationData];
}

class EditQuotation extends ChooseProductEvent {
  final Quotation quotation;
  final QuickQuotation quickQuotation;

  const EditQuotation({required this.quotation, required this.quickQuotation});

  @override
  List<Object?> get props => [quotation, quickQuotation];
}
