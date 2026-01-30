import 'package:core/modules/common/resources/wealthy_cast.dart';

class DebentureModel {
  int? productVariant;
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
  bool? isPublished;
  String? isin;
  double? lotAvailable;
  bool? lotCheckEnabled;
  String? sellPrice;
  String? confirmationAmount;
  String? minPurchaseAmount;
  String? confirmationDate;
  String? tradeDate;
  String? paymentEndDate;

  DebentureModel({
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
    this.isPublished,
    this.isin,
    this.lotAvailable,
    this.lotCheckEnabled,
    this.sellPrice,
    this.confirmationAmount,
    this.minPurchaseAmount,
    this.confirmationDate,
    this.tradeDate,
    this.paymentEndDate
  });

  factory DebentureModel.fromJson(Map<String, dynamic> json) => DebentureModel(
        productVariant: WealthyCast.toInt(json["product_variant"]),
        productType: WealthyCast.toStr(json["product_type"]),
        category: WealthyCast.toStr(json["category"]),
        categoryText: WealthyCast.toStr(json["category_text"]),
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]),
        productUrl: WealthyCast.toStr(json["product_url"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        expiryTime: WealthyCast.toInt(json["expiry_time"]),
        selectClient: WealthyCast.toBool(json["select_client"]),
        released: WealthyCast.toBool(json["released"]),
        isPublished: WealthyCast.toBool(json["is_published"]),
        isin: WealthyCast.toStr(json["isin"]),
        lotAvailable: WealthyCast.toDouble(json["lot_available"]),
        lotCheckEnabled: WealthyCast.toBool(json["lot_check_enabled"]),
        sellPrice: WealthyCast.toStr(json["sell_price"]),
        confirmationAmount: WealthyCast.toStr(json["confirmation_amount"]),
        minPurchaseAmount: WealthyCast.toStr(json["min_purchase_amount"]),
        confirmationDate: WealthyCast.toStr(json["confirmation_date"]),
        paymentEndDate: WealthyCast.toStr(json["payment_end_date"]),
        tradeDate: WealthyCast.toStr(json["trade_date"]),
      );
}
