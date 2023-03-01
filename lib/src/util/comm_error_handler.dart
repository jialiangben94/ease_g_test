class AppCustomException implements Exception {
  AppErrorCode? code;
  bool? status;
  String? message;
  AppCustomException({this.code, this.status, this.message});
}

enum AppErrorCode {
  resDataNull,
  decryptFailed,
  unhandleError,
  isSuccessFalse,
  requiredDataNotFoundServer,
  requiredDataNotFoundApp,
  osNotSupport,
  statusDataNotFound,
  requiredDataNotMatch,
  fileNotFound
}

const appErrorMessage = {
  AppErrorCode.resDataNull: "Response res.data empty",
  AppErrorCode.decryptFailed: "Decryption failed",
  AppErrorCode.unhandleError: "Unhandle Error",
  AppErrorCode.isSuccessFalse: "Server response IsSuccess false",
  AppErrorCode.requiredDataNotFoundServer:
      "Required Data not return from server",
  AppErrorCode.requiredDataNotFoundApp: "Required Data not pass to function",
  AppErrorCode.osNotSupport: "OS not support",
  AppErrorCode.statusDataNotFound: "Required status and data not found",
  AppErrorCode.requiredDataNotMatch: "Required data is not correctly mapping",
  AppErrorCode.fileNotFound: "File not exists"
};

AppCustomException throwErrorFormat(bool status, AppErrorCode code,
    [String? message, String? appendMsg]) {
  return AppCustomException(
      status: status,
      message: message ??
          ((appendMsg ?? "Communication Error. ") +
              (appErrorMessage[code] ?? "")),
      code: code);
}

dynamic handleThrowError(e) {
  if (e is AppCustomException) {
    throw e;
  } else {
    throw throwErrorFormat(false, AppErrorCode.unhandleError, e.toString());
  }
}
