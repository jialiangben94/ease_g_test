class Agent {
  List<Address>? userAddress;
  String? accountStatus;
  String? fullName;
  String? accountCode;
  String? emailAddress;
  String? mobilePhone;
  String? homePhone;
  String? officePhone;
  String? profilePhoto;

  String? branchCode;
  String? branchName;
  String? agentCodes;
  String? agentCodeMotor;
  String? agentType;
  String? agentSubType;
  double? agentComissionSetup;
  bool? agentGSTIndicator;
  int? iBusinessEntityID;
  String? agentCodeNonMotor;
  bool? allowIssueEPolicy;
  String? strictlyCBC;
  bool? strictlyCBCNonMotor;
  String? accountType;
  String? userLocation;
  String? pinNo;
  String? agencyName;
  String? username;
  BusinessEntity? businessEntity;
  String? products;
  List<Manager>? managers;
  String? lastAuthenticatedDate;

  Agent(
      {this.userAddress,
      this.accountStatus,
      this.fullName,
      this.accountCode,
      this.emailAddress,
      this.mobilePhone,
      this.homePhone,
      this.officePhone,
      this.profilePhoto,
      this.branchCode,
      this.branchName,
      this.agentCodes,
      this.agentCodeMotor,
      this.agentType,
      this.agentSubType,
      this.agentComissionSetup,
      this.agentGSTIndicator,
      this.iBusinessEntityID,
      this.agentCodeNonMotor,
      this.allowIssueEPolicy,
      this.strictlyCBC,
      this.strictlyCBCNonMotor,
      this.accountType,
      this.userLocation,
      this.pinNo,
      this.agencyName,
      this.username,
      this.businessEntity,
      this.products,
      this.managers,
      this.lastAuthenticatedDate});

  factory Agent.fromJson(Map<String, dynamic> parsedJson) {
    return Agent(
        userAddress: (parsedJson['ListUserAddress'] as List)
            .map((i) => Address.fromJson(i))
            .toList(),
        accountStatus: parsedJson["AccountStatus"],
        fullName: parsedJson["FullName"],
        accountCode: parsedJson["AccountCode"],
        emailAddress: parsedJson["EmailAddress"],
        mobilePhone: parsedJson["MobilePhone"],
        homePhone: parsedJson["HomePhone"],
        officePhone: parsedJson["OfficePhone"],
        profilePhoto: parsedJson["ProfilePhoto"],
        branchCode: parsedJson["BranchCode"],
        branchName: parsedJson["BranchName"],
        agentCodes: parsedJson["AgentCodes"],
        agentCodeMotor: parsedJson["agentCodeMotor"],
        agentType: parsedJson["agentType"],
        agentSubType: parsedJson["agentSubType"],
        agentComissionSetup: parsedJson["agentComissionSetup"],
        agentGSTIndicator: parsedJson["agentGSTIndicator"],
        iBusinessEntityID: parsedJson["i_BusinessEntityID"],
        agentCodeNonMotor: parsedJson["agentCodeNonMotor"],
        allowIssueEPolicy: parsedJson["allowIssueEPolicy"],
        strictlyCBC: parsedJson["strictlyCBC"],
        strictlyCBCNonMotor: parsedJson["strictlyCBCNonMotor"],
        accountType: parsedJson["AccountType"],
        userLocation: parsedJson["userLocation"],
        pinNo: parsedJson["PINNo"],
        agencyName: parsedJson["AgencyName"],
        username: parsedJson["Username"],
        businessEntity: BusinessEntity.fromJson(parsedJson['BusinessEntity']),
        products: parsedJson["Products"],
        managers: (parsedJson['Managers'] as List)
            .map((i) => Manager.fromJson(i))
            .toList(),
        lastAuthenticatedDate: parsedJson["LastLoginDateTime"] != null &&
                parsedJson["LastLoginDateTime"]["LastLoginDateTime"] != null
            ? parsedJson["LastLoginDateTime"]["LastLoginDateTime"]
            : "");
  }

  Map<String, dynamic> toJson() => {
        "ListUserAddress": userAddress,
        "AccountStatus": accountStatus,
        "FullName": fullName,
        "AccountCode": accountCode,
        "EmailAddress": emailAddress,
        "MobilePhone": mobilePhone,
        "HomePhone": homePhone,
        "OfficePhone": officePhone,
        "ProfilePhoto": profilePhoto,
        "BranchCode": branchCode,
        "BranchName": branchName,
        "AgentCodes": agentCodes,
        "agentCodeMotor": agentCodeMotor,
        "agentType": agentType,
        "agentSubType": agentSubType,
        "gentComissionSetup": agentComissionSetup,
        "agentGSTIndicator": agentGSTIndicator,
        "i_BusinessEntityID": iBusinessEntityID,
        "agentCodeNonMotor": agentCodeNonMotor,
        "allowIssueEPolicy": allowIssueEPolicy,
        "strictlyCBC": strictlyCBC,
        "strictlyCBCNonMotor": strictlyCBCNonMotor,
        "AccountType": accountType,
        "userLocation": userLocation,
        "PINNo": pinNo,
        "AgencyName": agencyName,
        "Username": username,
        "BusinessEntity": businessEntity,
        "Products": products,
        "Managers": managers,
        "LastLoginDateTime": {
          "LastLoginDateTime":
              lastAuthenticatedDate ?? DateTime.now().toString()
        }
      };
}

