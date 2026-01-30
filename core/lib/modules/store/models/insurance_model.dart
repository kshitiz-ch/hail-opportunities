import 'package:core/modules/common/resources/wealthy_cast.dart';

class InsuranceListModel {
  InsuranceListModel({
    this.products,
  });

  List<InsuranceModel>? products;

  factory InsuranceListModel.fromJson(Map<String, dynamic> json) =>
      InsuranceListModel(
        products: WealthyCast.toList(json["products"])
            .map<InsuranceModel>((x) => InsuranceModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": products == null
            ? null
            : List<dynamic>.from(
                products!.map((x) => x.toJson()),
              ),
      };
}

class InsuranceModel {
  InsuranceModel({
    this.productVariant,
    this.productType,
    this.category,
    this.categoryText,
    this.title,
    this.description,
    this.productUrl,
    this.iconSvg,
    this.iconUrl,
    this.selectClient,
  });

  String? productVariant;
  String? productType;
  String? category;
  String? categoryText;
  String? title;
  String? description;
  String? productUrl;
  String? iconSvg;
  String? iconUrl;
  bool? selectClient;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) => InsuranceModel(
        productVariant: WealthyCast.toStr(json["product_variant"]),
        productType: WealthyCast.toStr(json["product_type"]),
        category: WealthyCast.toStr(json["category"]),
        categoryText: WealthyCast.toStr(json["category_text"]),
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]),
        productUrl: WealthyCast.toStr(json["product_url"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        selectClient: WealthyCast.toBool(json["select_client"]),
      );

  Map<String, dynamic> toJson() => {
        "product_variant": productVariant,
        "category": category,
        "category_text": categoryText,
        "title": title,
        "description": description,
        "product_url": productUrl,
        "icon_svg": iconSvg,
        "icon_url": iconUrl,
        "select_client": selectClient,
      };
}
