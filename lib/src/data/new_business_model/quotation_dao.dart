import 'dart:async';
import 'dart:convert';

import 'package:ease/src/data/app_database.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/util/string_util.dart';
import 'package:intl/intl.dart';
import 'package:sembast/sembast.dart';

class QuotationDao {
  static const String quotationStoreName = 'quotations';
  // A Store with int keys and Map<String, dynamic> values.
  // This Store acts like a persistent map, values of which are Quotation objects converted to Map
  final StoreRef<int?, Map<String, Object?>> _quotationStore =
      intMapStoreFactory.store(quotationStoreName);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Database> get _db async => await AppDatabase.instance.database;

  // Toggle encrypt on/off
  bool isEncrypt = true;

  Future<int?> insert(Quotation quotation) async {
    //Insert function will return id
    int? id;
    String encodeJson = jsonEncode(quotation.toMap());
    String encryptedData = await encryptAES(encodeJson);

    if (isEncrypt) {
      Map<String, dynamic> encryptedQuote = {"encrypted": encryptedData};
      id = await _quotationStore.add(await _db, encryptedQuote);
    } else {
      id = await _quotationStore.add(await _db, quotation.toMap());
    }
    return id;
  }

  Future update(Quotation quotation) async {
    // For filtering by key (ID), RegEx, greater than, and many other criteria,
    // we use a Finder.
    String encodeJson = jsonEncode(quotation.toMap());
    String encryptedData = await encryptAES(encodeJson);
    Map<String, dynamic> encryptedQuote = {"encrypted": encryptedData};
    int? id;

    final finder = Finder(filter: Filter.byKey(quotation.id));
    if (isEncrypt) {
      id = await _quotationStore.update(await _db, encryptedQuote,
          finder: finder);
    } else {
      id = await _quotationStore.update(await _db, quotation.toMap(),
          finder: finder);
    }
    return id;
  }

  Future delete(Quotation quotation) async {
    final finder = Finder(filter: Filter.byKey(quotation.id));
    await _quotationStore.delete(await _db, finder: finder);
  }

