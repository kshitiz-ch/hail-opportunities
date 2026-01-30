import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientMandateModel {
  int? amount;
  String? failureReason;
  bool? isConfirmed;
  DateTime? mandateConfirmedAt;
  DateTime? mandateExpiredAt;
  String? paymentBankIfscCode;
  String? paymentBankName;
  int? paymentBankAccountNumber;
  String? paymentBankId;
  int? bankVerifiedStatus;
  int? stage;
  String? status;

  String? method;
  String? authType;
  String? currentStatus;

  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'Active';
      case 'order_success':
        return 'Bank Approval Pending';
      case 'rejected':
        return 'Rejected';
      case 'deleted':
        return 'Deleted';
      case 'cancelled':
        return 'Cancelled';
      default:
        return '';
    }
  }

  String get maskedPaymentBankAccountNumber {
    if (paymentBankAccountNumber == null) return '';

    final accountNumberStr = paymentBankAccountNumber.toString();

    if (accountNumberStr.length <= 4) {
      return accountNumberStr;
    }

    final maskedPart = 'X' * (accountNumberStr.length - 4);
    final lastFourDigits =
        accountNumberStr.substring(accountNumberStr.length - 4);

    return '$maskedPart$lastFourDigits';
  }

  ClientMandateModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toInt(json['amount']);
    failureReason = WealthyCast.toStr(json['failureReason']);
    isConfirmed = WealthyCast.toBool(json['isConfirmed']);
    mandateConfirmedAt = WealthyCast.toDate(json['mandateConfirmedAt']);
    mandateExpiredAt = WealthyCast.toDate(json['mandateExpiredAt']);
    paymentBankIfscCode = WealthyCast.toStr(json['paymentBankIfscCode']);
    paymentBankName = WealthyCast.toStr(json['paymentBankName']);
    paymentBankAccountNumber =
        WealthyCast.toInt(json['paymentBankAccountNumber']);
    paymentBankId = WealthyCast.toStr(json['paymentBankId']);
    bankVerifiedStatus = WealthyCast.toInt(json['bankVerifiedStatus']);
    stage = WealthyCast.toInt(json['stage']);
    status = WealthyCast.toStr(json['status']);
    method = WealthyCast.toStr(json['method']);
    authType = WealthyCast.toStr(json['authType']);
    if (method?.toLowerCase() == 'upi') {
      method = method?.toUpperCase();
    }
    if (method?.toLowerCase() == 'emandate') {
      method = 'Emandate';
    }
    currentStatus = WealthyCast.toStr(json['currentStatus']);
  }

  ClientMandateModel.copy(ClientMandateModel other) {
    amount = other.amount;
    failureReason = other.failureReason;
    isConfirmed = other.isConfirmed;
    mandateConfirmedAt = other.mandateConfirmedAt;
    mandateExpiredAt = other.mandateExpiredAt;
    paymentBankIfscCode = other.paymentBankIfscCode;
    paymentBankName = other.paymentBankName;
    paymentBankAccountNumber = other.paymentBankAccountNumber;
    paymentBankId = other.paymentBankId;
    bankVerifiedStatus = other.bankVerifiedStatus;
    stage = other.stage;
    status = other.status;
    method = other.method;
    authType = other.authType;
    currentStatus = other.currentStatus;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClientMandateModel &&
        other.amount == amount &&
        other.failureReason == failureReason &&
        other.isConfirmed == isConfirmed &&
        other.mandateConfirmedAt == mandateConfirmedAt &&
        other.mandateExpiredAt == mandateExpiredAt &&
        other.paymentBankIfscCode == paymentBankIfscCode &&
        other.paymentBankName == paymentBankName &&
        other.paymentBankAccountNumber == paymentBankAccountNumber &&
        other.paymentBankId == paymentBankId &&
        other.bankVerifiedStatus == bankVerifiedStatus &&
        other.stage == stage &&
        other.status == status &&
        other.method == method &&
        other.authType == authType &&
        other.currentStatus == currentStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
        amount,
        failureReason,
        isConfirmed,
        mandateConfirmedAt,
        mandateExpiredAt,
        paymentBankIfscCode,
        paymentBankName,
        paymentBankAccountNumber,
        paymentBankId,
        bankVerifiedStatus,
        stage,
        status,
        method,
        authType,
        currentStatus);
  }
}

class UserMandateMeta {
  double? amount;
  DateTime? mandateConfirmedAt;
  String? statusText;

  UserMandateMeta({this.amount, this.mandateConfirmedAt, this.statusText});

  UserMandateMeta.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toDouble(json['amount']);
    mandateConfirmedAt = WealthyCast.toDate(json['mandateConfirmedAt']);
    statusText = WealthyCast.toStr(json['statusText']);
  }
}
