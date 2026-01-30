import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/my_team/models/partner_metric_model.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/src/intl/date_format.dart';

class MyTeamController extends GetxController with GetTickerProviderStateMixin {
  // Fields

  ApiResponse createTeamResponse = ApiResponse();
  ApiResponse fetchAgentDesignationResponse = ApiResponse();
  ApiResponse fetchDailyMetricResponse = ApiResponse();
  ApiResponse fetchEmployeesResponse = ApiResponse();
  ApiResponse renameOfficeResponse = ApiResponse();
  ApiResponse removeEmployeeResponse = ApiResponse();

  List<EmployeesModel> employees = [];
  List<EmployeesModel> members = [];

  TabController? tabController;
  TextEditingController searchController = TextEditingController(text: '');
  TextEditingController newTeamNameController = TextEditingController();

  Timer? _debounce;

  String searchQuery = '';

  MyTeamController() {
    tabController = TabController(length: tabLength, vsync: this);
    tabController?.addListener(() {
      if (tabController?.indexIsChanging == true) {
        update();
      }
    });
  }

  bool get isEmployeeTabActive => (tabController?.index ?? 0) == 0;

  @override
  void onInit() {
    super.onInit();
    getAgentDesignation();
    // getEmployees(DesignationType.Employee);
  }

  bool get hasAssociateAccess {
    try {
      return Get.find<HomeController>().hasAssociateAccess;
    } catch (error) {
      return false;
    }
  }

  int get tabLength => hasAssociateAccess ? 2 : 1;

  // TODO: Later
  // int limit = 20;
  // int page = 0;
  // ScrollController scrollController;
  // bool isPaginating = false;

  bool isAgentPartOfTeam = false;
  late AgentDesignationModel agentDesignationModel;

  Future<void> getAgentDesignation() async {
    try {
      fetchAgentDesignationResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;

      QueryResult response =
          await (AdvisorOverviewRepository().getAgentDesignation(apiKey));

      await checkForAssociateAccess();

      if (response.hasException) {
        fetchAgentDesignationResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchAgentDesignationResponse.state = NetworkState.error;
      } else {
        agentDesignationModel = AgentDesignationModel.fromJson(
            response.data!['hydra']['agentDesignation']);

        if (agentDesignationModel.partnerOfficeName.isNotNullOrEmpty) {
          isAgentPartOfTeam = true;
        }

        // update office name in home controller
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          if (homeController.advisorOverviewModel?.agentDesignation != null)
            homeController.advisorOverviewModel!.agentDesignation!
                .partnerOfficeName = agentDesignationModel.partnerOfficeName;
        }

        if (isAgentPartOfTeam && agentDesignationModel.designation == "owner") {
          await getEmployees();
        }

        fetchAgentDesignationResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchAgentDesignationResponse.message =
          'Something went wrong. Please try again';
      fetchAgentDesignationResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> search(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        clearSearchBar();
        return null;
      } else {
        getEmployees();
      }
    });
  }

  Future<void> checkForAssociateAccess() async {
    try {
      HomeController controller = Get.find<HomeController>();
      if (!controller.hasAssociateAccess) {
        await controller.getAgentsWithAssoicateAccess();
      }
    } catch (error) {
      LogUtil.printLog(error);
    }
  }

  Future<void> getEmployees() async {
    try {
      fetchEmployeesResponse.state = NetworkState.loading;
      update();

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().getEmployees(
          search: searchQuery,
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
        List<String> associateExternalIdList = [];

        members.clear();
        employees.clear();

        response.data!['hydra']['employees'].forEach((v) {
          EmployeesModel employeeModel = EmployeesModel.fromJson(v);

          if (employeeModel.designation?.toLowerCase() == "employee") {
            if (employeeModel.agentExternalId.isNotNullOrEmpty) {
              employeeExternalIdList.add(employeeModel.agentExternalId!);
            }
            employees.add(employeeModel);
          } else if (employeeModel.designation?.toLowerCase() == "member") {
            if (employeeModel.agentExternalId.isNotNullOrEmpty) {
              associateExternalIdList.add(employeeModel.agentExternalId!);
            }
            members.add(employeeModel);
          }
        });

        List<String> agentExternalIdList = [
          ...employeeExternalIdList,
          ...associateExternalIdList
        ];

        await getPartnersDailyMetric(agentExternalIdList);

        fetchEmployeesResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchEmployeesResponse.message = 'Something went wrong. Please try again';
      fetchEmployeesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getPartnersDailyMetric(List<String> agentExternalIdList) async {
    try {
      fetchDailyMetricResponse.state = NetworkState.loading;

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

        for (EmployeesModel employee in [...employees, ...members]) {
          if (dailyMetricMapping.containsKey(employee.agentExternalId)) {
            LogUtil.printLog(dailyMetricMapping[employee.agentExternalId]);
            employee.updateAum =
                dailyMetricMapping[employee.agentExternalId] ?? 0;
          }
        }

        fetchDailyMetricResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchDailyMetricResponse.message =
          'Something went wrong. Please try again';
      fetchDailyMetricResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> createPartnerOffice() async {
    try {
      createTeamResponse.state = NetworkState.loading;
      update(['new-team']);

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().createPartnerOffice(
          name: newTeamNameController.text, apiKey: apiKey);

      if (response.hasException) {
        createTeamResponse.message =
            response.exception!.graphqlErrors[0].message;
        createTeamResponse.state = NetworkState.error;
      } else {
        createTeamResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      createTeamResponse.message = 'Something went wrong. Please try again';
      createTeamResponse.state = NetworkState.error;
    } finally {
      update(['new-team']);
    }
  }

  Future<void> renameOffice(String text) async {
    try {
      renameOfficeResponse.state = NetworkState.loading;
      update(['rename-office']);

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().renameOffice(
        apiKey: apiKey!,
        payload: {'name': text},
      );

      if (response.hasException) {
        renameOfficeResponse.message =
            response.exception!.graphqlErrors[0].message;
        renameOfficeResponse.state = NetworkState.error;
      } else {
        renameOfficeResponse.message = response.data?["updatePartnerOffice"]
                ?["message"] ??
            "Partner Office name successfully updated! to $text";
        renameOfficeResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      renameOfficeResponse.message = 'Something went wrong. Please try again';
      renameOfficeResponse.state = NetworkState.error;
    } finally {
      update(['rename-office']);
    }
  }

  Future<void> removeEmployee(String employeeExternalId) async {
    try {
      removeEmployeeResponse.state = NetworkState.loading;
      update(['remove-employee']);

      String? apiKey = await getApiKey();

      QueryResult response = await MyTeamRepository().removeEmployee(
        apiKey: apiKey!,
        payload: {'employeeExternalId': employeeExternalId},
      );

      if (response.hasException) {
        removeEmployeeResponse.message =
            response.exception!.graphqlErrors[0].message;
        removeEmployeeResponse.state = NetworkState.error;
      } else {
        removeEmployeeResponse.message =
            response.data?["removePartnerOfficeEmployee"]?["message"] ??
                "Employee Successfully removed";
        removeEmployeeResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      removeEmployeeResponse.message = 'Something went wrong. Please try again';
      removeEmployeeResponse.state = NetworkState.error;
    } finally {
      update(['remove-employee']);
    }
  }

  void clearSearchBar() {
    searchQuery = '';
    searchController.clear();
    update();
    getEmployees();
  }
}
