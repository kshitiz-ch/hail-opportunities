import 'package:core/modules/common/resources/wealthy_cast.dart';

class UserProfileViewModel {
  ProfileModel? userModel;
  List<ProfileModel>? myProfiles;
  List<ProfileModel>? familyProfiles;
  ProfileReturnModel? myProfileReturn;
  ProfileReturnModel? familyProfileReturn;

  UserProfileViewModel.fromJson(Map<String, dynamic> json) {
    userModel = ProfileModel.fromJson(json);

    if (json['myProfiles'] != null) {
      myProfiles = <ProfileModel>[];
      json['myProfiles'].forEach((v) {
        myProfiles!.add(ProfileModel.fromJson(v));
      });
    }

    if (json['familyProfiles'] != null) {
      familyProfiles = <ProfileModel>[];
      json['familyProfiles'].forEach((v) {
        familyProfiles!.add(ProfileModel.fromJson(v));
      });
    }

    if (json['mfProfileInfo'] != null) {
      myProfileReturn = ProfileReturnModel.fromJson(json['mfProfileInfo']);
    }

    if (json['familyProfilesInfo'] != null) {
      familyProfileReturn =
          ProfileReturnModel.fromJson(json['familyProfilesInfo']);
    }
  }
}

class ProfileModel {
  String? name;
  String? userID;
  String? crn;
  String? relationship;
  String? accountType;
  String? accountSubType;
  String? panNumber;
  String? phoneNumber;
  String? email;
  double? investedValue;
  double? currentValue;
  double? absoluteReturn;
  double? absoluteReturnPercent;

  ProfileModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    userID = WealthyCast.toStr(json['userID']);
    crn = WealthyCast.toStr(json['crn']);
    relationship = WealthyCast.toStr(json['relationship']);
    accountType = WealthyCast.toStr(json['accountType']);
    accountSubType = WealthyCast.toStr(json['accountSubType']);
    panNumber = WealthyCast.toStr(json['panNumber']);
    phoneNumber = WealthyCast.toStr(json['phoneNumber']);
    email = WealthyCast.toStr(json['email']);
    investedValue = WealthyCast.toDouble(json['investedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    absoluteReturn = WealthyCast.toDouble(json['absoluteReturn']);
    absoluteReturnPercent = WealthyCast.toDouble(json['absoluteReturnPercent']);
  }
}

class ProfileReturnModel {
  double? investedValue;
  double? currentValue;
  double? unrealisedGain;
  double? absoluteReturns;
  double? xirr;

  ProfileReturnModel.fromJson(Map<String, dynamic> json) {
    investedValue = WealthyCast.toDouble(json['investedValue']);
    currentValue = WealthyCast.toDouble(json['currentValue']);
    absoluteReturns = WealthyCast.toDouble(json['absoluteReturns']);
    unrealisedGain = WealthyCast.toDouble(json['unrealisedGain']);
    xirr = WealthyCast.toDouble(json['xirr']);
  }
}
