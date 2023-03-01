import 'package:ease/src/data/new_business_model/quick_quotation.dart';
import 'package:ease/src/data/new_business_model/quotation.dart';
import 'package:ease/src/data/new_business_model/quotation_dao.dart';

class QuotationRepository {
  final quotationDao = QuotationDao();
  Future getAllQuotation({String? query}) => quotationDao.sortByKey("Latest");
  Future sortQuotation(String? category) => quotationDao.sortByKey(category);
  Future addQuotation(Quotation quotation) => quotationDao.insert(quotation);
  Future updateQuotation(Quotation quotation) => quotationDao.update(quotation);
  Future deleteQuotationById(Quotation quotation) =>
      quotationDao.delete(quotation);
  Future deleteQuickQuotationById(
          Quotation quotation, QuickQuotation? quickQtn) =>
      quotationDao.deleteQuickQuotationById(quotation, quickQtn);
  // Future getQuotationById(Quotation quotation) => quotationDao.getSingleQuotation(quotation);
}
