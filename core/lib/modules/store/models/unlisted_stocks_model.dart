import 'package:core/modules/common/resources/wealthy_cast.dart';

class UnlistedStockModel {
  UnlistedStockModel({
    this.products,
  });

  List<UnlistedProductModel>? products;

  factory UnlistedStockModel.fromJson(Map<String, dynamic> json) =>
      UnlistedStockModel(
        products: WealthyCast.toList(json["products"])
            .map((x) => UnlistedProductModel.fromJson(x))
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

class UnlistedProductModel {
  UnlistedProductModel({
    this.productVariant,
    this.productType,
    this.category,
    this.categoryText,
    this.title,
    this.description,
    this.productUrl,
    this.iconSvg,
    this.iconUrl,
    this.isin,
    this.vendor,
    this.minPurchaseAmount,
    this.minSellPrice,
    this.landingPrice,
    this.maxSellPrice,
    this.reportUrl,
    this.expiryTime,
    this.depServiceAvailable,
    this.lotAvailable,
    this.lotCheckEnabled,
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
  String? isin;
  int? vendor;
  double? minPurchaseAmount;
  double? minSellPrice;
  double? maxSellPrice;
  double? landingPrice;
  String? reportUrl;
  int? expiryTime;
  String? depServiceAvailable;
  int? lotAvailable;
  bool? lotCheckEnabled;

  factory UnlistedProductModel.fromJson(Map<String, dynamic> json) =>
      UnlistedProductModel(
        productVariant: WealthyCast.toStr(json["product_variant"]),
        productType: WealthyCast.toStr(json["product_type"]),
        category: WealthyCast.toStr(json["category"]),
        categoryText: WealthyCast.toStr(json["category_text"]),
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]) ?? "",
        productUrl: WealthyCast.toStr(json["product_url"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        isin: WealthyCast.toStr(json["isin"]),
        vendor: WealthyCast.toInt(json["vendor"]),
        landingPrice: WealthyCast.toDouble(json["partner_landing_price"]),
        minPurchaseAmount: WealthyCast.toDouble(json["min_purchase_amount"]),
        minSellPrice: WealthyCast.toDouble(json["min_sell_price"]),
        maxSellPrice: WealthyCast.toDouble(json["max_sell_price"]),
        reportUrl: WealthyCast.toStr(json["report_url"]),
        expiryTime: WealthyCast.toInt(json["expiry_time"]) ?? 0,
        depServiceAvailable: WealthyCast.toStr(json["dep_service_available"]),
        lotAvailable: WealthyCast.toInt(json["lot_available"]),
        lotCheckEnabled: WealthyCast.toBool(json["lot_check_enabled"]),
      );

  Map<String, dynamic> toJson() => {
        "product_variant": productVariant,
        "category": category,
        "category_text": categoryText,
        "title": title,
        "description": description ?? "",
        "product_url": productUrl,
        "icon_svg": iconSvg,
        "icon_url": iconUrl,
        "isin": isin,
        "vendor": vendor,
        "min_purchase_amount": minPurchaseAmount,
        "min_sell_price": minSellPrice,
        "max_sell_price": maxSellPrice,
        "report_url": reportUrl,
        "expiry_time": expiryTime ?? 0
      };
}
