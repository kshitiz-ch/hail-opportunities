import 'package:core/modules/common/resources/wealthy_cast.dart';

class RewardsBalanceModel {
  RewardsBalanceModel({this.userId, this.balance, this.product});

  String? userId;
  int? balance;
  String? product;

  factory RewardsBalanceModel.fromJson(Map<String, dynamic> json) =>
      RewardsBalanceModel(
        userId: WealthyCast.toStr(json["user_id"]),
        balance: WealthyCast.toInt(json["balance"]),
        product: WealthyCast.toStr(json["product"]),
      );
}
