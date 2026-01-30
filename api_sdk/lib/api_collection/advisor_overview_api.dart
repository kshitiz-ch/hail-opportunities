import 'dart:convert';

import 'package:api_sdk/api_constants.dart';
import 'package:api_sdk/graphql_method/graphql_handler.dart';
import 'package:api_sdk/log_util.dart';
import 'package:api_sdk/main.dart';
import 'package:api_sdk/rest/rest_api_handler_data.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

class AdvisorOverviewAPI {
  static getAdvisorOverview(int year, int month, String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.advisorOverview(month, year);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerAumOverview(String apiKey,
      {String agentExternalId = '',
      List<String> agentExternalIdList = const []}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getPartnerAumOverview(
          agentExternalId, agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getPartnerAumAggregate(String apiKey,
      {String agentExternalId = '',
      List<String> agentExternalIdList = const []}) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getPartnerAumAggregate(
          agentExternalId, agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentDesignation(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getAgentDesignation();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getRevenueData(
      {String? apiKey, int? agentId, int? month, int? year}) async {
    try {
      String queryParams =
          "year=$year&month=$month&limit=500&offset=0&sort_by=client_email&search=";

      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().getRestApiUrl('revenue-book')}?$queryParams',
          headers);
      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  static verifyGst(String apiKey, Map<String, dynamic> payload) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = 'application/json';

      final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('gst')}verify/',
        jsonEncode(payload),
        headers,
      );

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  static saveGst(String apiKey, Map<String, dynamic> payload) async {
    try {
      dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
      headers['content-type'] = 'application/json';

      final response = await RestApiHandlerData.postData(
        '${ApiConstants().getRestApiUrl('gst')}',
        jsonEncode(payload),
        headers,
      );

      return response;
    } catch (error) {
      LogUtil.printLog(error.toString());
    }
  }

  static updatePartnerDetails(
    String apiKey,
    String updateField,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final GraphqlQlHandler githubRepository =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await githubRepository.updatePartnerDetails(updateField);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getActiveSipCount(
      String apiKey, List<String> agentExternalIdList) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response =
          await graphqlQlHandler.getActiveSipCount(agentExternalIdList);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentSegment(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getAgentSegment();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static initiateKyc(String apiKey, String pan, String email,
      bool isAadharLinked, String dob, String panUsageType) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      LogUtil.printLog('object=> $apiKey, $headers , $pan');
      final response = await graphqlHandler.initiateKyc(
        pan,
        email,
        isAadharLinked,
        dob,
        panUsageType,
      );
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static checkPartnerARN(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.checkPartnerARN();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static attachEUIN(
    String apiKey,
    String externalId,
    String euin,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    try {
      final GraphqlQlHandler githubRepository =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await githubRepository.attachEUIN(externalId, euin);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAdvisorContent() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/advisor-content', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getDashboardContent() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/app-dashboard-content',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAdvisorVideos(String? playlistId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      String queryParams = '';
      if (playlistId != null && playlistId.isNotEmpty) {
        queryParams = '?playlist=$playlistId';
      }

      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/advisor-videos$queryParams',
          headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getStories() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/advisor-stories', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getHomeProducts() async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);
    try {
      final response = await RestApiHandlerData.getData(
          '${ApiConstants().advisorWorkerBaseUrl}/explore-products', headers);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static searchPartnerArn(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.searchPartnerArn();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentEmpanelmentDetails(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getAgentEmpanelmentDetails();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getAgentEmpanelmentAddress(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    print(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.getAgentEmpanelmentAddress();
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  static payEmpanelmentFee(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.payEmpanelmentFee();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static storeEmpanelmentAddress(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlQlHandler.storeEmpanelmentAddress(payload);
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static validateEmpanelment(
      String apiKey, Map<String, dynamic> payload) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl = ApiConstants().paymentCollectorUrl;

    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
      apiUrl,
      jsonEncode(payload),
      headers,
    );

    return response;
  }

  static triggerDigioWebhook(body) async {
    dynamic headers = await ApiSdk.getHeaderInfo(null);

    headers['content-type'] = 'application/json';
    final response = await RestApiHandlerData.postData(
        ApiConstants().getRestApiUrl('digio-webhook'),
        jsonEncode(body),
        headers);

    return response;
  }

  static getVisitingCardBrochure(
      String apiKey, String agentExternalId, String templateName) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    String apiUrl =
        '${ApiConstants().getRestApiUrl('visiting-card-brochure')}?agent_id=$agentExternalId&template_name=$templateName';

    final response =
        await RestApiHandlerData.getData(apiUrl, headers, isPdf: true);

    return response;
  }

  static deletePartnerRequest(
    String apiKey,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    try {
      final GraphqlQlHandler graphqlQlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));
      final response = await graphqlQlHandler.deletePartner();
      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static getDeletePartnerDetails(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response = await graphqlHandler.getDeleteDetails();

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static cancelDeletePartnerRequest(String apiKey, String externalId) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);

    try {
      final GraphqlQlHandler graphqlHandler =
          GraphqlQlHandler(client: ApiConstants().client(apiKey, headers));

      final response =
          await graphqlHandler.cancelDeletePartnerRequest(externalId);

      return response;
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  static initiateKycSubFlow(
    String apiKey,
    String subFlowType,
  ) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final url = ApiConstants().getRestApiUrl('kyc-sub-flow');
    headers['content-type'] = 'application/json';

    final response = await RestApiHandlerData.postData(
      url,
      jsonEncode({'sub_flow': subFlowType}),
      headers,
    );

    return response;
  }

  static getProfilePhoto(String apiKey) async {
    dynamic headers = await ApiSdk.getHeaderInfo(apiKey);
    final apiUrl = '${ApiConstants().getRestApiUrl('agent-profile-photo')}';
    headers['Content-Type'] = 'application/json';

    final response = await RestApiHandlerData.getData(apiUrl, headers);

    return response;
  }

  static uploadProfilePhoto(String apiKey, String filePath) async {
    Map headers = await ApiSdk.getHeaderInfo(apiKey);
    final apiUrl =
        '${ApiConstants().getRestApiUrl('agent-profile-photo')}upload/';

    FormData formData = FormData.fromMap(
      {
        'profile_photo': await MultipartFile.fromFile(
          filePath,
          filename: 'profile_photo.png',
          contentType: MediaType('image', 'png'),
        ),
      },
    );

    final response =
        await RestApiHandlerData.postData(apiUrl, formData, headers);

    return response;
  }
}
