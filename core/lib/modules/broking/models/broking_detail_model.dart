import 'package:core/modules/common/resources/wealthy_cast.dart';

enum BrokingGraphType { payin, payout, brokerage, trades }

class BrokingDetailModel {
  BrokingSummaryModel? brokingSummaryModel;
  Map<BrokingGraphType, List<BrokingMonthlyDataModel>> brokingGraphData = {
    BrokingGraphType.brokerage: [],
    BrokingGraphType.payin: [],
    BrokingGraphType.payout: [],
    BrokingGraphType.trades: [],
  };

  BrokingDetailModel.fromJson(Map<String, dynamic> json) {
    brokingSummaryModel = BrokingSummaryModel.fromJson(json);
    getBrokingGraphModel(json);
  }

  void getBrokingGraphModel(Map<String, dynamic> json) {
    final now = DateTime.now();
    bool isCurrentMonthDataPresent = false;

    // last 5 months data
    json.entries.forEach(
      (entry) {
        // key format yyyy-mm
        if (entry.key.contains('-') && entry.value is Map) {
          final data = entry.key.split('-').toList();
          if (data.length == 2) {
            final month = WealthyCast.toInt(data.last);
            final year = WealthyCast.toInt(data.first);

            if (month == now.month && year == now.year) {
              isCurrentMonthDataPresent = true;
            }

            if (month != null && year != null) {
              final date = DateTime(year, month);
              Map graphData = entry.value;

              graphData.entries.forEach(
                (graphEntry) {
                  final graphValue = WealthyCast.toDouble(graphEntry.value);
                  final brokingMonthlyDataModel = BrokingMonthlyDataModel(
                    data: graphValue,
                    date: date,
                    month: date.month,
                  );
                  switch (graphEntry.key) {
                    case 'payin':
                      brokingGraphData[BrokingGraphType.payin]
                          ?.add(brokingMonthlyDataModel);
                      break;
                    case 'payout':
                      brokingGraphData[BrokingGraphType.payout]
                          ?.add(brokingMonthlyDataModel);
                      break;
                    case 'trades':
                      brokingGraphData[BrokingGraphType.trades]
                          ?.add(brokingMonthlyDataModel);
                      break;
                    case 'brokerage':
                      brokingGraphData[BrokingGraphType.brokerage]
                          ?.add(brokingMonthlyDataModel);
                      break;
                    default:
                  }
                },
              );
            }
          }
        }
      },
    );

    if (!isCurrentMonthDataPresent) {
      // add this month data
      brokingGraphData[BrokingGraphType.brokerage]?.add(
        BrokingMonthlyDataModel(
          data: brokingSummaryModel?.monthlyBrokerage,
          date: now,
          month: now.month,
        ),
      );
      brokingGraphData[BrokingGraphType.payin]?.add(
        BrokingMonthlyDataModel(
          data: brokingSummaryModel?.monthlyPayin,
          date: now,
          month: now.month,
        ),
      );
      brokingGraphData[BrokingGraphType.payout]?.add(
        BrokingMonthlyDataModel(
          data: brokingSummaryModel?.monthlyPayout,
          date: now,
          month: now.month,
        ),
      );
      brokingGraphData[BrokingGraphType.trades]?.add(
        BrokingMonthlyDataModel(
          data: brokingSummaryModel?.monthlyTrades,
          date: now,
          month: now.month,
        ),
      );
    }
  }
}

class BrokingSummaryModel {
  double? yesterdayPayin;
  double? monthlyPayin;
  double? monthlyPayout;
  double? yesterdayPayout;
  double? monthlyTrades;
  double? yesterdayTrades;
  double? yesterdayBrokerage;
  double? monthlyBrokerage;
  double? yesterdayTradingActivated;
  double? monthlyTradingActivated;
  double? yesterdayFNOActivated;
  double? monthlyFNOActivated;

  BrokingSummaryModel.fromJson(Map<String, dynamic> json) {
    yesterdayPayin = WealthyCast.toDouble(json['payin_yesterday']);
    yesterdayPayout = WealthyCast.toDouble(json['payout_yesterday']);
    yesterdayTrades = WealthyCast.toDouble(json['trades_yesterday']);
    yesterdayBrokerage = WealthyCast.toDouble(json['brokerage_yesterday']);
    monthlyPayin = WealthyCast.toDouble(json['payin_this_month']);
    monthlyPayout = WealthyCast.toDouble(json['payout_this_month']);
    monthlyTrades = WealthyCast.toDouble(json['trades_this_month']);
    monthlyBrokerage = WealthyCast.toDouble(json['brokerage_this_month']);
    yesterdayTradingActivated =
        WealthyCast.toDouble(json['trading_activated_yesterday']);
    monthlyTradingActivated =
        WealthyCast.toDouble(json['trading_activated_last_month']);
    yesterdayFNOActivated =
        WealthyCast.toDouble(json['fno_activated_yesterday']);
    monthlyFNOActivated =
        WealthyCast.toDouble(json['fno_activated_last_month']);
  }
}

class BrokingMonthlyDataModel {
  double? data;
  int? month;
  DateTime? date;

  BrokingMonthlyDataModel({this.data, this.month, this.date});
}
