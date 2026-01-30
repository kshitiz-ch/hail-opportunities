import 'package:core/modules/common/resources/wealthy_cast.dart';

class AgentReportModel {
  String? id;
  DateTime? createdAt;
  String? name;
  int? status;
  String? urlToken;
  DateTime? expiresAt;
  String? requestorCode;
  String? shortLink;
  DateTime? reportGeneratedAt;
  String? reportUrl;

  AgentReportModel({
    this.createdAt,
    this.name,
    this.status,
    this.urlToken,
    this.expiresAt,
    this.requestorCode,
    this.shortLink,
    this.reportGeneratedAt,
    this.reportUrl,
    this.id,
  });

  AgentReportModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    name = WealthyCast.toStr(json['name']);
    status = WealthyCast.toInt(json['status']);
    urlToken = WealthyCast.toStr(json['urlToken']);
    expiresAt = WealthyCast.toDate(json['expiresAt']);
    requestorCode = WealthyCast.toStr(json['requestorCode']);
    shortLink = WealthyCast.toStr(json['shortLink']);
    reportGeneratedAt = WealthyCast.toDate(json['reportGeneratedAt']);
    reportUrl = WealthyCast.toStr(json['reportUrl']);
  }
}
