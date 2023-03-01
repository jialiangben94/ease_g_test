import 'package:ease/src/data/app_database.dart';
import 'package:sembast/sembast.dart';

class ApplicationDao {
  static const String storeName = 'application';
  final _store = intMapStoreFactory.store(storeName);
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int?> insert(data) async {
    try {
      return await _store.add(await _db, data);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> getAllData() async {
    try {
      var record = await _store.find(await _db);
      return record;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> getDataByID(int id) async {
    try {
      var record = await _store.record(id).get(await _db);
      return record;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> updateData(int id, obj) async {
    try {
      return await _store.record(id).put(await _db, obj, merge: true);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> bulkUpdate(ids, listObj) async {
    try {
      return await _store.records(ids).put(await _db, listObj, merge: true);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<dynamic> delete(id) async {
    try {
      return await _store.record(id).delete(await _db);
    } catch (e) {
      throw e.toString();
    }
  }
}
