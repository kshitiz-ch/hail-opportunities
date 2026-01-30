import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/foundation.dart';

class EmployeesModel {
  String? externalId;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  int? customersCount;
  String? agentExternalId;
  dynamic agentLeadId;
  String? designation;
  DateTime? lastLoginAt;

  String get name => "${firstName ?? ''} ${lastName ?? ''}";

  EmployeesModel({
    this.externalId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.customersCount,
    this.agentExternalId,
    this.agentLeadId,
    this.designation,
    this.lastLoginAt,
  });

  double? _aum;

  set updateAum(double aum) {
    this._aum = aum;
  }

  double? get aum => this._aum;

  factory EmployeesModel.fromJson(Map<String, dynamic> json) => EmployeesModel(
        externalId: WealthyCast.toStr(json["externalId"]),
        agentExternalId: WealthyCast.toStr(json["agentExternalId"]),
        firstName: WealthyCast.toStr(json["firstName"]),
        lastName: WealthyCast.toStr(json["lastName"]),
        email: WealthyCast.toStr(json["email"]),
        phoneNumber: WealthyCast.toStr(json["phoneNumber"]),
        customersCount: WealthyCast.toInt(json["customersCount"]),
        agentLeadId: json["agentLeadId"],
        designation: WealthyCast.toStr(json["designation"]),
        lastLoginAt: json["agent"] != null
            ? WealthyCast.toDate(json["agent"]["lastLoginAt"])
            : null,
      );
}

class PartnerOfficeModel {
  EmployeesModel? partnerEmployeeSelected;
  List<String>? partnerEmployeeExternalIdList;

  PartnerOfficeModel(
      {this.partnerEmployeeSelected, this.partnerEmployeeExternalIdList});

  bool get isAllEmployeesSelected =>
      partnerEmployeeSelected == null &&
      partnerEmployeeExternalIdList.isNotNullOrEmpty;

  bool get isEmployeeSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'employee';

  bool get isPartnerOfficeSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'partner-office';

  bool get isOwnerSelected =>
      partnerEmployeeSelected?.designation?.toLowerCase() == 'owner';

  List<String> get agentExternalIds {
    List<String> data = [];
    try {
      if (isOwnerSelected || isEmployeeSelected) {
        data = [partnerEmployeeSelected!.agentExternalId!];
      } else if (isPartnerOfficeSelected || isAllEmployeesSelected) {
        data = List.from(partnerEmployeeExternalIdList ?? []);
      }
    } catch (e) {
    } finally {
      return data;
    }
  }

  bool isSameInstance(PartnerOfficeModel? other) {
    return other?.partnerEmployeeSelected?.agentExternalId ==
            partnerEmployeeSelected?.agentExternalId &&
        listEquals(other?.partnerEmployeeExternalIdList,
            partnerEmployeeExternalIdList);
  }
}
