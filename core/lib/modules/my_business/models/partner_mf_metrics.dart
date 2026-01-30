import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerMFMetrics {
  double? currentMonthGtv;
  double? percentChangeInGtv;
  double? currentMonthSwitchAmount;
  double? currentMonthTotalPurchase;
  double? currentMonthTotalWithdrawal;
  double? totalMfInvestors;

  PartnerMFMetrics.fromJson(Map<String, dynamic> json) {
    currentMonthGtv = WealthyCast.toDouble(json['current_month_gtv']);
    percentChangeInGtv = WealthyCast.toDouble(json['percent_change_in_gtv']);
    currentMonthSwitchAmount =
        WealthyCast.toDouble(json['current_month_switch_amount']);
    currentMonthTotalPurchase =
        WealthyCast.toDouble(json['current_month_total_purchase']);
    currentMonthTotalWithdrawal =
        WealthyCast.toDouble(json['current_month_total_withdrawal']);
    totalMfInvestors = WealthyCast.toDouble(json['total_mf_investors']);
  }
}
