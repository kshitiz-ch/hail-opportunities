import 'package:core/modules/common/resources/wealthy_cast.dart';

class CheckPasscodeModel {
  String? os;
  String? appVersion;
  bool? disablePasscode;

  CheckPasscodeModel({
    this.os,
    this.appVersion,
    this.disablePasscode
  });

  CheckPasscodeModel.fromJson(Map<String, dynamic> json) {
    os = WealthyCast.toStr(json["os"]);
    appVersion = WealthyCast.toStr(json["app_version"]);
    disablePasscode = WealthyCast.toBool(json["disable_passcode"]);
  }
}