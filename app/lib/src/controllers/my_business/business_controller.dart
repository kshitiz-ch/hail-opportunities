import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/advisor/models/sip_metric_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/broking/models/broking_detail_model.dart';
import 'package:core/modules/broking/resources/broking_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/partner_metric_model.dart';
import 'package:core/modules/my_business/models/partner_client_metrics.dart';
import 'package:core/modules/my_business/models/partner_mf_metrics.dart';
import 'package:core/modules/my_business/resources/my_business_repository.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class BusinessController extends GetxController {
  String? apiKey;

  PartnerMetricValueModel? totalAumModel;
  ApiResponse totalAumResponse = ApiResponse();

  // Sip Summary Field
  ApiResponse sipMetricResponse = ApiResponse();
  SipAggregateModel? sipAggregate;

  // Broking Detail Field
  ApiResponse brokingDetailResponse = ApiResponse();
  BrokingDetailModel? brokingDetailModel;

  // Client Metrics Field
  ApiResponse clientMetricsResponse = ApiResponse();
  PartnerClientMetrics? partnerClientMetrics;

  // MF Metrics Field
  ApiResponse mfMetricsResponse = ApiResponse();
  PartnerMFMetrics? partnerMFMetrics;

  // Partner Office Fields
  PartnerOfficeModel? partnerOfficeModel;

  @override
  Future<void> onInit() async {
    super.onInit();
    apiKey = await getApiKey();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() {
    getPartnerTotalAum();
    getBrokingDetails();
    getSipMetrics();
    getPartnerMfMetrics();
    getPartnerClientMetrics();
  }

  Future<void> getBrokingDetails() async {
    brokingDetailResponse.state = NetworkState.loading;
    update([BusinessSectionId.Broking]);

    try {
      final apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();
      String currentDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: 1)));
      QueryResult response = await BrokingRepository().getBrokingDetails(
        apiKey,
        agentExternalIdList,
        currentDate,
      );

      if (!response.hasException) {
        final dailyMetrics =
            WealthyCast.toList(response.data!['delta']['partnersTotalMetric']);
        Map<String, dynamic>? brokingJson = dailyMetrics.isNotNullOrEmpty
            ? dailyMetrics.first['brokingDetails']
            : {};
        if (brokingJson != null && brokingJson.isNotEmpty) {
          brokingDetailModel = BrokingDetailModel.fromJson(brokingJson);
        } else {
          brokingDetailModel = null;
        }

        brokingDetailResponse.state = NetworkState.loaded;
      } else {
        brokingDetailResponse.state = NetworkState.error;
        brokingDetailResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      brokingDetailResponse.state = NetworkState.error;
      brokingDetailResponse.message = genericErrorMessage;
    } finally {
      update([BusinessSectionId.Broking]);
    }
  }

  Future<void> getSipMetrics() async {
    sipMetricResponse.state = NetworkState.loading;
    update([
      BusinessSectionId.OnlineSipMetrics,
      BusinessSectionId.OfflineSipMetrics
    ]);

    try {
      String apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response =
          await AdvisorRepository().getSipMetrics(apiKey, agentExternalIdList);

      if (!response.hasException) {
        sipMetricResponse.state = NetworkState.loaded;
        sipAggregate = SipAggregateModel.fromJson(response.data!["taxy"]);
      } else {
        sipMetricResponse.state = NetworkState.error;
        sipMetricResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      sipMetricResponse.state = NetworkState.error;
      sipMetricResponse.message = genericErrorMessage;
    } finally {
      update([
        BusinessSectionId.OnlineSipMetrics,
        BusinessSectionId.OfflineSipMetrics
      ]);
    }
  }

  Future<void> getPartnerTotalAum() async {
    totalAumResponse.state = NetworkState.loading;
    update([BusinessSectionId.TotalAum]);

    try {
      String apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response = await MyBusinessRepository().getPartnerTotalAum(
        apiKey,
        agentExternalIdList,
      );

      if (!response.hasException) {
        final responseData = WealthyCast.toList(
          response.data!['delta'][agentExternalIdList.length > 1
              ? 'partnersMonthlyMetricAum'
              : 'partnerMonthlyMetric'],
        );
        totalAumModel = PartnerMetricValueModel.fromJson(
          responseData.last['TOTAL'],
        );
        totalAumResponse.state = NetworkState.loaded;
      } else {
        totalAumResponse.state = NetworkState.error;
        totalAumResponse.message = response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      totalAumResponse.state = NetworkState.error;
      totalAumResponse.message = genericErrorMessage;
    } finally {
      update([BusinessSectionId.TotalAum]);
    }
  }

  Future<void> getPartnerMfMetrics() async {
    mfMetricsResponse.state = NetworkState.loading;
    update([BusinessSectionId.MFMetrics]);

    try {
      String apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();
      String currentDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: 1)));
      QueryResult response = await MyBusinessRepository()
          .getPartnerMfMetrics(apiKey, agentExternalIdList, currentDate);

      if (!response.hasException) {
        final responseData = WealthyCast.toList(
          response.data!['delta']['partnersTotalMetric'],
        );
        if (responseData.isNotNullOrEmpty) {
          partnerMFMetrics =
              PartnerMFMetrics.fromJson(responseData.first['myBusinessData']);
        }

        mfMetricsResponse.state = NetworkState.loaded;
      } else {
        mfMetricsResponse.state = NetworkState.error;
        mfMetricsResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      mfMetricsResponse.state = NetworkState.error;
      mfMetricsResponse.message = genericErrorMessage;
    } finally {
      update([BusinessSectionId.MFMetrics]);
    }
  }

  Future<void> getPartnerClientMetrics() async {
    clientMetricsResponse.state = NetworkState.loading;
    update([
      BusinessSectionId.ClientMetrics,
      BusinessSectionId.TrackerMetrics,
    ]);

    try {
      String apiKey = await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();

      QueryResult response =
          await MyBusinessRepository().getPartnerClientMetrics(
        apiKey,
        agentExternalIdList,
      );

      if (!response.hasException) {
        final responseData = WealthyCast.toList(
            response.data!['delta']['partnersClientMetrics']);
        if (responseData.isNotNullOrEmpty) {
          partnerClientMetrics =
              PartnerClientMetrics.fromJson(responseData.first);
        }

        clientMetricsResponse.state = NetworkState.loaded;
      } else {
        clientMetricsResponse.state = NetworkState.error;
        clientMetricsResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      clientMetricsResponse.state = NetworkState.error;
      clientMetricsResponse.message = genericErrorMessage;
    } finally {
      update([
        BusinessSectionId.ClientMetrics,
        BusinessSectionId.TrackerMetrics,
      ]);
    }
  }

  Future<List<String>> getAgentExternalIdList() async {
    List<String> agentExternalIds = [];
    if (partnerOfficeModel != null) {
      agentExternalIds = partnerOfficeModel!.agentExternalIds;
    }
    if (agentExternalIds.isNullOrEmpty) {
      agentExternalIds = [await getAgentExternalId() ?? ''];
    }
    return agentExternalIds;
  }

  void updatePartnerEmployeeSelected(PartnerOfficeModel partnerOfficeModel) {
    this.partnerOfficeModel = partnerOfficeModel;
    fetchData();
  }

  ApiResponse getApiResponse(String id) {
    if (id == BusinessSectionId.Broking) {
      return brokingDetailResponse;
    }
    if (id == BusinessSectionId.OfflineSipMetrics ||
        id == BusinessSectionId.OnlineSipMetrics) {
      return sipMetricResponse;
    }
    if (id == BusinessSectionId.MFMetrics) {
      return mfMetricsResponse;
    }
    if (id == BusinessSectionId.ClientMetrics ||
        id == BusinessSectionId.TrackerMetrics) {
      return clientMetricsResponse;
    }
    return ApiResponse();
  }

  void onRetry(String id) {
    if (id == BusinessSectionId.Broking) {
      getBrokingDetails();
    }
    if (id == BusinessSectionId.OnlineSipMetrics ||
        id == BusinessSectionId.OfflineSipMetrics) {
      getSipMetrics();
    }
    if (id == BusinessSectionId.MFMetrics) {
      getPartnerMfMetrics();
    }
    if (id == BusinessSectionId.ClientMetrics ||
        id == BusinessSectionId.TrackerMetrics) {
      getPartnerClientMetrics();
    }
  }

  Map<String, String> getUIData(String id) {
    if (id == BusinessSectionId.Broking) {
      final model = brokingDetailModel?.brokingSummaryModel;
      return <String, String>{
        'Trading Activated Clients':
            (model?.monthlyTradingActivated ?? 0).toStringAsFixed(0),
        'FnO Activated Clients':
            (model?.monthlyFNOActivated ?? 0).toStringAsFixed(0),
        'Payin': WealthyAmount.currencyFormat(
          model?.monthlyPayin ?? 0,
          1,
        ),
        'Payout': WealthyAmount.currencyFormat(
          model?.monthlyPayout ?? 0,
          1,
        ),
        'Brokerage': WealthyAmount.currencyFormat(
          model?.monthlyBrokerage ?? 0,
          1,
        ),
        'Number of Trades': (model?.monthlyTrades ?? 0).toStringAsFixed(0),
      };
    }
    if (id == BusinessSectionId.OnlineSipMetrics) {
      return <String, String>{
        'Number of Active SIPs': '${sipAggregate?.activeSip?.count ?? 0}',
        'Active SIP Amount':
            WealthyAmount.currencyFormat(sipAggregate?.activeSip?.amount, 1),
        'Unique Client with Active SIP':
            '${sipAggregate?.uniqueClientsWithActiveSips?.count ?? 0}',
        'Number of Successful SIP': '${sipAggregate?.wonSip?.count ?? 0}',
        'Successful SIP Amount':
            '${WealthyAmount.currencyFormat(sipAggregate?.wonSip?.amount, 1)}',
      };
    }

    if (id == BusinessSectionId.OfflineSipMetrics) {
      return <String, String>{
        'Number of Active SIPs':
            '${sipAggregate?.offlineSips?.activeCount ?? 0}',
        'Active SIP Amount': WealthyAmount.currencyFormat(
            sipAggregate?.offlineSips?.activeMonthlyAmount, 1),
        'Number of Paused SIP':
            '${sipAggregate?.offlineSips?.pausedCount ?? 0}',
      };
    }

    if (id == BusinessSectionId.MFMetrics) {
      return <String, String>{
        'Total Unique Client with MF Investment':
            '${partnerMFMetrics?.totalMfInvestors?.toInt() ?? 0}',
        'Gross Transaction Value':
            '${WealthyAmount.currencyFormat(partnerMFMetrics?.currentMonthGtv, 2)} (${partnerMFMetrics?.percentChangeInGtv ?? 0}%)',
        'Total Withdrawal Amount': WealthyAmount.currencyFormat(
            partnerMFMetrics?.currentMonthTotalWithdrawal, 2),
        'Total Purchase Amount ': WealthyAmount.currencyFormat(
            partnerMFMetrics?.currentMonthTotalPurchase, 2),
        'Total Switch Amount ': WealthyAmount.currencyFormat(
            partnerMFMetrics?.currentMonthSwitchAmount, 2),
      };
    }
    if (id == BusinessSectionId.ClientMetrics) {
      return <String, String>{
        'Total Clients': '${partnerClientMetrics?.totalClients ?? 0}',
        'Client with MF KYC Profile':
            '${partnerClientMetrics?.mfKycClients ?? 0}',
        'Client with Broking KYC profile':
            '${partnerClientMetrics?.brokingKycClients ?? 0}',
        'Client with Investment (Active Clients) ':
            '${partnerClientMetrics?.activeClients ?? 0}',
      };
    }

    if (id == BusinessSectionId.TrackerMetrics) {
      return <String, String>{
        'Synced Clients (Last 30 Days)':
            '${partnerClientMetrics?.syncedClientsLast30Days?.toStringAsFixed(0) ?? 0}',
        'External Tracker Amount': WealthyAmount.currencyFormat(
            partnerClientMetrics?.totalExternalTrackerAmount, 2),
        'Tracker Synced Amount': WealthyAmount.currencyFormat(
            partnerClientMetrics?.totalTrackerSyncedAmount, 2),
      };
    }

    return {};
  }
}

class BusinessSectionId {
  static const Broking = 'broking';
  static const OnlineSipMetrics = 'online-sip-metrics';
  static const OfflineSipMetrics = 'offline-sip-metrics';
  static const TotalAum = 'total-aum';
  static const MFMetrics = 'mf-metrics';
  static const ClientMetrics = 'client-metrics';
  static const TrackerMetrics = 'tracker-metrics';
}
