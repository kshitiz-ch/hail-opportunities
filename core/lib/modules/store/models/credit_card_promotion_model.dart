class CreditCardPromotionModel {
  CreditCardPromotionDetail? travelCreditCard;
  CreditCardPromotionDetail? shoppingCard;
  CreditCardPromotionDetail? topPremiumCard;
  CreditCardPromotionDetail? fuelCard;
  CreditCardPromotionDetail? library;

  CreditCardPromotionModel({
    this.travelCreditCard,
    this.shoppingCard,
    this.topPremiumCard,
    this.fuelCard,
    this.library,
  });

  CreditCardPromotionModel.fromJson(Map<String, dynamic> json) {
    travelCreditCard = json['travel_credit_card'] != null
        ? CreditCardPromotionDetail.fromJson(json['travel_credit_card'])
        : null;
    shoppingCard = json['shopping_card'] != null
        ? CreditCardPromotionDetail.fromJson(json['shopping_card'])
        : null;
    topPremiumCard = json['top_premium_card'] != null
        ? CreditCardPromotionDetail.fromJson(json['top_premium_card'])
        : null;
    fuelCard = json['fuel_card'] != null
        ? CreditCardPromotionDetail.fromJson(json['fuel_card'])
        : null;
    library = json['library'] != null
        ? CreditCardPromotionDetail.fromJson(json['library'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.travelCreditCard != null) {
      data['travel_credit_card'] = this.travelCreditCard?.toJson();
    }
    if (this.shoppingCard != null) {
      data['shopping_card'] = this.shoppingCard?.toJson();
    }
    if (this.topPremiumCard != null) {
      data['top_premium_card'] = this.topPremiumCard?.toJson();
    }
    if (this.fuelCard != null) {
      data['fuel_card'] = this.fuelCard?.toJson();
    }
    if (this.library != null) {
      data['library'] = this.library?.toJson();
    }
    return data;
  }
}

class CreditCardPromotionDetail {
  String? image;
  String? url;

  CreditCardPromotionDetail({this.image, this.url});

  CreditCardPromotionDetail.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['image'] = this.image;
    data['url'] = this.url;
    return data;
  }
}
