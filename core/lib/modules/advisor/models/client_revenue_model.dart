import 'package:core/modules/advisor/models/product_revenue_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientRevenueModel {
  ClientDetails? clientDetails;
  AgentDetails? agentDetails;
  double? totalRevenue;
  ProductRevenueUIData? productRevenueUIData;

  ClientRevenueModel.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      var products = <ProductRevenueModel>[];
      json['products'].forEach((v) {
        products.add(ProductRevenueModel.fromJson(v));
      });
      productRevenueUIData = ProductRevenueUIData(products);
    }
    clientDetails = json['client_details'] != null
        ? ClientDetails.fromJson(json['client_details'])
        : null;
    agentDetails = json['agent_details'] != null
        ? AgentDetails.fromJson(json['agent_details'])
        : null;
    totalRevenue = json['total_revenue'];
  }
}

class ClientDetails {
  String? name;
  String? taxyId;
  String? crn;

  ClientDetails.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    taxyId = WealthyCast.toStr(json['taxy_id']);
    crn = WealthyCast.toStr(json['crn']);
  }
}

class AgentDetails {
  String? name;
  String? email;
  String? phoneNumber;

  AgentDetails.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    email = WealthyCast.toStr(json['email']);
    phoneNumber = WealthyCast.toStr(json['phone_number']);
  }
}
