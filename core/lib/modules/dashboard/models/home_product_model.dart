import 'package:core/modules/common/resources/wealthy_cast.dart';

class HomeProductModel {
  HomeProductModel({
    this.id,
    this.icon,
    this.title,
    this.badgeText,
    this.badgeColor,
    this.description,
    this.subtitle,
    this.amount,
    this.route,
  });

  String? id;
  String? icon;
  String? badgeText;
  String? badgeColor;
  String? title;
  String? description;
  String? subtitle;
  String? amount;
  String? route;

  factory HomeProductModel.fromJson(Map<String, dynamic> json) =>
      HomeProductModel(
        id: WealthyCast.toStr(json["id"]),
        icon: WealthyCast.toStr(json["icon"]),
        badgeText: WealthyCast.toStr(json["badge_text"]),
        badgeColor: WealthyCast.toStr(json["badge_color"]),
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]),
        subtitle: WealthyCast.toStr(json["subtitle"]),
        amount: WealthyCast.toStr(json["amount"]),
        route: WealthyCast.toStr(json["route"]),
      );
}
