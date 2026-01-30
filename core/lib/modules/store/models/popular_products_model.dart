import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:core/modules/store/models/fixed_deposit_model.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';

class PopularProductsModel {
  // Fields
  final FundsModel fundsModel;
  final MutualFundsModel mfModel;
  final InsurancesModel insuranceModel;
  final WealthyProductsModel wealthyStoreProducts;

  // Constructor
  PopularProductsModel({
    this.mfModel = const MutualFundsModel(),
    this.insuranceModel = const InsurancesModel(),
    this.fundsModel = const FundsModel(),
    this.wealthyStoreProducts = const WealthyProductsModel(),
  });

  factory PopularProductsModel.fromJson(Map<String, dynamic> json) =>
      PopularProductsModel(
        fundsModel: FundsModel.fromJson(json['mf_funds']),
        insuranceModel: InsurancesModel.fromJson(json['insurance']),
        mfModel: MutualFundsModel.fromJson(json['mf_portfolios']),
        wealthyStoreProducts:
            WealthyProductsModel.fromJson(json['wealthy_products']),
      );

  Map<String, dynamic> toJson() => {};
}

class WealthyProductsModel {
  const WealthyProductsModel({
    this.products = const [],
  });

  final List products;

  factory WealthyProductsModel.fromJson(Map<String, dynamic> json) =>
      WealthyProductsModel(
        products: WealthyCast.toList(json["products"]).map(
          (product) {
            bool isMutualFund =
                WealthyCast.toStr(product['wschemecode']) != null;
            if (isMutualFund) {
              return SchemeMetaModel.fromJson(product);
            } else {
              String productType;
              bool isPortfolio = product['goal_subtypes'] != null;
              if (isPortfolio) {
                var goalSubtype = product['goal_subtypes'][0];
                productType =
                    WealthyCast.toStr(goalSubtype['product_type']) ?? '';
              } else {
                productType = WealthyCast.toStr(product['product_type']) ?? '';
              }
              switch (productType.toLowerCase()) {
                case ProductType.MF:
                  return GoalSubtypeModel.fromJson(product['goal_subtypes'][0]);
                case ProductType.UNLISTED_STOCK:
                  return UnlistedProductModel.fromJson(product);
                case ProductType.DEBENTURE:
                  return DebentureModel.fromJson(product);
                case ProductType.FIXED_DEPOSIT:
                  return FixedDepositModel.fromJson(product);
                case ProductType.SAVINGS:
                case ProductType.HEALTH:
                case ProductType.TERM:
                case ProductType.TWO_WHEELER:
                  return InsuranceModel.fromJson(product);
                // Temp
                case ProductType.DEMAT:
                  return UnlistedProductModel.fromJson(product);
                default:
                  return null;
              }
            }
          },
        ).toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

// Funds Model
class FundsModel {
  const FundsModel({
    this.products = const [],
  });

  final List<SchemeMetaModel> products;

  factory FundsModel.fromJson(Map<String, dynamic> json) => FundsModel(
        products: WealthyCast.toList(json["products"])
            .map<SchemeMetaModel>((x) => SchemeMetaModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

// MF Model
class MutualFundsModel {
  const MutualFundsModel({
    this.products = const [],
  });

  final List<MFProductModel> products;

  factory MutualFundsModel.fromJson(Map<String, dynamic> json) =>
      MutualFundsModel(
        products: WealthyCast.toList(json["products"])
            .map<MFProductModel>((x) => MFProductModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
      };
}

// Pre IPOs Model
class UnlistedStocksModel {
  const UnlistedStocksModel({
    this.products = const [],
  });

  final List<UnlistedProductModel> products;

  factory UnlistedStocksModel.fromJson(Map<String, dynamic> json) =>
      UnlistedStocksModel(
        products: WealthyCast.toList(json["products"])
            .map<UnlistedProductModel>((x) => UnlistedProductModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(
          products.map((x) => x.toJson()),
        ),
      };
}

// Insurances Model
class InsurancesModel {
  const InsurancesModel({
    this.products = const [],
  });

  final List<InsuranceModel> products;

  factory InsurancesModel.fromJson(Map<String, dynamic> json) =>
      InsurancesModel(
        products: WealthyCast.toList(json["products"])
            .map<InsuranceModel>((x) => InsuranceModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(
          products.map((x) => x.toJson()),
        ),
      };
}

// Debentures
class DebenturesModel {
  const DebenturesModel({
    this.products = const [],
  });

  final List<DebentureModel> products;

  factory DebenturesModel.fromJson(Map<String, dynamic> json) =>
      DebenturesModel(
        products: WealthyCast.toList(json["products"])
            .map<DebentureModel>((x) => DebentureModel.fromJson(x))
            .toList(),
      );
}

class FixedDepositsModel {
  const FixedDepositsModel({
    this.products = const [],
  });

  final List<FixedDepositModel> products;

  factory FixedDepositsModel.fromJson(Map<String, dynamic> json) =>
      FixedDepositsModel(
        products: WealthyCast.toList(json["products"])
            .map<FixedDepositModel>((x) => FixedDepositModel.fromJson(x))
            .toList(),
      );
}

class ProductType {
  static const MF = "mf";
  static const UNLISTED_STOCK = "unlistedstock";
  static const DEBENTURE = "mld";
  static const FIXED_DEPOSIT = "fd";
  static const SAVINGS = "traditional";
  static const HEALTH = "health";
  static const TERM = "term";
  static const TWO_WHEELER = "general";
  // Temp
  static const DEMAT = "demat";
}
