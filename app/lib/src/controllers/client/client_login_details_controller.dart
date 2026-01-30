import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:app/flavors.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:core/modules/clients/models/account_details_model.dart';
import 'package:core/modules/clients/models/client_detail_change_request_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_profile_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/resources/mutual_funds_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/src/core/query_result.dart';

class ClientLoginDetailsController extends GetxController {
  Client? client = Client();
  UserDetailsPrefillModel? userDetailsPrefill;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String? countryCode = indiaCountryCode;
  String? updateLink = '';
  bool showUpdateSuccessScreen = false;

  ApiResponse fetchClientDetailsResponse =
      ApiResponse(state: NetworkState.loading);

  NetworkState? generateClientUpdateLinkState;
  NetworkState? updateClientPhoneState;
  NetworkState? updateClientEmailState;
  NetworkState? updateClientMfEmailState;
  NetworkState? updateClientNameState;
  NetworkState? clientDetailChangeRequestState;

  String? clientDetailChangeRequestErrorMessage;
  ClientDetailChangeRequestModel? clientDetailChangeRequestModel;

  ClientLoginDetailsController(this.client, {this.userDetailsPrefill}) {
    client ??= Client();

    if (userDetailsPrefill != null) {
      firstNameController.text = userDetailsPrefill?.firstName ?? '';
      lastNameController.text = userDetailsPrefill?.lastName ?? '';

      // prefill textfield
      final email = userDetailsPrefill?.email ?? '';
      final phoneNumber = userDetailsPrefill?.phoneNumber ?? '';
      countryCode = extractCountryCode(phoneNumber);
      final phoneNo = extractPhoneNumber(phoneNumber);
      emailController.value = emailController.value.copyWith(
          text: email,
          selection: TextSelection.collapsed(offset: email.length));
      phoneNumberController.value = phoneNumberController.value.copyWith(
          text: phoneNo,
          selection: TextSelection.collapsed(offset: phoneNo.length));
    }
  }