  Future deleteQuickQuotationById(
      Quotation qtn, QuickQuotation? quickQtn) async {
    var quickQtnIndex = qtn.listOfQuotation!.indexWhere(
        (element) => element!.quickQuoteId == quickQtn!.quickQuoteId);

    try {
      if (quickQtnIndex != -1) {
        final finder = Finder(filter: Filter.byKey(qtn.id));
        qtn.listOfQuotation!.removeAt(quickQtnIndex);

        if (isEncrypt) {
          String encodeJson = jsonEncode(qtn.toMap());
          String encryptedData = await encryptAES(encodeJson);
          Map<String, dynamic> encryptedQuote = {"encrypted": encryptedData};

          await _quotationStore.update(await _db, encryptedQuote,
              finder: finder);
        } else {
          await _quotationStore.update(await _db, qtn.toMap(), finder: finder);
        }
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future sortByKey(String? category) async {
    // Random random = new Random();
    // bool randoms = random.nextBool();

    final finder = Finder(sortOrders: [SortOrder('category', true)]);

    final recordSnapshots =
        await _quotationStore.find(await _db, finder: finder);

    List<Quotation> data = [];
    List<Quotation> otherData = [];

    if (isEncrypt) {
      for (int i = 0; i < recordSnapshots.length; i++) {
        String resultString =
            await decryptAES(recordSnapshots[i].value['encrypted'] as String?);
        dynamic resultMap = jsonDecode(resultString);
        final quotation = Quotation.fromMap(resultMap);
        // An ID is a key of a record from the database.
        quotation.id = recordSnapshots[i].key;
        if (quotation.category == category) {
          data.add(quotation);
          // Temporary saved other category
        } else {
          otherData.add(quotation);
        }
      }

      // Once done, only then add other data
      for (int i = 0; i < otherData.length; i++) {
        if (!data.contains(otherData[i])) {
          data.add(otherData[i]);
        }
      }
    } else {
      // Making a List<Quotation> out of List<RecordSnapshot>
      var data = recordSnapshots.map((snapshot) {
        final quotation = Quotation.fromMap(snapshot.value);
        // An ID is a key of a record from the database.
        quotation.id = snapshot.key;
        return quotation;
      }).toList();

      // Simple workaround. Add data == category

      for (int i = 0; i < data.length; i++) {
        if (data[i].category == category) {
          data.add(data[i]);
        }
      }

      // Once done, only then add other data

      for (int i = 0; i < data.length; i++) {
        if (!data.contains(data[i])) {
          data.add(data[i]);
        }
      }
    }

    if (category == "High Potential" ||
        category == "Follow Up Required" ||
        category == "Low Potential") {
      data.sort((a, b) {
        int acategory = 4;
        int bcategory = 4;
        if (category == "High Potential") {
          acategory = a.category == "High Potential"
              ? 1
              : a.category == "Follow Up Required"
                  ? 2
                  : a.category == "Low Potential"
                      ? 3
                      : 4;
          bcategory = b.category == "High Potential"
              ? 1
              : b.category == "Follow Up Required"
                  ? 2
                  : b.category == "Low Potential"
                      ? 3
                      : 4;
        } else if (category == "Follow Up Required") {
          acategory = a.category == "Follow Up Required"
              ? 1
              : a.category == "High Potential"
                  ? 2
                  : a.category == "Low Potential"
                      ? 3
                      : 4;
          bcategory = b.category == "Follow Up Required"
              ? 1
              : b.category == "High Potential"
                  ? 2
                  : b.category == "Low Potential"
                      ? 3
                      : 4;
        } else if (category == "Low Potential") {
          acategory = a.category == "Low Potential"
              ? 1
              : a.category == "High Potential"
                  ? 2
                  : a.category == "Follow Up Required"
                      ? 3
                      : 4;
          bcategory = b.category == "Low Potential"
              ? 1
              : b.category == "High Potential"
                  ? 2
                  : b.category == "Follow Up Required"
                      ? 3
                      : 4;
        }
        return acategory.compareTo(bcategory);
      });
    } else if (category == "High to Low Premium (Monthly)" ||
        category == "High to Low Premium (Yearly)" ||
        category == "Low to High Premium (Monthly)" ||
        category == "Low to High Premium (Yearly)") {
      List<Quotation> sorted = [];
      List<Quotation> monthly = [];
      List<Quotation> quarterly = [];
      List<Quotation> halfYearly = [];
      List<Quotation> yearly = [];
      List<Quotation> nopaymode = [];

      for (var a in data) {
        if (a.listOfQuotation!.isNotEmpty) {
          if (a.listOfQuotation!.length > 1) {
            a.listOfQuotation!.sort((al, bl) {
              int av = al != null && al.version != null
                  ? int.tryParse(al.version!) ?? 1
                  : 1;
              int bv = bl != null && bl.version != null
                  ? int.tryParse(bl.version!) ?? 1
                  : 1;
              return av.compareTo(bv);
            });
          }
          int last = 0;
          if (a.listOfQuotation!.length > 1) {
            last = a.listOfQuotation!.length - 1;
          }
          QuickQuotation? aq = a.listOfQuotation![last];
          if (aq != null && aq.paymentMode != null) {
            if (aq.paymentMode == "1" || aq.paymentMode == "Monthly") {
              monthly.add(a);
            } else if (aq.paymentMode == "3" || aq.paymentMode == "Quarterly") {
              quarterly.add(a);
            } else if (aq.paymentMode == "6" ||
                aq.paymentMode == "Half Yearly") {
              halfYearly.add(a);
            } else if (aq.paymentMode == "12" || aq.paymentMode == "Yearly") {
              yearly.add(a);
            } else {
              nopaymode.add(a);
            }
          } else {
            nopaymode.add(a);
          }
        } else {
          nopaymode.add(a);
        }
      }

      int sortPrem(a, b) {
        QuickQuotation? aq;
        QuickQuotation? bq;
        if (a.listOfQuotation.length != null && a.listOfQuotation.length != 0) {
          int? last = 0;
          if (a.listOfQuotation.length > 1) {
            last = a.listOfQuotation.length - 1;
            a.listOfQuotation.sort((al, bl) {
              int av = al != null && al.version != null
                  ? int.tryParse(al.version) ?? 1
                  : 1;
              int bv = bl != null && bl.version != null
                  ? int.tryParse(bl.version) ?? 1
                  : 1;
              return av.compareTo(bv);
            });
          }
          aq = a.listOfQuotation[last];
        }

        if (b.listOfQuotation != null && b.listOfQuotation.length != 0) {
          int? last = 0;
          if (b.listOfQuotation.length > 1) {
            last = b.listOfQuotation.length - 1;
            b.listOfQuotation.sort((al, bl) {
              int av = al != null && al.version != null
                  ? int.tryParse(al.version) ?? 1
                  : 1;
              int bv = bl != null && bl.version != null
                  ? int.tryParse(bl.version) ?? 1
                  : 1;
              return av.compareTo(bv);
            });
          }
          bq = b.listOfQuotation[last];
        }

        double ap = aq != null && aq.totalPremium != null
            ? double.tryParse(aq.totalPremium!) ?? 0
            : 0;
        double bp = bq != null && bq.totalPremium != null
            ? double.tryParse(bq.totalPremium!) ?? 0
            : 0;

        if (ap == bp) {
          return 0;
        } else if (ap < bp) {
          return (category == "High to Low Premium (Monthly)" ||
                  category == "High to Low Premium (Yearly)")
              ? 1
              : -1;
        } else {
          return (category == "High to Low Premium (Monthly)" ||
                  category == "High to Low Premium (Yearly)")
              ? -1
              : 1;
        }
      }

      monthly.sort((a, b) => sortPrem(a, b));
      quarterly.sort((a, b) => sortPrem(a, b));
      halfYearly.sort((a, b) => sortPrem(a, b));
      yearly.sort((a, b) => sortPrem(a, b));

      if (category == "High to Low Premium (Monthly)" ||
          category == "Low to High Premium (Monthly)") {
        sorted.addAll(monthly);
        sorted.addAll(quarterly);
        sorted.addAll(halfYearly);
        sorted.addAll(yearly);
        sorted.addAll(nopaymode);
      } else {
        sorted.addAll(yearly);
        sorted.addAll(halfYearly);
        sorted.addAll(quarterly);
        sorted.addAll(monthly);
        sorted.addAll(nopaymode);
      }

      data = sorted;
    } else {
      data.sort((a, b) {
        DateTime adate = DateTime.now();
        DateTime bdate = DateTime.now();
        if (a.listOfQuotation!.isNotEmpty) {
          adate = DateFormat("dd MMM yyyy").parse(
              a.listOfQuotation![a.listOfQuotation!.length - 1]!.dateTime!);
        }
        if (b.listOfQuotation!.isNotEmpty) {
          bdate = DateFormat("dd MMM yyyy").parse(
              b.listOfQuotation![b.listOfQuotation!.length - 1]!.dateTime!);
        }
        return bdate.compareTo(adate);
      });
    }
    return data;
  }

  Future<List<Quotation>> getAllSortedByName() async {
    // Finder object can also sort data.
    final finder = Finder(sortOrders: [SortOrder('name')]);

    final recordSnapshots =
        await _quotationStore.find(await _db, finder: finder);

    List<Quotation> data = [];

    if (isEncrypt) {
      for (int i = 0; i < recordSnapshots.length; i++) {
        String resultString =
            await decryptAES(recordSnapshots[i].value['encrypted'] as String?);
        dynamic resultMap = jsonDecode(resultString);
        final quotation = Quotation.fromMap(resultMap);
        // An ID is a key of a record from the database.
        quotation.id = recordSnapshots[i].key;
        data.add(quotation);
      }

      data.sort((a, b) => a.policyOwner!.name!
          .toUpperCase()
          .compareTo(b.policyOwner!.name!.toUpperCase()));
      return data;
    } else {
      // Making a List<Quotation> out of List<RecordSnapshot>
      data = recordSnapshots.map((snapshot) {
        final quotation = Quotation.fromMap(snapshot.value);
        // An ID is a key of a record from the database.
        quotation.id = snapshot.key;
        return quotation;
      }).toList();

      data.sort((a, b) => a.policyOwner!.name!
          .toUpperCase()
          .compareTo(b.policyOwner!.name!.toUpperCase()));

      return data;
    }
  }

  Future<dynamic> getDataByID(int? id) async {
    try {
      if (isEncrypt) {
        var record = await (_quotationStore.record(id).get(await _db));
        String resultString = await decryptAES(record!['encrypted'] as String?);
        dynamic resultMap = jsonDecode(resultString);
        return resultMap;
      } else {
        var record = await _quotationStore.record(id).get(await _db);
        return record;
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Future updateData(obj) async {
    String encodeJson = jsonEncode(obj.toMap());
    String encryptedData = await encryptAES(encodeJson);
    if (isEncrypt) {
      Map<String, dynamic> encryptedQuote = {"encrypted": encryptedData};
      await _quotationStore
          .record(obj["id"])
          .put(await _db, encryptedQuote, merge: true);
    } else {
      await _quotationStore.record(obj["id"]).put(await _db, obj, merge: true);
    }
  }
}
