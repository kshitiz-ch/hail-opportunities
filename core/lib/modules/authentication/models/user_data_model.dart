import 'package:core/modules/common/resources/wealthy_cast.dart';

class UserDataModel {
  UserDataModel({
    this.apiKey,
    this.keyTimeOut,
    this.agent,
  });

  String? apiKey;
  int? keyTimeOut;
  AgentAuthModel? agent;

  factory UserDataModel.fromJson(Map<String, dynamic> json) => UserDataModel(
        apiKey: WealthyCast.toStr(json["api_key"]),
        keyTimeOut: WealthyCast.toInt(json["key_time_out"]),
        agent: json["agent"] == null
            ? null
            : AgentAuthModel.fromJson(json["agent"]),
      );

  Map<String, dynamic> toJson() => {
        "api_key": apiKey == null ? null : apiKey,
        "key_time_out": keyTimeOut == null ? null : keyTimeOut,
        "agent": agent == null ? null : agent!.toJson(),
      };
}

class AgentAuthModel {
  int? id;
  String? code;
  String? name;
  String? email;
  String? agentType;
  String? externalId;
  bool? hideRevenue;

  AgentAuthModel(
      {this.id,
      this.code,
      this.name,
      this.email,
      this.agentType,
      this.externalId,
      this.hideRevenue});

  AgentAuthModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toInt(json['id']);
    code = WealthyCast.toStr(json['code']);
    name = WealthyCast.toStr(json['name']);
    email = WealthyCast.toStr(json['email']);
    agentType = WealthyCast.toStr(json['agent_type']);
    externalId = WealthyCast.toStr(json['external_id']);
    hideRevenue = WealthyCast.toBool(json['hide_revenue']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['email'] = this.email;
    data['agent_type'] = this.agentType;
    data['external_id'] = this.externalId;
    data['hide_revenue'] = this.hideRevenue;
    return data;
  }
}
