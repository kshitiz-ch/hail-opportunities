import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class ReportTemplateGroupModel {
  String? groupName;
  List<ReportTemplateModel> reportTemplates;

  ReportTemplateGroupModel({
    this.groupName,
    this.reportTemplates = const [],
  });
}

class ReportTemplateModel {
  String? id;
  int? reportTemplateId;
  String? name;
  int? expiryTime;
  String? description;
  bool? canGiveComments;
  String? displayName;
  String? schema;
  String? tag;
  String? reportType;
  String? reportCategory;

  List<String> get reportTypeList {
    if (reportType.isNullOrEmpty) {
      return [];
    }
    return reportType!.split(',').map((e) => e.trim()).toList();
  }

  ReportTemplateModel({
    this.id,
    this.reportTemplateId,
    this.name,
    this.expiryTime,
    this.description,
    this.canGiveComments,
    this.displayName,
    this.schema,
    this.tag,
    this.reportType,
    this.reportCategory,
  });

  String get reportCategoryDescription {
    switch ((reportCategory ?? '').toLowerCase()) {
      case "i":
        return "Individual";
      case "f":
        return "Family";
      default:
        return "";
    }
  }

  ReportTemplateModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    reportTemplateId = WealthyCast.toInt(json['reportTemplateId']);
    name = WealthyCast.toStr(json['name']);
    expiryTime = WealthyCast.toInt(json['expiryTime']);
    description = WealthyCast.toStr(json['description']);
    canGiveComments = WealthyCast.toBool(json['canGiveComments']);
    displayName = WealthyCast.toStr(json['displayName']);
    schema = WealthyCast.toStr(json['schema']);
    tag = WealthyCast.toStr(json['tag']);
    reportType = WealthyCast.toStr(json['reportType']);
    reportCategory = WealthyCast.toStr(json['reportCategory']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reportTemplateId'] = this.reportTemplateId;
    data['name'] = this.name;
    data['expiryTime'] = this.expiryTime;
    data['description'] = this.description;
    data['canGiveComments'] = this.canGiveComments;
    data['displayName'] = this.displayName;
    data['schema'] = this.schema;
    data['tag'] = this.tag;
    data['reportType'] = this.reportType;
    return data;
  }
}
