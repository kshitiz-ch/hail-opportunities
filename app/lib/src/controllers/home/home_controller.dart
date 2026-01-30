import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/agents_associate_acesss_list.dart';
import 'package:app/src/config/constants/agents_limited_access.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart' as util;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/firebase/firebase_event_service.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/advisor/models/newsletter_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/models/advisor_payout_model.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:core/modules/dashboard/models/kyc/empanelment_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:core/modules/notifications/resources/notification_repository.dart';
import 'package:core/modules/rewards/models/reward_balance_model.dart';
import 'package:core/modules/rewards/resources/rewards_repository.dart';
import 'package:core/modules/store/models/insurance_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/models/popular_products_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  final AdvisorOverviewRepository advisorOverviewRepository =
      AdvisorOverviewRepository();
  final StoreRepository storeRepository = StoreRepository();
  AdvisorOverviewModel? advisorOverviewModel;

  bool isSalesPlanIdExists = false;

  MFPortfolioModel? mutualFundsResponseModel;

  WealthyProductsModel? popularProductsResult;
  AdvisorPayoutModel? advisorPayout;
  EmpanelmentModel? empanelmentDetails;

  String? popularProductsErrorMessage;
  NetworkState advisorOverviewState = NetworkState.cancel;
  NetworkState rewardsBalanceState = NetworkState.cancel;
  NetworkState partnerOfficeState = NetworkState.cancel;
  NetworkState creativeListState = NetworkState.cancel;

  // Initially it should be in loading state
  NetworkState dashboardContentState = NetworkState.loading;

  DashboardContentModel? dashboardContent;
  TextEditingController? searchController;

  int? rewardsBalance = 0;
  int? agentId;

  String? advisorOverviewErrorMessage = '';
  String? apiKey = '';

  String? appVersion;

  InsuranceListModel insurancesResult = InsuranceListModel(products: [
    InsuranceModel(productVariant: "term"),
    InsuranceModel(productVariant: "traditional"),
    InsuranceModel(productVariant: "health")
  ]);

  AuthenticationBloc? authenticationBloc;

  bool hasPartnerOffice = false;
  bool hasPartnerOfficeAssociates = false;
  bool isHomeScreenContentFetched = false;

  ApiResponse getImageResponse = ApiResponse();
  ApiResponse homeBannersResponse = ApiResponse();
  ApiResponse dismissBannerResponse = ApiResponse();

  List<DataNotificationModel> homeBanners = [];

  NetworkState kycSubFlowState = NetworkState.cancel;
  String? kycSubFlowUrl;

  Map<String, dynamic> amcDisplayNameMapping = {};

  List<String> agentsWithAssociateAccessList =
      defaultAgentsWithAssociateAccessList;
  List<String> agentsWithLimitedAccess = defaultAgentsWithLimitedAccess;

  bool get hasAssociateAccess => agentsWithAssociateAccessList
      .contains(advisorOverviewModel?.agent?.externalId);
  bool get hasLimitedAccess =>
      agentsWithLimitedAccess.contains(advisorOverviewModel?.agent?.externalId);

  bool get hideRevenue =>
      sharedPreferences?.getBool(SharedPreferencesKeys.hideRevenue) ?? false;

  bool get showTncBottomSheet {
    return sharedPreferences
            ?.getBool(SharedPreferencesKeys.showNewFeatureDetails) ??
        false;
  }

  bool get showSearchShowCase {
    return false;
  }

  bool get isSgbAvailable {
    // bool shouldShowNewFeatureDetails = sharedPreferences
    //         ?.getBool(SharedPreferencesKeys.showNewFeatureDetails) ??
    //     false;

    return false;
  }

  bool get canPromptBankUpdateFeature {
    bool showBankPrompt = true;
    // sharedPreferences?.getBool('show_new_feature_details') ?? true;

    return showBankPrompt && isKycDone && !isBankDetailAdded;
  }

  bool get isKycDone {
    return advisorOverviewModel?.agent?.kycStatus == AgentKycStatus.APPROVED;
  }

  bool get isBankDetailAdded {
    final accountNo = advisorOverviewModel?.agent?.bankDetail?.bankAccountNo;
    final ifscCode = advisorOverviewModel?.agent?.bankDetail?.bankIfscCode;
    return accountNo.isNotNullOrEmpty && ifscCode.isNotNullOrEmpty;
  }

  bool get isEmpanelmentPending {
    String? status = empanelmentDetails?.status;
    if (status == AgentEmpanelmentStatus.Pending ||
        status == AgentEmpanelmentStatus.InProgress) {
      return true;
    }
    return false;
  }

  bool get isEmpanelmentCompleted {
    final status = empanelmentDetails?.status;

    return status == AgentEmpanelmentStatus.Empanelled ||
        status == AgentEmpanelmentStatus.Bypass ||
        status == AgentEmpanelmentStatus.BypassTemp;
  }

  Map<String, bool> newsletterStatus = {
    'money-order': false,
    'bulls-eye': false,
  };

  SharedPreferences? sharedPreferences;

  String whatsappCommunityLink = '';
  ApiResponse whatsappLinkResponse = ApiResponse();

  bool? isBrandingEnabled;
  ApiResponse brandingResponse = ApiResponse();

  /// Determines whether to show the WhatsApp banner.
  /// The banner is shown if the current date is within 30 days of the feature release date
  /// or if the agent's creation date is within the last 60 days.
  bool get showWhatsappBanner {
    final now = DateTime.now();
    final featureReleaseDate = DateTime(2025, 6, 5);

    // Check if the current date is within 30 days of the feature release date
    final bool isWithinFeaturePeriod =
        now.difference(featureReleaseDate).inDays <= 30;

    // Check if the agent's creation date is within the last 60 days (if available)
    final bool isRecentAgentCreation = advisorOverviewModel?.agent?.createdAt !=
            null &&
        now.difference(advisorOverviewModel!.agent!.createdAt!).inDays <= 60;

    // The banner is shown if either of the above conditions is true
    final bool enableWhatsappBanner =
        isWithinFeaturePeriod || isRecentAgentCreation;

    if (enableWhatsappBanner && !whatsappLinkResponse.isLoaded) {
      getWhatsappCommunityLink();
    }

    return enableWhatsappBanner;
  }

  @override
  void onReady() async {
    authenticationBloc = AuthenticationBlocController().authenticationBloc;
    agentId = await util.getAgentId();
    sharedPreferences = await prefs;
    apiKey = sharedPreferences?.getString('apiKey');
    searchController = TextEditingController();
    getAdvisorOverview();

    final packageInfo = await util.initPackageInfo();
    appVersion = packageInfo.version;
  }

  Future<void> getAdvisorOverview({int? month, int? year}) async {
    advisorOverviewState = NetworkState.loading;
    update();

    final oldIsFirstTransactionCompleted =
        advisorOverviewModel?.agent?.isFirstTransactionCompleted;
    final oldKycStatus = advisorOverviewModel?.agent?.kycStatus;
    final oldEmpanelmentStatus = empanelmentDetails?.status;

    try {
      final SharedPreferences sharedPreferences = await prefs;

      String apiKey = (await util.getApiKey())!;
      final response = await advisorOverviewRepository.getAdvisorOverview(
        month ?? DateTime.now().month,
        year ?? DateTime.now().year,
        apiKey,
      );

      if (response.hasException) {
        advisorOverviewState = NetworkState.error;
        if (response.exception.graphqlErrors.length > 0) {
          advisorOverviewErrorMessage =
              response.exception.graphqlErrors[0]?.message;
        }
        await util.handleGraphqlTokenExpiry();
      } else {
        advisorOverviewModel =
            AdvisorOverviewModel.fromJson(response.data['hydra']);

        sharedPreferences.setBool(SharedPreferencesKeys.isAgentFixed,
            advisorOverviewModel!.agent!.isAgentFixed);
        sharedPreferences.setString(SharedPreferencesKeys.agentExternalId,
            advisorOverviewModel?.agent?.externalId ?? '');

        // // Store sales plan id
        // if (advisorOverviewModel?.agent?.salesPlanType != null) {
        //   sharedPreferences.setInt(
        //     SharedPreferencesKeys.salesPlanType,
        //     advisorOverviewModel!.agent!.salesPlanType!,
        //   );

        //   String salesPlanId = await util.getSalesPlanId();

        //   isSalesPlanIdExists = salesPlanId.isNotNullOrEmpty;
        // }

        // if (advisorOverviewModel?.agent?.isActivated ?? false) {
        //   // disable showcase if the agent is already activated
        //   if (Get.isRegistered<ShowCaseController>()) {
        //     Get.find<ShowCaseController>().disableShowCase();
        //   }
        // }

        // Get partner office name
        if (advisorOverviewModel?.agentDesignation?.partnerOfficeName != null &&
            advisorOverviewModel?.agentDesignation?.designation == "owner") {
          hasPartnerOffice = true;
          await checkPartnerAssociatesExists();
        } else {
          partnerOfficeState = NetworkState.loaded;
        }

        sharedPreferences.setInt(
            "agentKycStatus", advisorOverviewModel?.agent?.kycStatus ?? -1);

        await getAgentsWithLimitedAccess();

        if (advisorOverviewModel?.agent?.kycStatus == AgentKycStatus.APPROVED) {
          await getAgentEmpanelmentDetails();
        }

        final newIsFirstTransactionCompleted =
            advisorOverviewModel?.agent?.isFirstTransactionCompleted;
        final newKycStatus = advisorOverviewModel?.agent?.kycStatus;
        final newEmpanelmentStatus = empanelmentDetails?.status;

        _trackStatusChangeEvents(
          oldIsFirstTransactionCompleted: oldIsFirstTransactionCompleted,
          newIsFirstTransactionCompleted: newIsFirstTransactionCompleted,
          oldKycStatus: oldKycStatus,
          newKycStatus: newKycStatus,
          oldEmpanelmentStatus: oldEmpanelmentStatus,
          newEmpanelmentStatus: newEmpanelmentStatus,
        );

        advisorOverviewState = NetworkState.loaded;
      }
    } catch (error) {
      advisorOverviewState = NetworkState.error;
    } finally {
      update();
      getProfilePhoto();
    }
  }

  Future<void> getHomeScreenContent() async {
    getNewsletterStatus();
    await getAmcOptions();
    await getHomeBanners();

    getAgentsWithAssoicateAccess();
    getBrandingStatus();

    isHomeScreenContentFetched = true;
    update();
  }

  Future<void> getAgentsWithAssoicateAccess() async {
    try {
      var data = await AdvisorRepository().getAgentsWithAssoicateAccess();
      if (data["status"] == "200") {
        agentsWithAssociateAccessList = WealthyCast.toList(data['response']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> getAgentsWithLimitedAccess() async {
    try {
      var data = await AdvisorRepository().getAgentsWithLimitedAccess();
      if (data["status"] == "200") {
        agentsWithLimitedAccess = WealthyCast.toList(data['response']);
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> checkPartnerAssociatesExists() async {
    try {
      partnerOfficeState = NetworkState.loading;
      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().getEmployees(
          search: '',
          designation: 'member',
          apiKey: apiKey,
          limit: 0,
          offset: 0);

      if (!response.hasException) {
        List associateMemberList = response.data!['hydra']['employees'];

        hasPartnerOfficeAssociates = associateMemberList.length > 0;
      }

      partnerOfficeState = NetworkState.loaded;
    } catch (error) {
      partnerOfficeState = NetworkState.loaded;
    } finally {
      update();
    }
  }

  Future<void> getRewardsBalance() async {
    try {
      var response = await RewardsRepository()
          .getRewardsBalance(apiKey!, agentId.toString());
      if (response["status"] == "200") {
        RewardsBalanceModel rewardsBalanceModel =
            RewardsBalanceModel.fromJson(response["response"]);

        rewardsBalance = rewardsBalanceModel.balance;
        rewardsBalanceState = NetworkState.loaded;
      }
    } catch (error) {
      rewardsBalanceState = NetworkState.error;
    }
  }

  Future<void> getHomeBanners({bool isTokenRegenerated = false}) async {
    // dashboardContentState = NetworkState.loading;
    // update(['dashboard-content']);

    // try {
    //   final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    //   await remoteConfig.setConfigSettings(
    //     RemoteConfigSettings(
    //       fetchTimeout: const Duration(minutes: 0),
    //       minimumFetchInterval: Duration.zero,
    //     ),
    //   );
    //   await remoteConfig.fetchAndActivate();

    //   Map<String, dynamic> homeBannersJson = jsonDecode(
    //     remoteConfig.getValue("home_banners").asString(),
    //   ) as Map<String, dynamic>;

    //   if (homeBannersJson.isNotEmpty) {
    //     dashboardContent = DashboardContentModel.fromJson(homeBannersJson);
    //     dashboardContent!.homeBanners!
    //         .sort((a, b) => a.position!.compareTo(b.position!));
    //     dashboardContent!.homeBannersTablet!
    //         .sort((a, b) => a.position!.compareTo(b.position!));
    //     dashboardContentState = NetworkState.loaded;
    //   } else {
    //     throw Exception();
    //   }
    // } catch (error) {
    //   dashboardContentState = NetworkState.error;
    // } finally {
    //   update(['dashboard-content']);
    // }

    try {
      homeBannersResponse.state = NetworkState.loading;
      update(['dashboard-content']);

      String userToken = await getAgentCommunicationToken() ?? "";

      final data = await NotificationsRepository().getNotifications(
        userToken,
        screenLocation: "home-banners",
        limit: 10,
        offset: 0,
      );

      if (data['status'] == '200') {
        WealthyCast.toList(data["response"]["notifications"]).forEach((x) {
          homeBanners.add(DataNotificationModel.fromJson(x));
        });

        homeBannersResponse.state = NetworkState.loaded;
      } else if (data['status'] == '401' && !isTokenRegenerated) {
        await CommonController.getAgentCommunicationAuthToken();
        await getHomeBanners(isTokenRegenerated: true);
      } else {
        homeBannersResponse.message = getErrorMessageFromResponse(data);
        homeBannersResponse.state = NetworkState.error;
      }
    } catch (error) {
      homeBannersResponse.message = 'Notification Data not found.';
      homeBannersResponse.state = NetworkState.error;
    } finally {
      update(['dashboard-content']);
    }
  }

  Future<void> dismissBanner(DataNotificationModel? banner) async {
    try {
      dismissBannerResponse.state = NetworkState.loading;
      homeBanners.remove(banner);

      update(['dashboard-content']);

      final data = await NotificationsRepository()
          .dismissNotification(banner?.userToken ?? "");

      if (data["status"] == "200") {
        dismissBannerResponse.state = NetworkState.loaded;
      } else {
        dismissBannerResponse.message = getErrorMessageFromResponse(data);
        dismissBannerResponse.state = NetworkState.error;
      }
    } catch (error) {
      dismissBannerResponse.message = 'Notification Data not found.';
      dismissBannerResponse.state = NetworkState.error;
    } finally {
      update(['dashboard-content']);
    }
  }

  Future<void> getAgentEmpanelmentDetails() async {
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await advisorOverviewRepository.getAgentEmpanelmentDetails(apiKey);

      if (!response.hasException) {
        dynamic data = response.data?['hydra']['agent']['empanelment'];
        if (data != null) {
          empanelmentDetails = EmpanelmentModel.fromJson(data);
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  void refreshDashboard() {
    getAdvisorOverview();
    getHomeScreenContent();
  }

  Future<void> initiateKycSubFlow(
    BuildContext context,
    String subFlowType,
  ) async {
    kycSubFlowUrl = '';
    kycSubFlowState = NetworkState.loading;
    update(['update-bank-detail']);

    try {
      String apiKey = (await getApiKey())!;

      final response = await AdvisorOverviewRepository()
          .initiateKycSubFlow(apiKey, subFlowType);

      if (response["status"] == "200") {
        kycSubFlowUrl = response['response']['kyc_url'];
        showToast(text: "Opening form to update bank details");
        kycSubFlowState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        kycSubFlowState = NetworkState.error;
      }
    } catch (error) {
      kycSubFlowState = NetworkState.error;
      showToast(text: "Failed to get update url. Please try again.");
    } finally {
      update(['update-bank-detail']);
    }
  }

  Future<void> getAmcOptions() async {
    amcDisplayNameMapping.clear();
    update(['amc']);

    try {
      String apiKey = await getApiKey() ?? '';

      var response = await StoreRepository().getAmcList(apiKey);

      if (response["status"] == "200") {
        List amcListJson = response["response"]["data"];
        amcListJson.forEach((e) {
          amcDisplayNameMapping.addAll(
            {
              e["value"]: e["display_name"],
            },
          );
        });
      }
    } catch (error) {
      amcDisplayNameMapping = {};
    } finally {
      update(['amc']);
    }
  }

  Future<void> getProfilePhoto() async {
    try {
      getImageResponse.state = NetworkState.loading;
      update(['profile-picture']);

      String apiKey = (await getApiKey())!;

      final response =
          await AdvisorOverviewRepository().getProfilePhoto(apiKey);

      if (response["status"] == "200") {
        advisorOverviewModel?.profilePictureUrl =
            WealthyCast.toStr(response["response"]["profile_photo_url"]);
        getImageResponse.state = NetworkState.loaded;
      } else {
        handleApiError(response);
        getImageResponse.state = NetworkState.error;
      }
    } catch (error) {
      getImageResponse.state = NetworkState.error;
    } finally {
      update(['profile-picture']);
    }
  }

  Future<void> getNewsletterStatus() async {
    String getQueryParam(String selectedTab) {
      String queryParam = '?';
      if (selectedTab == "Money Order") {
        queryParam += 'content_type=money-order';
      } else {
        queryParam += 'content_type=bulls-eye';
      }
      queryParam += '&is_published=True';
      queryParam += '&ordering=-chronological_date';
      queryParam += '&limit=1';
      queryParam += '&offset=0';
      return queryParam;
    }

    try {
      final apiKey = await getApiKey();

      final responses = await Future.wait(
        [
          AdvisorRepository().getNewsletters(
            apiKey ?? '',
            getQueryParam("Money Order"),
          ),
          AdvisorRepository().getNewsletters(
            apiKey ?? '',
            getQueryParam("Bulls Eye"),
          )
        ],
      );

      responses.forEach(
        (response) {
          if (response['status'] == '200') {
            final results = WealthyCast.toList(response['response']['results']);
            if (results.isNotNullOrEmpty) {
              final model = NewsLetterModel.fromJson(results.first);
              if (model.publishedAt != null &&
                  model.contentType.isNotNullOrEmpty) {
                newsletterStatus[model.contentType!] =
                    DateTime.now().difference(model.publishedAt!).inDays <= 1;
              }
            }
          }
        },
      );
    } catch (e) {
    } finally {
      update();
    }
  }

  Future<void> getWhatsappCommunityLink() async {
    try {
      whatsappLinkResponse.state = NetworkState.loading;
      update(['whatsapp-community']);

      final remoteConfig = await getRemoteConfig();
      whatsappCommunityLink =
          remoteConfig.getValue('whatsapp_community').asString();
      whatsappLinkResponse.state = NetworkState.loaded;
    } catch (e) {
      whatsappLinkResponse.state = NetworkState.error;
      whatsappLinkResponse.message = genericErrorMessage;
    } finally {
      update(['whatsapp-community']);
    }
  }

  Future<void> getBrandingStatus() async {
    try {
      brandingResponse.state = NetworkState.loading;
      update(['branding-status']);

      final apiKey = await getApiKey() ?? '';

      final response =
          await AdvisorRepository().getBrandingDetail(apiKey, preview: false);

      if (response != null) {
        if (response['status'] == '200') {
          isBrandingEnabled = response?['response']?['published_at'] != null;
        }
        if (response['status'] == '404') {
          isBrandingEnabled = false;
        }
        brandingResponse.state = NetworkState.loaded;
      } else {
        brandingResponse.state = NetworkState.error;
        brandingResponse.message = 'No branding data received';
      }
    } catch (e) {
      brandingResponse.state = NetworkState.error;
      brandingResponse.message = genericErrorMessage;
    } finally {
      update(['branding-status']);
    }
  }

  void _trackStatusChangeEvents({
    required bool? oldIsFirstTransactionCompleted,
    required bool? newIsFirstTransactionCompleted,
    required int? oldKycStatus,
    required int? newKycStatus,
    required String? oldEmpanelmentStatus,
    required String? newEmpanelmentStatus,
  }) {
    // First Transaction
    if (oldIsFirstTransactionCompleted == false &&
        newIsFirstTransactionCompleted == true) {
      FirebaseEventService.logEvent('WL_Resp_CL_FT_Resp_Succ');
    }

    // KYC Status
    if (oldKycStatus != null &&
        oldKycStatus != AgentKycStatus.APPROVED &&
        newKycStatus == AgentKycStatus.APPROVED) {
      FirebaseEventService.logEvent('WL_Resp_KYC_Resp_succ');
    }

    // Empanelment Status
    final successStatuses = [
      AgentEmpanelmentStatus.Empanelled,
      AgentEmpanelmentStatus.Bypass,
      AgentEmpanelmentStatus.BypassTemp
    ];

    if (oldEmpanelmentStatus != null &&
        !successStatuses.contains(oldEmpanelmentStatus) &&
        successStatuses.contains(newEmpanelmentStatus)) {
      FirebaseEventService.logEvent('WL_Resp_EMP_Resp_succ');
    }
  }
}
