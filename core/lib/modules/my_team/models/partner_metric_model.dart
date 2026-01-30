import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerMetricModel {
  double? currentValue;
  double? currentInvestedValue;
  String? agentExternalId;
  String? date;

  PartnerMetricModel({
    this.currentValue,
    this.currentInvestedValue,
    this.agentExternalId,
    this.date,
  });

  factory PartnerMetricModel.fromJson(Map<String, dynamic> json) =>
      PartnerMetricModel(
        currentValue: WealthyCast.toDouble(json["TOTAL"]?["current_value"]),
        currentInvestedValue:
            WealthyCast.toDouble(json["TOTAL"]?["current_invested_value"]),
        agentExternalId: WealthyCast.toStr(json["agentExternalId"]),
        date: WealthyCast.toStr(json["date"]),
      );
}
