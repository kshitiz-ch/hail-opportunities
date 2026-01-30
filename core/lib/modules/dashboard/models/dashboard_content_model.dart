import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';

class DashboardContentModel {
  String? fdRateUrl;
  List<BannerModel>? homeBanners;
  List<BannerModel>? homeBannersTablet;
  VideoPlayListModel? learnVideos;

  DashboardContentModel({
    this.fdRateUrl,
    this.homeBannersTablet,
    this.homeBanners,
  });

  factory DashboardContentModel.fromJson(Map<String, dynamic> json) =>
      DashboardContentModel(
        fdRateUrl: WealthyCast.toStr(json["fd_rate_url"]) ?? '',
        homeBanners: List<BannerModel>.from(
          WealthyCast.toList(json["home_banners"]).map(
            (content) => BannerModel.fromJson(content),
          ),
        ),
        homeBannersTablet: List<BannerModel>.from(
          WealthyCast.toList(json["home_banners_tablet"]).map(
            (content) => BannerModel.fromJson(content),
          ),
        ),
      );
}

class BannerModel {
  String? image;
  String? actionUrl;
  bool? isDeepLink;
  String? name;
  int? position;
  bool? isCarousel;

  BannerModel({
    this.image,
    this.actionUrl,
    this.isDeepLink,
    this.name,
    this.position,
    this.isCarousel,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        image: WealthyCast.toStr(json["image"]),
        actionUrl: WealthyCast.toStr(json["action_url"]),
        isDeepLink: WealthyCast.toBool(json["is_deeplink"]),
        name: WealthyCast.toStr(json["name"]),
        position: WealthyCast.toInt(json["position"]) ?? 1,
        isCarousel: WealthyCast.toBool(json["is_carousel"]),
      );
}
