import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/my_team/resources/my_team_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:graphql/client.dart';

enum NewMemberAdditionMethod { NEW_USER, EXISTING_USER }

class AddTeamMemberController extends GetxController {
  TextEditingController otpInputController = TextEditingController();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String? countryCode = indiaCountryCode;

  GlobalKey<FormState> newMemberFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> existingMemberFormKey = GlobalKey<FormState>();

  NewMemberAdditionMethod selectedMethod =
      NewMemberAdditionMethod.EXISTING_USER;

  String? designation;
  String? leadId;

  ApiResponse saveMemberDetailsResponse = ApiResponse();
  ApiResponse verifyOtpResponse = ApiResponse();
  ApiResponse resendOtpResponse = ApiResponse();

  AddTeamMemberController({this.designation});

  Future<void> addPartnerOfficeEmployee() async {
    try {
      saveMemberDetailsResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;

      QueryResult response = await (MyTeamRepository().addPartnerOfficeEmployee(
          email: emailController.text,
          lastName: lastNameController.text,
          firstName: firstNameController.text,
          designation: designation,
          phoneNumber: '($countryCode)${phoneNumberController.text}',
          apiKey: apiKey));

      if (response.hasException) {
        saveMemberDetailsResponse.message =
            response.exception!.graphqlErrors[0].message;
        saveMemberDetailsResponse.state = NetworkState.error;
      } else {
        leadId = response.data!["addPartnerOfficeEmployee"]['agentLeadId'];
        saveMemberDetailsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      saveMemberDetailsResponse.message =
          'Something went wrong. Please try again';
      saveMemberDetailsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> addExistingAgentPartnerOfficeEmployee() async {
    try {
      saveMemberDetailsResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;

      QueryResult response = await (MyTeamRepository()
          .addExistingAgentPartnerOfficeEmployee(
              designation: designation,
              phoneNumber: '($countryCode)${phoneNumberController.text}',
              apiKey: apiKey));

      if (response.hasException) {
        saveMemberDetailsResponse.message =
            response.exception!.graphqlErrors[0].message;
        saveMemberDetailsResponse.state = NetworkState.error;
      } else {
        saveMemberDetailsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      saveMemberDetailsResponse.message =
          'Something went wrong. Please try again';
      saveMemberDetailsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> validateAndAddAssociate() async {
    try {
      verifyOtpResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;
      String? agentId = await getAgentExternalId();

      dynamic response = await MyTeamRepository().validateAndAddAssociate(
        ownerAgentId: agentId,
        phoneNumber: '($countryCode)${phoneNumberController.text}',
        otp: otpInputController.text,
        apiKey: apiKey,
      );

      if (response['status'] == '200') {
        verifyOtpResponse.state = NetworkState.loaded;
      } else {
        verifyOtpResponse.message =
            getErrorMessageFromResponse(response['response']);
        verifyOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      verifyOtpResponse.message = 'Something went wrong. Please try again';
      verifyOtpResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> validateAndAddEmployee() async {
    try {
      verifyOtpResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;
      String? agentId = await getAgentExternalId();

      dynamic response = await MyTeamRepository().validateAndAddEmployee(
        ownerAgentId: agentId,
        phoneNumber: '($countryCode)${phoneNumberController.text}',
        otp: otpInputController.text,
        apiKey: apiKey,
      );

      if (response['status'] == '200') {
        verifyOtpResponse.state = NetworkState.loaded;
      } else {
        verifyOtpResponse.message =
            getErrorMessageFromResponse(response['response']);
        verifyOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      verifyOtpResponse.message = 'Something went wrong. Please try again';
      verifyOtpResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> verifyNewAgentLeadOtp() async {
    try {
      verifyOtpResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;
      String? agentExternalId = await getAgentExternalId();

      dynamic response = await MyTeamRepository().verifyNewAgentLeadOtp(
        leadId: leadId,
        designation: designation,
        ownerAgentId: agentExternalId,
        otp: otpInputController.text,
        apiKey: apiKey,
      );

      if (response['status'] == '200') {
        verifyOtpResponse.state = NetworkState.loaded;
      } else {
        verifyOtpResponse.message =
            getErrorMessageFromResponse(response['response']);
        verifyOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      verifyOtpResponse.message = 'Something went wrong. Please try again';
      verifyOtpResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> resendAgentLeadOtp() async {
    try {
      resendOtpResponse.state = NetworkState.loading;
      update();

      String apiKey = (await getApiKey())!;

      var response = await MyTeamRepository()
          .resendAgentLeadOtp(leadId: leadId, apiKey: apiKey);

      if (response['status'] == '200') {
        resendOtpResponse.state = NetworkState.loaded;
        resendOtpResponse.message =
            getErrorMessageFromResponse(response['response']);
      } else {
        resendOtpResponse.message =
            getErrorMessageFromResponse(response['response']);
        resendOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      resendOtpResponse.message = 'Something went wrong. Please try again';
      resendOtpResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateAdditionMethod(NewMemberAdditionMethod value) {
    selectedMethod = value;
    update();
  }

  void resetOtpStates() {
    verifyOtpResponse.message = '';
    verifyOtpResponse.state = NetworkState.cancel;
    otpInputController.clear();
    update();
  }

  void resetMemberAddForm() {
    saveMemberDetailsResponse.state = NetworkState.cancel;
    saveMemberDetailsResponse.message = '';
    update();
  }
}
