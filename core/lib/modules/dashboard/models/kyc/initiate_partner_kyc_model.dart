import 'package:core/modules/common/resources/wealthy_cast.dart';

import 'kyc_request_model.dart';

class InitiatePartnerKycModel {
  KycRequestModel? kycRequest;
  String? kycUrl;

  InitiatePartnerKycModel({this.kycRequest, this.kycUrl});

  InitiatePartnerKycModel.fromJson(Map<String, dynamic> json) {
    kycRequest = json['kycRequest'] != null
        ? new KycRequestModel.fromJson(json['kycRequest'])
        : null;
    kycUrl = WealthyCast.toStr(json['kycUrl']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.kycRequest != null) {
      data['kycRequest'] = this.kycRequest!.toJson();
    }
    data['kycUrl'] = this.kycUrl;
    return data;
  }
}
