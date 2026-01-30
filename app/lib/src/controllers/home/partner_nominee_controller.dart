import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/advisor/models/partner_nominee_model.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/dashboard/models/kyc/empanelment_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/store/models/mf/screener_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> relationships = [
  {"display_name": "Brother", "value": "brother"},
  {"display_name": "Daughter", "value": "daughter"},
  {"display_name": "Father", "value": "father"},
  {"display_name": "Grand Daughter", "value": "grand daughter"},
  {"display_name": "Grand Father", "value": "grand father"},
  {"display_name": "Grand Mother", "value": "grand mother"},
  {"display_name": "Grand Son", "value": "grand son"},
  {"display_name": "Mother", "value": "mother"},
  {"display_name": "Others", "value": "others"},
  {"display_name": "Sister", "value": "sister"},
  {"display_name": "Son", "value": "son"},
  {"display_name": "Spouse", "value": "spouse"}
];

class PartnerNomineeController extends GetxController {
  PartnerNomineeModel? partnerNominee;
  bool fromKycFlow = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController guardianNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController guardianAddressController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  DateTime? pickedDob;

  Choice? nomineeRelationShip;
  List<Choice> nomineeRelatinoShips = [];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ApiResponse createNomineeResponse = ApiResponse();

  PartnerNomineeController({this.partnerNominee, this.fromKycFlow = false});

  bool isEmpanelmentMissing = true;
  NetworkState checkEmpanelmentState = NetworkState.cancel;

  bool get isGuardianRequired => pickedDob != null && !isAdult(pickedDob!);

  void onInit() {
    relationships.forEach((e) => nomineeRelatinoShips.add(Choice.fromJson(e)));
    if (partnerNominee != null) {
      nameController.text = partnerNominee?.name ?? '';
      guardianNameController.text = partnerNominee?.guardianName ?? '';
      addressController.text = partnerNominee?.address ?? '';
      guardianAddressController.text = partnerNominee?.guardianAddress ?? '';

      if (partnerNominee?.dob != null) {
        dobController.text =
            DateFormat('dd/MM/yyyy').format(partnerNominee!.dob!);
        pickedDob = partnerNominee?.dob;
      }

      if (partnerNominee?.relationship != null) {
        for (var relation in nomineeRelatinoShips) {
          if (relation.value == partnerNominee?.relationship) {
            nomineeRelationShip = relation;
          }
        }
      }
    }

    if (nomineeRelationShip == null) {
      nomineeRelationShip = nomineeRelatinoShips.first;
    }

    super.onInit();
  }

  void updateNomineeRelationship(Choice relation) {
    nomineeRelationShip = relation;
  }

  Future<void> createPartnerNominee() async {
    createNomineeResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        "name": nameController.text,
        "dob": DateFormat('yyyy-MM-dd').format(pickedDob!),
        "address": addressController.text,
        "percentage": 100,
        "relationship": nomineeRelationShip!.value
      };
      if (isGuardianRequired) {
        payload["guardianName"] = guardianNameController.text;
        payload["guardianAddress"] = guardianAddressController.text;
      }

      String agentId = (await getAgentId() ?? '').toString();
      QueryResult response = await AdvisorRepository()
          .createPartnerNominee(apiKey, payload, agentId);
      if (response.hasException) {
        createNomineeResponse.state = NetworkState.error;
        createNomineeResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        List nomineesJson = response.data?['createPartnerNominee']['nominees'];
        partnerNominee = PartnerNomineeModel.fromJson(nomineesJson.first);

        if (fromKycFlow) {
          await checkEmpanelmentStatus();
        }

        createNomineeResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      createNomineeResponse.state = NetworkState.error;
      createNomineeResponse.message = "Something went wrong. Please try again";
    } finally {
      update();
    }
  }

  Future<void> checkEmpanelmentStatus() async {
    isEmpanelmentMissing = true;
    checkEmpanelmentState = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      QueryResult response =
          await AdvisorOverviewRepository().getAgentEmpanelmentDetails(apiKey);

      if (!response.hasException) {
        dynamic data = response.data?['hydra']['agent']['empanelment'];
        if (data != null) {
          EmpanelmentModel empanelmentDetails = EmpanelmentModel.fromJson(data);
          if ([
            AgentEmpanelmentStatus.Empanelled,
            AgentEmpanelmentStatus.Bypass,
            AgentEmpanelmentStatus.BypassTemp
          ].contains(empanelmentDetails.status)) {
            isEmpanelmentMissing = false;
          }
        }
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      checkEmpanelmentState = NetworkState.loaded;
      update();
    }
  }
}
