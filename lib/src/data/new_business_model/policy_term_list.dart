class PolicyTermList {
  final String? clientType;
  final int? termFrom;
  final int? termTo;
  final int? minAgeMale;
  final int? maxAgeMale;
  final int? minAgeFemale;
  final int? maxAgeFemale;
  final int? lifeSeq;

  PolicyTermList({
    this.clientType,
    this.termFrom,
    this.termTo,
    this.minAgeMale,
    this.maxAgeMale,
    this.minAgeFemale,
    this.maxAgeFemale,
    this.lifeSeq,
  });

  factory PolicyTermList.fromMap(Map<String, dynamic> map) {
    return PolicyTermList(
        clientType: map['ClientType'],
        termFrom: map['TermFrom'],
        termTo: map['TermTo'],
        minAgeMale: map['MinAgeMale'],
        maxAgeMale: map['MaxAgeMale'],
        minAgeFemale: map['MinAgeFemale'],
        maxAgeFemale: map['MaxAgeFemale'],
        lifeSeq: map['LifeSeq']);
  }

  Map<String, dynamic> toMap() => {
        'ClientType': clientType,
        'TermFrom': termFrom,
        'TermTo': termTo,
        'MinAgeMale': minAgeMale,
        'MaxAgeMale': maxAgeMale,
        'MinAgeFemale': minAgeFemale,
        'MaxAgeFemale': maxAgeFemale,
        'LifeSeq': lifeSeq
      };
}
