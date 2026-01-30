import 'package:core/modules/common/resources/wealthy_cast.dart';

class EmpanelmentModel {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? externalId;
  String? status;
  int? fees;
  double? gst;
  double? totalFees;
  DateTime? empanelledAt;
  DateTime? bypassedAt;
  String? orderId;
  String? thirdPartyOrderId;
  String? orderStatus;
  DateTime? orderFinalStageArrivedAt;

  EmpanelmentModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.externalId,
    this.status,
    this.fees,
    this.gst,
    this.totalFees,
    this.empanelledAt,
    this.bypassedAt,
    this.orderId,
    this.thirdPartyOrderId,
    this.orderStatus,
    this.orderFinalStageArrivedAt,
  });

  EmpanelmentModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    updatedAt = WealthyCast.toDate(json['updatedAt']);
    externalId = WealthyCast.toStr(json['externalId']);
    status = WealthyCast.toStr(json['status']);
    fees = WealthyCast.toInt(json['fees']);
    gst = WealthyCast.toDouble(json['gst']);
    totalFees = WealthyCast.toDouble(json['totalFees']);
    empanelledAt = WealthyCast.toDate(json['empanelledAt']);
    bypassedAt = WealthyCast.toDate(json['bypassedAt']);
    orderId = WealthyCast.toStr(json['orderId']);
    thirdPartyOrderId = WealthyCast.toStr(json['thirdPartyOrderId']);
    orderStatus = WealthyCast.toStr(json['orderStatus']);
    orderFinalStageArrivedAt =
        WealthyCast.toDate(json['orderFinalStageArrivedAt']);
  }
}
