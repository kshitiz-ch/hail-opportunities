import 'package:core/modules/common/resources/wealthy_cast.dart';

class AgentProfileDeleteRequestModel {
  DateTime? createdAt;
  String? profileStatusText;
  String? agentEmail;
  String? status;
  String? externalId;

  AgentProfileDeleteRequestModel(
      {this.createdAt,
      this.profileStatusText,
      this.agentEmail,
      this.status,
      this.externalId});

  AgentProfileDeleteRequestModel.fromJson(Map<String, dynamic> json) {
    createdAt = WealthyCast.toDate(json['createdAt']);
    profileStatusText = WealthyCast.toStr(json['profileStatus']);
    agentEmail = WealthyCast.toStr(json['agentEmail']);
    status = WealthyCast.toStr(json['status']);
    externalId = WealthyCast.toStr(json['externalId']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['profileStatus'] = this.profileStatusText;
    data['agentEmail'] = this.agentEmail;
    data['status'] = this.status;
    data['externalId'] = this.externalId;
    return data;
  }
}
