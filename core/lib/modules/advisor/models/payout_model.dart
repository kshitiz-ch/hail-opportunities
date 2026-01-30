import 'dart:convert' as convert;

import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class PayoutModel {
  String? payoutId;
  double? totalPayout;

  DateTime? payoutDate;
  DateTime? payoutReadyDate;
  DateTime? payoutInitiatedAt;
  DateTime? payoutCompletedAt;
  DateTime? payoutPausedAt;
  DateTime? payoutReleasedAt;

  double? tds;
  double? effectiveGst;
  double? basePayout;
  String? status;
  double? finalPayout;
  List<PayoutRedemptionDetails>? payoutRedemptionDetails;
  DateTime? revenueDate;
  List<PayoutModel>? employeesPayouts;
  String? agentName;
  String? agentEmail;

  bool isBrokingPayout = false;

  String get statusDescription {
    switch (status?.toUpperCase()) {
      case PayoutStatus.Created:
        return 'Created';
      case PayoutStatus.PayoutGenerated:
        return 'Payout Generated';
      case PayoutStatus.PayoutReady:
        return 'Payout Ready';
      case PayoutStatus.PaymentInProgress:
        return 'Payment In Progress';
      case PayoutStatus.PayoutSuccessful:
        return 'Payout Successful';
      default:
        return 'Not Available';
    }
  }

  PayoutModel.fromJson(
    Map<String, dynamic> json, {
    bool isBrokingPayout = false,
  }) {
    payoutId = WealthyCast.toStr(json['payoutId']);
    agentEmail = WealthyCast.toStr(json['agentEmail']);
    agentName = WealthyCast.toStr(json['agentName']);
    totalPayout = WealthyCast.toDouble(json['totalPayout']);
    payoutDate = WealthyCast.toDate(json['payoutDate']);
    payoutReadyDate = WealthyCast.toDate(json['payoutReadyAt']);
    revenueDate = WealthyCast.toDate(json['revenueDate']);
    tds = WealthyCast.toDouble(json['tds']);
    status = WealthyCast.toStr(json['status']);
    finalPayout = WealthyCast.toDouble(json['finalPayout']);
    basePayout = WealthyCast.toDouble(json['basePayout']);
    effectiveGst = WealthyCast.toDouble(json['effectiveGst']);
    if (effectiveGst.isNullOrZero) {
      effectiveGst = WealthyCast.toDouble(json['gst']);
    }
    if (basePayout.isNullOrZero) {
      // finalPayout = basePayout + gst - tds
      basePayout = (finalPayout ?? 0) - (effectiveGst ?? 0) + (tds ?? 0);
    }

    // for general payout
    if (json['payoutRedemptionDetails'] != null) {
      payoutRedemptionDetails = <PayoutRedemptionDetails>[];
      json['payoutRedemptionDetails'].forEach((v) {
        payoutRedemptionDetails!.add(PayoutRedemptionDetails.fromJson(v));
      });
    }

    // for broking payout
    if (json['bankDetails'] != null) {
      final bankDetails = convert.json.decode(json['bankDetails']);
      final redemptionDetails = PayoutRedemptionDetails();
      redemptionDetails.paidBankAccountNo =
          WealthyCast.toStr(bankDetails['number']);
      redemptionDetails.paidBankIfscNo = WealthyCast.toStr(bankDetails['ifsc']);
      payoutRedemptionDetails = [redemptionDetails];
    }

    if (json['payoutInitiatedAt'] != null) {
      payoutInitiatedAt = WealthyCast.toDate(json['payoutInitiatedAt']);
    }

    if (json['payoutCompletedAt'] != null) {
      payoutCompletedAt = WealthyCast.toDate(json['payoutCompletedAt']);
    }

    if (json['payoutPausedAt'] != null) {
      payoutPausedAt = WealthyCast.toDate(json['payoutPausedAt']);
    }

    if (json['payoutReleasedAt'] != null) {
      payoutReleasedAt = WealthyCast.toDate(json['payoutReleasedAt']);
    }

    final employeePayoutsJson = WealthyCast.toList(json['employeesPayouts']);
    if (employeePayoutsJson.isNotNullOrEmpty) {
      employeesPayouts = employeePayoutsJson
          .map((employeeJson) => PayoutModel.fromJson(employeeJson))
          .toList();
    }

    this.isBrokingPayout = isBrokingPayout;
  }
}

class PayoutRedemptionDetails {
  String? payoutResponseDetails;
  String? description;
  String? paidBankAccountNo;
  String? paidBankIfscNo;
  String? status;
  double? amount;
  String? utr;

  PayoutRedemptionDetails({
    this.payoutResponseDetails,
    this.description,
    this.paidBankAccountNo,
    this.paidBankIfscNo,
    this.status,
    this.amount,
    this.utr,
  });

  PayoutRedemptionDetails.fromJson(Map<String, dynamic> json) {
    payoutResponseDetails = json['payoutResponseDetails'];
    description = WealthyCast.toStr(json['description']);
    status = WealthyCast.toStr(json['status']);
    amount = WealthyCast.toDouble(json['amount']);
    if (json['paidBankDetails'] != null) {
      paidBankAccountNo =
          WealthyCast.toStr(json['paidBankDetails']['bank_account_no']);
      paidBankIfscNo =
          WealthyCast.toStr(json['paidBankDetails']['bank_ifsc_code']);
    }
    try {
      Map payoutDetail = convert.json.decode(payoutResponseDetails ?? '');
      if (payoutDetail.isNotEmpty && payoutDetail.containsKey('utr')) {
        utr = payoutDetail['utr'];
      } else {
        utr = '-';
      }
    } catch (e) {
      utr = '-';
    }
  }
}

class PayoutBreakup {
  String? productType;
  double? baseRevenue;

  PayoutBreakup({
    this.productType,
    this.baseRevenue,
  });

  PayoutBreakup.fromJson(Map<String, dynamic> json) {
    productType =
        WealthyCast.toStr(json['productType'] ?? json['categoryType']);
    baseRevenue = WealthyCast.toDouble(json['baseRevenue']);
  }
}

class PayoutStatus {
  static const Created = 'C';
  static const PayoutGenerated = 'PI';
  static const PayoutReady = 'PR';
  static const PaymentInProgress = 'PP';
  static const PayoutSuccessful = 'PS';
}
