import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/insurance/resources/insurance_repository.dart';
import 'package:core/modules/transaction/models/insurance_transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InsurancePolicyController extends GetxController {
  ApiResponse sendOtpResponse = ApiResponse();
  ApiResponse verifyOtpResponse = ApiResponse();
  ApiResponse sharePolicyResponse = ApiResponse();

  Future<String> sendOtp(String userId) async {
    // reset otp fields
    String referenceId = '';
    verifyOtpResponse = ApiResponse();

    sendOtpResponse.state = NetworkState.loading;
    update([GetxId.send]);

    try {
      final apiKey = await getApiKey() ?? '';

      final payload = {'user_id': userId};

      final response = await InsuranceRepository().sendOtp(apiKey, payload);

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        referenceId =
            WealthyCast.toStr(response?['response']?['reference_id']) ?? '';
        sendOtpResponse.message = 'OTP sent successfully';
        sendOtpResponse.state = NetworkState.loaded;
      } else {
        sendOtpResponse.message = getErrorMessageFromResponse(
            response['response'],
            defaultMessage:
                WealthyCast.toStr(response?['response']?['error_message']));
        if (sendOtpResponse.message.isNullOrEmpty) {
          sendOtpResponse.message = genericErrorMessage;
        }
        sendOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      sendOtpResponse.state = NetworkState.error;
      sendOtpResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.send]);
      return referenceId;
    }
  }

  Future<void> verifyOtp(String otp, String referenceId) async {
    verifyOtpResponse.state = NetworkState.loading;
    update([GetxId.verify]);

    try {
      final apiKey = await getApiKey() ?? '';

      final payload = {'otp': otp, 'reference_id': referenceId};

      final response = await InsuranceRepository().verifyOtp(apiKey, payload);
      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        verifyOtpResponse.message = 'OTP verified successfully';
        verifyOtpResponse.state = NetworkState.loaded;
      } else {
        verifyOtpResponse.message = WealthyCast.toStr(
                (response?['response']?['errors'] as List).first['message']) ??
            genericErrorMessage;
        verifyOtpResponse.state = NetworkState.error;
      }
    } catch (error) {
      verifyOtpResponse.state = NetworkState.error;
      verifyOtpResponse.message = genericErrorMessage;
    } finally {
      update([GetxId.verify]);
    }
  }

  Future<void> sharePolicy(
    String userId,
    String orderId,
  ) async {
    sharePolicyResponse.state = NetworkState.loading;
    update(['${GetxId.share}-$orderId']);

    try {
      final apiKey = await getApiKey() ?? '';

      final payload = {
        // 'policy_number': policyNo,
        // 'insurance_type': insuranceType,
        'user_id': userId,
        'order_id': orderId,
        // 'insurer': insurer,
      };

      final response = await InsuranceRepository().sharePolicy(apiKey, payload);

      final status = WealthyCast.toInt(response['status']);
      final isSuccess = status != null && (status ~/ 100) == 2;

      if (isSuccess) {
        sharePolicyResponse.message =
            WealthyCast.toStr(response?['response']?['message']) ??
                'Policy document sent successfully';
        sharePolicyResponse.state = NetworkState.loaded;
      } else {
        sharePolicyResponse.message = getErrorMessageFromResponse(
          response['response'],
          defaultMessage: genericErrorMessage,
        );
        sharePolicyResponse.state = NetworkState.error;
      }
    } catch (error) {
      sharePolicyResponse.state = NetworkState.error;
      sharePolicyResponse.message = genericErrorMessage;
    } finally {
      update(['${GetxId.share}-$orderId']);
    }
  }

  static void addMixPanelAnalytics(
    String eventName,
    BuildContext context,
    InsuranceTransactionModel model,
  ) {
    try {
      final screenName = isPageAtTopStack(context, ClientDetailRoute.name)
          ? 'client_detail'
          : 'transaction';
      final userDetails =
          model.userDetails.isNotNullOrEmpty ? model.userDetails!.first : null;

      Map<String, dynamic>? properties = {
        'partner_name': model.agentName ?? '-',
        'partner_external_id': model.agentExternalId ?? '-',
        'client_name': userDetails?.name ?? '-',
        'client_email': userDetails?.email ?? '-',
        'client_phone': userDetails?.phone ?? '-',
        'policy': model.policyNumber
      };

      MixPanelAnalytics.trackWithAgentId(
        eventName,
        screen: screenName,
        properties: properties,
        screenLocation: 'insurance_transaction_listing',
      );
    } catch (e) {}
  }
}
