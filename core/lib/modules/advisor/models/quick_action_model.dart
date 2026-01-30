import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class QuickActionModel {
  String? id;
  String? name;
  String? deeplinkUrl;
  String? imageCdnUrl;
  int? defaultOrder;

  String get imageUrl {
    if (imageCdnUrl.isNotNullOrEmpty) return imageCdnUrl!;
    // default icon
    return 'https://i.wlycdn.com/partner-app/qc-blogs.png';
  }

  QuickActionModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    name = WealthyCast.toStr(json['name']);
    deeplinkUrl = WealthyCast.toStr(json['deeplinkUrl']);
    imageCdnUrl = WealthyCast.toStr(json['imageCdnUrl']);
    defaultOrder = WealthyCast.toInt(json['defaultOrder']);
  }
}
