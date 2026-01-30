import 'package:core/modules/common/resources/wealthy_cast.dart';

class SwpOrderModel {
  String? id;
  DateTime? swpDate;
  String? status;
  double? amount;
  String? customerFailureReason;

  SwpOrderModel({
    this.id,
    this.swpDate,
    this.status,
    this.amount,
    this.customerFailureReason,
  });

  SwpOrderModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    swpDate = WealthyCast.toDate(json['swpDate']);
    status = WealthyCast.toStr(json['status']);
    amount = WealthyCast.toDouble(json['amount']);
    customerFailureReason = WealthyCast.toStr(json['customerFailureReason']);
    status = WealthyCast.toStr(json['status']);
  }
}
