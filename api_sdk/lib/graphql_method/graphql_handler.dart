import 'dart:async';

import 'package:api_sdk/graphql_method/graphql_helper.dart';
import 'package:api_sdk/graphql_method/graphql_operations/mutations/add_client.dart'
    as mutations;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/advisor.dart'
    as advisorMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/broking.dart'
    as brokingMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/client.dart'
    as clientMutations;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/create_demat_account.dart'
    as dematMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/delete_partner_mutation.dart'
    as deletePartnerMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/family_members.dart'
    as familyMembersMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/goal.dart'
    as goalMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/initiate_kyc.dart'
    as initiateKycMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/my_team.dart'
    as myTeamMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/partner_arn_selection.dart'
    as partnerARNSelection;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/quick_actions.dart'
    as quickActionMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/reports.dart'
    as createReportMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/search_partner_arn.dart'
    as partnerArnMutation;
import 'package:api_sdk/graphql_method/graphql_operations/mutations/update_partner.dart'
    as updatePartner;
import 'package:api_sdk/graphql_method/graphql_operations/queries/advisor.dart'
    as advisor;
import 'package:api_sdk/graphql_method/graphql_operations/queries/agent_details.dart'
    as agent;
import 'package:api_sdk/graphql_method/graphql_operations/queries/broking.dart'
    as brokingQueries;
import 'package:api_sdk/graphql_method/graphql_operations/queries/chart_data.dart'
    as chartData;
import 'package:api_sdk/graphql_method/graphql_operations/queries/client.dart'
    as clients;
import 'package:api_sdk/graphql_method/graphql_operations/queries/client_investments.dart'
    as clientInvestments;
import 'package:api_sdk/graphql_method/graphql_operations/queries/client_tracker_queries.dart'
    as clientTrackerQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/delete_partner.dart'
    as deletePartnerQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/demat_accounts.dart'
    as dematQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/family_members.dart'
    as familyMemebers;
import 'package:api_sdk/graphql_method/graphql_operations/queries/fetch_portfolio.dart'
    as fetchPortfolioQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/goal.dart'
    as goal;
import 'package:api_sdk/graphql_method/graphql_operations/queries/mutual_funds.dart'
    as mutualFundsQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/my_business.dart'
    as myBusiness;
import 'package:api_sdk/graphql_method/graphql_operations/queries/my_team.dart'
    as myTeamQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/partner_arn.dart'
    as partnerARN;
import 'package:api_sdk/graphql_method/graphql_operations/queries/partner_transaction_queries.dart'
    as partnerTransactionQueries;
import 'package:api_sdk/graphql_method/graphql_operations/queries/proposal_count.dart'
    as proposalCountQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/quick_actions.dart'
    as quickActionQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/report_template.dart'
    as reportTemplateQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/reports.dart'
    as reportQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/revenue_sheet.dart'
    as revenueSheetQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/scheme_metas.dart'
    as schemeMetas;
import 'package:api_sdk/graphql_method/graphql_operations/queries/service_request.dart'
    as serviceRequestQuery;
import 'package:api_sdk/graphql_method/graphql_operations/queries/sip_queries.dart'
    as sipQueries;
import 'package:api_sdk/graphql_method/graphql_operations/queries/ticob.dart'
    as ticob;
import 'package:api_sdk/graphql_method/graphql_operations/queries/tracker_value.dart'
    as trackerValue;
import 'package:api_sdk/log_util.dart';
import 'package:graphql/client.dart';

import '../api_constants.dart';
import 'graphql_operations/queries/client.dart';
import 'graphql_operations/queries/wealthy_ai.dart' as wealthyAi;

class GraphqlQlHandler {
  final GraphQLClient client;
  late GraphQLHelper graphQLHelper;
  GraphqlQlHandler({required this.client}) {
    graphQLHelper = GraphQLHelper(client);
  }

  Future<QueryResult> getClientList(
      String agentId, bool isPrivileged, bool recentLeads, String? query,
      {limit = 20, offset = 0, requestAgentId = ''}) async {
    return await graphQLHelper.query(
      queryString: clients.clientList,
      queryName: 'getClientList',
      variables: <String, dynamic>{
        'recentLeads': recentLeads,
        'q': query,
        'limit': limit,
        'offset': offset,
        'requestAgentId': requestAgentId
      },
    );
  }

