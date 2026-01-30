import 'package:core/modules/common/resources/wealthy_cast.dart';

class StoryModel {
  final int? id;
  final String? name;
  final String? createdOn;
  final String? image;
  final Action? action;
  final int? position;

  StoryModel({
    this.id,
    this.name,
    this.createdOn,
    this.image,
    this.action,
    this.position,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) => StoryModel(
        id: WealthyCast.toInt(json["id"]),
        name: WealthyCast.toStr(json["name"]),
        createdOn: WealthyCast.toStr(json["created_on"]),
        image: WealthyCast.toStr(json["image"]),
        action: json["action"] != null ? Action.fromJson(json["action"]) : null,
        position: WealthyCast.toInt(json["position"]) ?? 1,
      );
}

class Action {
  final String? url;
  final bool? isDeepLink;

  Action({this.url, this.isDeepLink});

  factory Action.fromJson(Map<String, dynamic> json) => Action(
        url: WealthyCast.toStr(json["url"]),
        isDeepLink: WealthyCast.toBool(json["isDeepLink"]),
      );
}
