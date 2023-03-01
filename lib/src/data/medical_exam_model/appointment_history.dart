class AppointmentHistory {
  String? mcsAppointmentCode;
  String? appointmentDate;
  String? appointmentSlot;
  String? panelCode;
  String? panelName;
  String? panelAddress;
  String? panelWorkingHours;
  String? panelContactNo;
  String? panelType;
  String? panelLatitude;
  String? panelLongitude;
  String? appointmentStatus;
  String? createdDateTime;
  String? modifiedDateTime;
  String? modifiedBy;
  String? remarks;
  String? appointmentSubStatus;

  AppointmentHistory(
      {this.mcsAppointmentCode,
      this.appointmentDate,
      this.appointmentSlot,
      this.panelCode,
      this.panelName,
      this.panelAddress,
      this.panelWorkingHours,
      this.panelContactNo,
      this.panelType,
      this.panelLatitude,
      this.panelLongitude,
      this.appointmentStatus,
      this.createdDateTime,
      this.modifiedDateTime,
      this.modifiedBy,
      this.remarks,
      this.appointmentSubStatus});

  factory AppointmentHistory.fromJson(Map<String, dynamic> parsedJson) {
    return AppointmentHistory(
        mcsAppointmentCode: parsedJson['MCSAppointmentCode'],
        appointmentDate: parsedJson['AppointmentDate'],
        appointmentSlot: parsedJson['AppointmentSlot'],
        panelCode: parsedJson['PanelCode'],
        panelName: parsedJson['PanelName'],
        panelAddress: parsedJson['PanelAddress'],
        panelWorkingHours: parsedJson['PanelWorkingHours'],
        panelContactNo: parsedJson['PanelContactNo'],
        panelType: parsedJson['PanelType'],
        panelLatitude: parsedJson['Latitude'],
        panelLongitude: parsedJson['Longitude'],
        appointmentStatus: parsedJson['AppointmentStatus'],
        createdDateTime: parsedJson['CreatedDateTime'],
        modifiedDateTime: parsedJson['ModifiedDateTime'],
        modifiedBy: parsedJson["ModifiedBy"],
        remarks: parsedJson['Remarks'],
        appointmentSubStatus: parsedJson['AppointmentSubStatus']);
  }
}
