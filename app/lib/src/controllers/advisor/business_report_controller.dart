import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/advisor/models/advisor_report_model.dart';
import 'package:core/modules/advisor/models/advisor_report_template_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class BusinessReportController extends GetxController {
  ApiResponse agentReportResponse = ApiResponse();
  AgentReportModel? selectedTemplateReport;
  bool? isReportGenerated;

  ApiResponse agentReportTemplateResponse = ApiResponse();
  List<AdvisorReportTemplateModel> agentReportTemplateList = [];

  ApiResponse createReportResponse = ApiResponse();
  ApiResponse refreshReportReponse = ApiResponse();

  AdvisorReportTemplateModel? selectedAgentReportTemplate;

  String? apiKey;

  final String reportExtension = 'xlsx';

  String get getDownloadURL {
    return '${F.url}${selectedTemplateReport?.reportUrl}&type=$reportExtension';
  }

  @override
  void onInit() async {
    super.onInit();
    apiKey = await getApiKey();
    getAgentReportTemplates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getAgentReportTemplates() async {
    agentReportTemplateResponse.state = NetworkState.loading;
    update();
    try {
      apiKey ??= await getApiKey() ?? '';
      QueryResult response =
          await AdvisorRepository().getAgentReportTemplates(apiKey!);
      if (!response.hasException) {
        agentReportTemplateResponse.state = NetworkState.loaded;
        agentReportTemplateList = WealthyCast.toList(
                response.data!['hydra']['agentReportTemplates'])
            .map((agentReportTemplateJson) =>
                AdvisorReportTemplateModel.fromJson(agentReportTemplateJson))
            .toList();
        updateTemplateListing();
      } else {
        agentReportTemplateResponse.state = NetworkState.error;
        agentReportTemplateResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      agentReportTemplateResponse.state = NetworkState.error;
      agentReportTemplateResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> getAgentReport() async {
    agentReportResponse.state = NetworkState.loading;
    update();
    try {
      apiKey ??= await getApiKey() ?? '';
      Map<String, dynamic> payload = <String, dynamic>{
        // show only last report
        "limit": 1,
        "offset": 0,
        "templateName": selectedAgentReportTemplate?.name
      };
      QueryResult response =
          await AdvisorRepository().getAgentReport(apiKey!, payload);
      if (!response.hasException) {
        final agentReportList =
            WealthyCast.toList(response.data!['hydra']['agentReports']);
        if (agentReportList.isNotNullOrEmpty) {
          selectedTemplateReport =
              AgentReportModel.fromJson(agentReportList.first);
        }
        agentReportResponse.state = NetworkState.loaded;
      } else {
        agentReportResponse.state = NetworkState.error;
        agentReportResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      agentReportResponse.state = NetworkState.error;
      agentReportResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> createAgentReport() async {
    createReportResponse.state = NetworkState.loading;
    update();

    try {
      int agentId = await getAgentId() ?? 0;
      apiKey ??= await getApiKey() ?? '';

      DateTime today = DateTime.now();
      String asOnDate = (today).toIso8601String().split('T')[0];

      final variables = <String, dynamic>{
        "agentId": agentId,
        "templateName": selectedAgentReportTemplate?.name ?? '',
        // pass true to refresh old reports
        "regenerate": true,
        "context": "{ \"as_on_date\": \"$asOnDate\"}"
      };

      QueryResult response =
          await AdvisorRepository().createAgentReport(apiKey!, variables);

      if (response.hasException) {
        createReportResponse.state = NetworkState.error;
        createReportResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        isReportGenerated =
            response.data!['createAgentReport']['report'] != null;
        createReportResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      createReportResponse.state = NetworkState.error;
      createReportResponse.message = 'Something went wrong. Please try again';
    } finally {
      // 3 seconds delay to get report generated date as non null
      Future.delayed(Duration(seconds: 3));
      update();
    }
  }

  Future<AgentReportModel?> refreshReportLink(String reportId) async {
    AgentReportModel? newReportModel;
    refreshReportReponse.state = NetworkState.loading;
    update();

    try {
      QueryResult response = await AdvisorRepository().refreshAgentReportLink(
        apiKey: apiKey!,
        payload: {'report': reportId},
      );

      if (response.hasException) {
        refreshReportReponse.message =
            response.exception!.graphqlErrors[0].message;
        refreshReportReponse.state = NetworkState.error;
      } else {
        newReportModel = AgentReportModel.fromJson(
            response.data!['generateAgentReportLink']['report']);
        refreshReportReponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      refreshReportReponse.message = 'Something went wrong';
      refreshReportReponse.state = NetworkState.error;
    } finally {
      if (newReportModel != null) {
        selectedTemplateReport = newReportModel;
      }
      update();
      return newReportModel;
    }
  }

  void updateTemplateListing() {
    // remove invalid template
    agentReportTemplateList
        .removeWhere((element) => element.name == 'CLIENT-LIST-REPORT');
    // add revenue template
    agentReportTemplateList.add(
      AdvisorReportTemplateModel(
        name: 'REVENUE-SHEET',
        displayName: 'Revenue Sheet Report',
      ),
    );
  }
}
