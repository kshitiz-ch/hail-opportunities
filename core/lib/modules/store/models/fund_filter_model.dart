import 'package:core/modules/common/resources/wealthy_cast.dart';

class FundFilterModel {
  String? name;
  String? displayName;
  List<dynamic>? options;
  bool? isCustom;

  FundFilterModel({
    this.name,
    this.displayName,
    this.options,
    this.isCustom
  });

  factory FundFilterModel.fromJson(Map<String, dynamic> json) =>
      FundFilterModel(
        name: WealthyCast.toStr(json["name"]),
        displayName: WealthyCast.toStr(json["display_name"]),
        options: WealthyCast.toList(json["options"]),
        isCustom: WealthyCast.toBool(json["is_custom"])
      );
}

class FundSortModel {
  String? name;
  String? displayName;
  String? sortReverse;


  FundSortModel({
    this.name,
    this.displayName,
    this.sortReverse
  });

  factory FundSortModel.fromJson(Map<String, dynamic> json) =>
      FundSortModel(
        name: WealthyCast.toStr(json["name"]),
        displayName: WealthyCast.toStr(json["display_name"]),
        sortReverse: WealthyCast.toStr(json["sort_reverse"]),
      );
}