  @override
  void onInit() {
    super.onInit();

    getClientDetails();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void changeCountryCode(newCountryCode) {
    countryCode = newCountryCode;
    update();
  }

  Future<void> getClientDetails() async {
    try {
      fetchClientDetailsResponse.state = NetworkState.loading;

      String? apiKey = await getApiKey();

      QueryResult response = await ClientListRepository()
          .getClientLoginDetails(client?.taxyID, apiKey);

      if (response.hasException) {
        fetchClientDetailsResponse.message =
            response.exception!.graphqlErrors[0].message;
        fetchClientDetailsResponse.state = NetworkState.error;
      } else {
        final data = response.data!["hagrid"];
        final wealthyMfProfileData = data["wealthyMfProfile"];
        final wealthyUserDetails = data["wealthyUserDetailsPrefill"];

        if (wealthyMfProfileData != null) {
          client?.mfEmail = wealthyMfProfileData["email"];
        }

        if (wealthyUserDetails != null) {
          client?.email = wealthyUserDetails["email"];
          client?.emailVerified = wealthyUserDetails["emailVerifiedAt"] != null;

          client?.phoneNumber = wealthyUserDetails["phoneNumber"];
          client?.phoneVerified = wealthyUserDetails["phoneVerifiedAt"] != null;
        }

        fetchClientDetailsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      fetchClientDetailsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<RestApiResponse> getAccountData(userId) async {
    RestApiResponse result = RestApiResponse();
    try {
      String apiKey = (await getApiKey())!;
      var data =
          await MutualFundsRepository().getClientProfileData(apiKey, userId);
      final accountData = AccountDetailsModel.fromJson(json.decode(data));
      result.data = accountData;
      result.status = 1;
    } catch (error) {
      LogUtil.printLog(error.toString());
      result.status = 0;
    }

    return result;
  }

  void updateClientPhone(userId, callback) async {
    try {
      updateClientPhoneState = NetworkState.loading;
      update();
      String apiKey = (await getApiKey())!;
      var response = await ClientListRepository().updateClientPhone(
        apiKey,
        userId,
        '($countryCode)${phoneNumberController.text}',
      );
      if (response['status'] == "200") {
        await callback();
        showUpdateSuccessScreen = true;
        updateClientPhoneState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        updateClientPhoneState = NetworkState.error;
      }
    } catch (error) {
      showToast(
        text: 'Something went wrong',
      );
      updateClientPhoneState = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateClientEmail(userId, callback) async {
    try {
      updateClientEmailState = NetworkState.loading;
      update();
      String apiKey = (await getApiKey())!;
      var response = await ClientListRepository().updateClientEmail(
        apiKey,
        userId,
        emailController.text,
      );
      if (response['status'] == "200") {
        await callback();
        showUpdateSuccessScreen = true;
        updateClientEmailState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        updateClientEmailState = NetworkState.error;
      }
    } catch (error) {
      showToast(
        text: 'Something went wrong',
      );
      updateClientEmailState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> updateClientName() async {
    try {
      updateClientNameState = NetworkState.loading;
      update();
      String apiKey = (await getApiKey())!;
      var response = await ClientListRepository().updateClientName(
        apiKey,
        client!.taxyID!,
        firstNameController.text,
        lastNameController.text,
      );
      if (response['status'] == "200") {
        updateClientNameState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        updateClientNameState = NetworkState.error;
      }
    } catch (error) {
      showToast(
        text: 'Something went wrong',
      );
      updateClientNameState = NetworkState.error;
    } finally {
      update();
    }
  }

  void setShowUpdateSuccessScreen() {
    showUpdateSuccessScreen = true;
    update();
  }

  void generateClientUpdateLink(userId, callback, requestType) async {
    try {
      generateClientUpdateLinkState = NetworkState.loading;
      update();
      String apiKey = (await getApiKey())!;
      var response = await ClientListRepository()
          .generateClientUpdateLink(apiKey, userId, requestType);
      if (response['status'] == "200") {
        await callback();
        showUpdateSuccessScreen = true;
        updateLink = response['response']['link'];
        generateClientUpdateLinkState = NetworkState.loaded;
      } else {
        handleApiError(response, showToastMessage: true);
        generateClientUpdateLinkState = NetworkState.error;
      }
    } catch (error) {
      showToast(
        text: 'Something went wrong',
      );
      generateClientUpdateLinkState = NetworkState.error;
    } finally {
      update();
    }
  }

  /// Get Client's Detail Change request data
  Future<void> getClientDetailChangeRequestData(String requestType) async {
    clientDetailChangeRequestState = NetworkState.loading;
    update();

    try {
      String? apiKey = await getApiKey();

      // CHANGE-LOGIN-PHONE-NUMBER
      // CHANGE-LOGIN-EMAIL

      Map<dynamic, dynamic> payload = {
        "user_id": client?.taxyID,
        "request_type": requestType
      };
      final data = await ClientListRepository()
          .getClientDetailChangeRequestData(apiKey!, payload);

      if (data['status'] == '200') {
        clientDetailChangeRequestModel =
            ClientDetailChangeRequestModel.fromJson(data['response']);
        getClientChangeRequestURL(clientDetailChangeRequestModel?.token ?? '');
        clientDetailChangeRequestState = NetworkState.loaded;
      } else {
        clientDetailChangeRequestErrorMessage =
            getErrorMessageFromResponse(data['response']);
        clientDetailChangeRequestState = NetworkState.error;
      }
    } catch (error) {
      clientDetailChangeRequestErrorMessage = 'Something went wrong';
      clientDetailChangeRequestState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> requestVerifiedProfileUpdate() async {
    clientDetailChangeRequestState = NetworkState.loading;
    update();

    try {
      String? apiKey = await getApiKey();

      QueryResult response = await ClientProfileRepository()
          .requestVerifiedProfileUpdate(apiKey!, client!.taxyID!);

      if (!response.hasException) {
        updateLink = WealthyCast.toStr(
            response.data?['requestUserUpdateVerifiedProfileDetails']['url']);
        clientDetailChangeRequestState = NetworkState.loaded;
      } else {
        clientDetailChangeRequestErrorMessage =
            response.exception!.graphqlErrors[0].message;
        clientDetailChangeRequestState = NetworkState.error;
      }
    } catch (error) {
      clientDetailChangeRequestErrorMessage = 'Something went wrong';
      clientDetailChangeRequestState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> requestProfileUpdate(
      {String? phoneNumber, String? emailId}) async {
    clientDetailChangeRequestState = NetworkState.loading;
    update();

    try {
      String? apiKey = await getApiKey();

      final payload = {
        "userId": client?.taxyID,
        "commonFields": {
          if (emailId.isNotNullOrEmpty) "email": emailId,
          if (phoneNumber.isNotNullOrEmpty) "phoneNumber": phoneNumber,
        }
      };

      QueryResult response = await ClientProfileRepository()
          .requestProfileUpdate(apiKey!, client!.taxyID!, payload);

      if (!response.hasException) {
        clientDetailChangeRequestState = NetworkState.loaded;
      } else {
        clientDetailChangeRequestErrorMessage =
            response.exception!.graphqlErrors[0].message;
        clientDetailChangeRequestState = NetworkState.error;
      }
    } catch (error) {
      clientDetailChangeRequestErrorMessage = 'Something went wrong';
      clientDetailChangeRequestState = NetworkState.error;
    } finally {
      update();
    }
  }

  void getClientChangeRequestURL(String token) {
    final baseURL = F.appFlavor == Flavor.DEV
        ? 'https://app.wealthydev.in/'
        : 'https://app.wealthy.in/';
    final path = 'update-personal-info/?token=$token';
    updateLink = baseURL + path;
  }
}
