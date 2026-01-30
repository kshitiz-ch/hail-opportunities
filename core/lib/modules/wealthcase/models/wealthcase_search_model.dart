import 'package:core/modules/common/resources/wealthy_cast.dart';

class WealthcaseSearchResultModel {
  final String? basketId;
  final String? riaName;
  final String? name;
  final String? viewName;
  final String? description;
  final String? status;
  final String? sectors;
  final double? minInvestment;
  final String? riskProfile;
  final int? stockCount;
  final String? productType;
  final String? productVariant;
  final String? category;
  final double? oneYearReturns;
  final double? threeYearReturns;
  final double? fiveYearReturns;

  WealthcaseSearchResultModel({
    this.basketId,
    this.riaName,
    this.name,
    this.viewName,
    this.description,
    this.status,
    this.sectors,
    this.minInvestment,
    this.riskProfile,
    this.stockCount,
    this.productType,
    this.productVariant,
    this.category,
    this.oneYearReturns,
    this.threeYearReturns,
    this.fiveYearReturns,
  });

  factory WealthcaseSearchResultModel.fromJson(Map<String, dynamic> json) =>
      WealthcaseSearchResultModel(
        basketId: WealthyCast.toStr(json['basket_id']),
        riaName: WealthyCast.toStr(json['ria_name']),
        name: WealthyCast.toStr(json['name']),
        viewName: WealthyCast.toStr(json['view_name']),
        description: WealthyCast.toStr(json['description']),
        status: WealthyCast.toStr(json['status']),
        sectors: WealthyCast.toStr(json['sectors']),
        minInvestment: WealthyCast.toDouble(json['min_investment']),
        riskProfile: WealthyCast.toStr(json['risk_profile']),
        stockCount: WealthyCast.toInt(json['stock_count']),
        productType: WealthyCast.toStr(json['product_type']),
        productVariant: WealthyCast.toStr(json['product_variant']),
        category: WealthyCast.toStr(json['category']),
        oneYearReturns: WealthyCast.toDouble(json['one_year_returns']),
        threeYearReturns: WealthyCast.toDouble(json['three_year_returns']),
        fiveYearReturns: WealthyCast.toDouble(json['five_year_returns']),
      );

  // Helper methods for UI display
  String get formattedMinInvestment {
    if (minInvestment == null) return '₹0';
    return '₹${minInvestment!.toStringAsFixed(2)}';
  }

  String get displayRiskProfile {
    if (riskProfile == null) return 'Unknown';
    switch (riskProfile!.toUpperCase()) {
      case 'HIGH':
        return 'High Risk';
      case 'MEDIUM':
        return 'Medium Risk';
      case 'LOW':
        return 'Low Risk';
      default:
        return riskProfile!;
    }
  }

  String get displayStatus {
    if (status == null) return 'Unknown';
    switch (status!.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      case 'suspended':
        return 'Suspended';
      default:
        return status!;
    }
  }

  String get stockCountText {
    if (stockCount == null) return '0 stocks';
    return stockCount == 1 ? '1 stock' : '$stockCount stocks';
  }

  // Helper methods for returns display
  String get formattedOneYearReturns {
    if (oneYearReturns == null) return 'N/A';
    return '${(oneYearReturns! * 100).toStringAsFixed(1)}%';
  }

  String get formattedThreeYearReturns {
    if (threeYearReturns == null) return 'N/A';
    return '${(threeYearReturns! * 100).toStringAsFixed(1)}%';
  }

  String get formattedFiveYearReturns {
    if (fiveYearReturns == null) return 'N/A';
    return '${(fiveYearReturns! * 100).toStringAsFixed(1)}%';
  }

  bool get hasPositiveOneYearReturns {
    return oneYearReturns != null && oneYearReturns! > 0;
  }

  bool get hasPositiveThreeYearReturns {
    return threeYearReturns != null && threeYearReturns! > 0;
  }

  bool get hasPositiveFiveYearReturns {
    return fiveYearReturns != null && fiveYearReturns! > 0;
  }
}
