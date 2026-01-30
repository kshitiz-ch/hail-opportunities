import 'dart:io';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/agents_limited_access.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/button/rounded_loading_button.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/advisor/models/partner_nominee_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/kyc/empanelment_model.dart';
import 'package:core/modules/dashboard/models/kyc/partner_arn_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/rewards/models/reward_balance_model.dart';
import 'package:core/modules/rewards/resources/rewards_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  // Fields
  RoundedLoadingButtonController? btnController;
  late AdvisorOverviewRepository advisorOverviewRepository;
  late RewardsRepository rewardsRepository;

  NetworkState getVerificationRequestIdState = NetworkState.loaded;
  NetworkState sendVerificationState = NetworkState.loaded;
  NetworkState updatePartnerState = NetworkState.loaded;
  NetworkState getRewardBalanceState = NetworkState.loaded;
  NetworkState getAdvisorOverviewState = NetworkState.loaded;

  ApiResponse searchPartnerArnResponse = ApiResponse();
  ApiResponse changeDisplayNameResponse = ApiResponse();

  NetworkState kycSubFlowState = NetworkState.cancel;
  String? kycSubFlowUrl;

  String? apiKey;
  int? agentId;
  int? rewardBalance;
  AdvisorOverviewModel? advisorOverview;
  late RewardsBalanceModel rewardsBalanceModel;
  bool shouldRefreshDashboard = false;

  dynamic updatedPartnerDetailsData;
  String? updatePartnerDetailsErrorMessage;
  String advisorOverviewErrorMessage = '';
  String? appVersion;

  String? verificationRequestId;

  NetworkState empanelmentState = NetworkState.cancel;
  EmpanelmentModel? empanelmentDetails;

  NetworkState partnerNomineeeState = NetworkState.cancel;
  PartnerNomineeModel? partnerNominee;

  TextEditingController referralCodeController = TextEditingController();
  ApiResponse changeReferralCodeResponse = ApiResponse();

  String? selectedAvatar;
  File? pickedImage;
  ApiResponse uploadImageResponse = ApiResponse();
  ApiResponse getImageResponse = ApiResponse();
  SharedPreferences? sharedPreferences;

  String get brochureUrl =>
      sharedPreferences?.getString(SharedPreferencesKeys.brochureUrl) ?? '';

  bool get isBankDetailPresent {
    final accountNo = advisorOverview?.agent?.bankDetail?.bankAccountNo;
    final ifscCode = advisorOverview?.agent?.bankDetail?.bankIfscCode;
    return accountNo.isNotNullOrEmpty && ifscCode.isNotNullOrEmpty;
  }

  bool get hasLimitedAccess {
    if (Get.isRegistered<HomeController>()) {
      return Get.find<HomeController>().hasLimitedAccess;
    } else {
      return defaultAgentsWithLimitedAccess
          .contains(advisorOverview?.agent?.externalId);
    }
  }

  ProfileController(this.advisorOverview) {
    getApiKey().then((value) {
      apiKey = value;
    });
    rewardsRepository = RewardsRepository();
    advisorOverviewRepository = AdvisorOverviewRepository();
    getRewardBalanceState = NetworkState.loading;
    getAdvisorOverviewState = NetworkState.loading;
    btnController = RoundedLoadingButtonController();
    if (advisorOverview == null) {
      getAdvisorOverview();
    } else if (advisorOverview != null) {
      getAdvisorOverviewState = NetworkState.loaded;
    }
  }

  @override
  Future<void> onInit() async {
    await getAppVersion();
    super.onInit();
  }

  @override
  void onReady() async {
    sharedPreferences = await prefs;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getAppVersion() async {
    PackageInfo packageInfo = await initPackageInfo();
    appVersion = packageInfo.version;
    update([GetxId.profile]);
  }

  void getRewardsBalance() async {
    try {
      getRewardBalanceState = NetworkState.loading;
      update([GetxId.rewardBalance]);
      agentId = await getAgentId();
      var response = await rewardsRepository.getRewardsBalance(
          apiKey!, agentId.toString());
      if (response["status"] == "200") {
        rewardsBalanceModel =
            RewardsBalanceModel.fromJson(response["response"]);
        getRewardBalanceState = NetworkState.loaded;
      }
    } catch (error) {
      getRewardBalanceState = NetworkState.error;
    } finally {
      update([GetxId.rewardBalance]);
    }
  }

  void getAdvisorOverview() async {
    try {
      apiKey ??= await getApiKey();
      getAdvisorOverviewState = NetworkState.loading;
      update([GetxId.profile]);
      final currentTime = DateTime.now();
      final response = await advisorOverviewRepository.getAdvisorOverview(
          currentTime.year, currentTime.month, apiKey!);
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        getAdvisorOverviewState = NetworkState.error;
        advisorOverviewErrorMessage =
            response.exception.graphqlErrors[0]?.message ??
                'Something went wrong';
      } else {
        final updatedAdvisorOverview =
            AdvisorOverviewModel.fromJson(response.data['hydra']);

        // TODO: Revisit

        // bool isPartnerDetailsUpdated = updatedAdvisorOverview?.agent?.email !=
        //         advisorOverview?.agent?.email ||
        //     updatedAdvisorOverview?.agent?.phoneNumber !=
        //         advisorOverview?.agent?.phoneNumber;
        // if (isPartnerDetailsUpdated) {
        //   shouldRefreshDashboard = true;
        // }
        advisorOverview = updatedAdvisorOverview;

        getAdvisorOverviewState = NetworkState.loaded;
      }
    } catch (error) {
      getAdvisorOverviewState = NetworkState.error;
      advisorOverviewErrorMessage = 'Something went wrong';
    } finally {
      update([GetxId.profile]);
      getProfilePhoto();
    }
  }

  Future<dynamic> updatePartnerDetails(String updateField) async {
    try {
      updatePartnerState = NetworkState.loading;
      update([updateField]);
      var response = await advisorOverviewRepository.updatePartnerDetails(
          apiKey!, updateField);
      if (response.exception != null &&
          response.exception.graphqlErrors.length > 0) {
        updatePartnerDetailsErrorMessage =
            response.exception.graphqlErrors[0].message;
        updatePartnerState = NetworkState.error;
      } else {
        if (response.data != null) {
          updatedPartnerDetailsData =
              response.data['createPartnerFieldUpdateRequest'];
          updatePartnerState = NetworkState.loaded;
        } else {
          updatePartnerState = NetworkState.error;
          throw Exception();
        }
      }
    } catch (error) {
      updatePartnerDetailsErrorMessage =
          'Something went wrong! please try again';
      updatePartnerState = NetworkState.error;
    } finally {
      update([updateField]);
    }

    return updatedPartnerDetailsData;
  }

  Future<void> getPartnerVerificationRequestId(String verifyFieldName) async {
    getVerificationRequestIdState = NetworkState.loading;
    update([verifyFieldName]);

    try {
      String apiKey = (await getApiKey())!;

      Map<String, dynamic> payload = {"verify_field": verifyFieldName};

      var data = await AuthenticationRepository()
          .getPartnerVerificationRequestId(apiKey, payload);

      if (data["status"] == "200") {
        verificationRequestId = data["response"]["request_id"];
        getVerificationRequestIdState = NetworkState.loaded;
      } else {
        getVerificationRequestIdState = NetworkState.error;
      }
    } catch (error) {
      getVerificationRequestIdState = NetworkState.error;
    } finally {
      update([verifyFieldName]);
    }
  }

  Future<void> sendPartnerVerificationOtp(
      String verifyFieldName, String? verifyFieldValue) async {
    sendVerificationState = NetworkState.loading;
    update([verifyFieldName]);

    try {
      {
        String apiKey = (await getApiKey())!;
        Map<String, dynamic> payload = {
          "request_id": verificationRequestId,
          "field_value": verifyFieldValue
        };

        var response = await AuthenticationRepository()
            .sendPartnerVerificationOtp(apiKey, payload);

        if (response["status"] == "200") {
          sendVerificationState = NetworkState.loaded;
        } else {
          sendVerificationState = NetworkState.error;
        }
      }
    } catch (error) {
      sendVerificationState = NetworkState.error;
    } finally {
      update([verifyFieldName]);
    }
  }

  Future<void> searchPartnerArn() async {
    update([GetxId.searchArn]);
    searchPartnerArnResponse.state = NetworkState.loading;

    try {
      QueryResult response =
          await advisorOverviewRepository.searchParnterArn(apiKey!);

      if (response.hasException) {
        searchPartnerArnResponse.state = NetworkState.error;
        searchPartnerArnResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        dynamic data = response.data?['searchPartnerArn'];
        if (data != null) {
          advisorOverview?.partnerArn =
              PartnerArnModel.fromJson(data['partnerArnNode']);
        }
        searchPartnerArnResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      searchPartnerArnResponse.state = NetworkState.error;
      searchPartnerArnResponse.message = 'Please retry after sometime';
    } finally {
      update([GetxId.searchArn]);
      update([GetxId.profile]);
    }
  }

  Future<void> getAgentEmpanelmentDetails() async {
    empanelmentState = NetworkState.loading;
    update(['empanelment']);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await advisorOverviewRepository.getAgentEmpanelmentDetails(apiKey);

      if (response.hasException) {
        empanelmentState = NetworkState.error;
      } else {
        dynamic data = response.data?['hydra']['agent']['empanelment'];
        if (data != null) {
          empanelmentDetails = EmpanelmentModel.fromJson(data);
        }
        empanelmentState = NetworkState.loaded;
      }
    } catch (error) {
      empanelmentState = NetworkState.loaded;
    } finally {
      update(['empanelment']);
    }
  }

  Future<void> getPartnerNominee() async {
    partnerNomineeeState = NetworkState.loading;
    update(['partner-nominee']);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await AdvisorRepository().getPartnerNominee(apiKey);

      if (response.hasException) {
        partnerNomineeeState = NetworkState.error;
      } else {
        List nomineesJson = response.data?['partnerNominees'];
        partnerNominee = PartnerNomineeModel.fromJson(nomineesJson.first);

        partnerNomineeeState = NetworkState.loaded;
      }
    } catch (error) {
      partnerNomineeeState = NetworkState.loaded;
    } finally {
      update(['partner-nominee']);
    }
  }

  Future<void> changePartnerDisplayName(String displayName) async {
    changeDisplayNameResponse.state = NetworkState.loading;
    update([GetxId.name]);

    try {
      String apiKey = await getApiKey() ?? '';
      String agentId = (await getAgentId() ?? '').toString();

      QueryResult response = await AdvisorRepository()
          .changePartnerDisplayName(apiKey, agentId, displayName);

      if (response.hasException) {
        changeDisplayNameResponse.message =
            response.exception!.graphqlErrors[0].message;
        changeDisplayNameResponse.state = NetworkState.error;
      } else {
        String? displayName =
            response.data?['changeDisplayName']['agent']['displayName'];
        if (displayName.isNotNullOrEmpty) {
          advisorOverview?.agent?.displayName = displayName;

          if (Get.isRegistered<HomeController>()) {
            final homeController = Get.find<HomeController>();
            homeController.advisorOverviewModel?.agent?.displayName =
                displayName;
            homeController.update();
          }
        }

        changeDisplayNameResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      changeDisplayNameResponse.state = NetworkState.error;
      changeDisplayNameResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.name, GetxId.profile]);
      update();
    }
  }

  Future<void> changeReferralCode() async {
    changeReferralCodeResponse.state = NetworkState.loading;
    update([GetxId.referralCode]);

    try {
      String apiKey = await getApiKey() ?? '';
      String agentId = (await getAgentId() ?? '').toString();

      QueryResult response = await AdvisorRepository()
          .changeReferralCode(apiKey, agentId, referralCodeController.text);

      if (response.hasException) {
        changeReferralCodeResponse.message =
            response.exception!.graphqlErrors[0].message;
        changeReferralCodeResponse.state = NetworkState.error;
      } else {
        if (Get.isRegistered<CommonController>()) {
          final commonController = Get.find<CommonController>();
          await commonController.getAgentReferralData();
          if (commonController.agentReferralResponse.isLoaded) {
            final referralUrl =
                commonController.agentReferralModel?.referralUrl;
            // response.data?['changeClientReferralCode']['referralCode'];
            if (referralUrl.isNotNullOrEmpty) {
              advisorOverview?.agent?.referralUrl = referralUrl;

              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>()
                    .advisorOverviewModel
                    ?.agent
                    ?.referralUrl = referralUrl;
              }
            }

            changeReferralCodeResponse.state = NetworkState.loaded;
          } else {
            changeReferralCodeResponse.message =
                'Failed to fetch Referral Url. Please restart the app';
            changeReferralCodeResponse.state = NetworkState.error;
          }
        }
      }
    } catch (error) {
      changeReferralCodeResponse.state = NetworkState.error;
      changeReferralCodeResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.referralCode, GetxId.profile]);
    }
  }

  Future<void> initiateKycSubFlow(
    BuildContext context,
    String subFlowType,
  ) async {
    kycSubFlowUrl = '';
    kycSubFlowState = NetworkState.loading;
    // initiate screen loader
    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
      ),
    );

    try {
      {
        String apiKey = (await getApiKey())!;

        final response = await AdvisorOverviewRepository()
            .initiateKycSubFlow(apiKey, subFlowType);

        if (response["status"] == "200") {
          kycSubFlowUrl = response['response']['kyc_url'];
          showToast(text: "Opening web view to update field");
          // launch(proposalUrl);
          kycSubFlowState = NetworkState.loaded;
        } else {
          handleApiError(response, showToastMessage: true);
          kycSubFlowState = NetworkState.error;
        }
      }
    } catch (error) {
      kycSubFlowState = NetworkState.error;
      showToast(text: "Failed to get update url. Please try again.");
    } finally {
      // close screen loader
      AutoRouter.of(context).popForced();
      update();
    }
  }

  Future<void> uploadProfilePhoto() async {
    try {
      uploadImageResponse.state = NetworkState.loading;
      update(['profile-picture', GetxId.profile]);

      final apiKey = (await getApiKey())!;
      String filePath = '';
      if (selectedAvatar.isNotNullOrEmpty) {
        filePath = (await getImageFileFromAssets(selectedAvatar!)).path;
      } else {
        filePath = pickedImage!.path;
      }
      final response = await AdvisorOverviewRepository()
          .uploadProfilePhoto(apiKey, filePath);
      final isSuccess =
          ((WealthyCast.toInt(response["status"]) ?? 0) ~/ 100) == 2;
      if (isSuccess) {
        uploadImageResponse.state = NetworkState.loaded;
        getProfilePhoto();
      } else {
        handleApiError(response, showToastMessage: true);
        uploadImageResponse.state = NetworkState.error;
      }
    } catch (error) {
      uploadImageResponse.state = NetworkState.error;
      showToast(text: "Something went wrong. Please try again.");
    } finally {
      update(['profile-picture', GetxId.profile]);
    }
  }

  Future<void> getProfilePhoto() async {
    try {
      getImageResponse.state = NetworkState.loading;
      update(['profile-picture', GetxId.profile]);

      String apiKey = (await getApiKey())!;

      final response =
          await AdvisorOverviewRepository().getProfilePhoto(apiKey);

      if (response["status"] == "200") {
        advisorOverview?.profilePictureUrl =
            WealthyCast.toStr(response["response"]["profile_photo_url"]);

        getImageResponse.state = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        getImageResponse.state = NetworkState.error;
      }
    } catch (error) {
      getImageResponse.state = NetworkState.error;
    } finally {
      update(['profile-picture', GetxId.profile]);

      // refresh home controller
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : Get.put(HomeController());
      homeController.getProfilePhoto();
    }
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
