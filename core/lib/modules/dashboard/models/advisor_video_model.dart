import 'package:core/modules/common/resources/wealthy_cast.dart';

class VideoPlayListModel {
  String? id;
  String? title;
  String? subtitle;
  String? thumbnail;
  String? url;
  String? playlistId;
  int? duration;
  List<AdvisorVideoModel>? videos;

  VideoPlayListModel({
    this.id,
    this.title,
    this.subtitle,
    this.thumbnail,
    this.url,
    this.videos,
    this.playlistId,
    this.duration,
  });

  factory VideoPlayListModel.fromJson(Map<String, dynamic> json) =>
      VideoPlayListModel(
        id: WealthyCast.toStr(json["id"]) ?? "",
        duration: WealthyCast.toInt(json["duration"]),
        title: WealthyCast.toStr(json["title"]) ?? "",
        subtitle: WealthyCast.toStr(json["subtitle"]) ?? "",
        playlistId: WealthyCast.toStr(json["playlist_id"]),
        thumbnail: WealthyCast.toStr(json["thumbnail"]),
        url: WealthyCast.toStr(json["url"]) ?? "",
        videos: List<AdvisorVideoModel>.from(
          WealthyCast.toList(json["videos"])
              .map((x) => AdvisorVideoModel.fromJson(x)),
        ),
      );
}

class AdvisorVideoModel {
  String? title;
  String? description;
  String? link;
  String? id;
  String? thumbnail;

  AdvisorVideoModel(
      {this.title, this.description, this.link, this.id, this.thumbnail});

  factory AdvisorVideoModel.fromJson(Map<String, dynamic> json) =>
      AdvisorVideoModel(
        title: WealthyCast.toStr(json["title"]) ?? '',
        description: WealthyCast.toStr(json["description"]),
        link: WealthyCast.toStr(json["link"]) ?? '',
        id: WealthyCast.toStr(json["id"]),
        thumbnail: WealthyCast.toStr(json["thumbnail"]),
      );
}
