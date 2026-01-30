import 'package:core/modules/common/resources/wealthy_cast.dart';

class OfflineSipModel {
  String? name;
  String? userId;
  String? panNumber;
  String? folioNumber;
  String? schemeCode;
  String? schemeName;
  String? crn;
  double? amount;
  double? monthlyAmount;
  String? agentName;
  String? agentExternalId;
  String? status;
  String? sipDays;
  String? frequency;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? regDate;
  DateTime? terminationDate;

  List<int> get sipDaysList {
    return sipDays?.split(',').map((e) => WealthyCast.toInt(e)!).toList() ?? [];
  }

  String get frequencyText {
    //  camelCaseToWords
    return (frequency ?? '')
        .replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ');
  }

  bool get isActive => status == 'Active';
  bool get isInActive => status == 'Inactive';
  bool get isPaused => status == 'Paused';

  OfflineSipModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    userId = WealthyCast.toStr(json['userId']);
    panNumber = WealthyCast.toStr(json['panNumber']);
    folioNumber = WealthyCast.toStr(json['folioNumber']);
    schemeCode = WealthyCast.toStr(json['schemeCode']);
    schemeName = WealthyCast.toStr(json['schemeName']);
    crn = WealthyCast.toStr(json['crn']);
    amount = WealthyCast.toDouble(json['amount']);
    monthlyAmount = WealthyCast.toDouble(json['monthlyAmount']);
    agentName = WealthyCast.toStr(json['agentName']);
    agentExternalId = WealthyCast.toStr(json['agentExternalId']);
    status = WealthyCast.toStr(json['status']);
    sipDays = json['sipDays'];
    frequency = WealthyCast.toStr(json['frequency']);
    startDate = WealthyCast.toDate(json['startDate']);
    endDate = WealthyCast.toDate(json['endDate']);
    regDate = WealthyCast.toDate(json['regDate']);
    terminationDate = WealthyCast.toDate(json['terminationDate']);
  }
}
