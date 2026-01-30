import 'package:core/config/util_constants.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class AgentReferralModel {
  String? referralUrl;
  int? totalClicks;
  int? totalUniqueClicks;
  int? totalSignups;
  double? totalTransacted;
  List<ReferredUsers>? referredUsers;

  AgentReferralModel.fromJson(Map<String, dynamic> json) {
    referralUrl = transformReferralUrl(WealthyCast.toStr(json['referralUrl']));
    totalClicks = WealthyCast.toInt(json['totalClicks']);
    totalUniqueClicks = WealthyCast.toInt(json['totalUniqueClicks']);
    totalSignups = WealthyCast.toInt(json['totalSignups']);
    totalTransacted = WealthyCast.toDouble(json['totalTransacted']);
    if (json['referredUsers'] != null) {
      referredUsers = <ReferredUsers>[];
      json['referredUsers'].forEach((v) {
        referredUsers!.add(ReferredUsers.fromJson(v));
      });
    }
  }
}

class ReferredUsers {
  String? stage;
  String? userId;
  String? userEmail;
  String? userPhone;
  String? userName;

  ReferredUsers.fromJson(Map<String, dynamic> json) {
    stage = WealthyCast.toStr(json['stage']);
    userId = WealthyCast.toStr(json['userId']);
    userEmail = WealthyCast.toStr(json['userEmail']);
    userPhone = WealthyCast.toStr(json['userPhone']);
    userName = WealthyCast.toStr(json['userName']);
  }
}
