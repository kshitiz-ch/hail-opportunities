import 'package:core/modules/common/resources/wealthy_cast.dart';

class SyncedPanModel {
  String? pan;
  String? name;
  DateTime? lastSyncedAt;
  double? mfOpportunity;
  double? mfCurrentValue;
  String? userId;
  Map<String, BrokerOverview>? brokerOverview;

  // Getter for Wealthy broking overview
  BrokerOverview? get wealthyBrokingOverview => brokerOverview?['W'];

  // Getter for outside broking overview
  BrokerOverview? get outsideBrokingOverview => brokerOverview?['O'];

  // Getter for outside current value
  double? get outsideCurrentValue => outsideBrokingOverview?.currentValue;

  // Getter to check if there are valid outside investments
  bool get hasValidOutsideInvestments {
    if (brokerOverview == null) {
      return false;
    }

    if (outsideBrokingOverview == null) {
      return false;
    }

    final currentValue = outsideBrokingOverview?.currentValue;

    return currentValue != null && currentValue > 0;
  }

  SyncedPanModel.fromJson(Map<String, dynamic> json) {
    pan = WealthyCast.toStr(json['pan']);
    name = WealthyCast.toStr(json['name']);

    lastSyncedAt =
        WealthyCast.toDate(json['lastSyncedAt'] ?? json["last_synced_at"]);

    mfOpportunity = WealthyCast.toDouble(json['mfOpportunity']);
    mfCurrentValue = WealthyCast.toDouble(json['mfCurrentValue']);
    userId = WealthyCast.toStr(json['user_id']);

    // Parse broker overview
    if (json['broker_overview'] != null) {
      brokerOverview = <String, BrokerOverview>{};
      json['broker_overview'].forEach((key, value) {
        brokerOverview![key] = BrokerOverview.fromJson(value);
      });
    }
  }
}

class BrokerOverview {
  double? investedAmount;
  double? currentValue;
  double? irr;

  BrokerOverview.fromJson(Map<String, dynamic> json) {
    investedAmount = WealthyCast.toDouble(json['invested_amount']);
    currentValue = WealthyCast.toDouble(json['current_value']);
    irr = WealthyCast.toDouble(json['irr']);
  }
}
