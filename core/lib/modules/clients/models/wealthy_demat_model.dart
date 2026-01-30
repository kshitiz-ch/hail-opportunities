import 'package:core/modules/common/resources/wealthy_cast.dart';

class WealthyDematModel {
  String? ucc;
  String? panUsageType;
  String? panUsageSubtype;
  int? kycStatus;
  String? kycId;
  String? segments;
  String? dematId;
  String? frontendStatus;
  DateTime? poaEnabledAt;

  WealthyDematModel({
    this.ucc,
    this.panUsageType,
    this.panUsageSubtype,
    this.kycStatus,
    this.kycId,
    this.segments,
    this.dematId,
    this.frontendStatus,
    this.poaEnabledAt,
  });

  WealthyDematModel.fromJson(Map<String, dynamic> json) {
    ucc = WealthyCast.toStr(json['ucc']);
    panUsageType = WealthyCast.toStr(json['panUsageType']);
    panUsageSubtype = WealthyCast.toStr(json['panUsageSubtype']);
    kycStatus = WealthyCast.toInt(json['kycStatus']);
    kycId = WealthyCast.toStr(json['kycId']);
    segments = WealthyCast.toStr(json['segments']);
    dematId = WealthyCast.toStr(json['dematId']);
    frontendStatus = WealthyCast.toStr(json['frontendStatus']);
    poaEnabledAt = WealthyCast.toDate(json['poaEnabledAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ucc'] = this.ucc;
    data['panUsageType'] = this.panUsageType;
    data['panUsageSubtype'] = this.panUsageSubtype;
    data['kycStatus'] = this.kycStatus;
    data['kycId'] = this.kycId;
    data['segments'] = this.segments;
    data['dematId'] = this.dematId;
    data['frontendStatus'] = this.frontendStatus;
    data['poaEnabledAt'] = this.poaEnabledAt?.toIso8601String();
    return data;
  }
}
