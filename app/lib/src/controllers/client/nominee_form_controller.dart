import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
// import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/nominee_validation_utils.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class ClientNomineeFormController extends GetxController {
  ClientNomineeModel? nominee;
  Client? client;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ApiResponse nomineeFormResponse = ApiResponse();

  TextEditingController nameController = TextEditingController();
  TextEditingController guardianNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController guardianDobController = TextEditingController();
  TextEditingController nomineeIdController = TextEditingController();
  TextEditingController guardianIdController = TextEditingController();

  DateTime? dob;
  DateTime? guardianDob;

  String? selectedRelationship;
  String? selectedGuardianRelationship;

  PersonIDType nomineeIdType = PersonIDType.Pan;
  PersonIDType guardianIdType = PersonIDType.Pan;

  String selectedAddressId = '';
  bool includeNomineeInSoa = false;

  bool isEditFlow = false;

  ClientNomineeFormController(this.nominee, this.client);

  @override
  void onInit() {
    if (nominee != null) {
      populateNomineeFormFields();
    }

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<ClientAddressController>(tag: 'client_nominee');
  }

  void populateNomineeFormFields() {
    isEditFlow = true;
    nameController.text = nominee!.name ?? "";
    if (nominee!.dob != null) {
      dobController.text = DateFormat('dd/MM/yyyy').format(nominee!.dob!);
      dob = nominee!.dob;
    }

    // panController.text = nominee!.panNumber ?? "";
    if (nominee!.relationship != null && nominee!.relationship!.contains("_")) {
      selectedRelationship = nominee!.relationship!.split("_").last;
    } else {
      selectedRelationship = nominee!.relationship;
    }

    // Populate mobile and email
    mobileController.text = nominee!.phoneNumber ?? "";
    emailController.text = nominee!.email ?? "";

    // Populate nominee ID details
    void _populateNomineeIdFromType(String idType) {
      switch (idType.toLowerCase()) {
        case 'aadhaar':
          nomineeIdType = PersonIDType.Aadhaar;
          nomineeIdController.text = nominee!.aadhaarNumber ?? "";
          break;
        case 'pan':
        case 'pancard':
          nomineeIdType = PersonIDType.Pan;
          nomineeIdController.text = nominee!.panNumber ?? "";
          break;
        case 'passport':
          nomineeIdType = PersonIDType.Passport;
          nomineeIdController.text = nominee!.passportNumber ?? "";
          break;
        default:
          // Default to PAN if type is unrecognized
          nomineeIdType = PersonIDType.Pan;
          nomineeIdController.text = nominee!.panNumber ?? "";
          break;
      }
    }

    if (nominee!.nomineeIdType.isNotNullOrEmpty) {
      _populateNomineeIdFromType(nominee!.nomineeIdType!);
    } else {
      // Fallback: infer ID type from available data
      if (nominee!.aadhaarNumber.isNotNullOrEmpty) {
        _populateNomineeIdFromType('aadhaar');
      } else if (nominee!.panNumber.isNotNullOrEmpty) {
        _populateNomineeIdFromType('pan');
      } else if (nominee!.passportNumber.isNotNullOrEmpty) {
        _populateNomineeIdFromType('passport');
      }
    }

    // Populate guardian details if nominee is a minor
    if (nominee!.dob != null && !isAdult(nominee!.dob!)) {
      guardianNameController.text = nominee!.guardianName ?? "";

      if (nominee!.guardianDob != null) {
        guardianDobController.text =
            DateFormat('dd/MM/yyyy').format(nominee!.guardianDob!);
        guardianDob = nominee!.guardianDob;
      }

      // Populate guardian relationship
      selectedGuardianRelationship = nominee!.nomineeRelationWithGuardian;

      // Populate guardian ID details
      if (nominee!.guardianIdValue.isNotNullOrEmpty) {
        guardianIdController.text = nominee!.guardianIdValue!;
        if (nominee!.guardianIdType.isNotNullOrEmpty) {
          switch (nominee!.guardianIdType!.toLowerCase()) {
            case 'aadhaar':
              guardianIdType = PersonIDType.Aadhaar;
              break;
            case 'pan':
            case 'pancard':
              guardianIdType = PersonIDType.Pan;
              break;
            case 'passport':
              guardianIdType = PersonIDType.Passport;
              break;
            default:
              guardianIdType = PersonIDType.Aadhaar;
          }
        }
      }
    }

    // Populate address if available
    if (nominee!.address?.externalID.isNotNullOrEmpty == true) {
      selectedAddressId = nominee!.address!.externalID!;
    }

    final clientAddressController =
        Get.find<ClientAddressController>(tag: 'client_nominee');

    // If selectedAddressId is not present, use first address if available
    if (selectedAddressId.isEmpty &&
        clientAddressController.clientAddressModelList.isNotEmpty) {
      selectedAddressId =
          clientAddressController.clientAddressModelList.first.externalID ?? '';
    }

    final editIndex = clientAddressController.clientAddressModelList.indexWhere(
      (address) => address.externalID == selectedAddressId,
    );
    clientAddressController.initInputController(
      editIndex: editIndex != -1 ? editIndex : null,
    );

    includeNomineeInSoa = nominee!.includeNomineeInSoa ?? false;

    // Set nominee ID type to Passport if nominee is NRI in the model
    if (nominee!.nomineeIsNri == true) {
      nomineeIdType = PersonIDType.Passport;
    }
  }

  Map<String, dynamic> _buildNomineeRequestBody() {
    Map<String, dynamic> body = {
      "name": nameController.text,
      "relationship": selectedRelationship ?? "",
      "dob": DateFormat('yyyy-MM-dd').format(dob!),
      "phoneNumber": mobileController.text,
      "email": emailController.text,
      "includeNomineeInSoa": includeNomineeInSoa,
      "nomineeIsNri": nomineeIdType.isPassport,
    };

    // Add nominee ID details based on selected type
    if (nomineeIdType.isPan) {
      body["nomineeIdType"] = "PAN";
      body["panNumber"] = nomineeIdController.text;
      body["aadhaarNumber"] = "";
      body["passportNumber"] = "";
    } else if (nomineeIdType.isAadhaar) {
      body["nomineeIdType"] = "AADHAAR";
      body["aadhaarNumber"] = nomineeIdController.text;
      body["panNumber"] = "";
      body["passportNumber"] = "";
    } else if (nomineeIdType.isPassport) {
      body["nomineeIdType"] = "PASSPORT";
      body["passportNumber"] = nomineeIdController.text;
      body["panNumber"] = "";
      body["aadhaarNumber"] = "";
    }

    // Add guardian details if nominee is a minor
    if (dob != null && !isAdult(dob!)) {
      body["guardianName"] = guardianNameController.text;
      body["guardianDob"] = DateFormat('yyyy-MM-dd').format(guardianDob!);
      body["nomineeRelationWithGuardian"] = selectedGuardianRelationship ?? "";

      // Add guardian ID details
      if (guardianIdType.isPan) {
        body["guardianIdType"] = "PAN";
      } else if (guardianIdType.isAadhaar) {
        body["guardianIdType"] = "AADHAAR";
      } else if (guardianIdType.isPassport) {
        body["guardianIdType"] = "PASSPORT";
      }
      body["guardianIdValue"] = guardianIdController.text;
    }

    // Add address ID if selected
    if (selectedAddressId.isNotEmpty) {
      body["addressId"] = selectedAddressId;
    }

    return body;
  }

  /// Comprehensive validation for the nominee form
  List<String> _validateNomineeForm() {
    return NomineeValidationUtils.validateNomineeForm(
      nomineeName: nameController.text.trim(),
      nomineeDob: dob,
      selectedRelationship: selectedRelationship,
      email: emailController.text.trim(),
      nomineeIdType: nomineeIdType,
      nomineeIdValue: nomineeIdController.text.trim(),
      isNri: nomineeIdType.isPassport,
      guardianName: guardianNameController.text.trim(),
      guardianDob: guardianDob,
      selectedGuardianRelationship: selectedGuardianRelationship,
      guardianIdType: guardianIdType,
      guardianIdValue: guardianIdController.text.trim(),
      accountHolder: client,
      nomineeAddressId: selectedAddressId,
    );
  }

  Future<void> addNomineeDetails() async {
    // Perform comprehensive validation before API call
    final validationErrors = _validateNomineeForm();
    if (validationErrors.isNotEmpty) {
      // Show first validation error
      nomineeFormResponse.state = NetworkState.error;
      nomineeFormResponse.message = validationErrors.first;
      update();
      return;
    }

    nomineeFormResponse.state = NetworkState.loading;
    update();

    try {
      // Handle new address creation before nominee submission
      // If user selected 'new' address option, we need to create the address first
      // and get its ID before proceeding with nominee creation/update
      if (selectedAddressId == 'new') {
        // Get the address controller instance that was tagged specifically for nominee address management
        final clientAddressController =
            Get.find<ClientAddressController>(tag: 'client_nominee');

        // Attempt to create a new address and get the generated address ID
        final addedAddressId = await clientAddressController.addClientAddress();

        // Check if address creation was successful
        if (clientAddressController.addEditAddress.isLoaded) {
          // Success: Update selectedAddressId with the newly created address ID
          // This ID will be used in the nominee request body
          selectedAddressId = addedAddressId;
          // Fetch the newly created address details
          clientAddressController.getClientAddressDetail();
        } else {
          // Address creation failed: Propagate the error to nominee form response
          // and abort the nominee creation/update process
          nomineeFormResponse.state = NetworkState.error;
          nomineeFormResponse.message =
              'Address creation failed: ${clientAddressController.addEditAddress.message}';
          update(); // Notify UI about the error state
          return; // Exit early to prevent proceeding with invalid address
        }
      }

      final apiKey = await getApiKey() ?? '';
      final body = _buildNomineeRequestBody();

      QueryResult response;

      if (isEditFlow) {
        response = await (ClientProfileRepository().updateUserNominee(
          apiKey,
          body,
          clientId: client!.taxyID!,
          nomineeId: nominee?.externalId ?? '',
        ));
      } else {
        response = await (ClientProfileRepository().createUserNominee(
          apiKey,
          client!.taxyID!,
          body,
        ));
      }

      if (response.hasException) {
        nomineeFormResponse.state = NetworkState.error;
        nomineeFormResponse.message =
            response.exception!.graphqlErrors[0].message;
      } else {
        nomineeFormResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      nomineeFormResponse.state = NetworkState.error;
      nomineeFormResponse.message = "Something went wrong. Please try again";
    } finally {
      update();
    }
  }
}
