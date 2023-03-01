class Panel {
  String? providerCode;
  String? name;
  String? address;
  String? contact;
  String? bizHrs;
  String? providerType;
  String? latitude;
  String? longitude;

  Panel(
      {this.providerCode,
      this.name,
      this.address,
      this.contact,
      this.bizHrs,
      this.providerType,
      this.latitude,
      this.longitude});

  factory Panel.fromJson(Map<String, dynamic> parsedJson) {
    return Panel(
        providerCode: parsedJson["ProviderCode"].toString(),
        name: parsedJson["Name"].toString(),
        address: parsedJson["Address"].toString(),
        contact: parsedJson["Contact"].toString(),
        bizHrs: parsedJson["BizHrs"].toString(),
        providerType: parsedJson["ProviderType"].toString(),
        longitude: parsedJson["Longitude"].toString(),
        latitude: parsedJson["Latitude"].toString());
  }

  Map<String, dynamic> toJson() => {
        'ProviderCode': providerCode,
        'Name': name,
        'Address': address,
        'Contact': contact,
        'BizHrs': bizHrs,
        'ProviderType': providerType,
        'Longitude': longitude,
        'Latitude': latitude
      };
}

String cleanPanelAddress(String address) {
  String newAddress = "";
  var newText = address.split(",");
  for (int i = 0; i < newText.length; i++) {
    if (newText[i] != "") {
      if (i == newText.length - 3) {
        if (newText[newText.length - 2] != "") {
          newAddress = "$newAddress\n${newText[i]} ";
        } else {
          newAddress = "$newAddress\n${newText[i]},";
        }
      } else if (i == newText.length - 1) {
        newAddress = "$newAddress\n${newText[i]}";
      } else if (newText[i] != "") {
        newAddress = "$newAddress${newText[i]}, ";
      }
    }
  }
  return newAddress;
}
