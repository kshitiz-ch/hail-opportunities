import 'package:core/modules/common/resources/wealthy_cast.dart';

class MetaDataModel {
  int? totalCount;
  int limit;
  int page;
  int? count;

  MetaDataModel({
    this.totalCount,
    this.limit = 20,
    this.page = 0,
    this.count,
  });

  factory MetaDataModel.fromJson(Map<String, dynamic> json) => MetaDataModel(
        totalCount: WealthyCast.toInt(json["total_count"]) ?? 0,
        limit: WealthyCast.toInt(json["limit"]) ?? 20,
        page: WealthyCast.toInt(json["page"]) ?? 0,
        count: WealthyCast.toInt(json["count"]),
      );
}
