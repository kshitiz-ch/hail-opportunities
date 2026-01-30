import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class SipDetailModel {
  String? id;
  List<SipModel>? upcomingSips;
  List<SipModel>? pastSips;

  SipDetailModel({this.id, this.upcomingSips, this.pastSips});

  SipDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['upcomingSips'] != null) {
      upcomingSips = <SipModel>[];
      json['upcomingSips'].forEach((v) {
        upcomingSips!.add(new SipModel.fromJson(v));
      });
    }
    if (json['pastSips'] != null) {
      pastSips = <SipModel>[];
      json['pastSips'].forEach((v) {
        pastSips!.add(new SipModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.upcomingSips != null) {
      data['upcomingSips'] = this.upcomingSips!.map((v) => v.toJson()).toList();
    }
    if (this.pastSips != null) {
      data['pastSips'] = this.pastSips!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SipModel {
  String? id;
  DateTime? sipDate;
  String? stage;
  int? amount;
  DateTime? pauseDate;
  String? status;
  String? failureReason;
  // orderId coming as list because if sip amount is 2lakh & upi mandate limit is 90k
  // then 3 order of 90+90+20 will be created
  List<int>? orderIds;

  SipModel({
    this.id,
    this.sipDate,
    this.stage,
    this.amount,
    this.pauseDate,
    this.orderIds,
    this.failureReason,
  });

  SipModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    sipDate = WealthyCast.toDate(json['sipDate']);
    stage = WealthyCast.toStr(json['stage']);
    amount = WealthyCast.toInt(json['amount']);
    pauseDate = WealthyCast.toDate(json['pauseDate']);
    status = WealthyCast.toStr(json['status']);
    failureReason = WealthyCast.toStr(json['failureReason']);
    if (json['orderId'] != null && (json['orderId'] as List).isNotNullOrEmpty) {
      orderIds = (json['orderId'] as List)
          .map<int>((e) => WealthyCast.toInt(e)!)
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sipDate'] = this.sipDate;
    data['stage'] = this.stage;
    data['amount'] = this.amount;
    data['pauseDate'] = this.pauseDate;
    data['status'] = this.status;
    return data;
  }
}
