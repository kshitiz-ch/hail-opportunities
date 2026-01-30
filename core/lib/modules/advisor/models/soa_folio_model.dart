import 'package:core/modules/common/resources/wealthy_cast.dart';

class SoaFolioModel {
  String? folioNumber;
  String? amc;
  int? amcCode;
  double? totalAmount;
  double? totalUnits;
  double? totalCurrentValue;
  String? imageUrl;
  bool? soaDownloadAllowed;

  SoaFolioModel.fromJson(Map<String, dynamic> json) {
    folioNumber = WealthyCast.toStr(json['folio_number']);
    amc = WealthyCast.toStr(json['amc']);
    amcCode = WealthyCast.toInt(json['amc_code']);
    totalAmount = WealthyCast.toDouble(json['total_amount']);
    totalUnits = WealthyCast.toDouble(json['total_units']);
    totalCurrentValue = WealthyCast.toDouble(json['total_current_value']);
    imageUrl = WealthyCast.toStr(json['image_url']);
    soaDownloadAllowed = WealthyCast.toBool(json['soa_download_allowed']);
  }
}
