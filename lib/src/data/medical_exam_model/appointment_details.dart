import 'package:ease/src/data/medical_exam_model/appointment_request.dart';
import 'package:ease/src/data/medical_exam_model/panel.dart';

enum CancelBy { user, panel }

enum CancelReason {
  noSlotAvailable,
  doctorNotAvailable,
  equipmentNotInService,
  others
}

class AppointmentDetails {
  String? id;
  AppointmentRequest? appointmentRequest;
  String? agentCode;
  Panel? selectedPanels;
  CancelBy? cancelledBy;
  DateTime? cancelledOn;
  CancelReason? cancelReason;
  String? cancelReasonExt;
  // String medicalCheckType;
  String? appointmentDateTime;
  String? timeRange;
  String? appointmentCode;

  AppointmentDetails(
      {this.id,
      this.appointmentRequest,
      this.agentCode,
      this.selectedPanels,
      this.cancelledBy,
      this.cancelledOn,
      this.cancelReason,
      this.cancelReasonExt,
      this.appointmentDateTime,
      this.timeRange,
      this.appointmentCode});

  String sortAddress(
      {String? addressOne,
      String? addressTwo,
      String? addressThree,
      String? postcode,
      String? city}) {
    final String newAddress = (addressOne != "" ? "${addressOne!} " : "") +
        (addressTwo != "" ? "${addressTwo!} " : "") +
        (addressThree != "" ? "${addressThree!} " : "") +
        (postcode != "" ? "${postcode!} " : "") +
        (city != "" ? "${city!} " : "");

    return newAddress;
  }

  // Convert to JSON for submit appointment API
  Map<String, dynamic> toJson(String? facilityCode) => {
        "ClientID": appointmentRequest!.client!.clientId,
        "UserID": agentCode,
        "ProposalMEId": appointmentRequest!.proposalMEId,
        "PanelCode": selectedPanels!.providerCode,
        "PanelName": selectedPanels!.name,
        "PanelAddress": selectedPanels!.address,
        "PanelWorkingHours": selectedPanels!.bizHrs,
        "PanelContactNo": selectedPanels!.contact,
        "CustomerAddress": sortAddress(
            addressOne: appointmentRequest!.client!.addressOne,
            addressTwo: appointmentRequest!.client!.addressTwo,
            addressThree: appointmentRequest!.client!.addressThree,
            postcode: appointmentRequest!.client!.postcode,
            city: appointmentRequest!.client!.city),
        "AppointmentDate": appointmentDateTime,
        "AppointmentSlot": timeRange,
        "PanelType": selectedPanels!.providerType,
        "PolicyName": appointmentRequest!.productName,
        "QuotationNo": appointmentRequest!.ssProposalNo,
        "AppointmentCode": appointmentCode,
        "FacilityCode": facilityCode
      };
  // Convert to JSON for submit appointment API
  Map<String, dynamic> toCancelJson() => {
        "UserID": agentCode,
        "ProposalMEId": appointmentRequest!.proposalMEId,
        "AppointmentCode": appointmentCode
      };
}
