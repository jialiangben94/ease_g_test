import 'dart:convert';
import 'dart:io';

import 'package:ease/src/data/new_business_model/vpms_fieldlist/vpms_mapping.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<VpmsMapping> getVPMSMappingData(String? prodCode) async {
  final output = await getTemporaryDirectory();
  String pathPlan;
  String plan;
  String? filename;

  // Plan vpms mapping
  if (prodCode == "PCWI03") {
    filename = "vpms_mapping_matrix_securelink.json";
  } else if (prodCode == "PCJI01") {
    filename = "vpms_mapping_matrix_megalink.json";
  } else if (prodCode == "PTWI03") {
    filename = "vpms_mapping_matrix_eliteplus_takafulink.json";
  } else if (prodCode == "PCJI02") {
    filename = "vpms_mapping_matrix_megaplus.json";
  } else if (prodCode == "PCTA01") {
    filename = "vpms_mapping_matrix_etiqalifesecure.json";
  } else if (prodCode == "PCWA01") {
    filename = "vpms_mapping_matrix_enrichlifeplan.json";
  } else if (prodCode == "PCHI03" || prodCode == "PCHI04") {
    filename = "vpms_mapping_matrix_maxipro.json";
  } else if (prodCode == "PCEL01") {
    filename = "vpms_mapping_matrix_triple_growth.json";
  } else if (prodCode == "PCEE01") {
    filename = "vpms_mapping_matrix_aspire.json";
  } else if (prodCode == "PTHI01" || prodCode == "PTHI02") {
    filename = "vpms_mapping_matrix_hadiyyah_takafulink.json";
  } else if (prodCode == "PTJI01") {
    filename = "vpms_mapping_matrix_mahabbah.json";
  }

  plan = await rootBundle.loadString('assets/files/$filename');
  pathPlan = "${output.path}/$filename";

  final filePlan = File(pathPlan);
  filePlan.writeAsStringSync(plan);
  String planContents = await filePlan.readAsString();
  final dataPlan = jsonDecode(planContents);
  VpmsMapping vpmsMapping = VpmsMapping.fromMap(dataPlan);
  return vpmsMapping;
}
