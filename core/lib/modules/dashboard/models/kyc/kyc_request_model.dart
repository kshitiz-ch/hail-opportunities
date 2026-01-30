import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class KycRequestModel {
  String? id;
  String? externalId;
  AgentModel? agent;
  String? phoneNumber;
  String? name;
  String? tpRequestId;
  String? tpRequestValidTill;
  int? kycStatus;
  String? tpAccessToken;
  String? tpAccessTokenValidTill;

  KycRequestModel({
    this.id,
    this.externalId,
    this.agent,
    this.phoneNumber,
    this.name,
    this.tpRequestId,
    this.tpRequestValidTill,
    this.kycStatus,
    this.tpAccessToken,
    this.tpAccessTokenValidTill,
  });

  KycRequestModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    externalId = WealthyCast.toStr(json['externalId']);
    agent =
        json['agent'] != null ? new AgentModel.fromJson(json['agent']) : null;
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    name = WealthyCast.toStr(json['name']);
    tpRequestId = WealthyCast.toStr(json['tpRequestId']);
    tpRequestValidTill = WealthyCast.toStr(json['tpRequestValidTill']);
    kycStatus = WealthyCast.toInt(json['kycStatus']);
    tpAccessToken = WealthyCast.toStr(json['tpAccessToken']);
    tpAccessTokenValidTill = WealthyCast.toStr(json['tpAccessTokenValidTill']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['externalId'] = this.externalId;
    if (this.agent != null) {
      data['agent'] = this.agent!.toJson();
    }
    data['phoneNumber'] = this.phoneNumber;
    data['name'] = this.name;
    data['tpRequestId'] = this.tpRequestId;
    data['tpRequestValidTill'] = this.tpRequestValidTill;
    data['kycStatus'] = this.kycStatus;
    data['tpAccessToken'] = this.tpAccessToken;
    data['tpAccessTokenValidTill'] = this.tpAccessTokenValidTill;
    return data;
  }
}
