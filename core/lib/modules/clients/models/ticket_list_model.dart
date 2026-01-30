import 'package:core/config/util_constants.dart';
import 'package:core/modules/common/models/wealthy_system_user_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class TicketsListModel {
  String? id;
  List<TicketModel>? tickets;
  int? ticketsCount;

  TicketsListModel({this.id, this.tickets, this.ticketsCount});

  TicketsListModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    if (json['tickets'] != null) {
      tickets = <TicketModel>[];
      json['tickets'].forEach((v) {
        tickets!.add(new TicketModel.fromJson(v));
      });
    }
    ticketsCount = WealthyCast.toInt(json['ticketsCount']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.tickets != null) {
      data['tickets'] = this.tickets!.map((v) => v.toJson()).toList();
    }
    data['ticketsCount'] = this.ticketsCount;
    return data;
  }
}

class TicketModel {
  String? id;
  String? title;
  DateTime? createdAt;
  int? ticketId;
  String? no;
  String? ticketName;
  String? status;
  String? priority;
  WealthySystemUserModel? requestor;
  WealthySystemUserModel? assignee;
  String? customerApprovedOn;
  DateTime? customerUrlTokenExpiresAt;
  Group? group;

  TicketModel(
      {this.id,
      this.title,
      this.createdAt,
      this.ticketId,
      this.no,
      this.ticketName,
      this.status,
      this.priority,
      this.requestor,
      this.assignee,
      this.customerApprovedOn,
      this.customerUrlTokenExpiresAt,
      this.group});

  TicketModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    title = WealthyCast.toStr(json['title']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    ticketId = WealthyCast.toInt(json['ticketId']);
    no = WealthyCast.toStr(json['no']);
    ticketName = WealthyCast.toStr(json['ticketName']);
    status = WealthyCast.toStr(json['status']);
    priority = WealthyCast.toStr(json['priority']);
    requestor = json["requestorCode"] != null
        ? WealthySystemUserModel.fromJson(
            jwtDecoder(json["requestorCode"]) ?? {})
        : null;
    assignee = json["assigneeCode"] != null
        ? WealthySystemUserModel.fromJson(
            jwtDecoder(json["assigneeCode"]) ?? {})
        : null;
    customerApprovedOn = WealthyCast.toStr(json['customerApprovedOn']);
    customerUrlTokenExpiresAt =
        WealthyCast.toDate(json['customerUrlTokenExpiresAt']);
    group = json['group'] != null ? new Group.fromJson(json['group']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['createdAt'] = this.createdAt;
    data['ticketId'] = this.ticketId;
    data['no'] = this.no;
    data['ticketName'] = this.ticketName;
    data['status'] = this.status;
    data['priority'] = this.priority;
    data['requestorCode'] = this.requestor;
    data['assigneeCode'] = this.assignee;
    data['customerApprovedOn'] = this.customerApprovedOn;
    data['customerUrlTokenExpiresAt'] =
        this.customerUrlTokenExpiresAt?.toIso8601String();
    if (this.group != null) {
      data['group'] = this.group!.toJson();
    }
    return data;
  }
}

class Group {
  String? id;
  int? ticketGroupId;

  Group({this.id, this.ticketGroupId});

  Group.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    ticketGroupId = WealthyCast.toInt(json['ticketGroupId']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ticketGroupId'] = this.ticketGroupId;
    return data;
  }
}
