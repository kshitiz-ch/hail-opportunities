import 'package:core/modules/common/resources/wealthy_cast.dart';

class AmcModel {
  String? amc;
  String? imageUrl;
  bool? soaDownloadAllowed;
  String? rta;
  int? amcCode;

  AmcModel.fromJson(Map<String, dynamic> json) {
    amc = WealthyCast.toStr(json['amc']);
    imageUrl = WealthyCast.toStr(json['image_url']);
    soaDownloadAllowed = WealthyCast.toBool(json['soa_download_allowed']);
    rta = WealthyCast.toStr(json['rta']);
    amcCode = WealthyCast.toInt(json['amc_code']);
  }
}
