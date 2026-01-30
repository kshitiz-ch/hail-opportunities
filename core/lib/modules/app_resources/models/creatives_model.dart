import 'package:core/modules/common/resources/wealthy_cast.dart';

class CreativeTagModel {
  String? id;
  String? name;
  String? value;

  CreativeTagModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    name = WealthyCast.toStr(json["name"]);
    value = WealthyCast.toStr(json["value"]);
  }
}

class CreativeNewModel {
  String? id;
  String? url;
  String? objectId;
  String? sequence;
  String? name;
  String? title;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnailUrl;
  String? description;
  String? type;
  String? status;
  List<CreativeTagModel>? allTags;
  bool blur = false;

  bool get isImage => type?.toLowerCase() == 'img';
  bool get isPdf =>
      type?.toLowerCase() == 'pdf' ||
      url?.toLowerCase().endsWith('.pdf') == true;

  String get networkUrl {
    if (url?.startsWith('https://') == true) {
      return url!;
    }
    return 'https://${url}';
  }

  CreativeNewModel({
    this.url,
    this.name,
    this.title,
    this.createdAt,
    this.updatedAt,
    this.thumbnailUrl,
    this.blur = false,
    this.type,
    this.description,
  });

  CreativeNewModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    url = WealthyCast.toStr(json["url"]);
    objectId = WealthyCast.toStr(json["object_id"]);
    sequence = WealthyCast.toStr(json["sequence"]);
    name = WealthyCast.toStr(json["name"]);
    title = WealthyCast.toStr(json["title"]);
    createdAt = WealthyCast.toDate(json["created_at"]);
    updatedAt = WealthyCast.toDate(json["updated_at"]);
    thumbnailUrl = WealthyCast.toStr(json["thumbnail_url"]);
    description = WealthyCast.toStr(json["description"]);
    type = WealthyCast.toStr(json["type"]);
    status = WealthyCast.toStr(json["status"]);
    allTags = json["all_tags"] != null
        ? List<CreativeTagModel>.from(WealthyCast.toList(json['all_tags'])
            .map((x) => CreativeTagModel.fromJson(x)))
        : null;
  }
}
