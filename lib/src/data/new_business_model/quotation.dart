import 'dart:convert';

import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/util/function.dart';

class Quotation {
  // Id will be gotten from the database.
  // It's automatically generated & unique for every stored Quotation.
  int? id;
  final String? uid;
  String? buyingFor;
  String? progress;
  // "1" - In Customer Details" | "2" - Choose Product | "3" Quotation generated
  String? category; // "High Potential" / "Follow Up Required" / "Uncategorised"
  String? agentCode;
  String? agentName;
  Person? lifeInsured;
  Person? policyOwner;
  bool? isSetReminder;
  String? reminderDate;
  List<QuickQuotation?>? listOfQuotation;

  Quotation(
      {this.id,
      this.uid,
      this.progress,
      this.category,
      this.buyingFor,
      this.agentCode,
      this.lifeInsured,
      this.policyOwner,
      this.isSetReminder,
      this.reminderDate,
      this.listOfQuotation});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'category': category ?? "Uncategorized",
      'buyingFor': buyingFor,
      'progress': progress,
      'agentCode': agentCode,
      'lifeInsured': jsonEncode(lifeInsured!.toJson()),
      'policyOwner': jsonEncode(policyOwner!.toJson()),
      'isSetReminder': isSetReminder,
      'reminderDetails': reminderDate,
      'listOfQuotation': listOfQuotation != null
          ? listOfQuotation!
              .map((data) => data!.toMap())
              .toList(growable: false)
          : []
    };
  }

  // JSON structure for quotation history API
  Map<String, dynamic> toJsonServer(QuickQuotation? quickQuotation,
      String action, Agent agent, String? isGIO) {
    List<Person?> listOfClient = [];
    List<QuickQuotation?> listOfQuickQtn = [];
    listOfQuickQtn.add(quickQuotation);
    listOfClient.add(lifeInsured);
    var prefLang = lifeInsured!.preferlanguage;
    // If policy owner is not same as life insured (client type != 3), add to client list
    if (policyOwner!.clientType == "1") {
      listOfClient.add(policyOwner);
    }

    return {
      'id': id,
      'uid': uid,
      'category': category ?? "Uncategorized",
      'isGIO': isGIO,
      'buyingFor': buyingFor,
      'progress': progress,
      'agentCode': agent.accountCode,
      'agentName': agent.fullName,
      'mobileNo': agent.mobilePhone,
      'clientList':
          listOfClient.map((data) => data!.toJsonAPI()).toList(growable: false),
      'isSetReminder': isSetReminder,
      'reminderDetails': reminderDate,
      'listOfQuotation': listOfQuickQtn
          .map((data) => data!.toJsonServer())
          .toList(growable: false),
      'Action': action,
      'PreferredLanguage': prefLang ?? getLocale("ENG")
    };
  }

  static Quotation fromMap(Map<String, dynamic> map) {
    return Quotation(
        id: map["id"],
        uid: map["uid"],
        buyingFor: map["buyingFor"],
        category: map['category'],
        progress: map["progress"],
        agentCode: map["agentCode"],
        lifeInsured: Person.fromJson(jsonDecode(map['lifeInsured'])),
        policyOwner: Person.fromJson(jsonDecode(map['policyOwner'])),
        isSetReminder: map['isSetReminder'],
        reminderDate: map['reminderDetails'],
        listOfQuotation: map['listOfQuotation']
            .map((mapping) => QuickQuotation.fromMap(mapping))
            .toList()
            .cast<QuickQuotation>());
  }
}
