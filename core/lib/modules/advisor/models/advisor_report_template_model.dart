import 'package:core/modules/common/resources/wealthy_cast.dart';

class AdvisorReportTemplateModel {
  String? name;
  String? functionParameters;
  String? reportType;
  String? pdfTemplateName;
  bool? isPublished;
  String? displayName;
  String? description;
  int? reportTemplateId;

  AdvisorReportTemplateModel(
      {this.name,
      this.functionParameters,
      this.reportType,
      this.pdfTemplateName,
      this.isPublished,
      this.displayName,
      this.description,
      this.reportTemplateId});

  AdvisorReportTemplateModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    functionParameters = WealthyCast.toStr(json['functionParameters']);
    reportType = WealthyCast.toStr(json['reportType']);
    pdfTemplateName = WealthyCast.toStr(json['pdfTemplateName']);
    isPublished = WealthyCast.toBool(json['isPublished']);
    displayName = WealthyCast.toStr(json['displayName']);
    description = WealthyCast.toStr(json['description']);
    reportTemplateId = WealthyCast.toInt(json['reportTemplateId']);
  }
}
