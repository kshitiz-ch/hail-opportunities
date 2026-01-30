import 'package:core/modules/common/resources/wealthy_cast.dart';

class InsuranceDetailModel {
  String? productVariant;
  bool? viaWebView;
  bool? isNewFlow;
  List<InsuranceProductDetailModel>? products;
  String? contactPhone;

  InsuranceDetailModel({this.productVariant, this.products, this.contactPhone});
  InsuranceDetailModel.fromJson(Map<String, dynamic> json) {
    productVariant = WealthyCast.toStr(json['product_variant']);
    contactPhone = WealthyCast.toStr(json['contact_phone']);
    viaWebView = WealthyCast.toBool(json['via_webview']);
    isNewFlow = WealthyCast.toBool(json['new_flow']);
    if (json['products'] != null) {
      products = <InsuranceProductDetailModel>[];
      json['products'].forEach((v) {
        products!.add(new InsuranceProductDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_variant'] = this.productVariant;
    if (this.products != null) {
      data['products'] = this.products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InsuranceProductDetailModel {
  String? name;
  String? logo;
  String? description;
  String? quoteUrl;
  List<String>? benefits;
  bool? isOffline;

  InsuranceProductDetailModel({
    this.name,
    this.logo,
    this.description,
    this.quoteUrl,
    this.benefits,
    this.isOffline,
  });

  InsuranceProductDetailModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    logo = WealthyCast.toStr(json['logo']);
    description = WealthyCast.toStr(json['description']);
    quoteUrl = WealthyCast.toStr(json['quote_url']);
    benefits = json['benefits'] != null
        ? WealthyCast.toList(json['benefits'].cast<String>())
        : null;
    isOffline = WealthyCast.toBool(json['is_offline']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['logo'] = this.logo;
    data['is_offline'] = this.isOffline;
    data['benefits'] = this.benefits;
    return data;
  }
}
