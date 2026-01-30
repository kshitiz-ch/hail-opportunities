import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/family_list_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';

enum FamilyAdditionMethod { NEW_USER, EXISTING_USER }

class ClientFamilyController extends GetxController {
  NetworkState? fetchFamilyState;
  List<FamilyModel> familyMembersList = [];
  List<FamilyInfoModel> familyList = [];
  Client? client;
  String? apiKey;
  late ClientListRepository clientListRepository;
  FamilyAdditionMethod selectedMethod = FamilyAdditionMethod.EXISTING_USER;

  GlobalKey<FormState>? memberCRNFormKey;
  GlobalKey<FormState>? memberDetailFormKey;

  TextEditingController? crnController;
  String? relationship;

  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? mobileNumberController;
  String? countryCode = indiaCountryCode;

  TextEditingController? otpInputController;

  NetworkState? createFamilyState;
  late FamilyResponse familyCreateResponse;
  FamilyResponse? familyVerifyResponse;
  FamilyResponse? familyResendResponse;

  NetworkState? verifyFamilyMemberState;

  NetworkState? resendOtpState;

  String? fetchFamilyErrorMessage;
  String? createFamilyErrorMessage;
  String? verifyFamilyErrorMessage;
  String? resendOtpErrorMessage;

  FamilyModel? newFamilyMemberInfo;

  NetworkState? searchState;
  int? agentId;

  late ClientListModel clientsResult;
  Timer? _debounce;
  FocusNode? searchBarFocusNode;

  String? clientsErrorMessage;
  Client? CRNSelectedClient;
  String searchQuery = '';

  NetworkState? removeFamilyState;
  String? removeFamilyErrorMessage;
  FamilyResponse? removeFamilyResponse;

  ClientFamilyController(this.client);

  @override
  Future<void> onInit() async {
    clientListRepository = ClientListRepository();
    apiKey = await getApiKey();
    agentId = await getAgentId();
    fetchClientFamily();
    super.onInit();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    crnController?.dispose();
    searchBarFocusNode?.dispose();
    super.dispose();
  }

  bool get isCRNFormEnabled =>
      memberCRNFormKey != null &&
      CRNSelectedClient != null &&
      relationship.isNotNullOrEmpty;

  bool get isDetailFormEnabled =>
      memberDetailFormKey != null &&
      firstNameController!.text.isNotNullOrEmpty &&
      lastNameController!.text.isNotNullOrEmpty &&
      mobileNumberController!.text.isNotNullOrEmpty &&
      relationship.isNotNullOrEmpty;

  bool get isCRNClientSelected => CRNSelectedClient != null;

  void initCRNForm() {
    otpInputController = TextEditingController();
    memberCRNFormKey = GlobalKey<FormState>();
    crnController = TextEditingController();
    relationship = null;
  }

  void initDetailForm() {
    otpInputController = TextEditingController();
    memberDetailFormKey = GlobalKey<FormState>();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    relationship = null;
  }

