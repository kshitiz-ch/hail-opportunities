import 'package:core/modules/common/resources/wealthy_cast.dart';

class ReturnsModel {
  double? oneWeekRtrns;
  double? oneMtRtrns;
  double? oneYrRtrns;
  double? sixMtRtrns;
  double? fiveYrRtrns;
  double? threeMtRtrns;
  double? threeYrRtrns;
  double? rtrnsSinceLaunch;

  ReturnsModel({
    this.oneWeekRtrns,
    this.oneMtRtrns,
    this.oneYrRtrns,
    this.sixMtRtrns,
    this.fiveYrRtrns,
    this.threeMtRtrns,
    this.threeYrRtrns,
    this.rtrnsSinceLaunch,
  });

  ReturnsModel.fromJson(Map<String, dynamic> json) {
    oneWeekRtrns = WealthyCast.toDouble(json["oneWeekRtrns"] ??
        json["oneWkRtrns"] ??
        json["one_week_rtrns"] ??
        json["one_wk_rtrns"] ??
        0);
    oneMtRtrns =
        WealthyCast.toDouble(json["oneMtRtrns"] ?? json["one_mt_rtrns"] ?? 0);
    oneYrRtrns =
        WealthyCast.toDouble(json["oneYrRtrns"] ?? json["one_yr_rtrns"] ?? 0);
    threeYrRtrns = WealthyCast.toDouble(
        json["threeYrRtrns"] ?? json["three_yr_rtrns"] ?? 0);
    fiveYrRtrns =
        WealthyCast.toDouble(json["fiveYrRtrns"] ?? json["five_yr_rtrns"] ?? 0);
    sixMtRtrns =
        WealthyCast.toDouble(json["sixMtRtrns"] ?? json["six_mt_rtrns"] ?? 0);
    threeMtRtrns = WealthyCast.toDouble(
        json["threeMtRtrns"] ?? json["three_mt_rtrns"] ?? 0);
    threeYrRtrns = WealthyCast.toDouble(
        json["threeYrRtrns"] ?? json["three_yr_rtrns"] ?? 0);
    rtrnsSinceLaunch = WealthyCast.toDouble(
        json['rtrnsSinceLaunch'] ?? json["rtrns_since_launch"] ?? 0);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oneMtRtrns'] = this.oneMtRtrns ?? 0;
    data['oneYrRtrns'] = this.oneYrRtrns ?? 0;
    data['sixMtRtrns'] = this.sixMtRtrns ?? 0;
    data['fiveYrRtrns'] = this.fiveYrRtrns ?? 0;
    data['threeMtRtrns'] = this.threeMtRtrns ?? 0;
    data['threeYrRtrns'] = this.threeYrRtrns ?? 0;
    data['rtrnsSinceLaunch'] = this.rtrnsSinceLaunch ?? 0;
    return data;
  }
}
