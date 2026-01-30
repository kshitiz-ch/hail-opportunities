import 'package:core/modules/common/resources/wealthy_cast.dart';

class BaseSipModel {
  List<BaseSip>? baseSips;

  BaseSipModel({this.baseSips});

  BaseSipModel.fromJson(Map<String, dynamic> json) {
    if (json['sipMetas'] != null) {
      baseSips = <BaseSip>[];
      json['sipMetas'].forEach((v) {
        baseSips!.add(new BaseSip.fromJson(v));
      });
    }
  }
}

class BaseSip {
  int? sipDay;
  int? sipDay2;
  int? sipAmount;
  DateTime? pauseDate;
  bool? isActive;
  String? id;
  DateTime? startDate;
  DateTime? endDate;
  int? completedOrderCount;
  DateTime? createdAt;
  int? baseSipId;
  Goal? goal;
  int? frequency;
  List<SipMetaFunds>? baseSipFunds;
  List<SipSchemes>? sipSchemes;
  String? days;
  bool? stepperEnabled;
  DateTime? stepperSetupDate;
  String? incrementPeriod;
  int? incrementPercentage;
  bool? isSipActive;
  DateTime? nextSipDate;

  String get stepUpPeriodText {
    if (incrementPeriod?.toLowerCase() == '6m') {
      return '6 Months';
    }
    return '1 Year';
  }

  BaseSip({
    this.sipDay,
    this.sipDay2,
    this.sipAmount,
    this.pauseDate,
    this.isActive,
    this.id,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.baseSipId,
    this.goal,
    this.frequency,
    this.baseSipFunds,
    this.sipSchemes,
    this.days,
    this.stepperEnabled,
    this.incrementPeriod,
    this.incrementPercentage,
    this.stepperSetupDate,
    this.isSipActive,
    this.nextSipDate,
    this.completedOrderCount,
  });

  BaseSip.fromJson(Map<String, dynamic> json) {
    sipDay = WealthyCast.toInt(json['sipDay']);
    sipDay2 = WealthyCast.toInt(json['sipDay2']);
    sipAmount = WealthyCast.toInt(json['sipAmount']);
    pauseDate = WealthyCast.toDate(json['pauseDate']);
    isActive = WealthyCast.toBool(json['isActive']);
    isSipActive = WealthyCast.toBool(json['isSipActive']);
    id = WealthyCast.toStr(json['id']);
    startDate = WealthyCast.toDate(json['startDate']);
    endDate = WealthyCast.toDate(json['endDate']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    baseSipId = WealthyCast.toInt(json['baseSipId']);
    frequency = WealthyCast.toInt(json['frequency']);
    completedOrderCount = WealthyCast.toInt(json['completedOrderCount']);

    stepperEnabled = WealthyCast.toBool(json['stepperEnabled']);
    days = WealthyCast.toStr(json['days']);
    stepperSetupDate = WealthyCast.toDate(json['stepperSetupDate']);
    incrementPercentage = WealthyCast.toInt(json['incrementPercentage']);
    incrementPeriod = WealthyCast.toStr(json['incrementPeriod']);

    goal = json['goal'] != null ? new Goal.fromJson(json['goal']) : null;
    if (json['sipMetaFunds'] != null) {
      baseSipFunds = <SipMetaFunds>[];
      json['sipMetaFunds'].forEach((v) {
        baseSipFunds!.add(new SipMetaFunds.fromJson(v));
      });
    }
    if (json['sipSchemes'] != null) {
      sipSchemes = <SipSchemes>[];
      json['sipSchemes'].forEach((v) {
        sipSchemes!.add(new SipSchemes.fromJson(v));
      });
    }
    if (json['nextSip'] != null && json['nextSip']['sipDate'] != null) {
      nextSipDate = WealthyCast.toDate(json['nextSip']['sipDate']);
    }
  }
}

class Goal {
  String? id;
  String? name;
  String? displayName;
  int? goalId;
  GoalSubtype? goalSubtype;

  Goal({this.id, this.name, this.displayName, this.goalId, this.goalSubtype});

  Goal.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    name = WealthyCast.toStr(json['name']);
    displayName = WealthyCast.toStr(json['displayName']);
    goalId = WealthyCast.toInt(json['goalId']);
    goalSubtype = json['goalSubtype'] != null
        ? new GoalSubtype.fromJson(json['goalSubtype'])
        : null;
  }
}

class GoalSubtype {
  String? id;
  int? subtype;
  int? goalType;

  GoalSubtype({this.id, this.subtype, this.goalType});

  GoalSubtype.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    subtype = WealthyCast.toInt(json['subtype']);
    goalType = WealthyCast.toInt(json['goalType']);
  }
}

class SipMetaFunds {
  String? wschemecode;
  int? amount;

  SipMetaFunds({this.wschemecode, this.amount});

  SipMetaFunds.fromJson(Map<String, dynamic> json) {
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    amount = WealthyCast.toInt(json['amount']);
  }
}

class SipSchemes {
  String? wschemecode;
  String? schemeName;

  SipSchemes({this.wschemecode, this.schemeName});

  SipSchemes.fromJson(Map<String, dynamic> json) {
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    schemeName = WealthyCast.toStr(json['schemeName']);
  }
}
