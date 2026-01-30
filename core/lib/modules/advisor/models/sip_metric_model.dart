import 'package:core/modules/common/resources/wealthy_cast.dart';

class SipAggregateModel {
  SipMetricModel? activeSip;
  SipMetricModel? newCurrentMonthSip;
  SipMetricModel? pausedCurrentMonth;
  SipMetricModel? wonSip;
  SipMetricModel? failedSip;
  SipMetricModel? pendingSip;
  SipMetricModel? inprogressSip;
  SipMetricModel? todaysMetric;
  SipMetricModel? currentMonthAggregate;
  SipMetricModel? uniqueClientsWithActiveSips;
  SipMetricModel? unsuccessfulMandateSips;
  OfflineSipsModel? offlineSips;

  SipAggregateModel({
    this.activeSip,
    this.newCurrentMonthSip,
    this.pausedCurrentMonth,
    this.wonSip,
    this.failedSip,
    this.pendingSip,
    this.inprogressSip,
    this.todaysMetric,
    this.currentMonthAggregate,
    this.uniqueClientsWithActiveSips,
    this.unsuccessfulMandateSips,
    this.offlineSips,
  });

  SipAggregateModel.fromJson(Map<String, dynamic> sipMetricJson) {
    final onlineSipJson = sipMetricJson['sipAggregateData'];
    final offlineSipJson = sipMetricJson['partnerMfOfflineSips'];

    activeSip = onlineSipJson["activeSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["activeSip"])
        : null;
    newCurrentMonthSip = onlineSipJson["newCurrentMonthSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["newCurrentMonthSip"])
        : null;
    pausedCurrentMonth = onlineSipJson["pausedCurrentMonth"] != null
        ? SipMetricModel.fromJson(onlineSipJson["pausedCurrentMonth"])
        : null;
    wonSip = onlineSipJson["wonSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["wonSip"])
        : null;
    failedSip = onlineSipJson["failedSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["failedSip"])
        : null;
    pendingSip = onlineSipJson["pendingSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["pendingSip"])
        : null;
    inprogressSip = onlineSipJson["inprogressSip"] != null
        ? SipMetricModel.fromJson(onlineSipJson["inprogressSip"])
        : null;
    todaysMetric = onlineSipJson["todaysMetric"] != null
        ? SipMetricModel.fromJson(onlineSipJson["todaysMetric"])
        : null;
    currentMonthAggregate = onlineSipJson["currentMonthAggregate"] != null
        ? SipMetricModel.fromJson(onlineSipJson["currentMonthAggregate"])
        : null;
    uniqueClientsWithActiveSips =
        onlineSipJson["uniqueClientsWithActiveSips"] != null
            ? SipMetricModel.fromJson(
                onlineSipJson["uniqueClientsWithActiveSips"])
            : null;
    unsuccessfulMandateSips = onlineSipJson["unsuccessfulMandateSips"] != null
        ? SipMetricModel.fromJson(onlineSipJson["unsuccessfulMandateSips"])
        : null;
    offlineSips = offlineSipJson != null
        ? OfflineSipsModel.fromJson(offlineSipJson)
        : null;
  }
}

class SipMetricModel {
  double? amount;
  double? sipAmount;
  int? sips;
  int? count;
  int? transactions;

  SipMetricModel({
    this.amount,
    this.sipAmount,
    this.sips,
    this.count,
    this.transactions,
  });

  SipMetricModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toDouble(json['amount']);
    sipAmount = WealthyCast.toDouble(json['sipAmount']);
    count = WealthyCast.toInt(json['count']);
    sips = WealthyCast.toInt(json['sips']);
    transactions = WealthyCast.toInt(json['transactions']);
  }
}

class MonthSipModel {
  int? month;
  double? amount;

  MonthSipModel({this.amount, this.month});

  MonthSipModel.fromJson(Map<String, dynamic> json) {
    month = WealthyCast.toInt(json['month']);
    amount = WealthyCast.toDouble(json['amount']);
  }
}

class DailySipModel {
  int? count;
  double? amount;
  int? day;

  DailySipModel({this.count, this.amount, this.day});

  DailySipModel.fromJson(Map<String, dynamic> json) {
    count = WealthyCast.toInt(json['count']);
    amount = WealthyCast.toDouble(json['amount']);
  }
}

class OfflineSipsModel {
  int? count;
  double? activeAmount;
  int? activeCount;
  int? pausedCount;
  int? inactiveCount;
  double? activeMonthlyAmount;

  OfflineSipsModel({
    this.count,
    this.activeAmount,
    this.activeCount,
    this.pausedCount,
    this.inactiveCount,
    this.activeMonthlyAmount,
  });

  OfflineSipsModel.fromJson(Map<String, dynamic> json) {
    count = WealthyCast.toInt(json['count']);
    activeAmount = WealthyCast.toDouble(json['activeAmount']);
    activeCount = WealthyCast.toInt(json['activeCount']);
    pausedCount = WealthyCast.toInt(json['pausedCount']);
    inactiveCount = WealthyCast.toInt(json['inactiveCount']);
    activeMonthlyAmount = WealthyCast.toDouble(json['activeMonthlyAmount']);
  }
}
