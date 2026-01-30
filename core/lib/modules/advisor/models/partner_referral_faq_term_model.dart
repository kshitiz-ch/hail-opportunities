import 'package:core/modules/common/resources/wealthy_cast.dart';

class PartnerReferralFaqAndTermsModel {
  List<Faqs>? faqs;
  List<String>? termsAndConditions;

  PartnerReferralFaqAndTermsModel.fromJson(Map<String, dynamic> json) {
    if (json['faqs'] != null) {
      faqs = <Faqs>[];
      json['faqs'].forEach((v) {
        faqs!.add(Faqs.fromJson(v));
      });
    }
    termsAndConditions = json['terms_and_conditions'].cast<String>();
  }
}

class Faqs {
  String? question;
  String? answer;

  Faqs.fromJson(Map<String, dynamic> json) {
    question = WealthyCast.toStr(json['question']);
    answer = WealthyCast.toStr(json['answer']);
  }
}
