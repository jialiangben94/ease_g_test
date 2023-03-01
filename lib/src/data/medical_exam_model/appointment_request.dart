import 'package:ease/src/data/medical_exam_model/appointment_history.dart';

enum ProgressStatus {
  checkUpDone,
  partialReportSubmitted,
  fullReportSubmitted,
  etiqaFeedback,
  revision,
  completed
}

class AppointmentRequest {
  String? propNo;
  String? ssProposalNo;
  String? requestDate;
  String? prodCode;
  String? productName;
  String? documentId;
  String? proposalMEId;
  String? appointmentStatus;
  String? proposalStatus;
  Client? client;
  List<AppointmentHistory>? appointmentHistory;

  AppointmentRequest(
      {this.propNo,
      this.ssProposalNo,
      this.requestDate,
      this.prodCode,
      this.productName,
      this.documentId,
      this.proposalMEId,
      this.appointmentStatus,
      this.proposalStatus,
      this.client,
      this.appointmentHistory});

  factory AppointmentRequest.fromJson(Map<String, dynamic> parsedJson) {
    return AppointmentRequest(
        propNo: parsedJson['PropNo'].toString(),
        ssProposalNo: parsedJson['SSProposalNo'].toString(),
        requestDate: parsedJson['RequestDate'].toString(),
        prodCode: parsedJson['ProdCode'].toString(),
        productName: parsedJson['ProductName'].toString(),
        documentId: parsedJson['DocumentId'].toString(),
        proposalMEId: parsedJson['ProposalMEId'].toString(),
        appointmentStatus: parsedJson['Status'].toString(),
        proposalStatus: parsedJson['ProposalStatus'].toString(),
        client: Client.fromJson(parsedJson['ClientDetail']),
        appointmentHistory: (parsedJson['AppointmentHistory'] as List)
            .map((i) => AppointmentHistory.fromJson(i))
            .toList());
  }
}

class Client {
  bool? isPO;
  String? poName;
  String? clientType;
  String? clientId;
  String? clientName;
  String? addressOne;
  String? addressTwo;
  String? addressThree;
  String? city;
  String? postcode;
  String? stateCode;
  String? countryCode;
  List<AssesmentList>? assestmentList;

  Client(
      {this.isPO,
      this.poName,
      this.clientType,
      this.clientId,
      this.clientName,
      this.addressOne,
      this.addressTwo,
      this.addressThree,
      this.city,
      this.postcode,
      this.stateCode,
      this.countryCode,
      this.assestmentList});

  factory Client.fromJson(Map<String, dynamic> parsedJson) {
    return Client(
        isPO: parsedJson['IsPO'],
        poName: parsedJson['POName'],
        clientType: parsedJson['ClientType'].toString(),
        clientId: parsedJson['ClientID'].toString(),
        clientName: parsedJson['ClientName'].toString(),
        addressOne: parsedJson['Adr1'].toString(),
        addressTwo: parsedJson['Adr2'].toString(),
        addressThree: parsedJson['Adr3'].toString(),
        city: parsedJson['City'].toString(),
        postcode: parsedJson['PostCode'].toString(),
        stateCode: parsedJson['StateCode'].toString(),
        countryCode: parsedJson['CntryCode'].toString(),
        assestmentList: (parsedJson['assessmentList'] as List)
            .map((i) => AssesmentList.fromJson(i))
            .toList());
  }
}

class AssesmentList {
  String? examCode;
  String? examDesc;

  AssesmentList({this.examCode, this.examDesc});

  factory AssesmentList.fromJson(Map<String, dynamic> parsedJson) {
    return AssesmentList(
        examCode: parsedJson['examCode'].toString(),
        examDesc: parsedJson['examDesc'].toString());
  }
}
