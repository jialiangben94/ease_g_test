class ParticipantInput {
  final String? relationship;
  final String? participantRelationship;
  final String? participantDateOfBirth;
  final String? participantGender;
  final String? participantOccupational;
  final String? participantSmoker;

  ParticipantInput(
      {this.relationship,
      this.participantRelationship,
      this.participantDateOfBirth,
      this.participantGender,
      this.participantOccupational,
      this.participantSmoker});

  factory ParticipantInput.fromMap(Map<String, dynamic> json) =>
      ParticipantInput(
          relationship: json["Relationship"],
          participantRelationship: json["ParticipantRelationship"],
          participantDateOfBirth: json["ParticipantDateOfBirth"],
          participantGender: json["ParticipantGender"],
          participantOccupational: json["ParticipantOccupational"],
          participantSmoker: json["ParticipantSmoker"]);
}
