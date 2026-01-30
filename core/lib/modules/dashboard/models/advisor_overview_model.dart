import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';

class AdvisorOverviewModel {
  AdvisorOverviewModel(
      {
      // this.clientCountMetric,
      // this.revenueMetric,
      this.agentDesignation,
      this.agent,
      this.partnerArn,
      this.proposalsCount,
      this.proposalCompletedCount});

  // ClientCountMetric clientCountMetric;
  // RevenueMetric revenueMetric;
  AgentDesignationModel? agentDesignation;
  AgentModel? agent;
  PartnerArnModel? partnerArn;
  int? proposalsCount;
  int? proposalCompletedCount;
  String? profilePictureUrl;

  bool get isEmployee =>
      agentDesignation?.designation?.toLowerCase() == 'employee';
  bool get isOwner => agentDesignation?.designation?.toLowerCase() == 'owner';

  factory AdvisorOverviewModel.fromJson(Map<String, dynamic> json) =>
      AdvisorOverviewModel(
        // clientCountMetric: json["clientCountMetric"] == null
        //     ? null
        //     : ClientCountMetric.fromJson(json["clientCountMetric"]),
        // revenueMetric: json["revenueMetric"] == null
        //     ? null
        //     : RevenueMetric.fromJson(json["revenueMetric"]),
        agentDesignation: json["agentDesignation"] == null
            ? null
            : AgentDesignationModel.fromJson(json["agentDesignation"]),
        agent:
            json["agent"] == null ? null : AgentModel.fromJson(json["agent"]),
        partnerArn: json["partnerArn"] == null
            ? null
            : PartnerArnModel.fromJson(json["partnerArn"]),
        proposalsCount: WealthyCast.toInt(json["proposalsCount"]),
        proposalCompletedCount:
            WealthyCast.toInt(json["proposalCompletedCount"]),
      );

  Map<String, dynamic> toJson() => {
        // "clientCountMetric":
        //     clientCountMetric == null ? null : clientCountMetric.toJson(),
        // "revenueMetric": revenueMetric == null ? null : revenueMetric.toJson(),
        "agent": agent == null ? null : agent!.toJson(),
      };
}

class Manager {
  Manager({this.id, this.name, this.phoneNumber, this.email, this.imageUrl});

  String? id;
  String? name;
  String? phoneNumber;
  String? email;
  String? imageUrl;

  get isImageUrlPresent => imageUrl != null;

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
        id: WealthyCast.toStr(json["id"]),
        name: WealthyCast.toStr(json["name"]),
        phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
        email: WealthyCast.toStr(json["email"]),
        imageUrl: WealthyCast.toStr(json["imageUrl"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "phoneNumber": phoneNumber == null ? null : phoneNumber,
        "email": email ?? null,
        "imageUrl": imageUrl ?? null,
      };
}

class ClientCountMetric {
  ClientCountMetric({
    this.totalClients,
    this.pipelineCount,
    this.clientsAddedThisWeek,
    this.activeClients,
  });

  int? totalClients;
  int? pipelineCount;
  int? clientsAddedThisWeek;
  int? activeClients;

  factory ClientCountMetric.fromJson(Map<String, dynamic> json) =>
      ClientCountMetric(
        totalClients: WealthyCast.toInt(json["totalClients"]),
        pipelineCount: WealthyCast.toInt(json["pipelineCount"]),
        clientsAddedThisWeek: WealthyCast.toInt(json["clientsAddedThisWeek"]),
        activeClients: WealthyCast.toInt(json["activeClients"]),
      );

  Map<String, dynamic> toJson() => {
        "totalClients": totalClients == null ? null : totalClients,
        "pipelineCount": pipelineCount == null ? null : pipelineCount,
        "clientsAddedThisWeek":
            clientsAddedThisWeek == null ? null : clientsAddedThisWeek,
        "activeClients": activeClients == null ? null : activeClients,
      };
}

class RevenueMetric {
  RevenueMetric(
      {this.actualRevenue, this.noOfTransactions, this.deltaFromPreviousWeek});

  int? actualRevenue;
  int? noOfTransactions;
  double? deltaFromPreviousWeek;

  factory RevenueMetric.fromJson(Map<String, dynamic> json) => RevenueMetric(
      actualRevenue: WealthyCast.toInt(json["actualRevenue"]),
      noOfTransactions: WealthyCast.toInt(json["noOfTransactions"]),
      deltaFromPreviousWeek:
          WealthyCast.toDouble(json["deltaFromPreviousWeek"]));

  Map<String, dynamic> toJson() => {
        "actualRevenue": actualRevenue == null ? null : actualRevenue,
        "noOfTransactions": noOfTransactions == null ? null : noOfTransactions,
        "deltaFromPreviousWeek": deltaFromPreviousWeek ?? null,
      };
}

class AgentDesignationModel {
  String? designation;
  String? partnerOfficeName;

  AgentDesignationModel({this.designation, this.partnerOfficeName});

  factory AgentDesignationModel.fromJson(Map<String, dynamic> json) =>
      AgentDesignationModel(
        designation: WealthyCast.toStr(json["designation"]),
        partnerOfficeName: WealthyCast.toStr(json["partnerOfficeName"]),
      );
}
