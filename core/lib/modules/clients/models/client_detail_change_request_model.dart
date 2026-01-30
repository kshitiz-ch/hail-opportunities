import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientDetailChangeRequestModel {
  String? token;
  String? stage;

  ClientDetailChangeRequestModel({this.token, this.stage});

  ClientDetailChangeRequestModel.fromJson(Map<String, dynamic> json) {
    token = WealthyCast.toStr(json['token']);
    stage = WealthyCast.toStr(json['stage']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['stage'] = this.stage;
    return data;
  }
}
