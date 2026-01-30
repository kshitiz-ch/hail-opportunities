import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/partner_referral_faq_term_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PartnerReferralController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ApiResponse partnerReferralInfoResponse = ApiResponse();
  String? referralCode = '';
  String? referralUrl = '';

  ApiResponse referralFaqTermResponse = ApiResponse();
  PartnerReferralFaqAndTermsModel? faqTermModel;

  List<String> faqTermTabs = ['FAQs', 'Terms & Conditions'];
  late TabController tabController;

  PartnerReferralController() {
    tabController = TabController(length: faqTermTabs.length, vsync: this);
  }

  @override
  void onInit() {
    super.onInit();
    getPartnerReferralInfo();
    getReferralFaqTerms();

    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        update(['referral-faq']);
      }
    });
  }

  Future<void> getPartnerReferralInfo() async {
    try {
      partnerReferralInfoResponse.state = NetworkState.loading;
      update(['referral-code']);

      final apiKey = (await getApiKey())!;

      final response = await AdvisorRepository().getPartnerReferralInfo(apiKey);

      if (response["status"] == "200") {
        referralCode = WealthyCast.toStr(response["response"]["referral_code"]);
        referralUrl = WealthyCast.toStr(response["response"]["referral_url"]);
        partnerReferralInfoResponse.state = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        partnerReferralInfoResponse.state = NetworkState.error;
      }
    } catch (error) {
      partnerReferralInfoResponse.message = genericErrorMessage;
      partnerReferralInfoResponse.state = NetworkState.error;
    } finally {
      update(['referral-code']);
    }
  }

  Future<void> getReferralFaqTerms() async {
    try {
      referralFaqTermResponse.state = NetworkState.loading;
      update(['referral-faq']);

      final response = await AdvisorRepository().getReferralFaqTerms();

      if (response["status"] == "200") {
        faqTermModel =
            PartnerReferralFaqAndTermsModel.fromJson(response['response']);
        referralFaqTermResponse.state = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        referralFaqTermResponse.state = NetworkState.error;
      }
    } catch (error) {
      referralFaqTermResponse.message = genericErrorMessage;
      referralFaqTermResponse.state = NetworkState.error;
    } finally {
      update(['referral-faq']);
    }
  }
}
