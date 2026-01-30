import 'package:core/modules/common/resources/wealthy_cast.dart';

class RewardModel {
  RewardModel({
    this.id,
    this.rewardId,
    this.name,
    this.product,
    this.code,
    this.description,
    this.rewardType,
    this.rewardValue,
    this.conditions,
    this.coolingPeriod,
    this.startsAt,
    this.endAt,
    this.iconUrl,
    this.imageUrl,
    this.isNew,
    this.displayName,
    this.earnedAt,
    this.redeemedAt,
  });

  int? id;
  int? rewardId;
  String? name;
  String? displayName;
  String? product;
  String? code;
  String? description;
  String? rewardType;
  String? rewardValue;
  String? coolingPeriod;
  String? conditions;
  String? startsAt;
  String? endAt;
  String? iconUrl;
  String? imageUrl;
  bool? isNew;

  String? earnedAt;
  String? redeemedAt;

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
        id: WealthyCast.toInt(json["id"]),
        rewardId: WealthyCast.toInt(json["reward_id"]),
        name: WealthyCast.toStr(json["name"]),
        displayName: WealthyCast.toStr(json["display_name"]),
        product: WealthyCast.toStr(json["product"]),
        code: WealthyCast.toStr(json["code"]),
        description: WealthyCast.toStr(json["description"]),
        rewardType: WealthyCast.toStr(json["reward_type"]),
        rewardValue: WealthyCast.toStr(json["reward_value"]),
        coolingPeriod: WealthyCast.toStr(json["cooling_period"]),
        startsAt: WealthyCast.toStr(json["starts_at"]),
        endAt: WealthyCast.toStr(json["end_at"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        imageUrl: WealthyCast.toStr(json["image_url"]),
        isNew: WealthyCast.toBool(json["is_new"]),
        conditions: WealthyCast.toStr(json["conditions"]),
        earnedAt: WealthyCast.toStr(json["earned_at"]),
        redeemedAt: WealthyCast.toStr(json["redeemed_at"]),
      );
}
