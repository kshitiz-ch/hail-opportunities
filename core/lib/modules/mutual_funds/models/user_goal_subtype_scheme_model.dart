import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

class UserGoalSubtypeSchemeModel {
  double? currentInvestedValue;
  double? currentValue;
  int? idealWeight;
  bool? isDeprecated;
  double? currentAbsoluteReturns;
  double? currentIrr;
  DateTime? currentAsOn;
  String? wpc;
  String? amc;
  SchemeMetaModel? schemeData;
  FolioModel? folioOverview;
  List<FolioModel>? folioOverviews;

  UserGoalSubtypeSchemeModel({
    this.currentInvestedValue,
    this.currentValue,
    this.idealWeight,
    this.isDeprecated,
    this.currentIrr,
    this.currentAsOn,
    this.currentAbsoluteReturns,
    this.wpc,
    this.amc,
    this.schemeData,
    this.folioOverview,
    this.folioOverviews,
  });

  UserGoalSubtypeSchemeModel.fromJson(Map<String, dynamic> json) {
    currentInvestedValue = WealthyCast.toDouble(json['currentInvestedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    idealWeight = WealthyCast.toInt(json['idealWeight']);
    isDeprecated = WealthyCast.toBool(json['isDeprecated']);
    currentIrr = WealthyCast.toDouble(json['currentIrr']);
    currentAsOn = WealthyCast.toDate(json['currentAsOn']);
    currentAbsoluteReturns =
        WealthyCast.toDouble(json['currentAbsoluteReturns']);
    wpc = WealthyCast.toStr(json['wpc']);
    amc = WealthyCast.toStr(json['amc']);
    schemeData = json["schemeData"] != null
        ? SchemeMetaModel.fromJson(json["schemeData"])
        : null;
    folioOverview = json["folioOverview"] != null
        ? FolioModel.fromJson(json["folioOverview"])
        : null;
    folioOverviews = json["folioOverviews"] != null
        ? List<FolioModel>.from(
            WealthyCast.toList(json["folioOverviews"])
                .map((x) => FolioModel.fromJson(x)),
          )
        : null;
  }

  // Deep copy
  UserGoalSubtypeSchemeModel clone() {
    return UserGoalSubtypeSchemeModel(
      currentInvestedValue: this.currentInvestedValue,
      currentValue: this.currentValue,
      idealWeight: this.idealWeight,
      isDeprecated: this.isDeprecated,
      currentIrr: this.currentIrr,
      currentAsOn: this.currentAsOn,
      currentAbsoluteReturns: this.currentAbsoluteReturns,
      schemeData: this.schemeData,
      folioOverview: this.folioOverview,
      folioOverviews: this.folioOverviews,
    );
  }
}
