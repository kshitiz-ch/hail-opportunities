import 'package:core/modules/common/resources/wealthy_cast.dart';

class FixedDepositModel {
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
  bool? released;
  int? expiryTime;
  String? rateOfInterest;
  String? tenure;
  int? minPurchaseAmount;
  String? icraRating;

  FixedDepositModel({
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
    this.expiryTime,
    this.released,
    this.rateOfInterest,
    this.tenure,
    this.minPurchaseAmount,
    this.icraRating
  });

  factory FixedDepositModel.fromJson(Map<String, dynamic> json) =>
      FixedDepositModel(
        productVariant: WealthyCast.toStr(json["product_variant"]),
        productType: WealthyCast.toStr(json["product_type"]),
        category: WealthyCast.toStr(json["category"]),
        categoryText: WealthyCast.toStr(json["category_text"]),
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]),
        productUrl: WealthyCast.toStr(json["product_url"]),
        rateOfInterest: WealthyCast.toStr(json["rate_of_interest"]),
        minPurchaseAmount: WealthyCast.toInt(json["min_purchase_amount"]),
        tenure: WealthyCast.toStr(json["tenure"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        expiryTime: WealthyCast.toInt(json["expiry_time"]),
        selectClient: WealthyCast.toBool(json["select_client"]),
        released: WealthyCast.toBool(json["released"]),
        icraRating: WealthyCast.toStr(json["icra_rating"]),
      );
}
