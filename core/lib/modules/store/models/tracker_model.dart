import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class TrackerModel {
  AgentModel? agent;
  Client? customer;
  int? status;
  String? externalId;
  DateTime? completedAt;
  DateTime? createdAt;
  DateTime? markedInProgressAt;
  DateTime? failedAt;
  String? failureReason;

  TrackerModel({
    this.agent,
    this.customer,
    this.status,
    this.externalId,
    this.createdAt,
    this.completedAt,
    this.markedInProgressAt,
    this.failedAt,
    this.failureReason,
  });

  factory TrackerModel.fromJson(Map<String, dynamic> json) => TrackerModel(
        agent:
            json["agent"] == null ? null : AgentModel.fromJson(json["agent"]),
        customer:
            json["agent"] == null ? null : Client.fromJson(json["customer"]),
        status: WealthyCast.toInt(json["status"]),
        externalId: WealthyCast.toStr(json["external_id"]),
        createdAt: WealthyCast.toDate(json["created_at"]) ?? DateTime.now(),
        completedAt: WealthyCast.toDate(json["completed_at"]),
        markedInProgressAt: WealthyCast.toDate(json["marked_in_progress_at"]),
        failedAt: WealthyCast.toDate(json["failed_at"]),
        failureReason: WealthyCast.toStr(json["failure_reason"]),
      );
}

class FamilyReportModel {
  String? id;
  DateTime? syncDate;
  String? panNumber;
  String? currentValue;
  String? mfCurrentValue;

  FamilyReportModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json["id"]);
    syncDate = WealthyCast.toDate(json["syncDate"]);
    panNumber = WealthyCast.toStr(json["panNumber"]);
    currentValue = WealthyCast.toStr(json["currentValue"]);
    mfCurrentValue = WealthyCast.toStr(json["mfCurrentValue"]);
  }
}
