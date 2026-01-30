import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_address_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';

class ClientPersonalFormController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ClientMfProfileModel? clientMfProfile;
  Client? client;
  UserDetailsPrefillModel? userDetailsPrefill;

  ApiResponse addressResponse = ApiResponse();
  ApiResponse updateResponse = ApiResponse();

  // Text Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController jointNameTwoController = TextEditingController();
  TextEditingController jointNameThreeController = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  TextEditingController panController = TextEditingController();
  TextEditingController panTwoController = TextEditingController();
  TextEditingController panThreeController = TextEditingController();

  TextEditingController guardiansNameController = TextEditingController();
  TextEditingController guardiansPanController = TextEditingController();

  TextEditingController spouseNameController = TextEditingController();
  TextEditingController motherNameController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();
  TextEditingController permanentAddressController = TextEditingController();
  TextEditingController correspondenceAddressController =
      TextEditingController();

  // Other inputs
  String? countryCode = indiaCountryCode;
  DateTime? dob;
  String? maritalStatus;
  String? gender;
  String? panUsageType = PanUsageType.INDIVIDUAL;
  String? panUsageSubtype;

  String? taxStatus;
  String? accountType;

  // Flags
  bool isEditFlow = false;
  bool isPanVerified = false;

  bool get isAccountNew => clientMfProfile?.panNumber.isNotNullOrEmpty ?? false;

  bool get isEmailVerified {
    if (clientMfProfile != null) {
      return clientMfProfile?.isEmailVerified ?? false;
    } else {
      return userDetailsPrefill?.isEmailVerified ?? false;
    }
  }

  bool get isPhoneVerified {
    if (clientMfProfile != null) {
      return clientMfProfile?.isPhoneVerified ?? false;
    } else {
      return userDetailsPrefill?.isPhoneVerified ?? false;
    }
  }

  bool get disableEditPanOrName {
    if ((clientMfProfile?.isKycSubmittedOrApproved ?? false) &&
        (clientMfProfile?.panNumber.isNotNullOrEmpty ?? false) &&
        (clientMfProfile?.name.isNotNullOrEmpty ?? false)) {
      return true;
    } else {
      return false;
    }
  }

  ClientPersonalFormController(
      this.clientMfProfile, this.client, this.userDetailsPrefill) {
    preFillBasicInputs();
    if (clientMfProfile != null) {
      getClientAddress();
    }
  }

  void preFillBasicInputs() {
    // Pre fill phone number
    if (clientMfProfile?.phoneNumber.isNotNullOrEmpty ?? false) {
      phoneController.text =
          extractPhoneNumber(clientMfProfile?.phoneNumber ?? '');
      countryCode = extractCountryCode(clientMfProfile?.phoneNumber ?? '');
    } else {
      phoneController.text =
          extractPhoneNumber(userDetailsPrefill?.phoneNumber ?? '');
      countryCode = extractCountryCode(userDetailsPrefill?.phoneNumber ?? '');
    }

    // Pre fill email
    if (clientMfProfile?.email.isNotNullOrEmpty ?? false) {
      emailController.text = clientMfProfile?.email ?? '';
    } else {
      emailController.text = userDetailsPrefill?.email ?? '';
    }

    // Pre fill pan usage type
    if (clientMfProfile?.panUsageType.isNotNullOrEmpty ?? false) {
      panUsageType = clientMfProfile?.panUsageType;
    } else {
      panUsageType = PanUsageType.INDIVIDUAL;
    }

    // Pre fill pan usage subtype
    if (clientMfProfile?.panUsageSubtype.isNotNullOrEmpty ?? false) {
      panUsageSubtype = clientMfProfile?.panUsageSubtype;
    } else {
      panUsageSubtype = PanUsageSubtype.NON_NRI;
    }

    // Pre fill pan number
    if (clientMfProfile?.panNumber.isNotNullOrEmpty ?? false) {
      panController.text = clientMfProfile!.panNumber!;
    } else {
      panController.text = userDetailsPrefill?.panNumber ?? '';
    }

    // Pre fill name
    if (clientMfProfile?.name.isNotNullOrEmpty ?? false) {
      nameController.text = clientMfProfile!.name!;
    } else {
      nameController.text = userDetailsPrefill?.name ?? '';
    }

    // Pre fill DOB
    if (clientMfProfile?.dob != null) {
      dobController.text =
          DateFormat('dd/MM/yyyy').format(clientMfProfile!.dob!);
      dob = clientMfProfile?.dob;
    } else if (userDetailsPrefill?.dob != null) {
      dobController.text =
          DateFormat('dd/MM/yyyy').format(userDetailsPrefill!.dob!);
      dob = userDetailsPrefill?.dob;
    }

    // Pre fill gender, marital status
    gender = clientMfProfile?.gender ?? 'M';
    maritalStatus = clientMfProfile?.maritalStatus ?? 'S';

    panTwoController.text = clientMfProfile?.pan2 ?? '';
    panThreeController.text = clientMfProfile?.pan3 ?? '';

    jointNameTwoController.text = clientMfProfile?.jointName2 ?? '';
    jointNameThreeController.text = clientMfProfile?.jointName3 ?? '';

    guardiansNameController.text = clientMfProfile?.guardianName ?? '';
    guardiansPanController.text = clientMfProfile?.guardianPan ?? '';

    fatherNameController.text = clientMfProfile?.fatherName ?? '';
    motherNameController.text = clientMfProfile?.motherName ?? '';

    taxStatus = AccountType.getTaxStatusAccountType(
      panUsagetype: panUsageType ?? '',
      panUsageSubtype: panUsageSubtype ?? '',
      taxStatus: true,
      accountType: false,
    );
    accountType = AccountType.getTaxStatusAccountType(
      panUsagetype: panUsageType ?? '',
      panUsageSubtype: panUsageSubtype ?? '',
      taxStatus: false,
      accountType: true,
    );
  }

  void toggleEditFlow(bool enableEdit) {
    isEditFlow = enableEdit;
    update();
  }

  Future<dynamic> updatePersonalDetails() async {
    updateResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = getPersonalFormPayload();
      String apiKey = await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository()
          .createMfProfile(apiKey, client!.taxyID!, payload);

      if (response.hasException) {
        updateResponse.state = NetworkState.error;
        updateResponse.message = response.exception!.graphqlErrors[0].message;
      } else {
        clientMfProfile = ClientMfProfileModel.fromJson(
            response.data!["createUserMfProfile"]["mfProfile"]);
        updateResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      updateResponse.state = NetworkState.error;
      updateResponse.message = 'Something went wrong. Please try again';
    } finally {
      update();
    }
  }

  Map<String, dynamic> getPersonalFormPayload() {
    Map<String, dynamic> body = {
      "dob": DateFormat('yyyy-MM-dd').format(dob!),
      "email": emailController.text,
      "emailOwnerUserId": client!.taxyID!,
      "emailRelation": "self",
      "gender": gender,
      "maritalStatus": maritalStatus,
      "name": nameController.text,
      "panUsageType": panUsageType,
      "panUsageSubtype": panUsageSubtype,
      "phoneNumber": "($countryCode)${phoneController.text}",
      "phoneOwnerUserId": client!.taxyID!,
      "phoneRelation": "self"
    };

    if (panUsageType != PanUsageType.GUARDIAN) {
      body["panNumber"] = panController.text;
    } else {
      body["guardianPan"] = guardiansPanController.text;
      body["guardianName"] = guardiansNameController.text;
      body["panNumber"] = guardiansPanController.text;
    }

    if (panUsageType == PanUsageType.JOINT) {
      body["pan2"] = panTwoController.text;
      body["jointName2"] = jointNameTwoController.text;

      body["pan3"] = panThreeController.text;
      body["jointName3"] = jointNameThreeController.text;
    }

    body['investorType'] = AccountType.getInvestorType(accountType!);

    return body;
  }

  Future<dynamic> getClientAddress() async {
    addressResponse.state = NetworkState.loading;
    update();
    try {
      String apiKey = await getApiKey() ?? '';
      if (clientMfProfile?.defaultPerAddressId.isNotNullOrEmpty ?? false) {
        await getPermanentAddress(apiKey);
      }

      if (clientMfProfile?.defaultCorrAddressId.isNotNullOrEmpty ?? false) {
        await getCorAddress(apiKey);
      }

      addressResponse.state = NetworkState.loaded;
    } catch (error) {
      addressResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<dynamic> getPermanentAddress(String apiKey) async {
    QueryResult response = await ClientProfileRepository()
        .getClientAddressDetail(apiKey, client!.taxyID!,
            addressId: clientMfProfile?.defaultPerAddressId);

    if (!response.hasException) {
      List addressJson = response.data!["hagrid"]["userAddresses"] as List;
      ClientAddressModel defaultPerAddress =
          ClientAddressModel.fromJson(addressJson.first);

      permanentAddressController.text = defaultPerAddress.address ?? '';
    }
  }

  Future<dynamic> getCorAddress(String apiKey) async {
    QueryResult response = await ClientProfileRepository()
        .getClientAddressDetail(apiKey, client!.taxyID!,
            addressId: clientMfProfile?.defaultCorrAddressId);

    if (!response.hasException) {
      List addressJson = response.data!["hagrid"]["userAddresses"] as List;
      ClientAddressModel defaultCorAddress =
          ClientAddressModel.fromJson(addressJson.first);

      correspondenceAddressController.text = defaultCorAddress.address ?? '';
    }
  }
}
