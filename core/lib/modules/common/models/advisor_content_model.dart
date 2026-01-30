import 'package:core/modules/common/resources/wealthy_cast.dart';

class AdvisorContentListModel {
  int? id;
  String? screen;
  String? type;
  String? context;
  List<AdvisorContentModel>? content;

  AdvisorContentListModel({
    this.id,
    this.screen,
    this.context,
    this.type,
    this.content,
  });

  factory AdvisorContentListModel.fromJson(Map<String, dynamic> json) =>
      AdvisorContentListModel(
        id: WealthyCast.toInt(json["id"]),
        screen: WealthyCast.toStr(json["screen"]),
        context: WealthyCast.toStr(json["context"]),
        type: WealthyCast.toStr(json["type"]),
        content: List<AdvisorContentModel>.from(
            WealthyCast.toList(json["content"]).map(
          (content) => AdvisorContentModel.fromJson(content),
        )),
      );
}

class AdvisorContentModel {
  String? name;
  String? image;
  String? actionUrl;
  bool? isDeepLink;
  double? aspectRatio;
  String? heading;
  String? subheading;
  String? displayName;
  String? description;
  String? link;

  AdvisorContentModel({
    this.name,
    this.image,
    this.actionUrl,
    this.isDeepLink,
    this.aspectRatio,
    this.heading,
    this.subheading,
    this.displayName,
    this.description,
    this.link,
  });

  factory AdvisorContentModel.fromJson(Map<String, dynamic> json) =>
      AdvisorContentModel(
        name: WealthyCast.toStr(json["name"]),
        image: WealthyCast.toStr(json["image"]),
        actionUrl: WealthyCast.toStr(json["action_url"]),
        isDeepLink: WealthyCast.toBool(json["is_deeplink"]),
        aspectRatio: WealthyCast.toDouble(json["asepct_ratio"]),
        heading: WealthyCast.toStr(json["heading"]),
        subheading: WealthyCast.toStr(json["subheading"]),
        displayName: WealthyCast.toStr(json["display_name"]),
        description: WealthyCast.toStr(json["description"]),
        link: WealthyCast.toStr(json["link"]),
      );
}
