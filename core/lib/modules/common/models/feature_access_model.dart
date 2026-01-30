import 'package:core/modules/common/resources/wealthy_cast.dart';

class FeatureAccessModel {
  final bool trackEvents;
  final String variationType;
  final bool failed;
  final String version;
  final String reason;
  final String errorCode;
  final bool value;
  final bool cacheable;
  final String evaluatedRuleName;

  FeatureAccessModel({
    required this.trackEvents,
    required this.variationType,
    required this.failed,
    required this.version,
    required this.reason,
    required this.errorCode,
    required this.value,
    required this.cacheable,
    required this.evaluatedRuleName,
  });

  factory FeatureAccessModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] ?? {};

    return FeatureAccessModel(
      trackEvents: WealthyCast.toBool(json['trackEvents']) ?? false,
      variationType: WealthyCast.toStr(json['variationType']) ?? '',
      failed: WealthyCast.toBool(json['failed']) ?? false,
      version: WealthyCast.toStr(json['version']) ?? '',
      reason: WealthyCast.toStr(json['reason']) ?? '',
      errorCode: WealthyCast.toStr(json['errorCode']) ?? '',
      value: WealthyCast.toBool(json['value']) ?? false,
      cacheable: WealthyCast.toBool(json['cacheable']) ?? false,
      evaluatedRuleName: WealthyCast.toStr(metadata['evaluatedRuleName']) ?? '',
    );
  }
}
