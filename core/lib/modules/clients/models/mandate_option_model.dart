import 'package:core/modules/common/resources/wealthy_cast.dart';

class MandateOptionModel {
  List<MandateMethods>? mandateMethods;
  List<int>? paymentAmounts;
  int? minAmount;

  MandateOptionModel.fromJson(Map<String, dynamic> json) {
    if (json['mandate_methods'] != null) {
      mandateMethods = <MandateMethods>[];
      json['mandate_methods'].forEach((v) {
        mandateMethods!.add(new MandateMethods.fromJson(v));
      });
    }
    minAmount = WealthyCast.toInt(json['minimum_amount']);
    paymentAmounts = WealthyCast.toList(json['payment_amounts'])
        .map((value) => WealthyCast.toInt(value) ?? 0)
        .toList();
  }
}

class MandateMethods {
  String? method;
  String? title;
  String? pgAlias;

  MandateMethods({this.method, this.title, this.pgAlias});

  MandateMethods.fromJson(Map<String, dynamic> json) {
    method = WealthyCast.toStr(json['method']);
    title = WealthyCast.toStr(json['title']);
    pgAlias = WealthyCast.toStr(json['pg_alias']);
  }
}
