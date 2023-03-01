import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/new_business_model/quotation_repository.dart';
import 'package:ease/src/data/user_repository/agent.dart';
import 'package:ease/src/repositories/product_plan_repository.dart';
import 'package:ease/src/service/new_business_service.dart';
import 'package:ease/src/setting/global_config.dart';
import 'package:ease/src/util/validation.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'quotation_bloc_event.dart';
part 'quotation_bloc_state.dart';

class QuotationBloc extends Bloc<QuotationBlocEvent, QuotationBlocState> {
  final QuotationRepository quotationRepository;
  QuotationBloc({required this.quotationRepository})
      : super(QuotationLoadInProgress()) {
    on<LoadQuotation>(_mapQuotationLoadedToState);
    on<AddQuotation>(_mapQuotationAddedToState);
    on<DeleteQuotation>(_mapQuotationDeletedToState);
    on<UpdateQuotation>(_mapQuotationUpdatedToState);
    on<UpdateAndLoadQuotation>(_mapQuotationUpdatedAndLoadedToState);
    on<FindQuotation>(_mapFindQuotationToState);
    on<DeleteQuickQtn>(_mapDeleteQuickQtnToState);
    on<SortQuotation>(_mapSortQtnToState);
  }

  void _mapQuotationLoadedToState(
      LoadQuotation event, Emitter<QuotationBlocState> emit) async {
    try {
      final quotations = await quotationRepository.getAllQuotation();
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));

      if (quotations.isEmpty) {
        emit(const QuotationLoadSuccess([]));
      } else {
        for (int i = 0; i < quotations.length; i++) {
          if (quotations[i].agentCode == null) {
            quotations[i].agentCode = agent.accountCode;
            await quotationRepository.updateQuotation(quotations[i]);
          }
          if (quotations[i].agentCode == agent.accountCode) {
            quotations[i]
                .listOfQuotation
                .forEach((QuickQuotation element) async {
              if (element.isReadyToUpload != null && element.isReadyToUpload!) {
                if (element.isSavedOnServer != null &&
                    !element.isSavedOnServer!) {
                  await savetoserver(quotations[i], element, "A")
                      .then((value) async {
                    if (value != null && value["IsSuccess"]) {
                      Quotation updatedQuotation =
                          updateValue(quotations[i], element, value);
                      await quotationRepository
                          .updateQuotation(updatedQuotation);
                    }
                  }).catchError((onError) {});
                } else if (element.isDeleted != null && element.isDeleted!) {
                  dynamic value =
                      await savetoserver(quotations[i], element, "D");
                  if (value["IsSuccess"]) {
                    await quotationRepository
                        .deleteQuotationById(quotations[i]);
                  } else {
                    element.isDeleted = true;
                    var index = quotations[i].listOfQuotation.indexWhere(
                        (quickqtn) =>
                            quickqtn.quickQuoteId == element.quickQuoteId);
                    if (index != -1) {
                      quotations[i].listOfQuotation[index] = element;
                    }
                    await quotationRepository.updateQuotation(quotations[i]);
                  }
                }
              }
            });
          }

          List<Quotation> updatedquotations =
              await (quotationRepository.getAllQuotation());
          List<Quotation> filteredQuotations = [];
          for (var element in updatedquotations) {
            if (element.agentCode == agent.accountCode) {
              filteredQuotations.add(element);
            }
          }
          emit(QuotationLoadSuccess(filteredQuotations));
        }
      }
    } catch (e) {
      emit(QuotationLoadError(e.toString()));
    }
  }

  void _mapQuotationAddedToState(
      AddQuotation event, Emitter<QuotationBlocState> emit) async {
    try {
      int? id = await (quotationRepository.addQuotation(event.quotation));
      List<Quotation> quotations =
          await (quotationRepository.getAllQuotation());
      final pref = await SharedPreferences.getInstance();
      final Agent agent =
          Agent.fromJson(json.decode(pref.getString(spkAgent)!));
      List<Quotation> filteredQuotations = [];
      for (var element in quotations) {
        if (element.agentCode == agent.accountCode) {
          filteredQuotations.add(element);
        }
      }
      emit(QuotationAdded(id, event.quotation, filteredQuotations));
    } catch (e) {
      emit(QuotationLoadError(e.toString()));
    }
  }

  void _mapQuotationDeletedToState(
      DeleteQuotation event, Emitter<QuotationBlocState> emit) async {
    if (event.quotation.listOfQuotation!.isEmpty) {
      await quotationRepository.deleteQuotationById(event.quotation);
    } else {
      dynamic value = await savetoserver(
          event.quotation,
          (event.quotation.listOfQuotation != null
              ? event.quotation.listOfQuotation![0]
              : [QuickQuotation()]) as QuickQuotation?,
          "D");
      if (value["IsSuccess"]) {
        await quotationRepository.deleteQuotationById(event.quotation);
      } else {
        event.quotation.listOfQuotation![0]!.isDeleted = true;
        await quotationRepository.updateQuotation(event.quotation);
      }
    }
    final quotations = await quotationRepository.getAllQuotation();
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    List<Quotation> filteredQuotations = [];
    for (var element in quotations) {
      if (element.agentCode == agent.accountCode) {
        filteredQuotations.add(element);
      }
    }
    emit(QuotationLoadSuccess(filteredQuotations));
  }

  void _mapQuotationUpdatedToState(
      UpdateQuotation event, Emitter<QuotationBlocState> emit) async {
    int? id = await quotationRepository.updateQuotation(event.quotation!);
    final List<Quotation> quotations =
        await (quotationRepository.getAllQuotation());
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    List<Quotation> filteredQuotations = [];
    for (var element in quotations) {
      if (element.agentCode == agent.accountCode) {
        filteredQuotations.add(element);
      }
    }
    emit(QuotationUpdated(id, event.quotation!, filteredQuotations));
  }

  void _mapQuotationUpdatedAndLoadedToState(
      UpdateAndLoadQuotation event, Emitter<QuotationBlocState> emit) async {
    await quotationRepository.updateQuotation(event.quotation!);
    final List<Quotation> quotations =
        await (quotationRepository.getAllQuotation());
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    List<Quotation> filteredQuotations = [];
    for (var element in quotations) {
      if (element.agentCode == agent.accountCode) {
        filteredQuotations.add(element);
      }
    }
    emit(QuotationLoadSuccess(filteredQuotations));
  }

  void _mapFindQuotationToState(
      FindQuotation event, Emitter<QuotationBlocState> emit) async {
    if (event.id != null) {
      final List<Quotation> quotations =
          await (quotationRepository.getAllQuotation());
      var quotation =
          quotations.firstWhere((elements) => elements.uid == event.id);
      emit(QuotationSingle(quotation, quotations));
    }
  }

  void _mapDeleteQuickQtnToState(
      DeleteQuickQtn event, Emitter<QuotationBlocState> emit) async {
    dynamic value = await savetoserver(event.quotation, event.quickQtn, "D");
    if (value["IsSuccess"]) {
      await quotationRepository.deleteQuickQuotationById(
          event.quotation, event.quickQtn);
    } else {
      event.quickQtn!.isDeleted = true;
      var index = event.quotation.listOfQuotation!.indexWhere(
          (element) => element!.quickQuoteId == event.quickQtn!.quickQuoteId);
      if (index != -1) {
        event.quotation.listOfQuotation![index] = event.quickQtn;
      }
      await quotationRepository.updateQuotation(event.quotation);
    }

    final quotations = await quotationRepository.getAllQuotation();
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    List<Quotation> filteredQuotations = [];
    for (var element in quotations) {
      if (element.agentCode == agent.accountCode) {
        filteredQuotations.add(element);
      }
    }
    emit(QuotationLoadSuccess(filteredQuotations));
  }

  void _mapSortQtnToState(
      SortQuotation event, Emitter<QuotationBlocState> emit) async {
    final pref = await SharedPreferences.getInstance();
    final Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));
    List<Quotation> updatedquotations =
        await (quotationRepository.sortQuotation(event.category));
    List<Quotation> filteredQuotations = [];
    for (var element in updatedquotations) {
      if (element.agentCode == agent.accountCode) {
        filteredQuotations.add(element);
      }
    }
    emit(QuotationLoadSuccess(filteredQuotations));
  }
}

