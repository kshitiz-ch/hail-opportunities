import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/graphql_method/graphql_helper.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/ai/models/ai_profile_model.dart';
import 'package:core/modules/ai/resources/ai_repository.dart';
import 'package:core/modules/authentication/models/agent_referral_model.dart';
import 'package:core/modules/common/models/feature_access_model.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/resources/mutual_funds_repo.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:gql_http_link/gql_http_link.dart';
import 'package:graphql/src/core/query_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonController extends GetxController {
  // fix:
  // if allowedSipDays is list & some controller call this list
  // when getSipdays api call is not completed it will return empty list
  final allowedSipDays = RxList<int>();

  NetworkState userMandateState = NetworkState.cancel;
  String? userMandateStatus;

  ApiResponse wealthyAiResponse = ApiResponse();

  List<WealthyAiProfileModel>? wealthyAiProfile;

  String? wealthyAiUrl;
  String? wealthyAiUrlWithQuestion;

  RxBool brandingSectionFlag = true.obs;
  RxBool portfolioReviewSectionFlag = true.obs;

  // Send Tracker Request
  Map<String, String> trackerLinkMap = {};
  ApiResponse sendTrackerRequestResponse = ApiResponse();

  bool get hasWealthyAiAccess {
    return wealthyAiProfile != null;
  }

  bool get hasWealthyAiClientAccess {
    return wealthyAiProfile?.any((element) =>
            element.assistantKey == AIAssistantType.clientAssistant.key) ??
        false;
  }

  bool get hasWealthyAIFAQAccess {
    return wealthyAiProfile?.any((element) =>
            element.assistantKey == AIAssistantType.faqAssistant.key) ??
        false;
  }

  ApiResponse agentReferralResponse = ApiResponse();
  AgentReferralModel? agentReferralModel;

  WealthyAiProfileModel? getAssistantByAssistantKey(String assistantKey) {
    final assistant = wealthyAiProfile?.firstWhere(
      (element) => element.assistantKey == assistantKey,
    );
    return assistant;
  }

  @override
  void onInit() {
    listenToGraphQLError();
    getSipdays();
    getWealthyAiAccessToken();
    getAgentReferralData();

    // Check if the partner branding section is enabled
    checkFeatureAccess(
      FeatureFlag.partnerBrandingSection,
      defaultValue: brandingSectionFlag.value,
    ).then((value) {
      brandingSectionFlag.value = value;
    });

    // Check if the portfolio review section is enabled
    checkFeatureAccess(
      FeatureFlag.portfolioReviewSection,
      defaultValue: portfolioReviewSectionFlag.value,
    ).then((value) {
      portfolioReviewSectionFlag.value = value;
    });

    super.onInit();
  }

  Future<void> getSipdays() async {
    try {
      final data = await StoreRepository().getSipDays();
      if (data['status'] == '200') {
        allowedSipDays.value =
            WealthyCast.toList(data['response']['allowedDays'])
                .map((data) => WealthyCast.toInt(data) ?? 0)
                .toList();
      }
    } catch (error) {
      LogUtil.printLog('getSipdays error => ${error.toString()}');
    } finally {
      update();
    }
  }

  Future<void> getUserMandateStatus({
    int? sipDay,
    double? amount,
    String? taxyId,
  }) async {
    userMandateState = NetworkState.loading;
    update([GetxId.mandate]);

    try {
      String apiKey = await getApiKey() ?? '';
      final data = await MutualFundsRepository().getUserSipData(
        apiKey,
        {
          "sip_day": sipDay,
          "sip_amount": amount,
          "user_id": taxyId,
        },
      );

      if (data['status'] == '200') {
        userMandateStatus = data['response']['message'];
        userMandateState = NetworkState.loaded;
      } else {
        userMandateState = NetworkState.error;
      }
    } catch (error) {
      userMandateState = NetworkState.error;
    } finally {
      update([GetxId.mandate]);
    }
  }

  Future<dynamic> getWealthyAiAccessToken() async {
    wealthyAiResponse.state = NetworkState.loading;
    update([GetxId.search, GetxId.clients]);

    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await AIRepository().getWealthyAiAccessToken(apiKey);

      if (!response.hasException && response.data != null) {
        wealthyAiResponse.state = NetworkState.loaded;
        final data = response.data!['partnerWealthyAiAccessTokens'];
        wealthyAiProfile =
            WealthyAiProfileModel.fromJsonList(List<dynamic>.from(data));
        LogUtil.printLog('wealthyAiProfile: $wealthyAiProfile');
      } else {
        wealthyAiResponse.state = NetworkState.error;
      }
    } catch (error) {
      wealthyAiResponse.state = NetworkState.error;
      LogUtil.printLog('Error getting AI access token: $error');
    } finally {
      update([GetxId.search, GetxId.clients]);
    }
  }

  /// Gets agent communication auth token using GraphQL mutation
  static Future<void> getAgentCommunicationAuthToken() async {
    try {
      String apiKey = await getApiKey() ?? '';

      final response = await AuthenticationRepository()
          .getAgentCommunicationAuthToken(apiKey);

      if (!response.hasException && response.data != null) {
        final userToken = WealthyCast.toStr(
            response.data!['agentCommunicationAuthToken']['userToken']);
        final SharedPreferences sharedPreferences = await prefs;
        await sharedPreferences.setString(
            SharedPreferencesKeys.agentCommunicationToken, userToken ?? '');
      } else {
        LogUtil.printLog(
            'Error getting agent communication auth token: ${response.exception}');
      }
    } catch (error) {
      LogUtil.printLog('Error getting agent communication auth token: $error');
    }
  }

  // to be used in login & register controller
  static void registerDeviceToken({
    required String deviceToken,
    required String loginType,
    String? email,
  }) async {
    try {
      await getAgentCommunicationAuthToken();

      final deviceInfoPlugin = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      String deviceOs = '';
      String deviceVersion = '';
      String appVersion = packageInfo.version;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceOs = 'android';
        deviceVersion = androidInfo.version.release; // e.g., "13"
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceOs = 'ios';
        deviceVersion = iosInfo.systemVersion; // e.g., "16.5"
      }

      final payload = <String, dynamic>{
        'device_token': deviceToken,
        'device_os': deviceOs,
        'device_version': deviceVersion,
        'app_version': appVersion,
        'login_details': {
          if (loginType == 'email' && email.isNotNullOrEmpty) 'email': email,
          'login_type': loginType,
          'login_time': DateTime.now().toIso8601String(),
        },
      };
      final agentCommunicationToken = await getAgentCommunicationToken() ?? '';
      AuthenticationRepository()
          .registerDeviceToken(payload, agentCommunicationToken);
    } catch (e) {
      LogUtil.printLog(e.toString(), tag: 'registerDeviceToken');
    }
  }

  Future<void> getAgentReferralData() async {
    agentReferralResponse.state = NetworkState.loading;
    update(['agent-referral-data']);

    try {
      final apiKey = await getApiKey() ?? '';
      final response = await CommonRepository().getAgentReferralData(apiKey);

      if (response.hasException) {
        agentReferralResponse.state = NetworkState.error;
        if (response.exception.graphqlErrors.length > 0) {
          agentReferralResponse.message =
              response.exception.graphqlErrors[0]?.message;
        }
      } else {
        agentReferralModel = AgentReferralModel.fromJson(
            response.data['hydra']['agent']['agentReferralData']);
        agentReferralResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      agentReferralResponse.state = NetworkState.error;
      agentReferralResponse.message = genericErrorMessage;
    } finally {
      update(['agent-referral-data']);
    }
  }

  /// Sends tracker requests for a list of clients.
  ///
  /// This method is used in:
  ///   - Client tracker screen
  ///   - Client details screen
  ///   - Tracker listing screen
  ///
  /// For each client, an individual API call is made to request a tracker link.
  /// The backend does not support batch requests, so requests are executed in parallel using Future.wait.
  ///
  /// Updates [trackerLinkMap] with the tracker URL for each successful client request.
  /// Updates [sendTrackerRequestResponse] with the overall result and error messages if any requests fail.
  Future<void> sendTrackerRequest(List<Client> clients) async {
    try {
      final apiKey = await getApiKey();
      sendTrackerRequestResponse.state = NetworkState.loading;
      trackerLinkMap.clear();
      update(['tracker']);

      final selectedClientIds =
          clients.map((Client client) => client.taxyID.toString()).toList();

      // NOTE: Backend doesn't support batch requests with multiple customer_ids
      // We need to make individual API calls for each customer ID
      // Using parallel execution with Future.wait() to minimize total time
      List<Future<dynamic>> trackerRequests = selectedClientIds
          .map(
            (customerId) => StoreRepository().sendTrackerRequest(
              {
                "customer_ids": [customerId] // Single customer per request
              },
              apiKey!,
            ),
          )
          .toList();

      // Wait for all API calls to complete
      List<dynamic> responses = await Future.wait(trackerRequests);

      // Process responses
      List<dynamic> successfulResponses = [];
      List<String> errorMessages = [];

      for (int i = 0; i < responses.length; i++) {
        var response = responses[i];
        if (response['status'] == '200') {
          trackerLinkMap[selectedClientIds[i]] =
              WealthyCast.toStr(response['response']['customer_url']) ?? '';
          successfulResponses.add(response['response']);
        } else {
          errorMessages.add(
              'Client ${selectedClientIds[i]}: ${getErrorMessageFromResponse(response)}');
        }
      }

      if (successfulResponses.isNotEmpty) {
        if (errorMessages.isEmpty) {
          sendTrackerRequestResponse.state = NetworkState.loaded;
        } else {
          // Partial success
          sendTrackerRequestResponse.state = NetworkState.loaded;
          sendTrackerRequestResponse.message =
              'Some requests failed: ${errorMessages.join(', ')}';
        }
      } else {
        sendTrackerRequestResponse.message =
            'All requests failed: ${errorMessages.join(', ')}';
        sendTrackerRequestResponse.state = NetworkState.error;
      }
    } catch (error) {
      sendTrackerRequestResponse.message =
          handleApiError(error) ?? genericErrorMessage;
      sendTrackerRequestResponse.state = NetworkState.error;
    } finally {
      update(['tracker']);
    }
  }

  void listenToGraphQLError() {
    try {
      GraphQLHelper.graphQLErrorStream.listen((graphqlException) {
        if (graphqlException.linkException is HttpLinkServerException) {
          final exception =
              (graphqlException.linkException as HttpLinkServerException);
          final errorJson =
              jsonDecode(exception.parsedResponse?.response['message']);
          final isUnauthorizedError = errorJson['error_code'] == 'AUTH002';
          if (isUnauthorizedError) {
            AuthenticationBlocController()
                .authenticationBloc
                .add(UserLogOut(showLogoutMessage: true));
          }
        }
      });
    } catch (e) {}
  }

  /// Checks if a feature flag is enabled for the current user
  /// Returns a boolean value: true if the feature is enabled, false otherwise
  /// In case of any errors or issues, it returns the defaultValue provided (false if not specified)
  Future<bool> checkFeatureAccess(
    String featureName, {
    Map<String, dynamic> customData = const {},
    bool defaultValue = false,
  }) async {
    try {
      final agentId = await getAgentId();
      if (agentId == null) {
        LogUtil.printLog('checkFeatureAccess: agentId is null');
        return defaultValue; // Return provided default value when agent ID is not available
      }

      final response = await CommonRepository().checkFeatureAccess(
        featureName,
        agentId.toString(),
        customData,
      );

      if (response != null && response['status'] == '200') {
        // Parse the response using the model
        final featureAccess = FeatureAccessModel.fromJson(response['response']);

        // Return the boolean value directly
        return featureAccess.failed ? defaultValue : featureAccess.value;
      }

      LogUtil.printLog(
          'checkFeatureAccess: Invalid response structure or status');
      return defaultValue; // Return provided default value for invalid responses
    } catch (e) {
      LogUtil.printLog(
          'checkFeatureAccess controller error ==> ${e.toString()}');
      return defaultValue; // Return provided default value on exceptions
    }
  }
}
