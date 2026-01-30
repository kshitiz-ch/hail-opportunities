import 'package:core/modules/common/resources/wealthy_cast.dart';

class NotificationsIncomingModel {
  NotificationsIncomingModel({
    this.agentId,
    this.eventName,
    this.product,
    this.eventData,
  });

  var agentId;
  String? eventName;
  String? product;
  EventData? eventData;

  factory NotificationsIncomingModel.fromJson(Map<String, dynamic> json) =>
      NotificationsIncomingModel(
        agentId: json["agent_id"] == null ? null : json["agent_id"],
        eventName: WealthyCast.toStr(json["event_name"]),
        product: WealthyCast.toStr(json["product"]),
        eventData: json["event_data"] == null
            ? null
            : EventData.fromJson(json["event_data"]),
      );

  Map<String, dynamic> toJson() => {
        "agent_id": agentId == null ? null : agentId,
        "event_name": eventName == null ? null : eventName,
        "product": product == null ? null : product,
        "event_data": eventData == null ? null : eventData!.toJson(),
      };
}

class EventData {
  EventData({
    this.id,
    this.layout,
  });

  int? id;
  dynamic layout;

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
        id: WealthyCast.toInt(json["id"]),
        layout: json["layout"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "layout": layout,
      };
}
