import 'package:core/modules/common/resources/wealthy_cast.dart';

class PortfolioSipsModel {
  int? amount;
  String? sipDate;
  int? stage;
  dynamic pauseDate;
  int? mandateStage;

  PortfolioSipsModel(
      {this.amount,
      this.sipDate,
      this.stage,
      this.pauseDate,
      this.mandateStage});

  PortfolioSipsModel.fromJson(Map<String, dynamic> json) {
    amount = WealthyCast.toInt(json['amount']);
    sipDate = WealthyCast.toStr(json['sipDate']);
    stage = WealthyCast.toInt(json['stage']);
    pauseDate = json['pauseDate'];
    mandateStage = WealthyCast.toInt(json['mandateStage']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['sipDate'] = this.sipDate;
    data['stage'] = this.stage;
    data['pauseDate'] = this.pauseDate;
    data['mandateStage'] = this.mandateStage;
    return data;
  }
}
