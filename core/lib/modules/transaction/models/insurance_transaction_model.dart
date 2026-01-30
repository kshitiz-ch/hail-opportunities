import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/transaction/models/mf_order_transaction_model.dart';

class InsuranceTransactionModel {
  String? userId;
  List<UserDetails>? userDetails;
  String? name;
  String? insuranceType;
  String? insurer;
  String? sourcingChannel;
  int? premiumWithGst;
  int? premiumWithoutGst;
  String? premiumFrequency;
  String? policyNumber;
  String? status;
  DateTime? paymentCompletedAt;
  DateTime? policyIssueDate;
  DateTime? lastRenewalPaidAt;
  DateTime? renewalDate;
  String? agentName;
  String? agentExternalId;
  String? policyDocumentPath;
  String? orderId;
  List<OrderStageAudit>? orderStageAudit;

  bool get enablePolicyActions => policyDocumentPath.isNotNullOrEmpty;

  InsuranceTransactionModel.fromJson(Map<String, dynamic> json) {
    userId = WealthyCast.toStr(json['userId']);
    if (json['userDetails'] != null) {
      userDetails = <UserDetails>[];
      json['userDetails'].forEach((v) {
        userDetails!.add(UserDetails.fromJson(v));
      });
    }
    name = WealthyCast.toStr(json['name']);
    insuranceType = WealthyCast.toStr(json['insuranceType']);
    insurer = WealthyCast.toStr(json['insurer']);
    sourcingChannel = WealthyCast.toStr(json['sourcingChannel']);
    premiumWithGst = WealthyCast.toInt(json['premiumWithGst']);
    premiumWithoutGst = WealthyCast.toInt(json['premiumWithoutGst']);
    premiumFrequency = WealthyCast.toStr(json['premiumFrequency']);
    policyNumber = WealthyCast.toStr(json['policyNumber']);
    status = WealthyCast.toStr(json['status']);
    paymentCompletedAt = WealthyCast.toDate(json['paymentCompletedAt']);
    policyIssueDate = WealthyCast.toDate(json['policyIssueDate']);
    lastRenewalPaidAt = WealthyCast.toDate(json['lastRenewalPaidAt']);
    renewalDate = WealthyCast.toDate(json['renewalDate']);
    agentName = WealthyCast.toStr(json['agentName']);
    agentExternalId = WealthyCast.toStr(json['agentExternalId']);
    policyDocumentPath = WealthyCast.toStr(json['policyDocumentPath']);
    orderId = WealthyCast.toStr(json['orderId']);
    if (json['orderStageAudit'] != null) {
      orderStageAudit = <OrderStageAudit>[];
      json['orderStageAudit'].forEach((v) {
        orderStageAudit!.add(OrderStageAudit.fromJson(v));
      });
    }
  }
}

class UserDetails {
  String? name;
  String? phone;
  String? email;

  UserDetails({this.name, this.phone, this.email});

  UserDetails.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    phone = WealthyCast.toStr(json['phone']);
    email = WealthyCast.toStr(json['email']);
  }
}
