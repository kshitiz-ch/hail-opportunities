import 'dart:async';
import 'dart:convert';

import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/common/resources/common_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/my_team/models/partner_metric_model.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/src/intl/date_format.dart';

class ReassignClientController extends GetxController {
  final PartnerOfficeModel? partnerOfficeModel;

  ReassignClientController({this.partnerOfficeModel});

  ApiResponse assignUnassignResponse = ApiResponse();

  ApiResponse fetchEmployeesResponse = ApiResponse();
  ApiResponse fetchDailyMetricResponse = ApiResponse();
  Timer? _debounce;
  String searchEmployeeQuery = '';
  TextEditingController searchEmployeeController = TextEditingController();
  List<EmployeesModel> employees = [];
  EmployeesModel? owner;

  ApiResponse getClientsResponse = ApiResponse();
  List<NewClientModel> clientList = [];
  String? clientSearchQuery;
  TextEditingController clientSearchController = TextEditingController();

  Map<String, String> reassignClientMap = {};
  EmployeesModel? reassignTargetEmployee;

  ScrollController scrollController = ScrollController();
  MetaDataModel clientListMetaData =
      MetaDataModel(limit: 20, page: 0, totalCount: 0);
  bool isPaginating = false;

  bool get selectAllClient => reassignClientMap.length == clientList.length;

  @override
  void onInit() async {
    scrollController.addListener(_handlePagination);

    queryClientList();
    super.onInit();
  }

