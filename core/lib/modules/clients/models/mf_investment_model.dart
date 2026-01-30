import 'package:api_sdk/log_util.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

import 'client_investments_model.dart';

class MfInvestmentModel {
  MfInvestmentModel({this.products, this.overview});

  MfProductsInvestmentModel? products;
  InvestmentOverviewModel? overview;

  MfInvestmentModel.fromJson(Map<String, dynamic> json) {
    overview = json['overview'] != null
        ? InvestmentOverviewModel.fromJson(json['overview'])
        : null;
    products = json['products'] != null
        ? MfProductsInvestmentModel.fromJson(json['products'])
        : null;
  }
}

class MfProductsInvestmentModel {
  MfProductInvestmentModel? customPortfolios;
  MfProductInvestmentModel? otherFunds;
  MfProductInvestmentModel? wealthyPortfolios;

  MfProductsInvestmentModel(
      {this.customPortfolios, this.otherFunds, this.wealthyPortfolios});

  MfProductsInvestmentModel.fromJson(Map<String, dynamic> json) {
    customPortfolios = json['customPortfolios'] != null
        ? MfProductInvestmentModel.fromJson(json['customPortfolios'])
        : null;
    otherFunds = json['otherFunds'] != null
        ? new MfProductInvestmentModel.fromJson(json['otherFunds'])
        : null;
    wealthyPortfolios = json['wealthyPortfolios'] != null
        ? new MfProductInvestmentModel.fromJson(json['wealthyPortfolios'])
        : null;
    // customPortfolios = null;
    // wealthyPortfolios = null;
    // otherFunds = json['other_funds'] != null
    //     ? new MfProductInvestmentModel.fromJson({
    //         "current_absolute_returns": 0.08467901450518911,
    //         "current_invested_value": 11059.767458,
    //         "current_irr": 0,
    //         "current_value": 11996.297667,
    //         "products": [
    //           {
    //             "current_absolute_returns": 0.084679,
    //             "current_as_on": "2024-03-13",
    //             "current_invested_value": 11059.767458,
    //             "current_irr": 0.290362,
    //             "current_value": 11996.297667,
    //             "external_id":
    //                 "PGNsYXNzICdhY2NvdW50cy5tb2RlbHMuR29hbCc+OjI4Nzg2",
    //             "goal_type": "AnyFund",
    //             "portfolio_name": "Any Fund",
    //             "product_name": "Any Fund",
    //             "schemes": [
    //               {
    //                 "current_absolute_returns": 0.214464,
    //                 "current_as_on": "2024-03-13",
    //                 "current_invested_value": 1000,
    //                 "current_irr": 0.382424,
    //                 "current_value": 1214.464381,
    //                 "folio_overviews": [
    //                   {
    //                     "absolute_returns": 0.214464381,
    //                     "as_on": "2024-03-13",
    //                     "current_irr": 0.382424,
    //                     "current_value": 1214.464381,
    //                     "exit_load_free_amount": 0,
    //                     "folio_number": "13756660",
    //                     "id":
    //                         "PGNsYXNzICdyZXBvcnRzLm1vZGVscy5Gb2xpb092ZXJ2aWV3Jz46MTM4NTUw",
    //                     "invested_value": 1000,
    //                     "is_tax_saver": false,
    //                     "live_ltcg": 0,
    //                     "live_stcg": 219.029546,
    //                     "units": 17.519,
    //                     "withdrawal_amount_available": 1214.464381,
    //                     "withdrawal_units_available": 17.519
    //                   },
    //                   {
    //                     "absolute_returns": 0.214464381,
    //                     "as_on": "2024-03-13",
    //                     "current_irr": 0.382424,
    //                     "current_value": 1214.464381,
    //                     "exit_load_free_amount": 0,
    //                     "folio_number": "24856660",
    //                     "id":
    //                         "PGNsYXNzICdyZXBvcnRzLm1vZGVscy5Gb2xpb092ZXJ2aWV3Jz46MTM4NTUw",
    //                     "invested_value": 1000,
    //                     "is_tax_saver": false,
    //                     "live_ltcg": 0,
    //                     "live_stcg": 219.029546,
    //                     "units": 17.519,
    //                     "withdrawal_amount_available": 1214.464381,
    //                     "withdrawal_units_available": 17.519
    //                   }
    //                 ],
    //                 "for_switch": false,
    //                 "id":
    //                     "PGNsYXNzICdnb2FsbWV0YS5tb2RlbHMuVXNlckdvYWxTdWJ0eXBlU2NoZW1lJz46MjY1NDgx",
    //                 "ideal_weight": 0,
    //                 "is_deprecated": false,
    //                 "scheme_data": {
    //                   "category": "Flexi Cap Fund",
    //                   "display_name": "Parag Parikh Flexi Cap Fund (G)",
    //                   "expense_ratio": 1.33,
    //                   "fund_type": 0,
    //                   "id":
    //                       "PGNsYXNzICdyZXBvcnRzLm1vZGVscy5DdXJyZW50TmF2Jz46Tm9uZQ==",
    //                   "launchDate": "2013-05-13",
    //                   "nav": 69.3227,
    //                   "nav_date": "2024-03-12",
    //                   "wschemecode": "MPFSPP001RGGR"
    //                 }
    //               }
    //             ]
    //           }
    //         ]
    //       })
    //     : null;
  }
}

