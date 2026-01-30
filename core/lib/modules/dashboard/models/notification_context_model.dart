import 'package:core/modules/common/resources/wealthy_cast.dart';

class NotificationContextModel {
  String? actionUrl;
  String? webviewUrl;
  String? directUrl;
  String? email;
  String? name;
  String? deviceToken;
  int? pnTokenOsType;
  String? mobileAppVersion;
  int? userId;
  String? to;
  String? tab;
  String? productCategory;
  String? productType;
  String? status;
  String? proposalId;
  String? productVariant;
  String? videoUrl;
  String? storyId;
  String? playlistId;
  String? clientId;
  // might come from notification screen data in 'attrs' field
  String? amount;
  String? userName;
  String? eventId;
  bool? showDailyCreative;
  String? amc;
  String? id;
  String? category;
  String? language;
  String? creativeUrl;
  DateTime? dob;

  NotificationContextModel({
    this.actionUrl,
    this.webviewUrl,
    this.directUrl,
    this.email,
    this.name,
    this.deviceToken,
    this.pnTokenOsType,
    this.mobileAppVersion,
    this.userId,
    this.to,
    this.tab,
    this.productType,
    this.productCategory,
    this.status,
    this.proposalId,
    this.videoUrl,
    this.storyId,
    this.playlistId,
    this.productVariant,
    this.amount,
    this.userName,
    this.clientId,
    this.eventId,
    this.showDailyCreative,
    this.amc,
    this.id,
    this.category,
    this.creativeUrl,
    this.dob,
    this.language,
  });

  factory NotificationContextModel.fromJson(Map<String, dynamic> json) =>
      NotificationContextModel(
        actionUrl: WealthyCast.toStr(json["action_url"]) ?? "",
        webviewUrl: WealthyCast.toStr(json["webview_url"]) ?? "",
        directUrl: WealthyCast.toStr(json["direct_url"]) ?? "",
        email: WealthyCast.toStr(json["email"]) ?? "",
        name: WealthyCast.toStr(json["name"]) ?? "",
        deviceToken: WealthyCast.toStr(json["device_token"]) ?? "",
        pnTokenOsType: WealthyCast.toInt(json["pn_token_os_type"]),
        mobileAppVersion: WealthyCast.toStr(json["mobile_app_version"]) ?? "",
        userId: WealthyCast.toInt(json["user_id"]),
        proposalId: WealthyCast.toStr(json["proposal_id"]),
        status: (json["status_category"] == null ||
                json["status_category"].toString().trim().isEmpty)
            ? null
            : WealthyCast.toStr(json["status_category"])!.toLowerCase(),
        productCategory: (json["product_category"] == null ||
                json["product_category"].toString().trim().isEmpty)
            ? null
            : WealthyCast.toStr(json["product_category"]),
        productType: (json["product_type"] == null ||
                json["product_type"].toString().trim().isEmpty)
            ? null
            : WealthyCast.toStr(json["product_type"]),
        videoUrl: WealthyCast.toStr(json["video_url"]),
        storyId: WealthyCast.toStr(json["story_id"]),
        //TODO: wealthy_cast
        productVariant: WealthyCast.toStr(json["product_variant"]),
        playlistId: WealthyCast.toStr(json["playlist_id"]),
        clientId: WealthyCast.toStr(json["client_id"]),
        amount: WealthyCast.toStr(json["amount"]),
        userName: WealthyCast.toStr(json["user_name"]),
        eventId: WealthyCast.toStr(json["event_id"]),
        showDailyCreative: WealthyCast.toBool(json["show_daily_creative"]),
        amc: WealthyCast.toStr(json["amc"]),
        id: WealthyCast.toStr(json["id"]),
        category: WealthyCast.toStr(json["category"]),
        creativeUrl: WealthyCast.toStr(json["creative_url"]),
        dob: WealthyCast.toDate(json["dob"]),
        language: WealthyCast.toStr(json["language"]),
      );

  Map<String, dynamic> toJson() => {
        "action_url": actionUrl,
        "webview_url": webviewUrl,
        "direct_url": directUrl,
        "email": email,
        "name": name,
        "device_token": deviceToken,
        "pn_token_os_type": pnTokenOsType,
        "mobile_app_version": mobileAppVersion,
        "user_id": userId,
        "proposal_id": proposalId,
        "status_category": status,
        "product_category": productCategory,
        "product_type": productType,
        "video_url": videoUrl,
        "story_id": storyId,
        "product_variant": productVariant,
        "playlist_id": playlistId,
        "client_id": clientId,
        "amount": amount,
        "user_name": userName,
      };
}
