part of 'quotation_bloc.dart';

abstract class QuotationBlocEvent extends Equatable {
  const QuotationBlocEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuotation extends QuotationBlocEvent {}

class AddQuotation extends QuotationBlocEvent {
  final Quotation quotation;
  const AddQuotation(this.quotation);

  @override
  List<Object> get props => [quotation];

  @override
  String toString() => 'Quotation Added { quotation: $quotation }';
}

class UpdateQuotation extends QuotationBlocEvent {
  final Quotation? quotation;
  const UpdateQuotation(this.quotation);

  @override
  List<Object?> get props => [quotation];

  @override
  String toString() => 'Quotation Updated { quotation: $quotation }';
}

class UpdateAndLoadQuotation extends QuotationBlocEvent {
  final Quotation? quotation;
  const UpdateAndLoadQuotation(this.quotation);

  @override
  List<Object?> get props => [quotation];

  @override
  String toString() => 'Quotation Updated { quotation: $quotation }';
}

class FindQuotation extends QuotationBlocEvent {
  final String? id;
  const FindQuotation(this.id);

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'Quotation Find: $id }';
}

class DeleteQuotation extends QuotationBlocEvent {
  final Quotation quotation;
  const DeleteQuotation(this.quotation);

  @override
  List<Object> get props => [quotation];

  @override
  String toString() => 'Quotation Updated { quotation: $quotation }';
}

class SortQuotation extends QuotationBlocEvent {
  final String? category;
  const SortQuotation(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteQuickQtn extends QuotationBlocEvent {
  final Quotation quotation;
  final QuickQuotation? quickQtn;
  const DeleteQuickQtn(this.quotation, this.quickQtn);

  @override
  List<Object?> get props => [quotation, quickQtn];

  @override
  String toString() => 'Quotation Updated { quotation: $quotation }';
}
