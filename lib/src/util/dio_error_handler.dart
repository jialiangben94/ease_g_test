import 'package:dio/dio.dart';
import 'package:ease/src/util/validation.dart';

Future<String> errorHandler(DioError e) async {
  String errorMsg;
  bool haveConn = await checkConnectivity();
  if (!haveConn) {
    errorMsg = "Please check your internet connection";
  } else {
    if (e.type == DioErrorType.connectTimeout) {
      errorMsg =
          "The connection has timed out. The server is taking too long to response";
    } else if (e.type == DioErrorType.receiveTimeout) {
      errorMsg = "Connection error: no data received";
    } else if (e.type == DioErrorType.response) {
      errorMsg = "Received invalid status code: ${e.response!.statusCode}";
    } else if (e.type == DioErrorType.cancel) {
      errorMsg = "Request has been cancelled";
    } else if (e.type == DioErrorType.other) {
      errorMsg = "Can't access server";
    } else {
      errorMsg = "Unexpected error occurred";
    }
  }
  return errorMsg;
}
