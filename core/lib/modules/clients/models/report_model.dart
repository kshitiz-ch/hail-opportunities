import 'package:core/modules/common/resources/wealthy_cast.dart';

class ReportModel {
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? reportId;
  String? name;
  String? displayName;
  DateTime? expiresAt;
  int? timeRemaining;
  String? requestorCode;
  String? shortLink;
  String? urlToken;
  String? accessToken;
  int? editorTimeRemaining;
  String? editorUrl;
  DateTime? reportGeneratedAt;

  String? status;
  // A_0 -- initiated
  // A_1 -- generated
  // A_2 -- expired but use expiry date to check
  // A_3 -- failure
  String? error;

  // Status getters
  bool get isInitiated => status == 'A_0';

  bool get isGenerated => status == 'A_1';

  bool get isExpired {
    if (status == 'A_2') return true;
    if (expiresAt != null) {
      return DateTime.now().isAfter(expiresAt!);
    }
    return false;
  }

  bool get isFailure => status == 'A_3';

  ReportModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    updatedAt = WealthyCast.toDate(json['updatedAt']);
    reportId = WealthyCast.toInt(json['reportId']);
    name = WealthyCast.toStr(json['name']);
    displayName = WealthyCast.toStr(json['displayName']);
    expiresAt = WealthyCast.toDate(json['expiresAt']);
    timeRemaining = WealthyCast.toInt(json['timeRemaining']);
    requestorCode = WealthyCast.toStr(json['requestorCode']);
    shortLink = WealthyCast.toStr(json['shortLink']);
    urlToken = WealthyCast.toStr(json['urlToken']);
    accessToken = WealthyCast.toStr(json['accessToken']);
    editorTimeRemaining = WealthyCast.toInt(json['editorTimeRemaining']);
    editorUrl = WealthyCast.toStr(json['editorUrl']);
    status = WealthyCast.toStr(json['status']);
    reportGeneratedAt = WealthyCast.toDate(json['reportGeneratedAt']);

    try {
      error = WealthyCast.toStr(json['error'])
          ?.replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '');
    } catch (e) {
      error = WealthyCast.toStr(json['error']);
    }
  }
}
