import 'package:core/modules/common/resources/wealthy_cast.dart';

class BrokingOnboardingModel {
  String? agentId;
  String? agentName;
  String? email;
  String? frontendStatus;
  bool? isTradingEnabled;
  bool? isFnoEnabled;
  int? kycStatus;
  String? name;
  String? phoneNumber;
  String? ucc;
  DateTime? updatedAt;
  DateTime? createdAt;
  String? userId;

  bool get showKycButton {
    const SendKycUrlStatusList = [
      BrokingKycStatusLabel.Initiated,
      BrokingKycStatusLabel.InProgress,
      BrokingKycStatusLabel.SubmittedByCustomer,
      BrokingKycStatusLabel.UploadedToKRA,
      BrokingKycStatusLabel.Approved,
      BrokingKycStatusLabel.EsignPending,
      BrokingKycStatusLabel.ApprovedByAdmin,
      BrokingKycStatusLabel.ValidatedByKRA
    ];
    return SendKycUrlStatusList.contains(this.kycStatus) &&
        !(this.isTradingEnabled ?? false);
  }

  bool get showFnOButton {
    return !(this.isFnoEnabled ?? false);
  }

  BrokingOnboardingModel({
    this.agentId,
    this.agentName,
    this.email,
    this.frontendStatus,
    this.isTradingEnabled,
    this.isFnoEnabled,
    this.kycStatus,
    this.name,
    this.phoneNumber,
    this.ucc,
    this.updatedAt,
    this.userId,
    this.createdAt,
  });

  BrokingOnboardingModel.fromJson(Map<String, dynamic> json) {
    agentId = WealthyCast.toStr(json['agentId']);
    agentName = WealthyCast.toStr(json['agentName']);
    email = WealthyCast.toStr(json['email']);
    frontendStatus = WealthyCast.toStr(json['frontendStatus']);
    isTradingEnabled = WealthyCast.toBool(json['isTradingEnabled']);
    isFnoEnabled = WealthyCast.toBool(json['isFnoEnabled']);
    kycStatus = WealthyCast.toInt(json['kycStatus']);
    name = WealthyCast.toStr(json['name']);
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    ucc = WealthyCast.toStr(json['ucc']);
    updatedAt = WealthyCast.toDate(json['updatedAt']);
    userId = WealthyCast.toStr(json['userId']);
    createdAt = WealthyCast.toDate(json['createdAt']);
  }
}

class BrokingKycStatusLabel {
  static const NotResponding = -1;
  static const Missing = 0;
  static const Initiated = 1;
  static const InProgress = 2;
  static const SubmittedByCustomer = 3;
  static const FollowUpWithCustomer = 4;
  static const UploadedToKRA = 5;
  static const Approved = 6;
  static const RejectedByKRA = 7;
  static const EsignPending = 8;
  static const ApprovedByAdmin = 9;
  static const RejectedByAdmin = 10;
  static const ValidatedByKRA = 11;
  static const RejectedBySystem = 12;
}
