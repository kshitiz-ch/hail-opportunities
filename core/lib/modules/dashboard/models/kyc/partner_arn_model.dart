import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerArnModel {
  String? id;
  String? externalId;
  String? arn;
  String? euin;
  String? arnStatus;
  String? status;
  List<String?>? additionalEuins;
  String? nameAsPerArn;
  String? addressAsPerArn;
  String? phoneNumberAsPerArn;
  DateTime? arnValidFrom;
  DateTime? arnValidTill;
  DateTime? partnerApprovedAt;
  bool? isArnActive;
  String? mode;

  PartnerArnModel(
      {this.id,
      this.externalId,
      this.arn,
      this.euin,
      this.arnStatus,
      this.status,
      this.additionalEuins,
      this.nameAsPerArn,
      this.addressAsPerArn,
      this.phoneNumberAsPerArn,
      this.arnValidFrom,
      this.arnValidTill,
      this.partnerApprovedAt,
      this.isArnActive,
      this.mode});

  PartnerArnModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']) ?? "";
    externalId = WealthyCast.toStr(json['externalId']) ?? "";
    arn = WealthyCast.toStr(json['arn']) ?? "";
    euin = WealthyCast.toStr(json['euin']) ?? "";
    arnStatus = WealthyCast.toStr(json['arnStatus']) ?? "";
    status = WealthyCast.toStr(json['status']);
    // TODO: wealthy_cast to list
    additionalEuins = [];
    if (json['additionalEuins'] != null) {
      json['additionalEuins'].forEach((v) {
        additionalEuins!.add(WealthyCast.toStr(v));
      });
    }
    nameAsPerArn = WealthyCast.toStr(json['nameAsPerArn']) ?? "";
    addressAsPerArn = WealthyCast.toStr(json['addressAsPerArn']) ?? "";
    phoneNumberAsPerArn = WealthyCast.toStr(json['phoneNumberAsPerArn']) ?? "";
    arnValidFrom = WealthyCast.toDate(json['arnValidFrom']);
    arnValidTill = WealthyCast.toDate(json['arnValidTill']);
    partnerApprovedAt = WealthyCast.toDate(json['partnerApprovedAt']);
    isArnActive = WealthyCast.toBool(json['isArnActive']);
    mode = WealthyCast.toStr(json['mode']) ?? "";
  }
}
