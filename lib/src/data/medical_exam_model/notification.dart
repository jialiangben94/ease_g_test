class Notifications {
  String? id;
  String? topic;
  String? title;
  String? body;
  String? refType;
  String? refId;
  String? tabId;
  bool? isRead;

  Notifications(
      {this.id,
      this.topic,
      this.title,
      this.body,
      this.refType,
      this.refId,
      this.tabId,
      this.isRead});

  factory Notifications.fromJson(Map<String, dynamic> parsedJson) {
    return Notifications(
      id: parsedJson["Id"].toString(),
      topic: parsedJson['Topic'].toString(),
      title: parsedJson['Title'].toString(),
      body: parsedJson['Body'].toString(),
      refType: parsedJson['RefType'].toString(),
      refId: parsedJson['RefId'].toString(),
      tabId: parsedJson['TabId'].toString(),
      isRead: parsedJson['IsRead'],
    );
  }
}
