import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class WealthySystemUserModel {
  WealthySystemUserModel({this.id, this.name, this.email, this.service});

  int? id;
  String? name;
  String? email;
  SystemUserServiceType? service;

  factory WealthySystemUserModel.fromJson(Map<String, dynamic> json) {
    SystemUserServiceType? service;
    final serviceText = WealthyCast.toStr(json["service"])?.toLowerCase();
    if (serviceText == SystemUserServiceType.hydra.name) {
      service = SystemUserServiceType.hydra;
    } else if (serviceText == SystemUserServiceType.garage.name) {
      service = SystemUserServiceType.garage;
    }
    return WealthySystemUserModel(
      id: WealthyCast.toInt(json["id"]),
      name: WealthyCast.toStr(json["name"]),
      email: WealthyCast.toStr(json["email"]),
      service: service,
    );
  }

  String get getDisplayName {
    try {
      if (this.name.isNotNullOrEmpty) {
        return this.name!;
      }
      String serviceText = '';
      switch (this.service) {
        case SystemUserServiceType.hydra:
          serviceText = "wm";
          break;
        case SystemUserServiceType.garage:
          serviceText = "ops";
          break;
        default:
          serviceText = "";
      }
      String nameText = '';
      if (email.isNotNullOrEmpty) {
        nameText = email?.split('@').toList().first ?? '';
        nameText = nameText.toCapitalized();
      }

      return nameText.isNotNullOrEmpty
          ? '$nameText ${serviceText.isNotNullOrEmpty ? '(${serviceText})' : ''}'
          : '-';
    } catch (e) {
      return '';
    }
  }
}

enum SystemUserServiceType {
  hydra,
  garage,
}
