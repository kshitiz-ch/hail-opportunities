import 'package:core/modules/common/resources/wealthy_cast.dart';

class BrokingPlanModel {
  double? openingCharges;
  double? amcCharges;
  String? planName;
  String? planCode;
  SegmentCharge? equityDelivery;
  SegmentCharge? equityOptions;
  SegmentCharge? equityIntraday;
  SegmentCharge? equityFuture;
  bool? isWealthyDefault;

  BrokingPlanModel({
    this.openingCharges,
    this.amcCharges,
    this.planName,
    this.planCode,
    this.equityDelivery,
    this.equityOptions,
    this.equityIntraday,
    this.equityFuture,
    this.isWealthyDefault,
  });

  BrokingPlanModel.fromJson(Map<String, dynamic> json) {
    openingCharges = WealthyCast.toDouble(json['openingCharges']);
    amcCharges = WealthyCast.toDouble(json['amcCharges']);
    planName = WealthyCast.toStr(json['planName']);
    planCode = WealthyCast.toStr(json['planCode']);
    isWealthyDefault = WealthyCast.toBool(json['isWealthyDefault']);
    if (json['segmentCharges'] != null) {
      json['segmentCharges'].forEach((v) {
        SegmentCharge segmentCharge = SegmentCharge.fromJson(v);

        if (segmentCharge.tradeSegment == "EQT_DEL" &&
            !(segmentCharge.templateName!.contains("HUF"))) {
          equityDelivery = segmentCharge;
        }

        if (segmentCharge.tradeSegment == "EQT_INT") {
          equityIntraday = segmentCharge;
        }

        if (segmentCharge.tradeSegment == "OPTION") {
          equityOptions = segmentCharge;
        }

        if (segmentCharge.tradeSegment == "FUTURE") {
          equityFuture = segmentCharge;
        }
      });
    }
  }

  BrokingPlanModel.clone(BrokingPlanModel x)
      : this(
          openingCharges: x.openingCharges,
          amcCharges: x.amcCharges,
          planName: x.planName,
          planCode: x.planCode,
          equityDelivery: x.equityDelivery,
          equityOptions: x.equityOptions,
          equityIntraday: x.equityIntraday,
          isWealthyDefault: x.isWealthyDefault,
        );
}

class SegmentCharge {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? brokerageProfileName;
  String? templateName;
  String? tradeSegment;
  String? chargeType;
  String? chargeValueType;
  double? value;
  int? maxBrokerage;
  String? description;

  SegmentCharge({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.brokerageProfileName,
    this.templateName,
    this.tradeSegment,
    this.chargeType,
    this.chargeValueType,
    this.value,
    this.maxBrokerage,
    this.description,
  });

  SegmentCharge.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toInt(json['id']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    updatedAt = WealthyCast.toDate(json['updatedAt']);
    brokerageProfileName = WealthyCast.toStr(json['brokerageProfileName']);
    templateName = WealthyCast.toStr(json['templateName']);
    tradeSegment = WealthyCast.toStr(json['tradeSegment']);
    chargeType = WealthyCast.toStr(json['chargeType']);
    chargeValueType = WealthyCast.toStr(json['chargeValueType']);
    value = WealthyCast.toDouble(json['value']);
    maxBrokerage = WealthyCast.toInt(json['maxBrokerage']);
    description = WealthyCast.toStr(json['description']);
  }
}

class BrokingApModel {
  String? apId;
  String? apRegistrationNo;
  String? apName;
  String? panNumber;
  String? externalAgentId;
  String? defaultBrokeragePlan;

  BrokingApModel(
      {this.apId,
      this.apRegistrationNo,
      this.apName,
      this.panNumber,
      this.externalAgentId,
      this.defaultBrokeragePlan});

  BrokingApModel.fromJson(Map<String, dynamic> json) {
    apId = WealthyCast.toStr(json['apId']);
    apRegistrationNo = WealthyCast.toStr(json['apRegistrationNo']);
    apName = WealthyCast.toStr(json['apName']);
    panNumber = WealthyCast.toStr(json['panNumber']);
    externalAgentId = WealthyCast.toStr(json['externalAgentId']);
    defaultBrokeragePlan = WealthyCast.toStr(json['defaultBrokeragePlan']);
  }
}
