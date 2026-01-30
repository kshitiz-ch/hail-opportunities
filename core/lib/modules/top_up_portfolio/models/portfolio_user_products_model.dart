import 'package:core/modules/common/resources/wealthy_cast.dart';

import 'portfolio_extras_model.dart';

class PortfolioUserProductsModel {
  String? id;
  String? activatedAt;
  String? externalId;
  String? name;
  String? displayName;
  dynamic startDate;
  dynamic endDate;
  dynamic currentInvestedValue;
  dynamic currentValue;
  String? productCode;
  String? productType;
  String? productVendor;
  String? productManufacturer;
  String? productCategory;
  PortfolioExtrasModel? extras;
  bool? hasExtrasSchema;
  bool? canMakePayment;
  dynamic amountEntered;

  PortfolioUserProductsModel({
    this.id,
    this.activatedAt,
    this.externalId,
    this.name,
    this.displayName,
    this.startDate,
    this.endDate,
    this.currentInvestedValue,
    this.currentValue,
    this.productCode,
    this.productType,
    this.productVendor,
    this.productManufacturer,
    this.productCategory,
    this.extras,
    this.hasExtrasSchema,
    this.canMakePayment,
  });

  PortfolioUserProductsModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    activatedAt = WealthyCast.toStr(json['activatedAt']);
    externalId = WealthyCast.toStr(json['externalId']);
    name = WealthyCast.toStr(json['name']);
    displayName = WealthyCast.toStr(json['displayName']);
    startDate = json['startDate'];
    endDate = json['endDate'];
    currentInvestedValue = json['currentInvestedValue'];
    currentValue = json['currentValue'];
    productCode = WealthyCast.toStr(json['productCode']);
    productType = WealthyCast.toStr(json['productType']);
    productVendor = WealthyCast.toStr(json['productVendor']);
    productManufacturer = WealthyCast.toStr(json['productManufacturer']);
    productCategory = WealthyCast.toStr(json['productCategory']);
    extras = json['extras'] != null
        ? new PortfolioExtrasModel.fromJson(json['extras'])
        : null;
    hasExtrasSchema = WealthyCast.toBool(json['hasExtrasSchema']);
    canMakePayment = WealthyCast.toBool(json['canMakePayment']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['activatedAt'] = this.activatedAt;
    data['externalId'] = this.externalId;
    data['name'] = this.name;
    data['displayName'] = this.displayName;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['currentInvestedValue'] = this.currentInvestedValue;
    data['currentValue'] = this.currentValue;
    data['productCode'] = this.productCode;
    data['productType'] = this.productType;
    data['productVendor'] = this.productVendor;
    data['productManufacturer'] = this.productManufacturer;
    data['productCategory'] = this.productCategory;
    if (this.extras != null) {
      data['extras'] = this.extras!.toJson();
    }
    data['hasExtrasSchema'] = this.hasExtrasSchema;
    data['canMakePayment'] = this.canMakePayment;
    return data;
  }
}
