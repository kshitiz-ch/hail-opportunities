import 'package:core/modules/common/resources/wealthy_cast.dart';

class TrackerSyncModel {
  WsyncProgress? wsyncProgress;
  List<WsyncEmailAccount>? wsyncEmailAccounts;
  TrackerSyncModel({this.wsyncProgress, this.wsyncEmailAccounts});

  TrackerSyncModel.fromJson(Map<String, dynamic> json) {
    wsyncProgress = WsyncProgress.fromJson(json["wsyncProgress"]);
    wsyncEmailAccounts = [];
    if (json["wsyncEmailAccounts"] != null &&
        json["wsyncEmailAccounts"].length > 0) {
      json["wsyncEmailAccounts"].forEach((item) {
        wsyncEmailAccounts!.add(WsyncEmailAccount.fromJson(item));
      });
    }
  }
}

class WsyncProgress {
  String? id;
  List<SyncProgress>? syncProgress;

  WsyncProgress({this.id, this.syncProgress});

  WsyncProgress.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    syncProgress = WealthyCast.toList(json["syncProgress"])
        .map((e) => SyncProgress.fromJson(e))
        .toList();
  }
}

class SyncProgress {
  String? id;
  String? email;
  DateTime? syncDate;
  DateTime? lastSyncedAt;

  SyncProgress({this.id, this.email, this.syncDate, this.lastSyncedAt});

  factory SyncProgress.fromJson(Map<String, dynamic> json) => SyncProgress(
        id: WealthyCast.toStr(json["id"]),
        email: WealthyCast.toStr(json["email"]),
        syncDate: WealthyCast.toDate(json["syncDate"]),
        lastSyncedAt: WealthyCast.toDate(json["lastSyncedAt"]),
      );
}

class WsyncEmailAccount {
  String? id;
  String? email;
  WsyncEmailAccount({this.id, this.email});

  factory WsyncEmailAccount.fromJson(Map<String, dynamic> json) =>
      WsyncEmailAccount(
          id: WealthyCast.toStr(json["id"]),
          email: WealthyCast.toStr(json["email"]));
}
