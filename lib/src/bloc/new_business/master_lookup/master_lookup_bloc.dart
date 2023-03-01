import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/new_business_model/master_lookup.dart';
import 'package:ease/src/util/required_file_handler.dart';
import 'package:equatable/equatable.dart';

part 'master_lookup_event.dart';
part 'master_lookup_state.dart';

class MasterLookupBloc extends Bloc<MasterLookupEvent, MasterLookupState> {
  MasterLookupBloc() : super(MasterLookupInitial()) {
    on<GetMasterLookUpList>(mapGetMasterLookUpListEventToState);
  }

  void mapGetMasterLookUpListEventToState(
      GetMasterLookUpList event, Emitter<MasterLookupState> emit) async {
    emit(const MasterLookupLoading());
    try {
      List<MasterLookup> data = await getMasterLookupList();
      emit(MasterLookupLoaded(data));
    } catch (e) {
      emit(MasterLookupError(e.toString()));
    }
  }
}

Future<List<MasterLookup>> getMasterLookupList() async {
  List<MasterLookup> masterLookupList = [];
  final file = await optionListFile();
  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      MasterLookup masterLookup = MasterLookup.fromMap(data[i]);
      masterLookupList.add(masterLookup);
    }
  }
  return masterLookupList;
}

Future<List<MasterLookupType>> getMasterLookupTypeList() async {
  List<MasterLookupType> masterLookupTypeList = [];
  final file = await optionTypeFile();
  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      MasterLookupType masterLookupType = MasterLookupType.fromMap(data[i]);
      masterLookupTypeList.add(masterLookupType);
    }
  }
  return masterLookupTypeList;
}

Future<List<BankLookUp>> getBankLookUpList() async {
  List<BankLookUp> bankLookUpList = [];
  final file = await bankListFile();
  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      BankLookUp bankLookUp = BankLookUp.fromMap(data[i]);
      bankLookUpList.add(bankLookUp);
    }
  }
  return bankLookUpList;
}

Future<List<TranslationLookUp>> getTranslationLookUpList() async {
  List<TranslationLookUp> translationLookUpList = [];
  final file = await translationFile();
  if (file.existsSync()) {
    String contents = await file.readAsString();
    final data = jsonDecode(contents);
    for (int i = 0; i < data.length; i++) {
      TranslationLookUp translationLookUp = TranslationLookUp.fromMap(data[i]);
      translationLookUpList.add(translationLookUp);
    }
  }
  return translationLookUpList;
}
