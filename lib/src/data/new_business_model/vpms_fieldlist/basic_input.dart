class BasicInput {
  final String? language;
  final String? quotationDate;
  final String? dateOfBirth;
  final String? gender;
  final String? occupational;
  final String? staff;
  final String? smoker;
  final String? paymentFrequency;
  final String? participantApplicable;
  final String? participantDateOfBirth;
  final String? participantGender;

  BasicInput(
      {this.language,
      this.quotationDate,
      this.dateOfBirth,
      this.gender,
      this.occupational,
      this.staff,
      this.smoker,
      this.paymentFrequency,
      this.participantApplicable,
      this.participantDateOfBirth,
      this.participantGender});

  factory BasicInput.fromMap(Map<String, dynamic> json) => BasicInput(
      language: json["Language"],
      quotationDate: json["QuotationDate"],
      dateOfBirth: json["DateOfBirth"],
      gender: json["Gender"],
      occupational: json["Occupational"],
      staff: json["Staff"],
      smoker: json["Smoker"],
      paymentFrequency: json["PaymentFrequency"],
      participantApplicable: json["ParticipantApplicable"],
      participantDateOfBirth: json["ParticipantDateOfBirth"],
      participantGender: json["ParticipantGender"]);
}
