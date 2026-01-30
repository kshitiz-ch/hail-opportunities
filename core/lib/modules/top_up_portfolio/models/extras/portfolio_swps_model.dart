import 'package:core/modules/common/resources/wealthy_cast.dart';

class PortfolioSwpsModel {
  int? amount;
  String? swpDate;
  int? stage;
  dynamic pauseDate;

  PortfolioSwpsModel({this.amount, this.swpDate, this.stage, this.pauseDate});

  PortfolioSwpsModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toInt(json['amount']);
    swpDate = WealthyCast.toStr(json['swpDate']);
    stage = WealthyCast.toInt(json['stage']);
    pauseDate = json['pauseDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['swpDate'] = this.swpDate;
    data['stage'] = this.stage;
    data['pauseDate'] = this.pauseDate;
    return data;
  }
}
