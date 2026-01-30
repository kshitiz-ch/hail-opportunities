import 'dart:math';

import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

final defaultFdMaxAmount = 10000000;
final defaultFdMinAmount = 15000;

class FixedDepositListModel {
  List<FixedDepositModel>? available;
  TenureMonths? tenureMonths;

  int maxAmount = defaultFdMaxAmount;
  int minAmount = defaultFdMinAmount;

  FixedDepositListModel.fromJson(Map<String, dynamic> json) {
    if (json['available'] != null) {
      available = <FixedDepositModel>[];
      json['available'].forEach((v) {
        available!.add(FixedDepositModel.fromJson(v));
      });
    }
    tenureMonths = json['tenure_months'] != null
        ? TenureMonths.fromJson(json['tenure_months'])
        : null;

    updateAmount();
  }

  void updateAmount() {
    if (available.isNotNullOrEmpty) {
      maxAmount = available!.first.productOverview?.amount?.maximumAmount ??
          defaultFdMaxAmount;
      minAmount = available!.first.productOverview?.amount?.minimumAmount ??
          defaultFdMinAmount;

      available!.forEach((fdProduct) {
        maxAmount = max(
          maxAmount,
          fdProduct.productOverview?.amount?.maximumAmount ?? maxAmount,
        );
        minAmount = min(
          minAmount,
          fdProduct.productOverview?.amount?.minimumAmount ?? minAmount,
        );
      });
    }
  }
}

class TenureMonths {
  int? min;
  int? max;

  TenureMonths.fromJson(Map<String, dynamic> json) {
    min = WealthyCast.toInt(json['min']);
    max = WealthyCast.toInt(json['max']);
  }
}

class FixedDepositModel {
  String? fdProvider;
  String? displayName;
  String? icon;
  bool? isOnline;
  ProductOverview? productOverview;
  String? crisilRating;
  String? pdfUrl;

  FixedDepositModel.fromJson(Map<String, dynamic> json) {
    fdProvider = WealthyCast.toStr(json['fd_provider']);
    displayName = WealthyCast.toStr(json['display_name']);
    icon = WealthyCast.toStr(json['icon']);
    isOnline = WealthyCast.toBool(json['is_online']);
    crisilRating = WealthyCast.toStr(json['crisil_rating']);
    pdfUrl = WealthyCast.toStr(json['form_pdf_url']);
    productOverview = json['product_overview'] != null
        ? ProductOverview.fromJson(json['product_overview'])
        : json['overview'] != null
            ? ProductOverview.fromJson(json['overview'])
            : null;
  }
}

class ProductOverview {
  InterestRate? interestRate;
  Amount? amount;

  ProductOverview.fromJson(Map<String, dynamic> json) {
    interestRate = json['interest_rate'] != null
        ? InterestRate.fromJson(json['interest_rate'])
        : null;
    amount = json['amount'] != null ? Amount.fromJson(json['amount']) : null;
  }
}

class InterestRate {
  double? minInterestRate;
  double? maxInterestRate;

  InterestRate.fromJson(Map<String, dynamic> json) {
    minInterestRate = WealthyCast.toDouble(json['min_interest_rate']);
    maxInterestRate = WealthyCast.toDouble(json['max_interest_rate']);
  }
}

class Amount {
  int? minimumAmount;
  int? maximumAmount;

  Amount.fromJson(Map<String, dynamic> json) {
    minimumAmount = WealthyCast.toInt(json['minimum_amount']);
    maximumAmount = WealthyCast.toInt(json['maximum_amount']);
  }
}
