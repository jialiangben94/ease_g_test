class MasterLookup {
  final int? optionType;
  final int? id;
  final int? typeId;
  final String? name;
  final String? callValue;
  final String? remark;
  final bool? isActive;

  MasterLookup(
      {this.optionType,
      this.id,
      this.typeId,
      this.name,
      this.callValue,
      this.remark,
      this.isActive});

  factory MasterLookup.fromMap(Map<String, dynamic> map) {
    return MasterLookup(
        optionType: map['OptionType'],
        id: map['Id'],
        typeId: map['TypeId'],
        name: map['Name'],
        callValue: map['CallValue'],
        remark: map['Remark'],
        isActive: map['IsActive']);
  }

  Map<String, dynamic> toJson() => {
        'OptionType': optionType,
        'Id': id,
        'TypeId': typeId,
        'Name': name,
        'CallValue': callValue,
        'Remark': remark,
        'IsActive': isActive
      };
}

class MasterLookupType {
  final int? id;
  final String? name;
  final String? remark;
  final bool? isActive;

  MasterLookupType({this.id, this.name, this.remark, this.isActive});

  factory MasterLookupType.fromMap(Map<String, dynamic> map) {
    return MasterLookupType(
        id: map['Id'],
        name: map['Name'],
        remark: map['Remark'],
        isActive: map['IsActive']);
  }

  Map<String, dynamic> toJson() =>
      {'Id': id, 'Name': name, 'Remark': remark, 'IsActive': isActive};
}

class BankLookUp {
  final int? id;
  final String? bankCode;
  final String? name;
  final String? accountTypeCode;
  final int? accountNumLength;

  BankLookUp(
      {this.id,
      this.bankCode,
      this.name,
      this.accountTypeCode,
      this.accountNumLength});

  factory BankLookUp.fromMap(Map<String, dynamic> map) {
    return BankLookUp(
        id: map['Id'],
        bankCode: map['BankCode'],
        name: map['Name'],
        accountTypeCode: map['AccountTypeCode'],
        accountNumLength: map['AccountNumLength']);
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'BankCode': bankCode,
        'Name': name,
        'AccountTypeCode': accountTypeCode,
        'AccountNumLength': accountNumLength
      };
}

class TranslationLookUp {
  final int? id;
  final String? tableName;
  final String? primaryKey;
  final int? languageId;
  final String? field;
  final String? text;

  TranslationLookUp(
      {this.id,
      this.tableName,
      this.primaryKey,
      this.languageId,
      this.field,
      this.text});

  factory TranslationLookUp.fromMap(Map<String, dynamic> map) {
    return TranslationLookUp(
        id: map['Id'],
        tableName: map['TableName'],
        primaryKey: map['PrimaryKey'],
        languageId: map['LanguageId'],
        field: map['Field'],
        text: map['Text']);
  }

  Map<String, dynamic> toJson() => {
        'Id': id,
        'TableName': tableName,
        'PrimaryKey': primaryKey,
        'LanguageId': languageId,
        'Field': field,
        'Text': text
      };
}
