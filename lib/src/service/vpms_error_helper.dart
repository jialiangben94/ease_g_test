import 'package:flutter/material.dart';

class VpmsErrorHelper with ChangeNotifier {
  List<String>? error = [];
  VpmsErrorHelper({this.error});

  List<String>? get vpmsError {
    return error;
  }

  List<String>? initError() {
    error = [];

    notifyListeners();
    return error;
  }

  List<String>? addError(String message) {
    error ??= [];

    error!.add(message);
    notifyListeners();
    return error;
  }

  List<String>? clearError() {
    error!.clear();
    notifyListeners();
    return error;
  }
}
