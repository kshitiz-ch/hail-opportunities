import 'package:core/modules/common/resources/wealthy_cast.dart';

class NotificationsCountModel {
  NotificationsCountModel({
    this.count,
  });

  int? count;

  factory NotificationsCountModel.fromJson(Map<String, dynamic> json) =>
      NotificationsCountModel(
        count: WealthyCast.toInt(json["count"]),
      );

  Map<String, dynamic> toJson() => {
        "count": count == null ? null : count,
      };
}