Future<dynamic> savetoserver(
    Quotation? quotation, QuickQuotation? quickQuotation, String action) async {
  var pref = await SharedPreferences.getInstance();
  bool haveConn = await checkConnectivity();

  if (pref.getString(spkAgent) != null && haveConn) {
    if (action == "D" &&
        (!quickQuotation!.isReadyToUpload! ||
            !quickQuotation.isSavedOnServer!)) {
      return {"IsSuccess": true};
    }
    Agent agent = Agent.fromJson(json.decode(pref.getString(spkAgent)!));

    String? isGIO;
    if (quickQuotation!.caseindicator != null) {
      isGIO = quickQuotation.caseindicator == "GIOCase" ? "Y" : "N";
    } else if (quickQuotation.productPlanCode == "PCHI03" ||
        quickQuotation.productPlanCode == "PCHI04") {
      double? limit = 200000;
      ProductPlan? productPlan = await ProductPlanRepositoryImpl()
          .getProductPlanSetupByProdCode(
              quickQuotation.productPlanCode == "PCHI04"
                  ? "PCHI03"
                  : quickQuotation.productPlanCode!);
      if (productPlan != null && productPlan.gaProductList!.isNotEmpty) {
        limit = productPlan.gaProductList![0].prodLimit;
      }
      double sa = double.tryParse(quickQuotation.sumInsuredAmt!) ?? 0;
      if (sa > limit!) {
        isGIO = "N";
      } else {
        var riders = quickQuotation.riderOutputDataList!
            .where((element) =>
                element.riderCode != quickQuotation.productPlanCode)
            .toList();
        isGIO = riders.isNotEmpty ? "N" : "Y";
      }
    }

    var encodeJson =
        quotation!.toJsonServer(quickQuotation, action, agent, isGIO);
    var obj = {
      "Method": "POST",
      "Param": {"Type": "HISTORY"},
      "Body": {"Quotation": encodeJson}
    };
    try {
      return await NewBusinessAPI().quotation(obj);
    } catch (e) {
      rethrow;
    }
  }
}

Quotation updateValue(
    Quotation quotation, QuickQuotation quickQuotation, dynamic response) {
  quickQuotation.isSavedOnServer = response["IsSuccess"];
  quickQuotation.quotationHistoryID = response["QuotationHistoryID"];

  var index = quotation.listOfQuotation!
      .indexWhere((element) => element!.quickQuoteId == element.quickQuoteId);
  if (index != -1) {
    quotation.listOfQuotation![index] = quickQuotation;
  }
  return quotation;
}
