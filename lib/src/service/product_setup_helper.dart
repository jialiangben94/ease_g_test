import 'package:ease/src/data/new_business_model/min_premium_list.dart';
import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/new_business_model/term_up_to_maturity.dart';

List<int?> getTermList(List<TermUpToMaturity> maturityTermList, int anb) {
  int minterm = anb + 20;
  List<int?> termList = [];

  for (int i = 0; i < maturityTermList.length; i++) {
    if (maturityTermList[i].maturityYear! >= minterm) {
      termList.add(maturityTermList[i].maturityYear);
    }
  }
  termList.sort();
  return termList;
}

int? getMinPolicyTerm(List<int?> maturityTermList) {
  if (maturityTermList.isNotEmpty) {
    return maturityTermList[0]!.toInt();
  } else {
    return null;
  }
}

int getMaxPolicyTerm(List<int?> maturityTermList) {
  if (maturityTermList.length == 1) {
    return maturityTermList[0]!.toInt();
  } else if (maturityTermList.length >= 2) {
    return maturityTermList[maturityTermList.length - 1]!.toInt();
  } else {
    return 0;
  }
}

int? getMinPremium({String? selectedPaymentMode, ProductPlan? productPlan}) {
  MinPremiumList minPremiumData;

  switch (selectedPaymentMode) {
    case "Monthly":
      {
        minPremiumData = productPlan!.minPremiumList!
            .firstWhere((element) => element.payMode == "CC12");
      }
      break;

    case "Quarterly":
      {
        minPremiumData = productPlan!.minPremiumList!
            .firstWhere((element) => element.payMode == "CC4");
      }
      break;

    case "Half Yearly":
      {
        minPremiumData = productPlan!.minPremiumList!
            .firstWhere((element) => element.payMode == "CC2");
      }
      break;

    case "Yearly":
      {
        minPremiumData = productPlan!.minPremiumList!
            .firstWhere((element) => element.payMode == "CC1");
      }
      break;

    default:
      {
        minPremiumData = productPlan!.minPremiumList!
            .firstWhere((element) => element.payMode == "CC12");
      }
      break;
  }
  return minPremiumData.minPremium;
}