  @override
  void onReady() async {}

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getEmployees() async {
    try {
      fetchEmployeesResponse.state = NetworkState.loading;
      update(['employee']);

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().getEmployees(
          search: searchEmployeeQuery,
          designation: '',
          apiKey: apiKey,
          limit: 0,
          offset: 0);

      if (response.hasException) {
        fetchEmployeesResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchEmployeesResponse.state = NetworkState.error;
      } else {
        List<String> employeeExternalIdList = [];

        employees.clear();

        response.data!['hydra']['employees'].forEach((v) {
          final employeeModel = EmployeesModel.fromJson(v);

          if (employeeModel.designation?.toLowerCase() == "employee") {
            if (employeeModel.agentExternalId.isNotNullOrEmpty) {
              employeeExternalIdList.add(employeeModel.agentExternalId!);
            }
            employees.add(employeeModel);
          }

          if (employeeModel.designation?.toLowerCase() == "owner") {
            if (employeeModel.agentExternalId.isNotNullOrEmpty) {
              employeeExternalIdList.add(employeeModel.agentExternalId!);
            }
            owner = employeeModel;
          }
        });

        await getPartnersDailyMetric(employeeExternalIdList);

        fetchEmployeesResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchEmployeesResponse.message = 'Something went wrong. Please try again';
      fetchEmployeesResponse.state = NetworkState.error;
    } finally {
      update(['employee']);
    }
  }

  Future<void> getPartnersDailyMetric(List<String> agentExternalIdList) async {
    try {
      fetchDailyMetricResponse.state = NetworkState.loading;
      update(['employee']);

      String? apiKey = await getApiKey();

      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);

      QueryResult response = await MyTeamRepository().getPartnersDailyMetric(
          agentExternalIdList: agentExternalIdList
              .map((agentExternalId) => agentExternalId ?? '')
              .toList(),
          date: date,
          apiKey: apiKey);

      if (response.hasException) {
        fetchDailyMetricResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchDailyMetricResponse.state = NetworkState.error;
      } else {
        List dailyMetricList =
            List.from(response.data!["delta"]["partnersDailyMetric"]);

        Map<String?, double?> dailyMetricMapping = {};

        dailyMetricList.forEach((metric) {
          PartnerMetricModel partnerMetricModel =
              PartnerMetricModel.fromJson(metric);

          dailyMetricMapping[partnerMetricModel.agentExternalId] =
              partnerMetricModel.currentValue;
        });

        for (EmployeesModel employee in employees) {
          if (dailyMetricMapping.containsKey(employee.agentExternalId)) {
            employee.updateAum =
                dailyMetricMapping[employee.agentExternalId] ?? 0;
          }
        }

        if (dailyMetricMapping.containsKey(owner?.agentExternalId)) {
          owner?.updateAum = dailyMetricMapping[owner?.agentExternalId] ?? 0;
        }

        fetchDailyMetricResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchDailyMetricResponse.message =
          'Something went wrong. Please try again';
      fetchDailyMetricResponse.state = NetworkState.error;
    } finally {
      update(['employee']);
    }
  }

  Future<dynamic> searchEmployee(String query) async {
    if (searchEmployeeQuery == query) return;
    searchEmployeeQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        clearEmployeeSearchBar();
        return null;
      } else {
        getEmployees();
      }
    });
  }

  void clearEmployeeSearchBar() {
    searchEmployeeQuery = '';
    searchEmployeeController.clear();
    update(['employee']);
    getEmployees();
  }

  Future<void> assignUnassignClient() async {
    try {
      assignUnassignResponse.state = NetworkState.loading;
      update(['assign-unassign-client']);

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().assignUnassignClient(
        apiKey: apiKey!,
        payload: {
          'clientIds': reassignClientMap.keys.toList(),
          'targetAgentExternalId': reassignTargetEmployee?.agentExternalId,
        },
      );

      if (response.hasException) {
        assignUnassignResponse.message =
            response.exception!.graphqlErrors[0].message;
        assignUnassignResponse.state = NetworkState.error;
      } else {
        assignUnassignResponse.message =
            'Client(s) reassignment initiated successfully';
        assignUnassignResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      assignUnassignResponse.message = 'Something went wrong. Please try again';
      assignUnassignResponse.state = NetworkState.error;
    } finally {
      update(['assign-unassign-client']);
    }
  }

  Future<void> queryClientList() async {
    Map<String, String> getQueryMap(String agentExternalIds) {
      final payload = {
        "q": clientSearchController.text,
        "page": (clientListMetaData.page + 1).toString(),
        "per_page": clientListMetaData.limit.toString(),
        "sort_by": "total_current_value",
        "sort_reverse": "true",
        "pt": "user_profile",
        "platform": "partner-app",
        if (partnerOfficeModel != null)
          "filters": jsonEncode(
            [
              {
                "key": "agent_external_id",
                "operation": "eq",
                "value": agentExternalIds
              }
            ],
          )
      };
      return payload;
    }

    try {
      if (!isPaginating) {
        clientList.clear();
        clientListMetaData = MetaDataModel(limit: 20, page: 0, totalCount: 0);
      }
      getClientsResponse.state = NetworkState.loading;
      update(['query-client']);

      final agentExternalIds = (await getAgentExternalIdList()).join(',');
      final apiKey = await getApiKey();

      final response = await CommonRepository().universalSearch(
        apiKey!,
        getQueryMap(agentExternalIds),
      );

      final status = WealthyCast.toInt(response["status"]);

      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        final clientListResponse =
            WealthyCast.toList(response?['response']?['user_profiles']?['data'])
                .map((clientJson) => NewClientModel.fromJson(clientJson))
                .toList();
        clientListMetaData.totalCount = WealthyCast.toInt(
            response?['response']?['user_profiles']?['meta']?['total_count']);
        if (isPaginating) {
          clientList.addAll(List.from(clientListResponse));
        } else {
          clientList = List.from(clientListResponse);
        }

        getClientsResponse.state = NetworkState.loaded;
      } else {
        getClientsResponse.state = NetworkState.error;
        getClientsResponse.message =
            'Error getting client list. \nPlease try again.';
      }
    } catch (e) {
      getClientsResponse.state = NetworkState.error;
      getClientsResponse.message = genericErrorMessage;
    } finally {
      isPaginating = false;
      update(['query-client']);
    }
  }

  Future<dynamic> searchClientList(String query) async {
    if (clientSearchQuery == query) return;

    clientSearchQuery = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (clientSearchQuery.isNullOrEmpty) {
        clearClientSearchBar();
      } else {
        queryClientList();
      }
    });
  }

  void clearClientSearchBar() {
    clientSearchQuery = '';
    clientSearchController.clear();
    queryClientList();
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

  void _handlePagination() {
    if (scrollController.hasClients) {
      final isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;

      final isPagesRemaining = (clientListMetaData.totalCount! /
              (clientListMetaData.limit * (clientListMetaData.page + 1))) >
          1;

      if (!isPaginating &&
          isScrolledToBottom &&
          isPagesRemaining &&
          getClientsResponse.state != NetworkState.loading) {
        clientListMetaData.page = clientListMetaData.page + 1;
        isPaginating = true;
        queryClientList();
      }
    }
  }
}
