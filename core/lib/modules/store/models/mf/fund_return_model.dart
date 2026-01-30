import 'dart:math';

import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/models/chart_data_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class FundReturnModel {
  double? currentValue;
  double? investedValue;
  double? absoluteGain;
  double? absoluteGainPercentage;
  double? xirrPercentage;
  List<ChartDataModel> chartDataResult = [];

  // Getters
  double get maxNav {
    if (chartDataResult.isNotEmpty) {
      return (chartDataResult.map<double>((e) => e.nav).reduce(max));
    } else {
      return 0;
    }
  }

  double get minNav {
    if (chartDataResult.isNotEmpty) {
      return (chartDataResult.map<double>((e) => e.nav).reduce(min));
    } else {
      return 0;
    }
  }

  double get maxCurrentValue {
    if (chartDataResult.isNotNullOrEmpty) {
      return (chartDataResult.map<double>((e) => e.currentValue).reduce(max));
    } else {
      return 0;
    }
  }

  double get minCurrentValue {
    if (chartDataResult.isNotNullOrEmpty) {
      return (chartDataResult.map<double>((e) => e.currentValue).reduce(min));
    } else {
      return 0;
    }
  }

  FundReturnModel({
    this.currentValue,
    this.absoluteGain,
    this.absoluteGainPercentage,
    this.xirrPercentage,
    this.investedValue,
  });

  FundReturnModel.fromJson(Map<String, dynamic> json, {bool useNav = false}) {
    currentValue = WealthyCast.toDouble(json['current_value']);
    investedValue = WealthyCast.toDouble(json['invested_value']);
    absoluteGain = (currentValue ?? 0) - (investedValue ?? 0);
    absoluteGainPercentage =
        WealthyCast.toDouble(json['absolute_returns_percentage']);
    xirrPercentage = WealthyCast.toDouble(json['xirr_percentage']);
    chartDataResult = WealthyCast.toList(json['returns_details']).map(
      (dataItem) {
        return ChartDataModel.returnCalculator(
          WealthyCast.toDate(dataItem['nav_date'])?.millisecondsSinceEpoch ?? 0,
          WealthyCast.toDouble(dataItem[useNav ? 'nav' : 'adj_nav']) ?? 0,
          WealthyCast.toDouble(dataItem['percentage']) ?? 0,
          WealthyCast.toDouble(dataItem['current_value']) ?? 0,
          WealthyCast.toDouble(dataItem['invested_value']) ?? 0,
        );
      },
    ).toList();
  }
}
