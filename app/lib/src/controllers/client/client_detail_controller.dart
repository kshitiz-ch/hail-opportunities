import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/authentication/models/agent_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/models/profile_prefill_model.dart';
import 'package:core/modules/clients/models/user_profile_view_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientDetailController extends GetxController {
  // Fields
  Client? client;
  AgentModel? mainClientAgent;

  ApiResponse clientMfProfileResponse = ApiResponse();
  ApiResponse mandateResponse = ApiResponse();
  ApiResponse investmentStatusResponse = ApiResponse();
  ApiResponse kraStatusResponse = ApiResponse();
  ApiResponse clientDetailResponse = ApiResponse();

  ApiResponse clientOnboardingResponse = ApiResponse();
  List<ProfilePrefillModel> clientOnboardingModels = [];

  ClientMfProfileModel? clientMfProfile;
  UserDetailsPrefillModel? userDetailsPrefill;
  UserMandateMeta? userMandateMeta;
  ApiResponse userProfileViewResponse = ApiResponse();

  // For Segment Events
  bool isClientProfileUpdated = false;
  bool isBankAccountUpdated = false;
  bool isNomineeDetailsUpdated = false;

  String mfInvestmentStatus = '-';
  String mfInvestmentStatusInfo = '-';
  String brokingInvestmentStatus = '-';
  String kraStatus = '-';

  List<String> profileViewSections = ['PAN Profiles', 'Family Holdings'];
  String selectedProfileSection = 'PAN Profiles';
  UserProfileViewModel? userProfileViewModel;
  ProfileModel? selectedProfile;
  bool tabBarViewLoading = false;

  bool get isPanProfileSelected {
    return selectedProfileSection == 'PAN Profiles';
  }

  int get panProfilesCount {
    return [
      userProfileViewModel?.userModel,
      ...userProfileViewModel?.myProfiles ?? []
    ].length;
  }

  bool get showPanAndFamilyView {
    return panProfilesCount > 0 &&
        (userProfileViewModel?.familyProfiles ?? []).isNotEmpty;
  }

  bool get showOnlyPanView {
    return (userProfileViewModel?.myProfiles ?? []).isNotEmpty;
  }

  bool get showProfileSection {
    return showPanAndFamilyView || showOnlyPanView;
  }

  List<ProfileModel?> get profileViewData {
    if (isPanProfileSelected) {
      return [
        userProfileViewModel?.userModel,
        ...userProfileViewModel?.myProfiles ?? []
      ];
    }
    return userProfileViewModel?.familyProfiles ?? [];
  }

  ProfileReturnModel? get profileReturn {
    if (isPanProfileSelected) {
      return userProfileViewModel?.myProfileReturn;
    }
    return userProfileViewModel?.familyProfileReturn;
  }

  /// Returns a ClientOnboardingSummary object
  ClientOnboardingSummary get clientOnboardingSummary {
    ProfilePrefillModel? currentOnboarding;
    bool isShowProgress = false;
    String onboardingText = '';

    if (clientOnboardingModels.length < 2) {
      return ClientOnboardingSummary(
        currentOnboarding: currentOnboarding,
        isShowProgress: isShowProgress,
        onboardingText: onboardingText,
      );
    }

    final mfOnboarding = clientOnboardingModels.first;
    final brokingOnboarding = clientOnboardingModels.last;

    if (brokingOnboarding.isInvestmentReady) {
      isShowProgress = false;
      return ClientOnboardingSummary(
        currentOnboarding: currentOnboarding,
        isShowProgress: isShowProgress,
        onboardingText: onboardingText,
      );
    }

    if (brokingOnboarding.isProfileNotFound) {
      isShowProgress = !mfOnboarding.isInvestmentReady;
      currentOnboarding = isShowProgress ? mfOnboarding : null;
      onboardingText = 'MF Onboarding';
      return ClientOnboardingSummary(
        currentOnboarding: currentOnboarding,
        isShowProgress: isShowProgress,
        onboardingText: onboardingText,
      );
    }

    if (brokingOnboarding.isIncomplete || brokingOnboarding.isUnderProcess) {
      isShowProgress = true;
      currentOnboarding = brokingOnboarding;
      onboardingText =
          mfOnboarding.isInvestmentReady ? 'Broking Onboarding' : 'Onboarding';
      return ClientOnboardingSummary(
        currentOnboarding: currentOnboarding,
        isShowProgress: isShowProgress,
        onboardingText: onboardingText,
      );
    }

    return ClientOnboardingSummary(
      currentOnboarding: currentOnboarding,
      isShowProgress: isShowProgress,
      onboardingText: onboardingText,
    );
  }

  // Constructor
  ClientDetailController(this.client) {
    mainClientAgent = this.client?.agent;
    if (client?.taxyID == null) {
      getClientDetails();
    }
  }

  bool get isEmailVerified {
    if (userDetailsPrefill == null) {
      return false;
    } else {
      return userDetailsPrefill?.isEmailVerified ?? false;
    }
  }

  bool get isPhoneVerified {
    if (userDetailsPrefill == null) {
      return false;
    } else {
      return userDetailsPrefill?.isPhoneVerified ?? false;
    }
  }

  bool get isKycComplete {
    if (clientMfProfile == null) {
      return false;
    } else {
      return clientMfProfile?.kycStatus == 6;
    }
  }

  int? get kycStatus {
    return clientMfProfile?.kycStatus ?? 0;
  }

  bool get isFirstNameAdded {
    return userDetailsPrefill?.firstName.isNotNullOrEmpty ?? false;
  }

  bool get isValidForfamilyAddition =>
      isFirstNameAdded && isPhoneVerified && isEmailVerified;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    if (client?.taxyID != null) {
      getUserMandateMeta();
      getClientProfileDetails();
      getClientInvestmentStatus();
      getUserProfileViewData();
      getClientOnboardingDetails();
    }

    super.onReady();
  }

  Future<void> getClientDetails({bool useTaxyId = false}) async {
    clientDetailResponse.state = NetworkState.loading;
    update(['client-details']);

    try {
      String? apiKey = await getApiKey();
      QueryResult response;
      if (useTaxyId) {
        response = await ClientListRepository().getClientDetailsByTaxyId(
          apiKey!,
          client!.taxyID!,
        );
      } else {
        response = await ClientListRepository().getClientDetails(
          clientId: client!.id,
          apiKey: apiKey,
        );
      }

      if (!response.hasException) {
        if (useTaxyId) {
          client = Client.fromJson(response.data!['hydra']['clients'].first);
        } else {
          client = Client.fromJson(response.data!['hydra']['client']);
          mainClientAgent = client?.agent;
        }

        getUserMandateMeta();
        getClientProfileDetails();
        getClientInvestmentStatus();
        getUserProfileViewData();
        getClientOnboardingDetails();

        clientDetailResponse.state = NetworkState.loaded;
      } else {
        clientDetailResponse.message =
            response.exception!.graphqlErrors.first.message;
        clientDetailResponse.state = NetworkState.error;
      }
    } catch (error) {
      clientDetailResponse.state = NetworkState.error;
    } finally {
      update(['client-details']);
    }
  }

  // /// Get Client's Account Details data from API
  Future<void> getClientProfileDetails({bool isRetry = false}) async {
    clientMfProfileResponse.state = NetworkState.loading;
    update(['account-details', 'client-details', 'tracker']);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await (ClientListRepository()
          .getClientProfileDetails(apiKey!, client!.taxyID!));

      if (response.hasException) {
        clientMfProfileResponse.message =
            response.exception!.graphqlErrors[0].message;
        clientMfProfileResponse.state = NetworkState.error;
      } else {
        if (response.data!['hagrid']['wealthyMfProfile'] != null) {
          clientMfProfile = ClientMfProfileModel.fromJson(
              response.data!['hagrid']['wealthyMfProfile']);
        }

        if (response.data!['hagrid']['wealthyUserDetailsPrefill'] != null) {
          userDetailsPrefill = UserDetailsPrefillModel.fromJson(
              response.data!['hagrid']['wealthyUserDetailsPrefill']);
        }
        clientMfProfileResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      clientMfProfileResponse.message = 'Something went wrong';
      clientMfProfileResponse.state = NetworkState.error;
    } finally {
      update(['account-details', 'client-details', 'tracker']);
    }
  }

  Future<void> getClientOnboardingDetails() async {
    clientOnboardingResponse.state = NetworkState.loading;
    update(['client-onboarding']);

    try {
      final apiKey = await getApiKey() ?? '';

      final responses = await Future.wait([
        ClientProfileRepository().getClientOnboardingDetails(
          apiKey!,
          client!.taxyID!,
          'MF',
        ),
        ClientProfileRepository().getClientOnboardingDetails(
          apiKey!,
          client!.taxyID!,
          'BROKING',
        )
      ]);

      if (responses.isNullOrEmpty ||
          responses.any((response) => response.hasException)) {
        clientOnboardingResponse.message = 'Error fetching onboarding details';
        clientOnboardingResponse.state = NetworkState.error;
      } else {
        clientOnboardingModels = responses
            .map((response) => ProfilePrefillModel.fromJson(
                response.data!['hagrid']!['profilePrefillData']!))
            .toList();
        clientOnboardingResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      clientOnboardingResponse.message = 'Something went wrong';
      clientOnboardingResponse.state = NetworkState.error;
    } finally {
      update(['client-onboarding']);
    }
  }

  Future<void> getUserMandateMeta() async {
    mandateResponse.state = NetworkState.loading;
    update(['account-details', 'client-status']);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response = await (ClientProfileRepository()
          .getUserMandateMeta(apiKey!, client!.taxyID!));

      if (!response.hasException) {
        userMandateMeta =
            UserMandateMeta.fromJson(response.data!["taxy"]["userMandateMeta"]);
        mandateResponse.state = NetworkState.loaded;
      } else {
        mandateResponse.state = NetworkState.error;
      }
    } catch (error) {
      mandateResponse.state = NetworkState.error;
    } finally {
      update(['account-details', 'client-status']);
    }
  }

  Future<void> getClientInvestmentStatus() async {
    investmentStatusResponse.state = NetworkState.loading;
    update(['investment-status', 'client-status']);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response =
          await ClientProfileRepository().getClientInvestmentStatus(
        clientId: client?.taxyID ?? '',
        apiKey: apiKey ?? '',
      );

      if (response.hasException) {
        investmentStatusResponse.state = NetworkState.error;
        investmentStatusResponse.message =
            response.exception!.graphqlErrors.first.message;
      } else {
        Map<String, dynamic>? wealthyMfProfileJson =
            response.data!['hagrid']['wealthyMfProfile'];
        if (wealthyMfProfileJson != null) {
          mfInvestmentStatus =
              WealthyCast.toStr(wealthyMfProfileJson["frontendStatusText"]) ??
                  '-';
          mfInvestmentStatusInfo =
              WealthyCast.toStr(wealthyMfProfileJson["frontendStatusInfo"]) ??
                  '-';
        }

        Map<String, dynamic>? wealthyBrokingProfileJson =
            response.data!['hagrid']['wealthyBrokingProfile'];
        if (wealthyBrokingProfileJson != null) {
          brokingInvestmentStatus = WealthyCast.toStr(
                  wealthyBrokingProfileJson["frontendStatusText"]) ??
              '-';
        }

        Map<String, dynamic>? wealthyUserProfileJson =
            response.data!['hagrid']['wealthyUserProfile'];
        if (wealthyUserProfileJson != null) {
          kraStatus =
              WealthyCast.toStr(wealthyUserProfileJson["kraStatusStr"]) ?? '-';
        }

        investmentStatusResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      investmentStatusResponse.message = genericErrorMessage;
      investmentStatusResponse.state = NetworkState.error;
    } finally {
      update(['investment-status', 'client-status']);
    }
  }

  Future<void> getClientKraStatusCheck() async {
    kraStatusResponse.state = NetworkState.loading;
    update(['investment-status', 'client-status']);

    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response =
          await ClientProfileRepository().getClientKraStatusCheck(
        apiKey ?? '',
        client?.taxyID ?? '',
      );

      if (response.hasException) {
        kraStatusResponse.state = NetworkState.error;
        kraStatusResponse.message =
            response.exception!.graphqlErrors.first.message;
      } else {
        Map<String, dynamic>? kraStatusCheckJson =
            response.data!['hagrid']['kraStatusCheck'];
        if (kraStatusCheckJson != null) {
          kraStatus = kraStatusCheckJson["kraStatusStr"] ?? '-';
        }
        kraStatusResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      kraStatusResponse.state = NetworkState.error;
    } finally {
      update(['investment-status', 'client-status']);
    }
  }

  Future<void> getUserProfileViewData() async {
    try {
      final apiKey = await getApiKey() ?? '';

      userProfileViewResponse.state = NetworkState.loading;
      update(['profile-view']);

      QueryResult response = await ClientProfileRepository()
          .getUserProfileViewData(apiKey!, client!.taxyID!);

      if (response.hasException) {
        userProfileViewResponse.message =
            response.exception!.graphqlErrors[0].message;
        userProfileViewResponse.state = NetworkState.error;
      } else {
        userProfileViewModel =
            UserProfileViewModel.fromJson(response.data!['userProfileView']);
        selectedProfile = userProfileViewModel?.userModel;
        if (showPanAndFamilyView == false) {
          profileViewSections = ['PAN Profiles'];
        }

        userProfileViewResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      userProfileViewResponse.message = 'Something went wrong';
      userProfileViewResponse.state = NetworkState.error;
    } finally {
      update(['profile-view']);
    }
  }

  void updateSelectedProfileSection(String value) {
    if (value == selectedProfileSection) {
      return;
    }

    selectedProfileSection = value;
    // selectedProfile =
    //     profileViewData.isNotNullOrEmpty ? profileViewData.first : null;
    // if (selectedProfile != null) {
    //   updateClientDetailData(selectedProfile!);
    // }
    if (value == "PAN Profiles" &&
        (selectedProfile?.userID != userProfileViewModel?.userModel?.userID)) {
      updateSelectedProfile(userProfileViewModel!.userModel!);
    } else if (value == "Family Holdings" &&
        (userProfileViewModel!.familyProfiles ?? []).isNotEmpty) {
      updateSelectedProfile(userProfileViewModel!.familyProfiles!.first);
    }

    update(['profile-view']);
  }

  void updateSelectedProfile(ProfileModel data) {
    selectedProfile = data;
    if (isPanProfileSelected) {
      updateClientDetailData(data);
    }
    tabBarViewLoading = true;
    update(['profile-view']);

    Future.delayed(Duration(milliseconds: 500), () {
      tabBarViewLoading = false;
      update(['profile-view']);
    });
  }

  void updateClientDetailData(ProfileModel data) {
    client = Client(
      name: data.name,
      crn: data.crn,
      taxyID: data.userID,
      panNumber: data.panNumber,
      phoneNumber: data.phoneNumber,
      panUsageSubtype: data.accountSubType,
      panUsageType: data.accountType,
      email: data.email,
    );

    getUserMandateMeta();
    getClientProfileDetails();
    getClientInvestmentStatus();
    getClientOnboardingDetails();
  }

  void switchToFamilyProfileView(ProfileModel data) async {
    client = Client(name: data.name, crn: data.crn, taxyID: data.userID);
    selectedProfile = data;

    selectedProfileSection = "PAN Profiles";
    await getClientDetails(useTaxyId: true);
  }
}

class ClientOnboardingSummary {
  final ProfilePrefillModel? currentOnboarding;
  final bool isShowProgress;
  final String onboardingText;

  ClientOnboardingSummary({
    required this.currentOnboarding,
    required this.isShowProgress,
    required this.onboardingText,
  });
}
