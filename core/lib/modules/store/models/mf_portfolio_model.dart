import 'package:core/modules/common/resources/wealthy_cast.dart';

class MFPortfolioModel {
  MFPortfolioModel({
    this.products,
  });

  List<MFProductModel>? products;

  factory MFPortfolioModel.fromJson(Map<String, dynamic> json) =>
      MFPortfolioModel(
        products: WealthyCast.toList(json["products"])
            .map<MFProductModel>((x) => MFProductModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "products": products == null
            ? null
            : List<dynamic>.from(products!.map((x) => x.toJson())),
      };
}

class MFProductModel {
  MFProductModel({
    this.goalType,
    this.name,
    this.description,
    this.minAmount,
    this.minAddAmount,
    this.iconSvg,
    this.enabled,
    this.iconUrl,
    this.goalSubtypes,
    this.subtype,
    this.isSmartSwitch,
  });

  int? goalType;
  String? name;
  String? description;
  double? minAmount;
  double? minAddAmount;
  String? iconSvg;
  bool? enabled;
  String? iconUrl;
  int? expiryTime;
  List<GoalSubtypeModel>? goalSubtypes;
  int? subtype;
  bool? isSmartSwitch;

  factory MFProductModel.fromJson(Map<String, dynamic> json) => MFProductModel(
        goalType: WealthyCast.toInt(json["goal_type"]),
        name: WealthyCast.toStr(json["name"]),
        description: WealthyCast.toStr(json["description"]),
        minAmount: WealthyCast.toDouble(json["min_amount"]),
        minAddAmount: WealthyCast.toDouble(json["min_add_amount"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        enabled: WealthyCast.toBool(json["enabled"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        goalSubtypes: WealthyCast.toList(json["goal_subtypes"])
            .map<GoalSubtypeModel>((x) => GoalSubtypeModel.fromJson(x))
            .toList(),
        // Don't Use this field, instead use the one from GoalSubtype Model
        isSmartSwitch: WealthyCast.toInt(json['goal_type']) == 2,
      );

  Map<String, dynamic> toJson() => {
        "goal_type": goalType,
        "name": name,
        "description": description,
        "min_amount": minAmount,
        "icon_svg": iconSvg,
        "enabled": enabled,
        "subtype": subtype,
        "icon_url": iconUrl,
        "goal_subtypes": goalSubtypes == null
            ? null
            : List<dynamic>.from(goalSubtypes!.map((x) => x.toJson())),
        "isSmartSwitch": goalType == 2,
      };
}

class GoalSubtypeModel {
  GoalSubtypeModel({
    this.goalType,
    this.productVariant,
    this.productType,
    this.category,
    this.categoryText,
    this.title,
    this.description,
    this.productUrl,
    this.iconSvg,
    this.iconUrl,
    this.expiryTime,
    this.externalId,
    this.avgReturns,
    this.minReturns,
    this.maxReturns,
    this.minAmount,
    this.minSipAmount,
    this.minAddAmount,
    this.schemes,
    this.possibleSwitchPeriods,
    this.term,
    this.risk,
    this.pastOneYearReturns,
    this.pastThreeYearReturns,
    this.pastFiveYearReturns,
  });

  int? goalType;
  String? productVariant;
  String? productType;
  Category? category;
  CategoryText? categoryText;
  String? title;
  String? description;
  String? productUrl;
  String? iconSvg;
  String? iconUrl;
  int? expiryTime;
  String? externalId;
  double? avgReturns;
  double? minReturns;
  double? maxReturns;
  double? minAmount;
  double? minSipAmount;
  double? minAddAmount;
  List<Map<String, dynamic>>? schemes;
  List<int>? possibleSwitchPeriods;
  int? term;
  int? risk;
  double? pastOneYearReturns;
  double? pastThreeYearReturns;
  double? pastFiveYearReturns;
  // Don't Use this field, instead use the one from GoalSubtype Model

  bool get isSmartSwitch => this.goalType == 2;
  bool get isTaxSaver => this.goalType == 0;

  factory GoalSubtypeModel.fromJson(Map<String, dynamic> json) =>
      GoalSubtypeModel(
        goalType: WealthyCast.toInt(json["goal_type"]),
        productVariant: WealthyCast.toStr(json["product_variant"]),
        productType: WealthyCast.toStr(json["product_type"]),
        category: json["category"] == null
            ? null
            : categoryValues.map[json["category"]],
        categoryText: json["category_text"] == null
            ? null
            : categoryTextValues.map[json["category_text"]],
        title: WealthyCast.toStr(json["title"]),
        description: WealthyCast.toStr(json["description"]),
        productUrl: WealthyCast.toStr(json["product_url"]),
        iconSvg: WealthyCast.toStr(json["icon_svg"]),
        iconUrl: WealthyCast.toStr(json["icon_url"]),
        expiryTime: WealthyCast.toInt(json["expiry_time"]),
        externalId: WealthyCast.toStr(json["external_id"]),
        avgReturns: WealthyCast.toDouble(json["avg_returns"]),
        minReturns: WealthyCast.toDouble(json["min_returns"]),
        maxReturns: WealthyCast.toDouble(json["max_returns"]),
        minAmount: WealthyCast.toDouble(json["min_amount"]),
        minSipAmount: WealthyCast.toDouble(json["min_sip_amount"]),
        pastOneYearReturns: WealthyCast.toDouble(json["past_one_year_returns"]),
        pastThreeYearReturns:
            WealthyCast.toDouble(json["past_three_year_returns"]),
        pastFiveYearReturns:
            WealthyCast.toDouble(json["past_five_year_returns"]),
        minAddAmount: WealthyCast.toDouble(json["min_add_amount"]),
        schemes: WealthyCast.toList<Map<String, dynamic>>(json["schemes"]),
        possibleSwitchPeriods: WealthyCast.toList<int>(
            json['possible_switch_periods'] ?? [3, 6, 9, 12]),
        term: WealthyCast.toInt(json['term']),
        risk: WealthyCast.toInt(json['risk']),
        // Don't Use this field, instead use the one from GoalSubtype Model
      );

  Map<String, dynamic> toJson() => {
        "goal_type": goalType,
        "product_variant": productVariant,
        "product_type": productType,
        "category": category == null ? null : categoryValues.reverse![category],
        "category_text": categoryText == null
            ? null
            : categoryTextValues.reverse![categoryText],
        "title": title,
        "description": description,
        "product_url": productUrl,
        "icon_svg": iconSvg,
        "icon_url": iconUrl,
        "external_id": externalId,
        "avg_returns": avgReturns,
        "min_returns": minReturns,
        "max_returns": maxReturns,
        "min_amount": minAmount,
        "min_add_amount": minAddAmount,
        "schemes": schemes,
        "possible_switch_periods": possibleSwitchPeriods ?? [],
        "term": term,
        "risk": risk,
      };
}

enum Category { INVEST }

final categoryValues = EnumValues({"Invest": Category.INVEST});

enum CategoryText { INVESTMENT }

final categoryTextValues = EnumValues({"Investment": CategoryText.INVESTMENT});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