  Future<QueryResult> getAgentReport(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: advisor.agentReports,
      queryName: 'getAgentReport',
      variables: payload,
    );
  }

  Future<QueryResult> getAgentReportTemplates() async {
    return await graphQLHelper.query(
      queryString: advisor.agentReportTemplates,
      queryName: 'getAgentReportTemplates',
    );
  }

  Future<QueryResult> createAgentReport(Map<String, dynamic> variables) async {
    LogUtil.printLog('getAgentReports payload ==> ${variables}');
    return await graphQLHelper.query(
      queryString: advisorMutation.createAgentReport,
      queryName: 'getAgentReports',
      variables: variables,
    );
  }

  Future<QueryResult> refreshAgentReportLink(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (advisorMutation.refreshAgentReportLink),
      variables: payload,
      mutationName: 'refreshAgentReportLink',
    );
  }

  Future<QueryResult> getClientLoginDetails(String? userId) async {
    return await graphQLHelper.query(
      queryString: clients.clientLoginDetails,
      queryName: 'getClientLoginDetails',
      variables: <String, dynamic>{
        'userId': userId,
      },
    );
  }

  Future<QueryResult> getProductInvestmentDetails(
      ClientInvestmentProductType type, bool showZeroFolios) async {
    String graphqlQuery = getQuery(type);
    return await graphQLHelper.query(
      queryString: graphqlQuery,
      queryName: 'getClientInvestmentDetailsv2',
      variables: <String, dynamic>{
        "filter": {
          if (type == ClientInvestmentProductType.mutualFunds)
            "fetchZeroGoals": showZeroFolios
          else
            "fetchZeroSchemes": showZeroFolios,
          if (type == ClientInvestmentProductType.mutualFunds)
            "fetchFundDetails": true
        }
      },
    );
  }

  Future<QueryResult> getUserPortfolioOverview(String memberUserId) async {
    return await graphQLHelper.query(
      queryString: clients.userPortfolioOverview,
      queryName: 'getUserPortfolioOverview',
      variables: <String, dynamic>{
        "memberUserId": memberUserId,
      },
    );
  }

  Future<QueryResult> deleteClient(String clientId) async {
    return await graphQLHelper.query(
      queryString: clients.deleteClient,
      queryName: 'deleteClient',
      variables: <String, dynamic>{
        'clientId': clientId,
      },
    );
  }

  Future<QueryResult> getClientsCount() async {
    return await graphQLHelper.query(
      queryString: clients.clientsCount,
      queryName: 'getClientsCount',
    );
  }

  Future<QueryResult> getEmployeesClientCount(String agentExternalId) async {
    return await graphQLHelper.query(
      queryString: clients.employeesClientCount,
      queryName: 'getEmployeesClientCount',
      variables: <String, dynamic>{'agentExternalId': agentExternalId},
    );
  }

  Future<QueryResult> getClientDetails({
    String? clientId,
    int? agentId,
  }) async {
    return await graphQLHelper.query(
      queryString: clients.clientDetails,
      queryName: 'getClientDetails',
      variables: <String, dynamic>{'id': clientId},
    );
  }

  Future<QueryResult> getClientDetailsByTaxyId(String? clientId) async {
    return await graphQLHelper.query(
      queryString: clients.clientDetailsByTaxyId,
      queryName: 'getClientDetailsByTaxyId',
      variables: <String, dynamic>{'userId': clientId},
    );
  }

  Future<QueryResult> getClientInvestments(String userId) async {
    return await graphQLHelper.query(
      queryString: (clientInvestments.clientInvestments),
      queryName: 'getClientInvestments',
      variables: <String, dynamic>{'userId': userId},
    );
  }

  Future<QueryResult> getClientMfTransactions(String userId,
      {String? goalId, int limit = 20, int offset = 0}) async {
    return await graphQLHelper.query(
      queryString: (clientInvestments.mfTransactions),
      queryName: 'getClientMfTransactions',
      variables: <String, dynamic>{
        'userId': userId,
        'limit': limit,
        'offset': offset,
        'goalId': goalId ?? '',
        'status': "1,2,3,4"
      },
    );
  }

  Future<QueryResult> getClientTrackerValue(String userId) async {
    return await graphQLHelper.query(
      queryString: (trackerValue.trackerValue),
      queryName: 'getClientTrackerValue',
      variables: <String, dynamic>{'userId': userId},
    );
  }

  Future<QueryResult> advisorOverview(int month, int year) async {
    return await graphQLHelper.query(
      queryString: (advisor.advisorOverview),
      queryName: 'advisorOverview',
      // variables: <String, dynamic>{'month': month, 'year': year},
    );
  }

  Future<QueryResult> getPartnerAumOverview(
      String agentExternalId, List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.aumOverview),
      queryName: 'getPartnerAumOverview',
      variables: <String, dynamic>{
        'userId': "",
        'agentExternalId': agentExternalId,
        'agentExternalIdList': agentExternalIdList,
        'months': 6,
        'includeCurrentMonth': true
      },
    );
  }

  Future<QueryResult> getPartnerAumAggregate(
      String agentExternalId, List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.aumAggregate),
      queryName: 'getPartnerAumAggregate',
      variables: <String, dynamic>{
        'userId': "",
        'agentExternalId': agentExternalId,
        'agentExternalIdList': agentExternalIdList,
        'months': 6,
        'includeCurrentMonth': true
      },
    );
  }

  Future<QueryResult> getWealthyAiUrl(String? question) async {
    return await graphQLHelper.query(
      queryString: wealthyAi.wealthyAiUrl,
      queryName: 'wealthyAiUrl',
      variables: {
        'question': question ?? '',
      },
      enableRetry: false,
    );
  }

  Future<QueryResult> getWealthyAiAccessToken() async {
    return await graphQLHelper.query(
      queryString: wealthyAi.getWealthyAiAccessToken,
      queryName: 'getWealthyAiAccessToken',
      enableRetry: false,
    );
  }

  Future<QueryResult> getAgentDesignation() async {
    return await graphQLHelper.query(
      queryString: (advisor.agentDesignation),
      queryName: 'getAgentDesignation',
    );
  }

  Future<QueryResult> getSipMetrics(List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.sipMetrics),
      queryName: 'getSipMetrics',
      variables: <String, dynamic>{
        'agentExternalIdList': agentExternalIdList,
      },
    );
  }

  Future<QueryResult> getPayouts({bool isBrokingPayout = false}) async {
    return await graphQLHelper.query(
      queryString: isBrokingPayout ? advisor.brokingPayouts : advisor.payouts,
      queryName: 'getPayouts',
      variables: <String, dynamic>{},
    );
  }

  Future<QueryResult> getPayoutProductBreakup(
    String payoutId, {
    bool isBrokingPayout = false,
  }) async {
    return await graphQLHelper.query(
      queryString: isBrokingPayout
          ? advisor.brokingPayoutBreakup
          : advisor.payoutProductBreakup,
      queryName: 'getPayoutProductBreakup',
      variables: <String, dynamic>{'payoutId': payoutId},
    );
  }

  Future<QueryResult> getSipGraphData(List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.sipGraphData),
      queryName: 'getSipGraphData',
      variables: <String, dynamic>{
        'agentExternalIdList': agentExternalIdList,
      },
    );
  }

  Future<QueryResult> getDailySipCount(List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.sipDayWiseActiveCount),
      queryName: 'getDailySipCount',
      variables: <String, dynamic>{
        'agentExternalIdList': agentExternalIdList,
      },
    );
  }

  Future<QueryResult> getSipUserData({
    required List<String> agentExternalIdList,
    int limit = 20,
    int offset = 0,
    List<String>? userIds,
    bool useSipDataV2Api = false,
    required Map<String, dynamic> filters,
  }) async {
    final variables = <String, dynamic>{
      'userIds': userIds ?? [],
      'agentExternalIdList': agentExternalIdList,
      'offset': offset,
      'limit': limit,
      ...filters
    };
    LogUtil.printLog('sipUserData payload ===> ' + variables.toString());

    return await graphQLHelper.query(
      queryString: (useSipDataV2Api ? advisor.sipDataV2 : advisor.sipUserData),
      queryName: 'getSipUserData',
      variables: variables,
    );
  }

  Future<QueryResult> getOfflineSipData(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: advisor.offlineSipList,
      queryName: 'getOfflineSipData',
      variables: payload,
    );
  }

  Future<QueryResult> getAgentSegment() async {
    return await graphQLHelper.query(
      queryString: (agent.agentDetails),
      queryName: 'getAgentSegment',
    );
  }

  Future<QueryResult> getProposalCount(userId) async {
    return await graphQLHelper.query(
      queryString: (proposalCountQuery.proposalCount),
      queryName: 'getProposalCount',
      variables: <String, dynamic>{'userId': userId},
    );
  }

  Future<QueryResult> getActiveSipCount(
      List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: (advisor.activeSipCount),
      queryName: 'getActiveSipCount',
      variables: <String, dynamic>{
        'agentExternalIdList': agentExternalIdList,
      },
    );
  }

  Future<QueryResult> getDematAccounts() async {
    return await graphQLHelper.query(
      queryString: (dematQuery.dematAccounts),
      queryName: 'getDematAccounts',
    );
  }

  Future<QueryResult> mutualFunds(int subType) async {
    return await graphQLHelper.query(
      queryString: (mutualFundsQuery.mutualFunds),
      queryName: 'mutualFunds',
      variables: <String, dynamic>{'subtype': subType},
    );
  }

  Future<QueryResult> getSchemeOrderStatus(
      {required String userId, required String proposalId}) async {
    return await graphQLHelper.query(
      queryString: (mutualFundsQuery.schemeOrderStatus),
      queryName: 'getSchemeOrderStatus',
      variables: <String, dynamic>{'proposalId': proposalId, 'userId': userId},
    );
  }

  Future<QueryResult> accountDetails(String userID) async {
    return await graphQLHelper.query(
      queryString: clients.accountDetails,
      queryName: 'accountDetails',
      variables: <String, dynamic>{'userId': userID},
    );
  }

  Future<QueryResult> getClientProfileDetails(String userID) async {
    return await graphQLHelper.query(
      queryString: clients.mfProfileDetails,
      queryName: 'clientProfileDetails',
      variables: <String, dynamic>{'userId': userID},
    );
  }

  Future<QueryResult> getClientMandates({
    required String userId,
    String sipMetaExternalId = '',
    bool fetchConfirmedOnly = false,
  }) async {
    return await graphQLHelper.query(
      queryString: clients.userMandates,
      queryName: 'getClientMandates',
      variables: <String, dynamic>{
        'userId': userId,
        'sipMetaExternalId': sipMetaExternalId,
        'fetchConfirmedOnly': fetchConfirmedOnly,
      },
    );
  }

  Future<QueryResult> getAgentEmpanelmentDetails() async {
    return await graphQLHelper.query(
        queryString: advisor.agentEmpanelment,
        queryName: 'getAgentEmpanelmentDetails');
  }

  Future<QueryResult> getAgentEmpanelmentAddress() async {
    return await graphQLHelper.query(
        queryString: advisor.empanelmentAddress,
        queryName: 'getAgentEmpanelmentAddress');
  }

  Future<QueryResult> getPartnerNominee() async {
    return await graphQLHelper.query(
      queryString: advisor.partnerNominee,
      queryName: 'getPartnerNominee',
    );
  }

  Future<QueryResult> createPartnerNominee(
    String agentId,
    Map<String, dynamic> payload,
  ) async {
    return await graphQLHelper.mutate(
      mutationString: (advisorMutation.createPartnerNominee),
      mutationName: 'createPartnerNominee',
      variables: <String, dynamic>{
        'agentId': agentId,
        'input': [payload],
      },
    );
  }

  Future<QueryResult> changePartnerDisplayName(
      String agentId, String displayName) async {
    return await graphQLHelper.mutate(
      mutationString: advisorMutation.changeDisplayName,
      mutationName: 'changePartnerDisplayName',
      variables: <String, dynamic>{
        'agentId': agentId,
        'displayName': displayName,
      },
    );
  }

  Future<QueryResult> getAgentReferralData() async {
    return await graphQLHelper.query(
      queryString: advisor.agentReferralData,
      queryName: 'agentReferralData',
    );
  }

  Future<QueryResult> changeReferralCode(
      String agentId, String referralCode) async {
    return await graphQLHelper.mutate(
      mutationString: advisorMutation.changeReferralCode,
      mutationName: 'changeReferralCode',
      variables: <String, dynamic>{
        'agentId': agentId,
        'referralCode': referralCode,
      },
    );
  }

  Future<QueryResult> addClient(
    String email,
    bool isEmailUnknown,
    String name,
    String phoneNumber,
    String source,
  ) async {
    return await graphQLHelper.mutate(
      mutationString: (mutations.createAgentClient),
      mutationName: 'addClient',
      variables: <String, dynamic>{
        'email': email,
        'isEmailUnknown': isEmailUnknown,
        'name': name,
        'phoneNumber': phoneNumber,
        'source': source
      },
    );
  }

  Future<QueryResult> storeEmpanelmentAddress(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (advisorMutation.storeEmpanelmentAddress),
      mutationName: 'storeEmpanelmentAddress',
      variables: <String, dynamic>{'input': payload},
    );
  }

  Future<QueryResult> payEmpanelmentFee() async {
    return await graphQLHelper.mutate(
      mutationString: (advisorMutation.payEmpanelmentFee),
      mutationName: 'payEmpanelmentFee',
    );
  }

  Future<QueryResult> updatePartnerDetails(String updateField) async {
    return await graphQLHelper.mutate(
      mutationString: (updatePartner.createPartnerUpdateRequest),
      mutationName: 'updatePartnerDetails',
      variables: <String, dynamic>{'updateField': updateField},
    );
  }

  Future<QueryResult> createDematAccount(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (dematMutation.createDematAccount),
      mutationName: 'createDematAccount',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> editDematAccount(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (dematMutation.editDematAccount),
      mutationName: 'editDematAccount',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> searchPartnerArn() async {
    return await graphQLHelper.mutate(
      mutationString: (partnerArnMutation.searchPartnerArn),
      mutationName: 'searchPartnerArn',
    );
  }

  Future<QueryResult> initiateKyc(String pan, String email, bool isAadharLinked,
      String dob, String panUsageType) async {
    return await graphQLHelper.mutate(
      mutationString: (initiateKycMutation.initiateKyc),
      mutationName: 'initiateKyc',
      variables: <String, dynamic>{
        'input': {
          'panNumber': pan,
          'email': email,
          // 'aadhaarLinked': isAadharLinked,
          'aadhaarLinked': false,
          'version': 'v1',
          'dob': dob,
          'panUsageType': panUsageType
        }
      },
    );
  }

  Future<QueryResult> attachEUIN(String externaId, String euin) async {
    return await graphQLHelper.mutate(
      mutationString: (partnerARNSelection.partnerArnSelection),
      mutationName: 'attachEUIN',
      variables: <String, dynamic>{'externalId': externaId, 'euin': euin},
    );
  }

  Future<QueryResult> createBankAccount(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.createBankAccount),
      mutationName: 'createBankAccount',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> updateBankAccount(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.updateBankAccount),
      mutationName: 'updateBankAccount',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> fetchClientPortfolio(
      String userId, String category) async {
    return await graphQLHelper.query(
      queryString: (fetchPortfolioQuery.fetchPortfolio),
      queryName: 'fetchClientPortfolio',
      variables: <String, dynamic>{'userId': userId, 'category': category},
    );
  }

  Future<QueryResult> fetchGoalSubtype(String userId, String goalId) async {
    return await graphQLHelper.query(
      queryString: (fetchPortfolioQuery.fetchGoalSubtype),
      queryName: 'fetchGoalSubtype',
      variables: <String, dynamic>{'userId': userId, 'goalId': goalId},
    );
  }

  Future<QueryResult> getClientCustomGoalFunds(
      String userId, String goalId) async {
    return await graphQLHelper.query(
      queryString: (goal.customGoalFunds),
      queryName: 'getClientCustomGoalFunds',
      variables: <String, dynamic>{'userId': userId, 'goalId': goalId},
    );
  }

  Future<QueryResult> fetchClientGoalAllocations(
      String userId, String goalId, String? wschemecode) async {
    return await graphQLHelper.query(
      queryString: (goal.goalAllocation),
      queryName: 'fetchClientGoalAllocations',
      variables: <String, dynamic>{
        'userId': userId,
        'goalId': goalId,
        'wschemecode': wschemecode ?? ''
      },
    );
  }

  Future<QueryResult> getGoalSchemesv2(
      String goalId, String? wschemecode) async {
    return await graphQLHelper.query(
      queryString: (goal.getGoalSchemesV2),
      queryName: 'getGoalSchemesv2',
      variables: <String, dynamic>{
        'goalIds': [goalId],
        'fetchFundDetails': true,
        if (wschemecode == null || wschemecode.isEmpty)
          'wschemecode': null
        else
          'wschemecode': [wschemecode]
      },
    );
  }

  Future<QueryResult> getSchemeData(String wsSchemeCodes) async {
    return await graphQLHelper.query(
      queryString: (schemeMetas.schemeMetas),
      queryName: 'storeFundAllocation',
      variables: <String, dynamic>{
        'wSchemeCodes': wsSchemeCodes,
      },
    );
  }

  Future<QueryResult> getSchemeExitLoadDetails(String wsSchemeCodes) async {
    return await graphQLHelper.query(
      queryString: (schemeMetas.schemeExitLoadDetails),
      queryName: 'exitLoadDetails',
      variables: <String, dynamic>{
        'wSchemeCodes': wsSchemeCodes,
      },
    );
  }

  Future<QueryResult> getGoalDetails(
      {required String userId, required String goalId}) async {
    return await graphQLHelper.query(
      queryString: (goal.goalDetails),
      queryName: 'getGoalDetails',
      variables: <String, dynamic>{'goalId': goalId, 'userId': userId},
    );
  }

  Future<QueryResult> getGoalSummary(
      {required String userId, required String goalId}) async {
    return await graphQLHelper.query(
      queryString: (goal.goalSummary),
      queryName: 'getGoalDetails',
      variables: <String, dynamic>{'goalId': goalId, 'userId': userId},
    );
  }

  Future<QueryResult> getGoalOrderCounts(
      {required String userId,
      required String goalId,
      String? wschemecode}) async {
    return await graphQLHelper.query(
      queryString: (goal.goalOrderCounts),
      queryName: 'getGoalDetails',
      variables: <String, dynamic>{
        'goalId': goalId,
        'userId': userId,
        'status': "1,2,3,4",
        'wschemecode': wschemecode ?? ''
      },
    );
  }

  Future<QueryResult> checkPartnerARN() async {
    return await graphQLHelper.query(
      queryString: (partnerARN.partnerARN),
      queryName: 'checkPartnerARN',
      variables: <String, dynamic>{},
    );
  }

  Future<QueryResult> getMfChartData(String wSchemeCode, int years,
      {String? navType}) async {
    return await graphQLHelper.query(
      queryString: (chartData.chartData),
      queryName: 'getMfChartData',
      variables: <String, dynamic>{
        'wSchemeCode': wSchemeCode,
        'years': years,
        'navType': navType ?? 'an' // Adjusted Nav
      },
    );
  }

  Future<QueryResult> getClientKraStatusCheck(String userId) async {
    return await graphQLHelper.query(
      queryString: (clients.kraStatusCheck),
      queryName: 'kraStatusCheck',
      variables: <String, dynamic>{'userId': userId},
    );
  }

  Future<QueryResult> deletePartner() async {
    return await graphQLHelper.mutate(
      mutationString: (deletePartnerMutation.deletePartnerRequest),
      mutationName: 'deletePartner',
    );
  }

  Future<QueryResult> getDeleteDetails() async {
    return await graphQLHelper.query(
      queryString: (deletePartnerQuery.deletePartner),
      queryName: 'getDeleteDetails',
    );
  }

  Future<QueryResult> cancelDeletePartnerRequest(String externalId) async {
    return await graphQLHelper.mutate(
      mutationString: (deletePartnerMutation.cancelDeletePartnerRequest),
      mutationName: 'cancelDeletePartnerRequest',
      variables: <String, dynamic>{'delReqId': externalId},
    );
  }

  Future<QueryResult> fetchfamilyMembers(String userId) async {
    return await graphQLHelper.query(
      queryString: (familyMemebers.familyMemberList),
      queryName: 'fetchfamilyMembers',
      variables: <String, dynamic>{
        'userId': userId,
      },
    );
  }

  Future<QueryResult> fetchClientFamily() async {
    return await graphQLHelper.query(
      queryString: (familyMemebers.familyInfo),
      queryName: 'fetchClientFamily',
    );
  }

  Future<QueryResult> createFamilyMembers(Map payload) async {
    return await graphQLHelper.mutate(
      mutationString: (familyMembersMutation.createFamilyUserRequest),
      mutationName: 'createFamilyMembers',
      variables: payload as Map<String, dynamic>,
    );
  }

  Future<QueryResult> verifyFamilyMember(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (familyMembersMutation.verifyFamilyUserRequest),
      mutationName: 'verifyFamilyMember',
      variables: payload,
    );
  }

  Future<QueryResult> resendFamilyVerificationOtp(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (familyMembersMutation.resendFamilyRequestOtp),
      mutationName: 'resendFamilyVerificationOtp',
      variables: payload,
    );
  }

  Future<QueryResult> kickFamilyMember(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (familyMembersMutation.kickFromFamily),
      mutationName: 'kickFamilyMember',
      variables: payload,
    );
  }

  Future<QueryResult> leaveFamily(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (familyMembersMutation.leaveFamily),
      mutationName: 'leaveFamily',
      variables: payload,
    );
  }

  // My Team
  Future<QueryResult> getEmployees({
    String? search,
    String? designation,
    int limit = 0,
    int offset = 0,
  }) async {
    Map<String, dynamic> body = {'search': search, 'designation': designation};

    return await graphQLHelper.query(
      queryString: (myTeamQuery.getEmployees),
      variables: body,
      queryName: 'getEmployees',
    );
  }

  Future<QueryResult> getPartnersDailyMetric({
    List<String>? agentExternalIdList,
    String date = '',
  }) async {
    Map<String, dynamic> body = {
      'date': date,
      'agentExternalIdList': agentExternalIdList
    };

    return await graphQLHelper.query(
      queryString: (myTeamQuery.getPartnersDailyMetric),
      variables: body,
      queryName: 'getPartnersDailyMetric',
    );
  }

  Future<QueryResult> createPartnerOffice(String? name) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.createPartnerOffice),
      variables: <String, dynamic>{'name': name},
      mutationName: 'createPartnerOffice',
    );
  }

  Future<QueryResult> addExistingAgentPartnerOfficeEmployee(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.addExistingAgentPartnerOfficeEmployee),
      variables: payload,
      mutationName: 'addExistingAgentPartnerOfficeEmployee',
    );
  }

  Future<QueryResult> addPartnerOfficeEmployee(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.addPartnerOfficeEmployee),
      variables: payload,
      mutationName: 'addPartnerOfficeEmployee',
    );
  }

  Future<QueryResult> assignUnassignClient(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.assignUnassignClient),
      variables: payload,
      mutationName: 'assignUnassignClient',
    );
  }

  Future<QueryResult> renameOffice(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.renameOffice),
      variables: payload,
      mutationName: 'renameOffice',
    );
  }

  Future<QueryResult> removeEmployee(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (myTeamMutation.removeEmployee),
      variables: payload,
      mutationName: 'removeEmployee',
    );
  }

  Future<QueryResult> getSIPList(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (sipQueries.sipListV2),
      variables: payload,
      queryName: 'getSIPList',
    );
  }

  Future<QueryResult> getSIPDetails(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (sipQueries.sipDetailsV2),
      variables: payload,
      queryName: 'getSIPDetails',
    );
  }

  Future<QueryResult> getSIPOrders(
    Map<String, dynamic> payload,
  ) async {
    return await graphQLHelper.query(
      queryString: (sipQueries.sipOrders),
      variables: payload,
      queryName: 'getSIPOrders',
    );
  }

  Future<QueryResult> getSIPDetailsV2(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (sipQueries.sipDetailsV2),
      variables: payload,
      queryName: 'getSIPDetailsV2',
    );
  }

  Future<QueryResult> getClientAllocationDetails({
    required String userId,
    required String panNumber,
  }) async {
    Map<String, dynamic> body = {
      'userId': userId,
      'panNumber': panNumber,
    };

    return await graphQLHelper.query(
      queryString: (clientTrackerQuery.familyMfOverview),
      variables: body,
      queryName: 'getClientAllocationDetails',
    );
  }

  Future<QueryResult> getClientHoldingDetails({
    required String userId,
    required String panNumber,
  }) async {
    // pass O for others, W for internal
    Map<String, dynamic> body = {
      'userId': userId,
      'panNumber': panNumber,
      'broker': "O",
    };

    return await graphQLHelper.query(
      queryString: (clientTrackerQuery.familyMfSchemeOverviews),
      variables: body,
      queryName: 'getClientHoldingDetails',
    );
  }

  Future<QueryResult> getClientTickets({
    required String userId,
    required int offset,
  }) async {
    Map<String, dynamic> body = {
      'userId': userId,
      'offset': offset,
      'limit': 20,
    };

    return await graphQLHelper.query(
      queryString: (serviceRequestQuery.serviceRequest),
      variables: body,
      queryName: 'getClientTickets',
    );
  }

  Future<QueryResult> getClientReportTemplates({
    required String userId,
  }) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (reportTemplateQuery.reportTemplate),
      variables: body,
      queryName: 'getClientReportTemplates',
    );
  }

  Future<QueryResult> getClientNominees({
    required String userId,
  }) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.nominees),
      variables: body,
      queryName: 'getClientNominees',
    );
  }

  Future<QueryResult> getClientBankAccounts({required userId}) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.bankAccounts),
      variables: body,
      queryName: 'getClientBankAccounts',
    );
  }

  Future<QueryResult> getClientBrokingBankAccounts({required userId}) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.brokingBankAccounts),
      variables: body,
      queryName: 'getClientBrokingBankAccounts',
    );
  }

  Future<QueryResult> getClientWealthyDematDetail({
    required String userId,
  }) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.wealthyDematProfile),
      variables: body,
      queryName: 'getClientWealthyDematDetail',
    );
  }

  Future<QueryResult> getClientAddressDetail(
      {required String userId, String? addressId}) async {
    Map<String, dynamic> body = {
      'userId': userId,
      'addressId': addressId ?? ''
    };

    return await graphQLHelper.query(
      queryString: (clients.clientAddressDetail),
      variables: body,
      queryName: 'getClientAddressDetail',
    );
  }

  Future<QueryResult> createMfProfile(Map<String, dynamic> body) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.createMfProfile),
      mutationName: 'createMfProfile',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> addClientAddress(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.addClientAddress),
      mutationName: 'addClientAddress',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> updateClientAddress(Map body) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.updateClientAddress),
      mutationName: 'updateClientAddress',
      variables: <String, dynamic>{'input': body},
    );
  }

  Future<QueryResult> deleteClientAddress(String id) async {
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.deleteClientAddress),
      mutationName: 'deleteClientAddress',
      variables: <String, dynamic>{'id': id},
    );
  }

  Future<QueryResult> getMandates(String userId) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.mandates),
      variables: body,
      queryName: 'getMandates',
    );
  }

  Future<QueryResult> getUserMandateMeta(String userId) async {
    Map<String, dynamic> body = {'userId': userId};

    return await graphQLHelper.query(
      queryString: (clients.userMandateMeta),
      variables: body,
      queryName: 'getUserMandateMeta',
    );
  }

  Future<QueryResult> setDefaultBankAccount(String bankId) async {
    Map<String, dynamic> body = {
      'input': {'id': bankId, 'product': 'MF'},
    };

    return await graphQLHelper.mutate(
      mutationString: (clientMutations.setDefaultBankAccount),
      variables: body,
      mutationName: 'setDefaultBankAccount',
    );
  }

  Future<QueryResult> createUserNominee(Map<String, dynamic> payload) async {
    Map<String, dynamic> body = {
      'input': payload,
    };

    return await graphQLHelper.mutate(
      mutationString: (clientMutations.createUserNominee),
      variables: body,
      mutationName: 'createUserNominee',
    );
  }

  Future<QueryResult> updateUserNominee(
      String nomineeId, Map<String, dynamic> payload) async {
    Map<String, dynamic> body = {
      'id': nomineeId,
      'input': payload,
    };
    return await graphQLHelper.mutate(
      mutationString: (clientMutations.updateUserNominee),
      variables: body,
      mutationName: 'updateUserNominee',
    );
  }

  Future<QueryResult> createMfNominees(
      List<Map<String, dynamic>> payload) async {
    Map<String, dynamic> body = {
      'input': payload,
    };

    return await graphQLHelper.mutate(
      mutationString: (clientMutations.createMfNominees),
      variables: body,
      mutationName: 'createMfNominees',
    );
  }

  Future<QueryResult> getClientReportList({
    required Map<String, dynamic> payload,
  }) async {
    return await graphQLHelper.query(
      queryString: (reportQuery.reportList),
      variables: payload,
      queryName: 'getClientReportList',
    );
  }

  Future<QueryResult> getClientReport(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (reportQuery.getReportById),
      variables: payload,
      queryName: 'getClientReport',
    );
  }

  Future<QueryResult> createClientReport({
    required Map<String, dynamic> payload,
  }) async {
    return await graphQLHelper.mutate(
      mutationString: (createReportMutation.createReport),
      variables: <String, dynamic>{'input': payload},
      mutationName: 'createClientReport',
    );
  }

  Future<QueryResult> refreshReportLink({
    required Map<String, dynamic> payload,
  }) async {
    return await graphQLHelper.mutate(
      mutationString: (createReportMutation.refreshReportLink),
      variables: <String, dynamic>{'input': payload},
      mutationName: 'refreshReportLink',
    );
  }

  Future<QueryResult> getClientInvestmentStatus(String userId) async {
    return await graphQLHelper.query(
      queryString: (clients.clientInvestmentStatus),
      queryName: 'getClientInvestmentStatus',
      variables: <String, dynamic>{
        'userId': userId,
      },
    );
  }

  Future<QueryResult> getGoalSchemeOrders(String userId,
      {required String goalId,
      String? wschemecode,
      int limit = 20,
      int offset = 0}) async {
    return await graphQLHelper.query(
      queryString: (goal.goalSchemeOrders),
      queryName: 'getGoalTransactions',
      variables: <String, dynamic>{
        'goalId': goalId,
        'wschemecode': wschemecode ?? '',
        'userId': userId,
        'schemeStatus': 'S',
        'limit': limit,
        'offset': offset,
        'status': "3"
      },
    );
  }

  Future<QueryResult> getSwpList({
    required String goalId,
    required String userId,
  }) async {
    final payload = <String, dynamic>{
      'goalId': goalId,
      'userId': userId,
    };
    LogUtil.printLog('getSwpList - payload' + payload.toString());

    return await graphQLHelper.query(
      queryString: (goal.swpList),
      queryName: 'getSwpList',
      variables: payload,
    );
  }

  Future<QueryResult> getSWPDetails(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: goal.swpDetails,
      variables: payload,
      queryName: 'getSWPDetails',
    );
  }

  Future<QueryResult> createGoalOrder({
    required Map<String, dynamic> payload,
  }) async {
    return await graphQLHelper.mutate(
      mutationString: (goalMutation.createTicket),
      variables: <String, dynamic>{'input': payload},
      mutationName: 'createTicket',
    );
  }

  Future<QueryResult> markGoalAsCustom({
    required String goalId,
  }) async {
    return await graphQLHelper.mutate(
      mutationString: (goalMutation.markGoalAsCustom),
      variables: <String, dynamic>{'goalId': goalId},
      mutationName: 'markGoalAsCustom',
    );
  }

  Future<QueryResult> updateGoal({
    required Map<String, dynamic> payload,
  }) async {
    return await graphQLHelper.mutate(
      mutationString: (goalMutation.updateGoal),
      variables: <String, dynamic>{'input': payload},
      mutationName: 'updateGoal',
    );
  }

  Future<int> _getPmsTransactionCount(Map<String, dynamic> payload) async {
    final defaultLimit = 1000;
    try {
      final response = await graphQLHelper.query(
        queryString: (partnerTransactionQueries.pmsTransactionCount),
        queryName: 'getPmsTransactionsCount',
        variables: payload,
      );

      final count = response.data?['entreat']?['pmsCashflowsPartner']
              ?['count'] ??
          defaultLimit;

      return count;
    } catch (e) {
      return defaultLimit;
    }
  }

  Future<QueryResult> getTransactions(
    Map<String, dynamic> payload,
    String type,
  ) async {
    String query;
    int pmsTransactionCount = 0;
    switch (type) {
      case 'PMS':
        query = partnerTransactionQueries.pmsTransactions;
        pmsTransactionCount = await _getPmsTransactionCount(payload);
        payload['limit'] = pmsTransactionCount;
        break;
      case 'Insurance':
        query = partnerTransactionQueries.insuranceTransactions;
        break;
      case 'Sip Detail':
        query = partnerTransactionQueries.mfOrderTransactions;
        break;
      default:
        query = partnerTransactionQueries.mfTransactions;
    }

    return await graphQLHelper.query(
      queryString: query,
      queryName: 'getTransactions',
      variables: payload,
    );
  }

  Future<QueryResult> getStpList(String userId, String goalId) async {
    return await graphQLHelper.query(
      queryString: goal.switches,
      variables: {'goalId': goalId, 'userId': userId},
      queryName: 'getStpList',
    );
  }

  Future<QueryResult> getStpOrders(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: goal.stpOrders,
      variables: payload,
      queryName: 'getStpOrders',
    );
  }

  Future<QueryResult> getBrokingActivity(
    Map<String, dynamic> payload,
  ) async {
    return await graphQLHelper.query(
      queryString: (brokingQueries.brokingClientActivity),
      queryName: 'getBrokingActivity',
      variables: payload,
    );
  }

  Future<QueryResult> getBrokingOnboardingClients(
    Map<String, dynamic> payload,
  ) async {
    return await graphQLHelper.query(
      queryString: (brokingQueries.brokingClientOnboarding),
      queryName: 'getBrokingOnboardingClients',
      variables: payload,
    );
  }

  Future<QueryResult> generateBrokingKycUrl(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (brokingMutation.generateUrl),
      variables: payload,
      mutationName: 'generateBrokingKycUrl',
    );
  }

  Future<QueryResult> getBrokingDetails(
      List<String> agentExternalIdList, String date) async {
    final payload = <String, dynamic>{
      'agentExternalIdList': agentExternalIdList,
      'date': date,
    };
    LogUtil.printLog('getBrokingDetails payload: ' + payload.toString());
    return await graphQLHelper.query(
      queryString: (brokingQueries.brokingDetails),
      queryName: 'getBrokingDetails',
      variables: payload,
    );
  }

  Future<QueryResult> getBrokingPlans() async {
    return await graphQLHelper.query(
      queryString: (brokingQueries.brokingPlans),
      queryName: 'getBrokingPlans',
    );
  }

  Future<QueryResult> getPartnerApStatus(String agentId) async {
    return await graphQLHelper.query(
        queryString: (brokingQueries.partnerApStatus),
        queryName: 'getPartnerApStatus',
        variables: {'agentId': agentId});
  }

  Future<QueryResult> updateDefaultBrokingPlan(
      String agentId, String planCode) async {
    return await graphQLHelper.mutate(
      mutationString: (brokingMutation.updateDefaultBrokingPlan),
      variables: {"agentId": agentId, "apPlanCode": planCode},
      mutationName: 'updateDefaultBrokingPlan',
    );
  }

  Future<QueryResult> updateUserBrokeragePlan(String planCode) async {
    return await graphQLHelper.mutate(
      mutationString: (brokingMutation.updateUserBrokeragePlan),
      variables: {
        "input": {"brokeragePlan": planCode}
      },
      mutationName: 'updateUserBrokeragePlan',
    );
  }

  Future<QueryResult> getProductTypes() async {
    return await graphQLHelper.query(
      queryString: revenueSheetQuery.productTypes,
      queryName: 'getProductTypes',
    );
  }

  Future<QueryResult> getQuickActions() async {
    return await graphQLHelper.query(
      queryString: (quickActionQuery.quickActions),
      queryName: 'getQuickActions',
    );
  }

  Future<QueryResult> updateQuickActions(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: (quickActionMutation.updateAgentCustomActions),
      variables: payload,
      mutationName: 'updateQuickActions',
    );
  }

  Future<QueryResult> getPartnerTotalAum(
      List<String> agentExternalIdList) async {
    return await graphQLHelper.query(
      queryString: agentExternalIdList.length == 1
          ? myBusiness.totalAumQuery
          : myBusiness.totalAumAggregateQuery,
      queryName: 'getPartnerTotalAum',
      variables: <String, dynamic>{
        'agentExternalId':
            agentExternalIdList.length == 1 ? agentExternalIdList.first : "",
        'agentExternalIdList':
            agentExternalIdList.length == 1 ? [] : agentExternalIdList,
      },
    );
  }

  Future<QueryResult> getPartnerMfMetrics(
      List<String> agentExternalIdList, String date) async {
    final payload = <String, dynamic>{
      'agentExternalIdList': agentExternalIdList,
      'date': date,
    };
    LogUtil.printLog('getPartnerMfMetrics payload: ' + payload.toString());
    return await graphQLHelper.query(
      queryString: (myBusiness.mfMetricsQuery),
      queryName: 'getPartnerMfMetrics',
      variables: payload,
    );
  }

  Future<QueryResult> getPartnerClientMetrics(
      List<String> agentExternalIdList) async {
    final payload = <String, dynamic>{
      'agentExternalIdList': agentExternalIdList
    };
    LogUtil.printLog('getPartnerClientMetrics payload: ' + payload.toString());
    return await graphQLHelper.query(
      queryString: (myBusiness.clientMetricsQuery),
      queryName: 'getPartnerClientMetrics',
      variables: payload,
    );
  }

  Future<QueryResult> getTicobTransactions(Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (ticob.ticobTransactions),
      variables: payload,
      queryName: 'getTicobTransactions',
    );
  }

  Future<QueryResult> getTicobOpportunities(
      Map<String, dynamic> payload) async {
    return await graphQLHelper.query(
      queryString: (ticob.cobOpportunities),
      variables: payload,
      queryName: 'getTicobOpportunities',
    );
  }

  Future<QueryResult> getSyncedPanInfo(String userId) async {
    return await graphQLHelper.query(
      queryString: (ticob.syncedPanInfo),
      variables: {'userId': userId},
      queryName: 'getSyncedPanInfo',
    );
  }

  Future<QueryResult> getTicobFolioList({
    required String userId,
    required String panNumber,
  }) async {
    // pass O for others, W for internal
    Map<String, dynamic> body = {
      'userId': userId,
      'panNumber': panNumber,
      'broker': "O",
    };
    LogUtil.printLog('getTicobFolioList payload $body');

    return await graphQLHelper.query(
      queryString: (ticob.ticobFolioOverview),
      variables: body,
      queryName: 'getTicobFolioList',
    );
  }

  Future<QueryResult> getPartnerTrackerMetrics(String agentExternalId) async {
    Map<String, dynamic> body = {
      'agentExternalIdList': [agentExternalId]
    };

    return await graphQLHelper.query(
      queryString: (advisor.partnerTrackerMetrics),
      variables: body,
      queryName: 'getPartnerTrackerMetrics',
    );
  }

  Future<QueryResult> getUserProfileViewData() async {
    return await graphQLHelper.query(
      queryString: userProfileView,
      queryName: 'getUserProfileViewData',
    );
  }

  Future<QueryResult> getClientOnboardingDetails(
    String userId,
    String onboardingProduct,
  ) async {
    Map<String, dynamic> body = {
      'userId': userId,
      'onboardingProduct': onboardingProduct
    };

    return await graphQLHelper.query(
      queryString: clientOnboardingDetails,
      queryName: 'getClientOnboardingDetails',
      variables: body,
    );
  }

  Future<QueryResult> requestProfileUpdate(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: clientMutations.requestUserUpdateProfile,
      mutationName: 'requestProfileUpdate',
      variables: {'input': payload},
    );
  }

  Future<QueryResult> requestVerifiedProfileUpdate() async {
    return await graphQLHelper.mutate(
      mutationString: clientMutations.requestUserUpdateVerifiedProfile,
      mutationName: 'requestVerifiedProfileUpdate',
    );
  }

  Future<QueryResult> getClientBirthdays() async {
    return await graphQLHelper.query(
      queryString: advisor.clientBirthdays,
      queryName: 'getClientBirthdays',
    );
  }

  /// Calls AI assistant to generate content based on input
  Future<QueryResult> callAiAssistant(Map<String, dynamic> payload) async {
    return await graphQLHelper.mutate(
      mutationString: advisorMutation.callAiAssistant,
      mutationName: 'callAiAssistant',
      variables: payload,
    );
  }

  /// Gets agent communication auth token
  Future<QueryResult> getAgentCommunicationAuthToken() async {
    return await graphQLHelper.mutate(
      mutationString: advisorMutation.agentCommunicationAuthToken,
      mutationName: 'agentCommunicationAuthToken',
    );
  }
}

String getQuery(ClientInvestmentProductType type) {
  switch (type) {
    case ClientInvestmentProductType.mutualFunds:
      return clients.userMFHybridView;
    case ClientInvestmentProductType.preIpo:
      return clients.userUnlistedOverview;
    case ClientInvestmentProductType.fixedDeposit:
      return clients.userFdOverview;
    case ClientInvestmentProductType.debentures:
      return clients.userMldOverview;
    case ClientInvestmentProductType.pms:
      return clients.userPmsOverview;
    default:
      return '';
  }
}
