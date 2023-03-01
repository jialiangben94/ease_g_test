import 'package:flutter/foundation.dart';

enum BuyingFor { self, children, spouse }

extension BuyingForE on BuyingFor {
  String get toStr => describeEnum(this);
}

enum PayS { success, failed, pending, others }

const Map<PayS, String> paymentStatus = {
  PayS.success: "0",
  PayS.failed: "1",
  PayS.pending: "22",
  PayS.others: "99"
};

enum AppStatus { pendingPayment, remote, completed, incomplete, assessed }
