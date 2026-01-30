import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/notification_context_model.dart';
import 'package:core/modules/notifications/models/notification_ui_model.dart';

class NotificationsModel {
  NotificationsModel({
    this.data,
  });

  List<NotificationModel>? data;

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        data: List<NotificationModel>.from(
          WealthyCast.toList(json["data"])
              .map((x) => NotificationModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class NotificationModel {
  NotificationModel({
    this.id,
    this.userId,
    this.product,
    this.priority,
    this.ntype,
    this.summaryHtml,
    this.attrs,
    this.createdAt,
    this.dismissUrl,
    this.markSeenUrl,
    this.descriptionHtmlUrl,
    this.actionUrl,
    this.client,
  });

  int? id;
  String? userId;
  String? product;
  int? priority;
  String? ntype;
  String? summaryHtml;
  NotificationContextModel? attrs;
  Client? client;
  DateTime? createdAt;
  String? dismissUrl;
  String? markSeenUrl;
  String? descriptionHtmlUrl;
  String? actionUrl;
  // update from summaryHtml parsing
  NotificationUIModel? notificationUIModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: WealthyCast.toInt(json["id"]),
        userId: WealthyCast.toStr(json["user_id"]),
        product: WealthyCast.toStr(json["product"]),
        priority: WealthyCast.toInt(json["priority"]),
        ntype: WealthyCast.toStr(json["ntype"]),
        summaryHtml: WealthyCast.toStr(json["summary_html"]),
        actionUrl: WealthyCast.toStr(json["action_url"]),
        attrs: json["attrs"] == null
            ? null
            : NotificationContextModel.fromJson(json["attrs"]),
        // TODO: update logic
        // temporary fix for notification screen
        // as external id not coming in attributes of notification api
        // so creating client object from data getting in attribute key value pair
        client: json["attrs"] == null ? null : Client.fromJson(json["attrs"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        dismissUrl: WealthyCast.toStr(json["dismiss_url"]),
        markSeenUrl: WealthyCast.toStr(json["mark_seen_url"]),
        descriptionHtmlUrl: WealthyCast.toStr(json["description_html_url"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "user_id": userId == null ? null : userId,
        "product": product == null ? null : product,
        "priority": priority == null ? null : priority,
        "ntype": ntype == null ? null : ntype,
        "summary_html": summaryHtml == null ? null : summaryHtml,
        "attrs": attrs == null ? null : attrs!.toJson(),
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "dismiss_url": dismissUrl == null ? null : dismissUrl,
        "mark_seen_url": markSeenUrl == null ? null : markSeenUrl,
        "description_html_url":
            descriptionHtmlUrl == null ? null : descriptionHtmlUrl,
        "action_url": actionUrl == null ? null : actionUrl,
      };
}

class DataNotificationModel {
  int? tenantId;
  String? userToken;
  String? summary;
  String? screenLocation;
  String? ntype;
  Map<String, dynamic>? attrs;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? dnRenderType;
  bool? groupDn;
  bool? isGroupPublished;
  int? priority;
  bool? isRead;
  String? descriptionHtmlId;

  bool? isDismissible;
  DateTime? expiryTime;
  NotificationUIModel? notificationUIModel;

  DataNotificationModel({
    this.tenantId,
    this.userToken,
    this.summary,
    this.screenLocation,
    this.ntype,
    this.attrs,
    this.createdAt,
    this.updatedAt,
    this.dnRenderType,
    this.groupDn,
    this.isGroupPublished,
    this.priority,
    this.isDismissible,
    this.expiryTime,
    this.isRead,
    this.descriptionHtmlId,
    this.notificationUIModel,
  });

  DataNotificationModel.fromJson(Map<String, dynamic> json) {
    tenantId = WealthyCast.toInt(json['tenant_id']);
    userToken = WealthyCast.toStr(json['user_token']);
    summary = WealthyCast.toStr(json['summary']);
    screenLocation = WealthyCast.toStr(json['screen_location']);
    ntype = WealthyCast.toStr(json['ntype']);
    isRead = WealthyCast.toBool(json["is_read"]);
    attrs = json["attrs"] ?? {};
    createdAt = WealthyCast.toDate(json['created_at']);
    descriptionHtmlId = WealthyCast.toStr(json['description_html_id']);
    updatedAt = WealthyCast.toDate(json['updated_at']);
    dnRenderType = WealthyCast.toStr(json['dn_render_type']);
    groupDn = WealthyCast.toBool(json['group_dn']);
    isGroupPublished = WealthyCast.toBool(json['is_group_published']);
    priority = WealthyCast.toInt(json['priority']);
    isDismissible = WealthyCast.toBool(json['is_dismissible']);
    expiryTime = WealthyCast.toDate(json['expiry_time']);
  }
}