class Address {
  String? addressType;
  String? adr1;
  String? adr2;
  String? adr3;
  String? postcode;
  String? state;
  String? city;
  String? country;

  Address(
      {this.addressType,
      this.adr1,
      this.adr2,
      this.adr3,
      this.postcode,
      this.state,
      this.city,
      this.country});

  factory Address.fromJson(Map<String, dynamic> parsedJson) {
    return Address(
        addressType: parsedJson['AddressType'],
        adr1: parsedJson['Adr1'],
        adr2: parsedJson['Adr2'],
        adr3: parsedJson['Adr3'],
        postcode: parsedJson['Postcode'],
        state: parsedJson['State'],
        city: parsedJson['City'],
        country: parsedJson['Country']);
  }

  Map<String, dynamic> toJson() => {
        'AddressType': addressType,
        'Adr1': adr1,
        'Adr2': adr2,
        'Adr3': adr3,
        'Postcode': postcode,
        'State': state,
        'City': city,
        'Country': country
      };
}

class AgentDetailGAD {
  String? agentType;
  String? agentName1;

  AgentDetailGAD({this.agentType, this.agentName1});

  factory AgentDetailGAD.fromJson(Map<String, dynamic> parsedJson) {
    return AgentDetailGAD(
        agentType: parsedJson['AgentType'],
        agentName1: parsedJson['AgentName1']);
  }

  Map<String, dynamic> toJson() =>
      {'AgentType': agentType, 'AgentName1': agentName1};
}

class BusinessEntity {
  int? entityID;
  String? entityCode;
  String? entityName;

  BusinessEntity({this.entityID, this.entityCode, this.entityName});

  factory BusinessEntity.fromJson(Map<String, dynamic> parsedJson) {
    return BusinessEntity(
        entityID: parsedJson['EntityID'],
        entityCode: parsedJson['EntityCode'],
        entityName: parsedJson['EntityName']);
  }

  Map<String, dynamic> toJson() => {
        'EntityID': entityID,
        'EntityCode': entityCode,
        'EntityName': entityName
      };
}

class Manager {
  String? ranking;
  String? pfNumber;
  String? fullName;
  String? emailAddress;

  Manager({this.ranking, this.pfNumber, this.fullName, this.emailAddress});

  factory Manager.fromJson(Map<String, dynamic> parsedJson) {
    return Manager(
        ranking: parsedJson['Ranking'],
        pfNumber: parsedJson['PFNumber'],
        fullName: parsedJson['FullName'],
        emailAddress: parsedJson['EmailAddress']);
  }

  Map<String, dynamic> toJson() => {
        'Ranking': ranking,
        'PFNumber': pfNumber,
        'FullName': fullName,
        'EmailAddress': emailAddress
      };
}

class LoginDetails {
  String? username;
  String? password;
  String? appCode;
  int? businessEntityID;
  String? uuid;

  LoginDetails(
      {this.username,
      this.password,
      this.appCode,
      this.businessEntityID,
      this.uuid});

  factory LoginDetails.fromJson(Map<String, dynamic> parsedJson) {
    return LoginDetails(
        username: parsedJson['AccountCode'],
        password: parsedJson['Password'],
        appCode: parsedJson['AppCode'],
        businessEntityID: parsedJson['password'],
        uuid: parsedJson['password']);
  }

  Map<String, dynamic> toJson() => {
        "AccountCode": username,
        "Password": password,
        "AppCode": appCode,
        "BusinessEntityID": businessEntityID,
        "UUiD": uuid
      };
}
