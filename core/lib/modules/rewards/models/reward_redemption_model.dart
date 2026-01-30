import 'package:core/modules/common/resources/wealthy_cast.dart';

class RewardRedemptionModel {
  RewardRedemptionModel(
      {this.id,
      this.orderId,
      this.name,
      this.email,
      this.phoneNumber,
      this.payoutCompletedAt,
      this.amount,
      this.redeemStatus,
      this.expiresAt,
      this.thirdPartyPaymentId,
      this.thirdPartyPaymentLink,
      this.redeemedAt});
  int? id;
  String? orderId;
  String? name;
  String? email;
  String? phoneNumber;
  String? payoutCompletedAt;
  int? amount;
  String? redeemStatus;
  String? expiresAt;
  String? thirdPartyPaymentId;
  String? thirdPartyPaymentLink;
  String? redeemedAt;

  factory RewardRedemptionModel.fromJson(Map<String, dynamic> json) =>
      RewardRedemptionModel(
        id: WealthyCast.toInt(json["id"]),
        orderId: WealthyCast.toStr(json["order_id"]),
        name: WealthyCast.toStr(json["name"]),
        email: WealthyCast.toStr(json["email"]),
        phoneNumber: WealthyCast.toStr(json["phone_number"]),
        payoutCompletedAt: WealthyCast.toStr(json["payout_completed_at"]),
        amount: WealthyCast.toInt(json["amount"]),
        redeemStatus: WealthyCast.toStr(json["redeem_status"]),
        expiresAt: WealthyCast.toStr(json["expires_at"]),
        thirdPartyPaymentId: WealthyCast.toStr(json["third_party_payment_id"]),
        thirdPartyPaymentLink:
            WealthyCast.toStr(json["third_party_payment_link"]),
        redeemedAt: WealthyCast.toStr(json["redeemed_at"]),
      );
}
