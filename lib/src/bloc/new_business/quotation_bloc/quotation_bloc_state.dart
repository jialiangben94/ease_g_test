part of 'quotation_bloc.dart';

abstract class QuotationBlocState extends Equatable {
  const QuotationBlocState();
  @override
  List<Object?> get props => [];
}

class QuotationLoadInProgress extends QuotationBlocState {}

class QuotationLoadSuccess extends QuotationBlocState {
  final List<Quotation> quotations;
  const QuotationLoadSuccess(this.quotations);

  @override
  List<Object> get props => [quotations];

  @override
  String toString() =>
      'QuotationLoadSuccess {quotations: ${quotations.length} }';
}

class QuotationAdded extends QuotationBlocState {
  final int? qtnId;
  final Quotation quotation;
  final List<Quotation> allQuotations;
  const QuotationAdded(this.qtnId, this.quotation, this.allQuotations)
      : super();
}

class QuotationUpdated extends QuotationBlocState {
  final int? qtnId;
  final Quotation quotation;
  final List<Quotation> allQuotations;
  const QuotationUpdated(this.qtnId, this.quotation, this.allQuotations)
      : super();
}

class QuotationRetrieved extends QuotationBlocState {
  final List<Quotation> quotations;
  const QuotationRetrieved([this.quotations = const []]);

  @override
  List<Object> get props => [quotations];

  @override
  String toString() =>
      'QuotationLoadSuccess {quotations: ${quotations.length} }';
}

class QuotationSingle extends QuotationBlocState {
  final List<Quotation>? quotations;
  final Quotation? quotation;
  const QuotationSingle([this.quotation, this.quotations]);

  @override
  List<Object?> get props => [quotation, quotations];

  @override
  String toString() => 'Loaded';
}

class QuotationLoadError extends QuotationBlocState {
  final String message;
  const QuotationLoadError(this.message);

  @override
  List<Object> get props => [message];
}
