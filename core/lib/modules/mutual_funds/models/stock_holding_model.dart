import 'package:core/modules/common/resources/wealthy_cast.dart';

class StockHoldingModel {
  String? wpc;
  String? holdingName;
  String? holdingTradingSymbol;
  double? holdingPercentage;
  String? marketValue;
  String? sectorName;
  String? reportedSector;

  StockHoldingModel({
    this.wpc,
    this.holdingName,
    this.holdingTradingSymbol,
    this.holdingPercentage,
    this.marketValue,
    this.sectorName,
    this.reportedSector,
  });

  StockHoldingModel.fromJson(Map<String, dynamic> json) {
    wpc = WealthyCast.toStr(json['wpc']);
    holdingName = WealthyCast.toStr(json['holding_name']);
    holdingTradingSymbol = WealthyCast.toStr(json['holding_trading_symbol']);
    holdingPercentage = WealthyCast.toDouble(json['holding_percentage']);
    marketValue = WealthyCast.toStr(json['market_value']);
    sectorName = WealthyCast.toStr(json['sector_name']);
    reportedSector = WealthyCast.toStr(json['reported_sector']);
  }
}
