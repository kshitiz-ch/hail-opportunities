import 'package:core/modules/common/resources/wealthy_cast.dart';

class RevenueSheetOverviewModel {
  double? currentRevenue;
  double? upfrontRevenue;
  double? trailRevenue;
  double? rewardRevenue;
  double? lockedRevenue;
  double? unlockedRevenue;

  RevenueSheetOverviewModel({
    this.currentRevenue,
    this.upfrontRevenue,
    this.trailRevenue,
    this.rewardRevenue,
    this.lockedRevenue,
    this.unlockedRevenue,
  });

  RevenueSheetOverviewModel.fromJson(Map<String, dynamic> json) {
    currentRevenue = WealthyCast.toDouble(json['current_revenue']);
    upfrontRevenue = WealthyCast.toDouble(json['upfront_revenue']);
    trailRevenue = WealthyCast.toDouble(json['trail_revenue']);
    rewardRevenue = WealthyCast.toDouble(json['reward_revenue']);
    lockedRevenue = WealthyCast.toDouble(json['locked_revenue']);
    unlockedRevenue = WealthyCast.toDouble(json['unlocked_revenue']);
  }
}
