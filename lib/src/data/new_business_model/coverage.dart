class Coverage {
  final String? name;
  final String? nric;
  final String? idnum;
  final String? dob;
  final String? agenextbirthdate;
  final String? gender;
  final String? nationality;
  final String? maritalStatus;
  final String? company;
  final String? startDate;
  final String? maturityDate;
  final String? policyName;
  final String? policyNumber;
  final String? policyStatus;
  final String? policyType;
  final double? sumInsured;
  final double? planlumpsummaturity;
  final double? planincomematurity;
  final double? totalPremiumAmt;
  final String? additionalbenefit;

  Coverage(
      {this.name,
      this.nric,
      this.idnum,
      this.dob,
      this.agenextbirthdate,
      this.gender,
      this.nationality,
      this.maritalStatus,
      this.company,
      this.policyName,
      this.policyStatus,
      this.policyNumber,
      this.policyType,
      this.sumInsured,
      this.planlumpsummaturity,
      this.planincomematurity,
      this.totalPremiumAmt,
      this.startDate,
      this.maturityDate,
      this.additionalbenefit});

  Map<String, dynamic> toJson() {
    return {
      'FullName': name,
      'NRIC': nric,
      'IDNumber': idnum,
      'DateofBirth': dob,
      'agenextbirthdate': agenextbirthdate,
      'Gender': gender,
      'Nationality': nationality,
      'MaritalStatus': maritalStatus,
      'Company': company,
      'PolicyName': policyName,
      'PolicyNumber': policyNumber,
      'PolicyStatus': policyStatus,
      'plantype': policyType,
      'SumInsured': sumInsured,
      'planlumpsummaturity': planlumpsummaturity,
      'planincomematurity': planincomematurity,
      'TotalPremiumAmt': totalPremiumAmt,
      'StartDate': startDate,
      'MaturityDate': maturityDate,
      'additionalbenefit': additionalbenefit
    };
  }

  factory Coverage.fromMap(Map<String, dynamic> map) {
    return Coverage(
        name: map['FullName'],
        nric: map['NRIC'],
        idnum: map['IDNumber'],
        dob: map['DateofBirth'],
        gender: map['Gender'],
        nationality: map['Nationality'],
        maritalStatus: map['MaritalStatus'],
        company: map['Company'],
        policyName: map['PolicyName'],
        policyNumber: map['PolicyNumber'],
        policyStatus: map['PolicyStatus'],
        policyType: map['PolicyType'],
        sumInsured: map['SumInsured'] != null
            ? map['SumInsured'] is double
                ? map['SumInsured']
                : double.tryParse(map['SumInsured'])
            : 0,
        totalPremiumAmt: map['TotalPremiumAmt'] != null
            ? map['TotalPremiumAmt'] is double
                ? map['TotalPremiumAmt']
                : double.tryParse(map['TotalPremiumAmt'])
            : 0,
        startDate: map['StartDate'],
        maturityDate: map['MaturityDate']);
  }

  factory Coverage.fromMap2(Map<String, dynamic> map) {
    return Coverage(
        name: map['planpolicyowner'],
        agenextbirthdate: map['agenextbirthdate'],
        company: map['plancompany'],
        policyName: map['planname'],
        policyType: map['plantype'],
        planlumpsummaturity: map['planlumpsummaturity'] != null
            ? map['planlumpsummaturity'] is double
                ? map['planlumpsummaturity']
                : double.tryParse(map['planlumpsummaturity'])
            : 0,
        planincomematurity: map['planincomematurity'] != null
            ? map['planincomematurity'] is double
                ? map['planincomematurity']
                : double.tryParse(map['planincomematurity'])
            : 0,
        totalPremiumAmt: map['planpremiumamount'] != null
            ? map['planpremiumamount'] is double
                ? map['planpremiumamount']
                : double.tryParse(map['planpremiumamount'])
            : 0,
        startDate: map['planstartdate'],
        maturityDate: map['planmaturitydate'],
        additionalbenefit: map['additionalbenefit']);
  }
}
