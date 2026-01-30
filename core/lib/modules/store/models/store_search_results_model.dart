import 'package:core/modules/common/resources/wealthy_cast.dart';

class StoreSearchResultsModel {
  final List<StoreSearchResultModel>? storeSearchResults;
  final int? total;

  StoreSearchResultsModel({this.total, this.storeSearchResults});

  factory StoreSearchResultsModel.fromJson(Map<String, dynamic> json) =>
      StoreSearchResultsModel(
        total: json['total'],
        storeSearchResults: WealthyCast.toList(json["results"])
            .map((x) => StoreSearchResultModel.fromJson(x))
            .toList(),
      );
}

class StoreSearchResultModel {
  final String? name;
  final String? description;
  final String? category;
  final String? portfolioName;
  final String? wschemecode;
  final String? productVariant;
  final String? productType;
  final double? oneYearReturns;
  final double? threeYearReturns;
  final List<SearchResultSchemeModel>? schemes;

  StoreSearchResultModel({
    this.name,
    this.description,
    this.category,
    this.portfolioName,
    this.wschemecode,
    this.productVariant,
    this.productType,
    this.oneYearReturns,
    this.threeYearReturns,
    this.schemes,
  });

  factory StoreSearchResultModel.fromJson(Map<String, dynamic> json) =>
      StoreSearchResultModel(
        name: WealthyCast.toStr(json['name']),
        description: WealthyCast.toStr(json['description']),
        category: WealthyCast.toStr(json['category']),
        portfolioName: WealthyCast.toStr(json['portfolio_name']),
        wschemecode: WealthyCast.toStr(json['wschemecode']),
        productVariant: WealthyCast.toStr(json['product_variant']),
        productType: WealthyCast.toStr(json['product_type']),
        oneYearReturns: WealthyCast.toDouble(json['one_year_returns']),
        threeYearReturns: WealthyCast.toDouble(json['three_year_returns']),
        schemes: WealthyCast.toList(json['schemes'])
            .map((x) => SearchResultSchemeModel.fromJson(x))
            .toList(),
      );
}

class SearchResultSchemeModel {
  final String name;
  final String wSchemeCode;

  SearchResultSchemeModel(this.name, this.wSchemeCode);

  factory SearchResultSchemeModel.fromJson(Map<String, dynamic> json) =>
      SearchResultSchemeModel(
        WealthyCast.toStr(json['name']) ?? '',
        WealthyCast.toStr(json['wschemecode']) ?? '',
      );
}
