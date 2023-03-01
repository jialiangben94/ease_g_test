class Journey {
  int? journeyId;
  String? journeyDesc;
  bool? isCompleted;
  String? statusDateTime;
  String? status;

  Journey({
    this.journeyId,
    this.journeyDesc,
    this.isCompleted,
    this.statusDateTime,
    this.status,
  });

  factory Journey.fromJson(Map<String, dynamic> parsedJson) {
    return Journey(
      journeyId: parsedJson['JourneyID'],
      journeyDesc: parsedJson['JourneyDesc'],
      isCompleted: parsedJson['IsCompleted'],
      statusDateTime: parsedJson['StatusDateTime'],
      status: parsedJson['Status'],
    );
  }
}
