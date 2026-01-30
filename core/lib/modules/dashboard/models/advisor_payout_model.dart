import 'package:core/modules/common/resources/wealthy_cast.dart';

class AdvisorPayoutModel {
  CurrentRevenueDisplay? currentRevenue;
  PayoutDisplay? payout;

  AdvisorPayoutModel({this.currentRevenue, this.payout});

  factory AdvisorPayoutModel.fromJson(Map<String, dynamic> json) =>
      AdvisorPayoutModel(
          currentRevenue: json["current_revenue_display"] != null
              ? CurrentRevenueDisplay.fromJson(json["current_revenue_display"])
              : null,
          payout: json["payout_display"] != null
              ? PayoutDisplay.fromJson(json["payout_display"])
              : null);
}

class CurrentRevenueDisplay {
  String? text;
  String? info;

  CurrentRevenueDisplay({this.text, this.info});

  factory CurrentRevenueDisplay.fromJson(Map<String, dynamic> json) =>
      CurrentRevenueDisplay(
          text: json["row1"] != null
              ? WealthyCast.toStr(json["row1"]["text"])
              : null,
          info: json["row1"] != null
              ? WealthyCast.toStr(json["row1"]["info"])
              : null);
}

class PayoutDisplay {
  String? text;
  String? info;

  PayoutDisplay({this.text, this.info});

  factory PayoutDisplay.fromJson(Map<String, dynamic> json) => PayoutDisplay(
      text:
          json["row1"] != null ? WealthyCast.toStr(json["row1"]["text"]) : null,
      info: json["row1"] != null
          ? WealthyCast.toStr(json["row1"]["info"])
          : null);
}
