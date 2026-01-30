import 'package:core/modules/common/resources/wealthy_cast.dart';

class PortfolioSwitchesModel {
  int? amount;
  String? switchDate;
  int? stage;
  dynamic pauseDate;

  PortfolioSwitchesModel(
      {this.amount, this.switchDate, this.stage, this.pauseDate});

  PortfolioSwitchesModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toInt(json['amount']);
    switchDate = WealthyCast.toStr(json['switchDate']);
    stage = WealthyCast.toInt(json['stage']);
    pauseDate = json['pauseDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['switchDate'] = this.switchDate;
    data['stage'] = this.stage;
    data['pauseDate'] = this.pauseDate;
    return data;
  }
}
