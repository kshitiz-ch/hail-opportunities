import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';

class CommonAPI {
  // Used in Client & Store
  static getAccountDetails(String apiKey, String userId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.accountDetails(userId);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // Used in Client & Store
  static createBankAccount(
    String apiKey,
    Map body,
    String userId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler githubRepository =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await githubRepository.createBankAccount(body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // Used in Client & Store
  static updateBankAccount(
    String apiKey,
    Map body,
    String userId,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler githubRepository =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await githubRepository.updateBankAccount(body);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  // Used in Proposal & Store
  static updateProposalData(
      String apiKey, String proposalId, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final response = await RestApiHandlerData.putData(
        '${ApiConstants().getRestApiUrl('proposals')}$proposalId/',
        body,
        headers);
    return response;
  }

  // Used in Proposal & Store
  static getProposalUrl(String apiKey, dynamic body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['content-type'] = "application/json";
    final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('proposals')}create-generic-proposal/',
        body,
        headers);
    return response;
  }

  static trackNotification(dynamic url) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.getData(url, headers);

    return response;
  }

  static getProductVideos(String product) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      String queryParams = '';
      if (product.isNotEmpty) {
        queryParams = '?product=$product';
      }

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/product-videos$queryParams',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getDataUpdatedAt(String content) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      String queryParams = '';
      if (content.isNotEmpty) {
        queryParams = '?content=$content';
      }

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/data-updated$queryParams',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getSchemeCodeMapping() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          'https://feeder-metadata.wealthy.workers.dev/meta-data/?datatype=schemecode',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getDematAccounts(String userId, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getDematAccounts();

      return response;
    } catch (e) {
      LogUtil.printLog('getDematAccounts error ==>${e.toString()}');
    }
  }

  static createDematAccount(String userId, Map body, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    headers['x-w-client-id'] = userId;
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.createDematAccount(body);

      return response;
    } catch (e) {
      LogUtil.printLog('createDematAccount error ==>${e.toString()}');
    }
  }

  static getSipDays() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final url = '${ApiConstants().advisorWorkerBaseUrl}/sip';
      final response = await RestApiHandlerData.getData(url, headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static auditDematConsent(String apiKey, Map<String, dynamic> payload) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = "application/json";
      final url = ApiConstants().getRestApiUrl('audit-demat-consent');
      final response = await RestApiHandlerData.postData(
        url,
        jsonEncode(payload),
        headers,
      );

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAddressFromPin(String pin) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(null);

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().getRestApiUrl('postal')}${pin}', headers);
      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  static universalSearch(
      String apiKey, Map<String, String> queryParamMap) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    String apiUrl = ApiConstants().getRestApiUrl('scout-search');
    String queryParam = Uri(queryParameters: queryParamMap).query;
    queryParam = '?$queryParam';
    apiUrl += queryParam;

    final response = await RestApiHandlerData.getData(
      apiUrl,
      headers,
    );
    return response;
  }

  static getAgentReferralData(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlHandler.getAgentReferralData();
      return response;
    } catch (e) {
      LogUtil.printLog('getAgentReferralData error ==> ${e.toString()}');
    }
  }

  /// Checks if a feature flag is enabled for a specific user/agent
  /// Configuration YAML: https://github.com/wealthy/feature-flags/blob/master/dev/partner_app_features.yaml
  /// Yaml online editor : https://gofeatureflag.org/editor
  ///
  /// Example Usage:
  /// ```dart
  /// // Check if 'partner-microsite-section' feature is enabled for agent
  /// final result = await CommonAPI.checkFeatureAccess(
  ///   'partner-microsite-section',
  ///   'user-123',
  ///   {'agent_external_id': 'ag_aQr9cRgD6dgPXhzxX6K8KD'}
  /// );
  ///
  /// // Sample response: {"value": true}
  ///
  /// // The feature flag configuration for this example is:
  /// // partner-microsite-section:
  /// //   variations:
  /// //     enabled: true
  /// //     disabled: false
  /// //   targeting:
  /// //     - name: External Ids of Agent
  /// //       query: agent_external_id in ["ag_aQr9cRgD6dgPXhzxX6K8KD","ag_aQr9cRgD6dgPXhzxX6K8KF"]
  /// //       variation: enabled
  /// //   defaultRule:
  /// //     variation: disabled
  /// ```
  static checkFeatureAccess(
    String featureName,
    String agentId,
    Map<String, dynamic> customData,
  ) async {
    try {
      // API key for accessing the feature flag service always fixed
      // TODO:
      // This key should be kept secure and not exposed in client-side code
      const apiKey =
          'Bearer ffkoZVcJeENy6ZvFAZxgoQ0BTTrVwvNzGCU7z69jDsoeN7cQCxQy5sCzWVgyKe05';
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = "application/json";

      final apiUrl =
          'https://featureflag.wealthy.in/v1/feature/$featureName/eval';

      // Prepare payload according to required format
      final Map<String, dynamic> payload = {
        "user": {"key": agentId, "custom": customData}
      };

      final response = await RestApiHandlerData.postData(
        apiUrl,
        json.encode(payload),
        headers,
      );
      return response;
    } catch (e) {
      LogUtil.printLog('checkFeatureAccess error ==> ${e.toString()}');
    }
  }
}
