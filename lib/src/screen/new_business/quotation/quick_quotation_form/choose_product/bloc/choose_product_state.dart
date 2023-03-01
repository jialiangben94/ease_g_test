part of 'choose_product_bloc.dart';

abstract class ChooseProductState extends Equatable {
  const ChooseProductState();
}

class ChooseProductInitial extends ChooseProductState {
  @override
  List<Object> get props => [];
}

class ChooseProductLoading extends ChooseProductState {
  @override
  List<Object> get props => [];
}

class BasicPlanChosen extends ChooseProductState {
  final int age;
  final String gender;
  final String dob;
  final bool? deductSalary;
  final ProductPlan selectedPlan;
  final List<ProductPlan> eligibleRiders;
  final QuickQuotation quickQtn;
  final VpmsMapping? vpmsMappingFile;
  final String vpmsVersion;
  final bool haveEnricher;

  const BasicPlanChosen(
      {required this.age,
      required this.gender,
      required this.dob,
      required this.deductSalary,
      required this.selectedPlan,
      required this.eligibleRiders,
      required this.quickQtn,
      required this.vpmsMappingFile,
      required this.vpmsVersion,
      required this.haveEnricher});

  @override
  List<Object> get props => [selectedPlan];
}

class SteppedPremiumChosen extends ChooseProductState {
  final bool isSteppedPremium;
  const SteppedPremiumChosen(this.isSteppedPremium);
  @override
  List<Object> get props => [isSteppedPremium];
}

class SustainabilityOptionChosen extends ChooseProductState {
  final int? sustainabilityOptionTerm;
  const SustainabilityOptionChosen({this.sustainabilityOptionTerm});
  @override
  List<Object?> get props => [sustainabilityOptionTerm];
}

class SumInsuredPremCalculated extends ChooseProductState {
  final CalcBasedOn? calcBasedOn;
  final int? sumInsuredAmount;
  final int? premAmount;
  final String? paymentMode;
  final String? premiumTerm;
  final bool? deductSalary;
  final String? planDetail;
  final String? policyTerm;
  final String? guaranteedCashPayment;

  const SumInsuredPremCalculated(
      {this.calcBasedOn,
      this.sumInsuredAmount,
      this.premAmount,
      this.paymentMode,
      this.deductSalary,
      this.premiumTerm,
      this.planDetail,
      this.policyTerm,
      this.guaranteedCashPayment});
  @override
  List<Object?> get props => [
        calcBasedOn,
        sumInsuredAmount,
        premAmount,
        paymentMode,
        premiumTerm,
        deductSalary,
        planDetail,
        policyTerm,
        guaranteedCashPayment
      ];
}

class RidersDeleted extends ChooseProductState {
  final List<RiderOutputData>? riderOutputDataList; // TO BE DELETED

  const RidersDeleted({required this.riderOutputDataList});
  @override
  List<Object?> get props => [riderOutputDataList];
}

class RidersChosen extends ChooseProductState {
  final List<RiderOutputData>? riderOutputDataList; // TO BE DELETED

  const RidersChosen({required this.riderOutputDataList});
  @override
  List<Object?> get props => [riderOutputDataList];
}

class AdhocChosen extends ChooseProductState {
  final int? adhocTopUp;

  const AdhocChosen({this.adhocTopUp});
  @override
  List<Object?> get props => [adhocTopUp];
}

class RTUChosen extends ChooseProductState {
  final int? regularTopUp;

  const RTUChosen({this.regularTopUp});
  @override
  List<Object?> get props => [regularTopUp];
}

class FundsChosen extends ChooseProductState {
  final List<FundOutputData>? outputFundData;

  const FundsChosen({this.outputFundData});
  @override
  List<Object?> get props => [outputFundData];
}

class CampaignSelected extends ChooseProductState {
  final bool isCampaign;
  final Campaign? campaign;

  const CampaignSelected(this.isCampaign, this.campaign);

  @override
  List<Object?> get props => [campaign];
}

class SetProductPlanType extends ChooseProductState {
  final ProductPlanType? productPlanType; // LI Data
  final List<String>? blockedCountry;

  const SetProductPlanType({this.productPlanType, this.blockedCountry});

  @override
  List<Object?> get props => [productPlanType];
}

class QuotationCalculated extends ChooseProductState {
  final String totalPremium;
  final QuickQuotation quickQuotation;

  const QuotationCalculated(
      {required this.totalPremium, required this.quickQuotation});

  @override
  List<Object?> get props => [totalPremium, quickQuotation];
}

class QuotationDuplicated extends ChooseProductState {
  final Quotation? quotation;
  final QuickQuotation? quickQuotationData;

  const QuotationDuplicated({this.quotation, this.quickQuotationData});

  @override
  List<Object?> get props => [quotation, quickQuotationData];
}

class PdfGenerated extends ChooseProductState {
  final Quotation? quotation;
  final QuickQuotation? quickQuotation;

  const PdfGenerated({this.quotation, this.quickQuotation});

  @override
  List<Object?> get props => [quotation, quickQuotation];
}

class ChooseProductError extends ChooseProductState {
  final String message;

  const ChooseProductError(this.message);
  @override
  List<Object> get props => [message];
}

class ChooseProductFieldRequired extends ChooseProductState {
  final String message;

  const ChooseProductFieldRequired(this.message);
  @override
  List<Object> get props => [message];
}

class ChooseProductErrorDialog extends ChooseProductState {
  final String totalPremium;
  final QuickQuotation quickQuotation;
  final dynamic data;
  final String message;

  const ChooseProductErrorDialog(
      this.totalPremium, this.quickQuotation, this.data, this.message);
  @override
  List<Object> get props => [quickQuotation, data, message];
}

class PremiumChecked extends ChooseProductState {
  final String totalPremium;
  final QuickQuotation quickQuotation;
  final String? caseindicator;

  const PremiumChecked(
      {required this.totalPremium,
      required this.quickQuotation,
      this.caseindicator});
  @override
  List<Object> get props => [totalPremium, quickQuotation];
}

class ViewQuotation extends ChooseProductState {
  final Quotation? quotation;
  final QuickQuotation? quickQuotation;

  const ViewQuotation({this.quotation, this.quickQuotation});
  @override
  List<Object?> get props => [quotation, quickQuotation];
}

class EditingQuotation extends ChooseProductState {
  final int age;
  final String? gender;
  final String? dob;
  final bool? deductSalary;
  final Quotation quotation;
  final QuickQuotation quickQuotation;
  final ProductPlan? selectedPlan;
  final VpmsMapping? vpmsMappingFile;
  final bool? haveEnricher;

  const EditingQuotation(
      {required this.age,
      required this.gender,
      required this.dob,
      required this.deductSalary,
      required this.quotation,
      required this.quickQuotation,
      this.selectedPlan,
      this.vpmsMappingFile,
      this.haveEnricher});
  @override
  List<Object?> get props => [
        age,
        gender,
        dob,
        quotation,
        quickQuotation,
        selectedPlan,
        vpmsMappingFile,
        haveEnricher
      ];
}
