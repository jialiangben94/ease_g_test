import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/new_business_model/person.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/util/function.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'existing_customer_event.dart';
part 'existing_customer_state.dart';

class ExistingCustomerBloc
    extends Bloc<ExistingCustomerEvent, ExistingCustomerListState> {
  ExistingCustomerBloc() : super(ExistingCustomerListInitial()) {
    on<SearchExistingCustomer>(mapSearchExistingCustomerEventToState);
  }

  void mapSearchExistingCustomerEventToState(SearchExistingCustomer event,
      Emitter<ExistingCustomerListState> emit) async {
    emit(const ExistingCustomerListLoading());
    try {
      List<Person> data =
          await searchExistingCustomerList(event.keyword, policyType: "Plan");
      if (data.isNotEmpty) {
        emit(ExistingCustomerListLoaded(data));
      } else {
        emit(const ExistingCustomerListError("No customer found"));
      }
    } catch (e) {
      emit(ExistingCustomerListError(e.toString()));
    }
  }
}

Future<List<Person>> searchExistingCustomerList(String? keyword,
    {String? policyType}) async {
  List<Person> existingCustomerList = [];

  final output = await getTemporaryDirectory();
  String path = "${output.path}/fffdetails.json";
  final file = File(path);

  await NewBusinessAPI()
      .searchLead(keyword, policyType: policyType)
      .then((data) async {
    if (data['IsSuccess'] && data['FFFDetails'] != null) {
      Uint8List bytes = base64.decode(data['FFFDetails']);
      await file.writeAsBytes(bytes);
      if (file.existsSync()) {
        String contents = await file.readAsString();
        final dataContent = jsonDecode(contents);
        for (int i = 0; i < dataContent.length; i++) {
          Person person = await Person.fromJsonFFF(dataContent[i]);
          if (person.existingCoverage!.isNotEmpty) {
            person.name = person.existingCoverage![0].name;
            person.nric = person.existingCoverage![0].nric ??
                person.existingCoverage![0].idnum;
            person.dob = person.existingCoverage![0].dob;
            person.age = getAgeString(
                nricToDOB(person.existingCoverage![0].nric != null
                    ? person.existingCoverage![0].nric!
                    : person.existingCoverage![0].idnum!),
                false);
            person.gender = person.existingCoverage![0].gender;
            person.nationality = person.existingCoverage![0].nationality;
            person.maritalStatus = person.existingCoverage![0].maritalStatus;
          }
          if (person.gender == null) {
            if (person.nric != null) {
              person.gender =
                  ((int.parse(person.nric![11]) % 2) == 0) ? "Female" : "Male";
            }
          }
          if (person.name != null &&
              person.dob != null &&
              person.gender != null) existingCustomerList.add(person);
        }
      }
      existingCustomerList.sort(
          (a, b) => a.name!.toUpperCase().compareTo(b.name!.toUpperCase()));
    }
  });
  return existingCustomerList;
}
