import 'dart:io';

class MedicalLetter {
  int? documentId;
  String? fileName;
  String? fileExtension;
  String? base64;
  File? file;
  String? createdDateTime;
  String? modifiedDateTime;

  MedicalLetter(
      {this.documentId,
      this.fileName,
      this.fileExtension,
      this.base64,
      this.createdDateTime,
      this.modifiedDateTime});

  factory MedicalLetter.fromJson(Map<String, dynamic> parsedJson) {
    return MedicalLetter(
        fileName: parsedJson['FileName'],
        fileExtension: parsedJson['Extension'],
        base64: parsedJson['Base64'],
        documentId: parsedJson['DocumentId'],
        createdDateTime: parsedJson['CreatedDateTime'],
        modifiedDateTime: parsedJson['ModifiedDateTime']);
  }

  Map<String, dynamic> toJson() => {
        'Filename': fileName,
        'Extension': fileExtension,
        'Base64': base64,
        'DocumentId': documentId,
        'CreatedDateTime': createdDateTime,
        'ModifiedDateTime': modifiedDateTime
      };
}
