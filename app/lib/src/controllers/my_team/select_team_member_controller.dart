import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:graphql/client.dart';
import 'package:get/get.dart';

class SelectTeamMemberController extends GetxController {
  EmployeesModel? selectedTeamMember;
  DesignationType selectedDesignation = DesignationType.Employee;

  List<EmployeesModel> employees = [];
  List<EmployeesModel> members = [];

  List<String> selectedAgentExternalIdList = [];

  bool isAllTeamMembersSelected = false;

  ApiResponse fetchEmployeesResponse = ApiResponse();

  SelectTeamMemberController(this.isAllTeamMembersSelected);

  void onInit() {
    getEmployees();
    super.onInit();
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
        members.clear();
        employees.clear();

        response.data!['hydra']['employees'].forEach(
          (v) {
            EmployeesModel employeeModel = EmployeesModel.fromJson(v);

            if (employeeModel.designation!.toLowerCase() == "employee") {
              employees.add(employeeModel);
            } else if (employeeModel.designation!.toLowerCase() == "member") {
              members.add(employeeModel);
            }
          },
        );

        if (isAllTeamMembersSelected) {
          selectAllTeamMembers();
        }

        fetchEmployeesResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchEmployeesResponse.message = 'Something went wrong. Please try again';
      fetchEmployeesResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  updateDesignationType(DesignationType newDesignation) {
    selectedDesignation = newDesignation;
    selectedAgentExternalIdList.clear();
    selectedTeamMember = null;
    if (isAllTeamMembersSelected) {
      selectAllTeamMembers();
    }

    update();
  }

  updateSelectedTeamMember(EmployeesModel newSelectedTeamMember) {
    isAllTeamMembersSelected = false;
    selectedTeamMember = newSelectedTeamMember;
    update();
  }

  selectAllTeamMembers() {
    selectedAgentExternalIdList.clear();
    List<EmployeesModel> employeeListToFilter =
        selectedDesignation == DesignationType.Employee ? employees : members;

    employeeListToFilter.forEach((EmployeesModel employee) {
      if (employee.agentExternalId.isNotNullOrEmpty) {
        selectedAgentExternalIdList.add(employee.agentExternalId!);
      }
    });

    selectedTeamMember = null;
    isAllTeamMembersSelected = true;

    update();
  }
}
