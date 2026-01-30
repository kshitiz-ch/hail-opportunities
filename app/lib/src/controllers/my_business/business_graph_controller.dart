import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/product_revenue_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/partner_metric_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class BusinessGraphController extends GetxController
    with GetSingleTickerProviderStateMixin {
  String? apiKey;

  // AUM Graph Field
  ApiResponse partnerAumApiResponse = ApiResponse(state: NetworkState.loading);
  List<PartnerMetricModel> parnterMonthlyMetrics = [];
  PartnerMetricModel? currentMonthlyMetric;
  MarketType marketTypeSelected = MarketType.All;

  // Revenue Graph Field
  ApiResponse revenueGraphResponse = ApiResponse();
  List<BusinessGraphModel> revenueGraphData = [];
  List<ProductRevenueModel> revenueTypeData = [];
  double totalSumRevenue = 0;

  // Partner Office Fields
  PartnerOfficeModel? partnerOfficeModel;

  final bool hasLimitedAccess;

  List<String> tabs = ['AUM', 'Revenue'];
  late TabController tabController;

  BusinessGraphController(this.hasLimitedAccess) {
    tabs = hasLimitedAccess == true ? ['AUM'] : ['AUM', 'Revenue'];
    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    apiKey = await getApiKey();
    fetchData();

    tabController.addListener(() {
      if (tabController.indexIsChanging == true) {
        fetchData();
      }
    });
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void fetchData() {
    if (tabs[tabController.index] == 'AUM') {
      getPartnerAumOverview();
    } else {
      getRevenueGraphData();
    }
  }

  List<BusinessGraphModel> get aumGraphData {
    List<BusinessGraphModel> aumGraphData = [];
    List<PartnerMetricModel> lastSixMonthsMetrics;

    const int noOfMonths = 6;

    if (parnterMonthlyMetrics.length > noOfMonths) {
      lastSixMonthsMetrics = parnterMonthlyMetrics.sublist(
        parnterMonthlyMetrics.length - noOfMonths,
        parnterMonthlyMetrics.length,
      );
    } else if (parnterMonthlyMetrics.length < noOfMonths) {
      lastSixMonthsMetrics = List.filled(
        noOfMonths - parnterMonthlyMetrics.length,
        PartnerMetricModel.fromJson({}),
        growable: true,
      );
      lastSixMonthsMetrics.addAll(parnterMonthlyMetrics);
    } else {
      lastSixMonthsMetrics = List.from(parnterMonthlyMetrics);
    }
    final lastSixMonthsDate = getLastSixMonthsDate();
    aumGraphData = List<BusinessGraphModel>.generate(
      noOfMonths,
      (index) {
        PartnerMetricModel parnterMetricModel = lastSixMonthsMetrics[index];
        parnterMetricModel.marketTypeSelected = marketTypeSelected;
        return BusinessGraphModel(
          parnterMetricModel.metricDataByType[MetricType.TotalAum] ?? 0,
          parnterMetricModel.date ?? lastSixMonthsDate[index],
        );
      },
    ).toList();
    return aumGraphData;
  }

  Future<void> getPartnerAumOverview() async {
    try {
      parnterMonthlyMetrics.clear();
      partnerAumApiResponse.state = NetworkState.loading;
      update();

      apiKey ??= await getApiKey() ?? '';

      List<String> agentExternalIdList = await getAgentExternalIdList();
      String agentExternalId = "";
      if (agentExternalIdList.length == 1) {
        agentExternalId = agentExternalIdList.first;
        agentExternalIdList = [];
      }

      QueryResult response;
      bool fetchAggregateApi = agentExternalIdList.isNotEmpty;
      if (fetchAggregateApi) {
        response = await AdvisorOverviewRepository().getPartnerAumAggregate(
          apiKey!,
          agentExternalId: agentExternalId,
          agentExternalIdList: agentExternalIdList,
        );
      } else {
        response = await AdvisorOverviewRepository().getPartnerAumOverview(
          apiKey!,
          agentExternalId: agentExternalId,
          agentExternalIdList: agentExternalIdList,
        );
      }

      if (response.hasException) {
        partnerAumApiResponse.message =
            response.exception!.graphqlErrors[0].message;
        partnerAumApiResponse.state = NetworkState.error;
      } else {
        response.data!['delta'][fetchAggregateApi
                ? 'partnersMonthlyMetricAum'
                : 'partnerMonthlyMetric']
            .forEach(
          (monthlyMetricJson) {
            PartnerMetricModel partnerMetricModel =
                PartnerMetricModel.fromJson(monthlyMetricJson);

            parnterMonthlyMetrics.add(partnerMetricModel);
          },
        );

        if (parnterMonthlyMetrics.isNotEmpty) {
          currentMonthlyMetric = parnterMonthlyMetrics.last;
        } else {
          currentMonthlyMetric = null;
        }

        partnerAumApiResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      partnerAumApiResponse.state = NetworkState.error;
      partnerAumApiResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  void setMarketTypeSelected(MarketType newMarketType) {
    marketTypeSelected = newMarketType;
    currentMonthlyMetric?.marketTypeSelected = newMarketType;
    update();
  }

  Future<List<ProductRevenueModel>?> getProductWiseRevenue(
      DateTime revenueDate) async {
    List<ProductRevenueModel>? productWiseRevenueData;
    try {
      apiKey ??= await getApiKey();

      String queryParams = '?';
      queryParams += 'month=${revenueDate.month}';
      queryParams += '&year=${revenueDate.year}';

      final externalAgentIds = await getAgentExternalIdList();
      if (externalAgentIds.isNotNullOrEmpty) {
        queryParams += '&request_agent_ids=${externalAgentIds.join(',')}';
      }

      final data =
          await AdvisorRepository().getProductWiseRevenue(apiKey!, queryParams);

      if (data['status'] == '200') {
        productWiseRevenueData = WealthyCast.toList(data['response']['data'])
            .map<ProductRevenueModel>(
              (productRevenue) => ProductRevenueModel.fromJson(productRevenue),
            )
            .toList();
      } else {}
    } catch (error) {
    } finally {
      return productWiseRevenueData;
    }
  }

  Future<void> getRevenueGraphData() async {
    revenueTypeData = [];
    totalSumRevenue = 0;
    revenueGraphData = [];
    Map<String, double> revenueLabelData = {};
    Map<DateTime, BusinessGraphModel> revenueGraphMap = {};

    try {
      revenueGraphResponse.state = NetworkState.loading;
      update();

      final lastSixMonthsDate = getLastSixMonthsDate();

      // call api to get 6 month revenue data
      // Future.wait makes parallel processing

      final revenueApiData = await Future.wait(
        List.generate(
          lastSixMonthsDate.length,
          (index) async {
            final date = lastSixMonthsDate[index];
            final data = await getProductWiseRevenue(date);
            if (data == null) {
              throw Exception();
            }
            return MapEntry<DateTime, List<ProductRevenueModel>?>(date, data);
          },
        ),
        eagerError: true,
      );

      // transform api data to graph data
      for (int index = 0; index < revenueApiData.length; index++) {
        double totalRevenueValue = 0;
        revenueApiData[index].value?.forEach((element) {
          totalRevenueValue = totalRevenueValue + element.revenue!;
          totalSumRevenue = totalSumRevenue + element.revenue!;
          final productType = (element.productType ?? 'Other').toLowerCase();
          if (revenueLabelData.containsKey(productType)) {
            revenueLabelData[productType] =
                (element.revenue ?? 0) + (revenueLabelData[productType] ?? 0);
          } else {
            revenueLabelData[productType] = element.revenue ?? 0;
          }
        });
        revenueGraphMap[revenueApiData[index].key] = BusinessGraphModel(
          totalRevenueValue,
          revenueApiData[index].key,
        );
      }

      // Update revenue graph data fields
      revenueGraphData =
          lastSixMonthsDate.map((date) => revenueGraphMap[date]!).toList();
      revenueTypeData = revenueLabelData.entries
          .map(
            (e) => ProductRevenueModel(
              revenue: e.value,
              productType: e.key,
              percentage: (e.value / totalSumRevenue) * 100,
            ),
          )
          .toList()
        ..sort((a, b) => b.revenue?.compareTo(a.revenue ?? 0) ?? 0);

      revenueGraphResponse.state = NetworkState.loaded;
    } catch (e) {
      revenueGraphResponse.state = NetworkState.error;
      revenueGraphResponse.message = genericErrorMessage;
    } finally {
      update();
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
    if (partnerOfficeModel.isSameInstance(this.partnerOfficeModel)) {
      // duplicate api call fix
      return;
    }
    this.partnerOfficeModel = partnerOfficeModel;
    update();
    fetchData();
  }
}

class BusinessGraphModel {
  final double value;
  final DateTime date;

  BusinessGraphModel(this.value, this.date);
}
