import 'dart:convert';
import 'dart:io';

import 'package:ease/src/data/new_business_model/product_plan.dart';
import 'package:ease/src/data/user_repository/agent_product.dart';
import 'package:ease/src/screen/new_business/quotation/quick_quotation_form/choose_product/choose_products.dart';
import 'package:ease/src/util/function.dart';
import 'package:path_provider/path_provider.dart';

abstract class ProductPlanRepository {
  Future<List<AgentProduct>> getAgentProduct();
  Future<List<ProductPlan>> getRiderPlanSetup();
  Future<bool> checkEnricher(List<String> prodCode);
  Future<List<ProductPlan>> getProductPlanSetup(
      {ProductPlanType? type,
      List<AgentProduct>? agentProducts,
      bool isFilterName = false});
  Future<ProductPlan?> getProductPlanSetupByProdCode(String prodCode);
  Future<ProductPlan?> getRiderSetupByProdCode(String riderCode);
  Future<List<Campaign>> getCampaignList();
}

class ProductPlanRepositoryImpl implements ProductPlanRepository {
  @override
  Future<List<AgentProduct>> getAgentProduct() async {
    List<AgentProduct> agentProductList = [];
    final output = await getTemporaryDirectory();
    String path = "${output.path}/agent_product.json";
    final file = File(path);
    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      for (int i = 0; i < data.length; i++) {
        AgentProduct agentProduct = AgentProduct.fromMap(data[i]);
        agentProductList.add(agentProduct);
      }
    }

    return agentProductList;
  }

  @override
  Future<List<ProductPlan>> getRiderPlanSetup() async {
    List<ProductPlan> riderPlanSetup = [];
    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_rider.json";
    final file = File(path);
    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      for (int i = 0; i < data.length; i++) {
        ProductPlan productPlan = ProductPlan.fromMap(data[i]);
        riderPlanSetup.add(productPlan);
      }
    }
    return riderPlanSetup;
  }

  @override
  Future<bool> checkEnricher(List<String> prodCode) async {
    bool haveEnricher = false;
    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_rider.json";
    final file = File(path);
    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      for (int i = 0; i < data.length; i++) {
        if (prodCode.contains(data[i]["ProductSetup"]["ProdCode"])) {
          if (data[i]["ProductSetup"]["PremiumBasis"] == "9") {
            haveEnricher = true;
            break;
          }
        }
      }
    }
    return haveEnricher;
  }

  @override
  Future<List<ProductPlan>> getProductPlanSetup(
      {ProductPlanType? type,
      List<AgentProduct>? agentProducts,
      bool isFilterName = false}) async {
    List<ProductPlan> productPlanSetup = [];
    List<String?> productName = [];
    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_plan.json";
    final file = File(path);
    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      for (int i = 0; i < data.length; i++) {
        ProductPlan productPlan = ProductPlan.fromMap(data[i]);
        if (isFilterName) {
          if (!productName.contains(productPlan.productSetup!.prodName)) {
            if (type != null) {
              if (type == ProductPlanType.traditional &&
                  (productPlan.productSetup!.lob == 1 ||
                      productPlan.productSetup!.lob == 15)) {
                productPlanSetup.add(productPlan);
                productName.add(productPlan.productSetup!.prodName);
              }
              if (type == ProductPlanType.investmentLink &&
                  (productPlan.productSetup!.lob == 2 ||
                      productPlan.productSetup!.lob == 16)) {
                productPlanSetup.add(productPlan);
                productName.add(productPlan.productSetup!.prodName);
              }
            } else {
              productPlanSetup.add(productPlan);
              productName.add(productPlan.productSetup!.prodName);
            }
          }
        } else {
          if (type != null) {
            if (type == ProductPlanType.traditional &&
                (productPlan.productSetup!.lob == 1 ||
                    productPlan.productSetup!.lob == 15)) {
              productPlanSetup.add(productPlan);
            }
            if (type == ProductPlanType.investmentLink &&
                (productPlan.productSetup!.lob == 2 ||
                    productPlan.productSetup!.lob == 16)) {
              productPlanSetup.add(productPlan);
            }
          } else {
            productPlanSetup.add(productPlan);
          }
        }
      }
    }

    productPlanSetup.sort((a, b) {
      bool isAvailableA;
      bool isAvailableB;

      if (availableProductCode.keys.contains(a.productSetup!.prodCode)) {
        isAvailableA = true;
      } else {
        isAvailableA = false;
      }

      if (availableProductCode.keys.contains(b.productSetup!.prodCode)) {
        isAvailableB = true;
      } else {
        isAvailableB = false;
      }

      if (!isAvailableA && isAvailableB) {
        return 1;
      } else if (isAvailableA && !isAvailableB) {
        return -1;
      } else {
        return a.productSetup!.prodName!.compareTo(b.productSetup!.prodName!);
      }
    });

    return productPlanSetup;
  }

  @override
  Future<ProductPlan?> getProductPlanSetupByProdCode(String prodCode) async {
    ProductPlan? productPlanSetup;
    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_plan.json";
    final file = File(path);

    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      prodCode = prodCode == "PCHI04" ? "PCHI03" : prodCode;
      var productSetup = data.firstWhere(
          (element) => element["ProductSetup"]["ProdCode"] == prodCode);
      productPlanSetup = ProductPlan.fromMap(productSetup);
    }
    return productPlanSetup;
  }

  @override
  Future<ProductPlan?> getRiderSetupByProdCode(String riderCode) async {
    ProductPlan? riderPlanSetup;
    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_rider.json";
    final file = File(path);
    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);

      for (var element in data) {
        if (element["ProductSetup"]["ProdCode"] == riderCode) {
          riderPlanSetup = ProductPlan.fromMap(element);
          break;
        }
      }
    }
    return riderPlanSetup;
  }

  @override
  Future<List<Campaign>> getCampaignList() async {
    List<ProductPlan> productPlanSetup = [];
    List<Campaign> campaignList = [];
    // List<String?> productName = [];

    final output = await getTemporaryDirectory();
    String path = "${output.path}/product_setup_plan.json";
    final file = File(path);

    if (file.existsSync()) {
      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      for (int i = 0; i < data.length; i++) {
        ProductPlan productPlan = ProductPlan.fromMap(data[i]);
        // if (!productName.contains(productPlan.productSetup!.prodName)) {
        productPlanSetup.add(productPlan);
        // productName.add(productPlan.productSetup!.prodName);
        // }
      }
    }

    for (var prod in productPlanSetup) {
      if (prod.campaignList != null && prod.campaignList!.isNotEmpty) {
        var listOfCampaign = prod.campaignList;
        if (listOfCampaign != null && listOfCampaign.isNotEmpty) {
          for (var campaign in listOfCampaign) {
            campaignList.add(campaign);
          }
        }
      }
    }
    return campaignList;
  }
}
