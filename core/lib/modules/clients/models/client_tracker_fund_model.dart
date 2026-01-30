import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

class ClientTrackerFundModel {
  double? currentValue;
  double? investedAmount;
  double? absoluteReturns;
  String? schemeCode;
  SchemeMetaModel? schemeMetaModel;

  ClientTrackerFundModel(
      {this.currentValue,
      this.investedAmount,
      this.absoluteReturns,
      this.schemeCode,
      this.schemeMetaModel});

  ClientTrackerFundModel.fromJson(Map<String, dynamic> json) {
    // final folioOverViews = json['folioOverviews'] as List?;
    // final folioOverview = folioOverViews.isNotNullOrEmpty
    //     ? FolioModel.fromJson(folioOverViews?.first)
    //     : null;
    currentValue = WealthyCast.toDouble(json['currentValue']);
    investedAmount = WealthyCast.toDouble(json['investedAmount']);
    absoluteReturns = WealthyCast.toDouble(json['absoluteReturns']);
    schemeCode = WealthyCast.toStr(json['schemeCode']);
    schemeMetaModel = json['schemeMeta'] != null
        ? new SchemeMetaModel.fromJson(json['schemeMeta'])
        : null;
    // if (schemeMetaModel != null) {
    //   schemeMetaModel?.folioOverview = folioOverview;
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentValue'] = this.currentValue;
    data['investedAmount'] = this.investedAmount;
    data['absoluteReturns'] = this.absoluteReturns;
    data['schemeCode'] = this.schemeCode;
    if (this.schemeMetaModel != null) {
      data['schemeMeta'] = this.schemeMetaModel!.toJson();
    }

    return data;
  }
}