class MfProductInvestmentModel {
  double? currentAbsoluteReturns;
  double? currentInvestedValue;
  int? currentIrr;
  double? currentValue;
  List<PortfolioInvestmentModel>? products;

  MfProductInvestmentModel(
      {this.currentAbsoluteReturns,
      this.currentInvestedValue,
      this.currentIrr,
      this.currentValue,
      this.products});

  MfProductInvestmentModel.fromJson(Map<String, dynamic> json) {
    currentAbsoluteReturns =
        WealthyCast.toDouble(json['current_absolute_returns']);
    currentInvestedValue = WealthyCast.toDouble(
        json['current_invested_value'] ?? json['currentInvested']);
    currentIrr = WealthyCast.toInt(json['current_irr'] ?? json['currentIrr']);
    currentValue =
        WealthyCast.toDouble(json['current_value'] ?? json['currentValue']);
    if (json['products'] != null) {
      products = <PortfolioInvestmentModel>[];
      json['products'].forEach((v) {
        products!.add(PortfolioInvestmentModel.fromJson(v));
      });
    }
  }
}

class PortfolioInvestmentModel {
  double? currentAbsoluteReturns;
  DateTime? currentAsOn;
  int? currentInvestedValue;
  double? currentIrr;
  double? currentValue;
  String? externalId;
  String? goalType;
  String? portfolioName;
  String? productName;
  List<SchemeMetaModel>? schemes;

  PortfolioInvestmentModel({
    this.currentAbsoluteReturns,
    this.currentAsOn,
    this.currentInvestedValue,
    this.currentIrr,
    this.currentValue,
    this.externalId,
    this.goalType,
    this.portfolioName,
    this.productName,
  });

  PortfolioInvestmentModel.fromJson(Map<String, dynamic> json) {
    currentAbsoluteReturns = WealthyCast.toDouble(
        json['current_absolute_returns'] ?? json["currentAbsoluteReturns"]);
    currentAsOn =
        WealthyCast.toDate(json['current_as_on'] ?? json["currentAsOn"]);
    currentInvestedValue = WealthyCast.toInt(
        json['current_invested_value'] ?? json["currentInvestedValue"]);
    currentIrr =
        WealthyCast.toDouble(json['current_irr'] ?? json['currentIrr']);
    currentValue =
        WealthyCast.toDouble(json['current_value'] ?? json["currentValue"]);
    externalId = WealthyCast.toStr(json['external_id'] ?? json['externalId']);
    goalType = WealthyCast.toStr(json['goal_type'] ?? json["goalType"]);
    portfolioName =
        WealthyCast.toStr(json['portfolio_name'] ?? json['portfolioName']);
    productName =
        WealthyCast.toStr(json['product_name'] ?? json['productName']);
    schemes = List<SchemeMetaModel>.from(
      WealthyCast.toList(json["schemes"]).map(
        (scheme) {
          Map<String, dynamic> schemeMetaJson = scheme;
          if (scheme["schemeData"] != null) {
            schemeMetaJson["displayName"] = scheme["displayName"];
            schemeMetaJson["category"] = scheme["schemeData"]["category"];
            schemeMetaJson["fundType"] = scheme["schemeData"]["fundType"];
            schemeMetaJson["wschemecode"] = scheme["schemeData"]["wschemecode"];
            try {
              schemeMetaJson["folioOverview"] = scheme["folioOverviews"] != null
                  ? scheme["folioOverviews"][0]
                  : null;
            } catch (error) {
              LogUtil.printLog(error.toString());
            }
          }

          return SchemeMetaModel.fromJson(schemeMetaJson);
        },
      ),
    );
  }
}
