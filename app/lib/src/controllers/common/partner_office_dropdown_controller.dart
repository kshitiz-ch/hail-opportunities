import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class PartnerOfficeDropdownController extends GetxController {
  ApiResponse fetchEmployeesResponse = ApiResponse();

  List<EmployeesModel> employees = [];

  List<String> agentExternalIdList = [];

  bool isAllTeamMembersSelected = false;
  bool isPartnerOfficeSelected = false;

  EmployeesModel? selectedEmployee;

  late EmployeesModel ownerAgent;

  PartnerOfficeDropdownController({this.selectedEmployee});

  void onInit() {
    getOwnerAgentDetails();
    getEmployees();
    super.onInit();
  }

  Future<void> getOwnerAgentDetails() async {
    String externalAgentId = await getAgentExternalId() ?? '';

    String? firstName;
    String? lastName;
    try {
      String agentName =
          Get.find<HomeController>().advisorOverviewModel?.agent?.name ?? '';
      firstName = agentName.split(" ")[0];
      lastName = agentName.split(" ")[1];
    } catch (error) {
      LogUtil.printLog(error);
    }

    ownerAgent = EmployeesModel(
      agentExternalId: externalAgentId,
      firstName: firstName ?? 'Self',
      lastName: lastName,
      designation: 'owner',
    );

    if (this.selectedEmployee == null) {
      selectedEmployee = ownerAgent;
    }
  }

  Future<void> getEmployees() async {
    try {
      fetchEmployeesResponse.state = NetworkState.loading;
      update();

      String? apiKey = await getApiKey();

      QueryResult response = await (MyTeamRepository().getEmployees(
          search: '', designation: '', apiKey: apiKey, limit: 0, offset: 0));

      if (response.hasException) {
        fetchEmployeesResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchEmployeesResponse.state = NetworkState.error;
      } else {
        employees.clear();

        response.data!['hydra']['employees'].forEach(
          (v) {
            EmployeesModel employeeModel = EmployeesModel.fromJson(v);

            if (employeeModel.designation!.toLowerCase() == "employee" &&
                employeeModel.agentExternalId.isNotNullOrEmpty) {
              employees.add(employeeModel);
              agentExternalIdList.add(employeeModel.agentExternalId!);
            }
          },
        );

        fetchEmployeesResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchEmployeesResponse.message = 'Something went wrong. Please try again';
      fetchEmployeesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateEmployeeSelected(EmployeesModel employee) {
    selectedEmployee = employee;
    isAllTeamMembersSelected = false;
    isPartnerOfficeSelected = false;
    update();
  }

  void selectAllEmployees() {
    isAllTeamMembersSelected = true;
    selectedEmployee = null;
    isPartnerOfficeSelected = false;
    update();
  }

  void selectPartnerOffice() {
    isPartnerOfficeSelected = true;
    selectedEmployee = null;
    isAllTeamMembersSelected = false;
    update();
  }
}