  Future<void> fetchClientFamily() async {
    try {
      fetchFamilyState = NetworkState.loading;
      update();

      apiKey ??= await getApiKey();

      QueryResult response = await clientListRepository.fetchFamilyMembers(
          apiKey!, client!.taxyID!);
      if (response.hasException) {
        fetchFamilyErrorMessage =
            response.exception!.graphqlErrors.first.message;
        LogUtil.printLog(
            'fetchClientFamily error==> ${fetchFamilyErrorMessage}');
        fetchFamilyState = NetworkState.error;
      } else {
        familyMembersList = (response.data!['hagrid']['familyMembers'] as List)
            .map(
              (memberJson) => FamilyModel.fromJson(memberJson),
            )
            .toList();

        // if (familyMembersListModel!.famMembers!.isEmpty) {
        response = await clientListRepository.fetchClientFamily(
            apiKey!, client!.taxyID!);
        if (!response.hasException) {
          var famiyListJson = response.data!['myfamilies'];

          // clear family list before adding new family list
          familyList.clear();

          famiyListJson.forEach((family) {
            familyList.add(FamilyInfoModel.fromJson(family));
          });
        }
        // }

        fetchFamilyState = NetworkState.loaded;
      }
    } catch (error) {
      fetchFamilyErrorMessage = genericErrorMessage;
      fetchFamilyState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> createFamilyMembers() async {
    try {
      createFamilyState = NetworkState.loading;

      update();

      apiKey ??= await getApiKey();

      // null payload not allowed
      // so passing empty string
      Map<String, dynamic> payload = <String, dynamic>{
        "input": {
          "MemberFirstName": selectedMethod == FamilyAdditionMethod.NEW_USER
              ? firstNameController!.text
              : '',
          "MemberLastName": selectedMethod == FamilyAdditionMethod.NEW_USER
              ? lastNameController!.text
              : '',
          "MemberPhoneNumber": selectedMethod == FamilyAdditionMethod.NEW_USER
              ? '($countryCode)${mobileNumberController!.text}'
              : '',
          "Relationship": relationship ?? '',
          "MemberCRN": selectedMethod == FamilyAdditionMethod.EXISTING_USER
              ? CRNSelectedClient!.crn!.trim()
              : '',
        },
      };

      final QueryResult response =
          await clientListRepository.createFamilyMembers(
        apiKey!,
        client!.taxyID!,
        payload,
      );

      if (response.hasException) {
        createFamilyErrorMessage =
            response.exception!.graphqlErrors.first.message;
        LogUtil.printLog(
            'createFamilyMembers error==> ${createFamilyErrorMessage}');
        createFamilyState = NetworkState.error;
      } else {
        familyCreateResponse =
            FamilyResponse.fromJson(response.data!['createFamMemberRequest']);
        createFamilyState = NetworkState.loaded;
      }
    } catch (error) {
      createFamilyErrorMessage = genericErrorMessage;
      createFamilyState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> verifyFamilyMembers() async {
    try {
      verifyFamilyMemberState = NetworkState.loading;
      update();

      apiKey ??= await getApiKey();
      Map<String, dynamic> payload = <String, dynamic>{
        "input": {
          "ID": familyCreateResponse.id,
          "Otp": otpInputController!.text,
        },
      };

      final QueryResult response = await clientListRepository
          .verifyFamilyMember(apiKey!, client!.taxyID!, payload);

      if (response.hasException) {
        verifyFamilyErrorMessage =
            response.exception!.graphqlErrors.first.message;
        verifyFamilyMemberState = NetworkState.error;
      } else {
        familyVerifyResponse =
            FamilyResponse.fromJson(response.data!['verifyFamRequest']);

        // update client family list to get details of added account
        // to be used in success page
        await fetchClientFamily();

        newFamilyMemberInfo = familyMembersList
            .where(
                (element) => element.id == familyVerifyResponse!.familyMemberID)
            .toList()
            .single;
        verifyFamilyMemberState = NetworkState.loaded;
      }
    } catch (error) {
      verifyFamilyErrorMessage = genericErrorMessage;
      verifyFamilyMemberState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> resendFamilyVerificationOtp() async {
    try {
      resendOtpState = NetworkState.loading;
      update();

      apiKey ??= await getApiKey();

      Map<String, dynamic> payload = <String, dynamic>{
        "input": {
          "ID": familyCreateResponse.id,
        },
      };

      final QueryResult response = await clientListRepository
          .resendFamilyVerificationOtp(apiKey!, client!.taxyID!, payload);
      if (response.hasException) {
        resendOtpErrorMessage = response.exception!.graphqlErrors.first.message;
        resendOtpState = NetworkState.error;
      } else {
        familyResendResponse =
            FamilyResponse.fromJson(response.data!['resendFamRequestOtp']);
        resendOtpState = NetworkState.loaded;
      }
    } catch (error) {
      resendOtpErrorMessage = genericErrorMessage;
      resendOtpState = NetworkState.error;
    } finally {
      update();
    }
  }

  /// Search
  Future<dynamic> searchClientForCRN(String query) async {
    searchQuery = query;
    searchState = NetworkState.loading;
    update();

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        clearSearchBar();
        return null;
      }

      try {
        QueryResult response = await clientListRepository.queryClientData(
          agentId.toString(),
          false,
          false,
          apiKey!,
          query: query,
          limit: 20,
          offset: 0,
        );

        if (response.hasException) {
          clientsErrorMessage = response.exception!.graphqlErrors[0].message;
          searchState = NetworkState.error;
        } else {
          clientsResult = ClientListModel.fromJson(response.data!['hydra']);
          // Removing client where crn is not present
          clientsResult.clients!.removeWhere(
            (element) => (element.crn?.trim() ?? '').isNullOrEmpty,
          );
          searchState = NetworkState.loaded;
        }
      } catch (error) {
        clientsErrorMessage = 'Something went wrong';
        searchState = NetworkState.error;
      } finally {
        update();
      }
    });
  }

  void clearSearchBar() {
    crnController?.clear();
    searchState = NetworkState.cancel;
    clientsResult = ClientListModel(clients: []);
    CRNSelectedClient = null;
    searchQuery = '';
    update();
  }

  void updateAdditionMethod(FamilyAdditionMethod value) {
    selectedMethod = value;
    update();
  }

  void updateRelationShip(String value) {
    relationship = value;
    update();
  }

  void updateCountryCode(String? value) {
    countryCode = value;
    update();
  }

  void updateCRNSelectedClient(Client data) {
    crnController?.clear();
    searchQuery = '';
    searchState = NetworkState.cancel;
    clientsResult = ClientListModel(clients: []);
    CRNSelectedClient = data;
    update();
  }

  Future<void> removeFromFamily(
      bool isClientPartOfFamily, String? memberUserID) async {
    try {
      removeFamilyState = NetworkState.loading;
      update();

      apiKey ??= await getApiKey();

      Map<String, dynamic> payload;
      if (isClientPartOfFamily) {
        payload = <String, dynamic>{
          // leave
          "input": {
            "FamilyID": memberUserID,
          },
        };
      } else {
        payload = <String, dynamic>{
          // kick
          "input": {
            "FamilyMemberID": memberUserID,
          },
        };
      }

      QueryResult? response;
      if (isClientPartOfFamily) {
        response = await clientListRepository.leaveFamily(
            apiKey!, client!.taxyID!, payload);
      } else {
        response = await clientListRepository.kickFamilyMember(
            apiKey!, client!.taxyID!, payload);
      }

      if (response!.hasException) {
        final apiErrorMessage = response.exception!.graphqlErrors.first.message;
        // from backend error is coming like this
        // ErrorCode: AUTH026, Message: Phone is not verified, ErrorType: CODE
        String errorMessage = '';
        final errorList = apiErrorMessage.split(',').toList();
        for (String error in errorList) {
          if (error.contains('Message:')) {
            errorMessage = error.replaceFirst('Message:', '');
            errorMessage = errorMessage.trim();
          }
        }
        if (errorMessage.isNotNullOrEmpty) {
          removeFamilyErrorMessage = errorMessage;
        } else {
          removeFamilyErrorMessage =
              response.exception!.graphqlErrors.first.message;
        }

        removeFamilyState = NetworkState.error;
      } else {
        removeFamilyResponse = isClientPartOfFamily
            ? FamilyResponse.fromJson(response.data!['leaveFamily'])
            : FamilyResponse.fromJson(response.data!['kickFromFamily']);
        await fetchClientFamily();
        removeFamilyState = NetworkState.loaded;
      }
    } catch (error) {
      removeFamilyErrorMessage = genericErrorMessage;
      removeFamilyState = NetworkState.error;
    } finally {
      update();
    }
  }
}
