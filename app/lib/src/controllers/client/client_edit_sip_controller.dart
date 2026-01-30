import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/clients/resources/client_goal_repository.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/clients/resources/client_profile_repository.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class ClientEditSipController extends GetxController {
  FundSelection? fundSelection;
  final SipUserDataModel selectedSip;
  ApiResponse updateSipResponse = ApiResponse();
  final Client client;
  ApiResponse customFundsResponse = ApiResponse();

  String? apiKey;
  final GlobalKey<FormState> editFundFormKey = GlobalKey<FormState>();

  late ClientGoalRepository clientGoalRepository;

  int? agentId;
  late SipData updatedSipData;
  List<SchemeMetaModel> addedCustomFunds = <SchemeMetaModel>[];

  late TextEditingController amountEditController;
  late TextEditingController phoneNumberController;
  late TextEditingController endDateController;
  late DateTime pickedEndDate;
  late TextEditingController startDateController;
  late DateTime pickedStartDate;
  String countryCode = indiaCountryCode;
  TextEditingController customFundAmountController = TextEditingController();
  SchemeMetaModel? selectedCustomFund;

  bool isSipV2Enabled = true;
  late bool isSelectedSipActive;
  StoreFundAllocation? customFundsData;

  ApiResponse sipMandateResponse = ApiResponse();
  List<ClientMandateModel> sipMandateList = [];
  ClientMandateModel? selectedMandate;
  ClientMandateModel? currentMandate;

  RxList<int> allowedSipDays = RxList<int>();

  String? updateSipProposalLink;

  bool get isAnyFund => selectedSip.goalType == GoalType.ANY_FUNDS;

  bool get isCustomFund => selectedSip.goalType == GoalType.CUSTOM;

  bool get isWealthyFund => !isCustomFund && !isAnyFund;

  bool get isManualfundSelectionValid =>
      selectedSip.sipMetaFunds.isNotNullOrEmpty;

  double get amount => amountEditController.text.isEmpty
      ? 0
      : amountEditController.text[0] == '₹'
          ? double.parse(
              amountEditController.text.substring(2).replaceAll(',', ''))
          : double.parse(amountEditController.text.replaceAll(',', ''));

  double get customFundAmount => addedCustomFunds.isNullOrEmpty
      ? 0
      : addedCustomFunds.fold<double>(
          0,
          (previousValue, element) =>
              previousValue + (element.amountEntered ?? 0),
        );

  ClientEditSipController(this.selectedSip, this.client);

  @override
  Future<void> onInit() async {
    clientGoalRepository = ClientGoalRepository();
    allowedSipDays = Get.find<CommonController>().allowedSipDays;
    updateSelectedSIP(selectedSip);
    getSipMandates();
    apiKey = await getApiKey();
    agentId = await getAgentId();
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateSelectedSIP(SipUserDataModel selectedSip) {
    addedCustomFunds = [];
    customFundAmountController = TextEditingController();
    customFundsData = StoreFundAllocation();

    prefillEditSIPFormData();
    initialiseFundSelection();
    update();
    if (isCustomFund) {
      getCustomFundsData();
    }
  }

  /// get custom funds data from wschemecodes
  Future<dynamic> getCustomFundsData() async {
    customFundsResponse.state = NetworkState.loading;
    update();

    try {
      apiKey ??= await getApiKey();
      final QueryResult response =
          await StoreRepository().getClientCustomGoalFunds(
        apiKey!,
        selectedSip.goalExternalId ?? '',
        client.taxyID!,
      );

      if (response.hasException) {
        customFundsResponse.message =
            response.exception!.graphqlErrors[0].message;
        customFundsResponse.state = NetworkState.error;
      } else {
        customFundsData = StoreFundAllocation();
        customFundsData?.schemeMetas =
            (response.data!['taxy']['userGoalSubtypeSchemes'] as List?)
                ?.map(
                  (userGoalSubtypeSchemesJson) => SchemeMetaModel.fromJson(
                    userGoalSubtypeSchemesJson['schemeData'],
                  ),
                )
                .toList();
        // initialise added custom funds
        // add already added sip funds from sip meta funds
        for (int i = 0; i < (customFundsData?.schemeMetas?.length ?? 0); i++) {
          final sipFundindex = selectedSip.sipMetaFunds?.indexWhere(
            (element) =>
                element.wschemecode ==
                customFundsData!.schemeMetas![i].wschemecode,
          );
          if (sipFundindex != null && sipFundindex >= 0) {
            customFundsData?.schemeMetas![i].amountEntered =
                selectedSip.sipMetaFunds![sipFundindex].amount?.toDouble();
            addedCustomFunds.add(customFundsData!.schemeMetas![i]);
          }
        }
        customFundsResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      customFundsResponse.message = genericErrorMessage;
      customFundsResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void prefillEditSIPFormData() {
    updatedSipData = SipData();
    updatedSipData.selectedSipDays = selectedSip.sipDays.isNotNullOrEmpty
        ? selectedSip.sipDays!
            .split(',')
            .map((e) => WealthyCast.toInt(e.trim())!)
            .toList()
        : [5];
    if (selectedSip.stepperEnabled ?? false) {
      updatedSipData.isStepUpSipEnabled = true;
      updatedSipData.stepUpPercentage = selectedSip.incrementPercentage ?? 0;
      updatedSipData.stepUpPeriod = selectedSip.stepUpPeriodText;
      updatedSipData.stepUpPercentageController = TextEditingController(
        text: updatedSipData.stepUpPercentage.toString(),
      );
    } else {
      updatedSipData.isStepUpSipEnabled = false;
    }
    amountEditController = TextEditingController(
      text: WealthyAmount.formatNumber(
        (selectedSip.sipAmount ?? 0).toString(),
      ),
    );
    final phoneNumber = isCorrectPhoneNumberFormat(client.phoneNumber)
        ? extractPhoneNumber(client.phoneNumber)
        : '';
    phoneNumberController = TextEditingController(text: phoneNumber);
    final selectedCountryCode = extractCountryCode(client.phoneNumber);
    countryCode = selectedCountryCode.isNotNullOrEmpty
        ? selectedCountryCode
        : indiaCountryCode;

    preFillStartEndDate();

    pickedEndDate = selectedSip.endDate ?? DateTime.now();
    pickedStartDate = selectedSip.startDate ?? DateTime.now();

    // Check This
    isSelectedSipActive = selectedSip.isSipActive == true;
    // selectedSip.isSipActive == true && selectedSip.pauseDate == null;
  }

  void initialiseFundSelection() {
    if (isAnyFund || isWealthyFund) {
      fundSelection = FundSelection.automatic;
    } else {
      fundSelection = FundSelection.manual;
    }
  }

  Future<dynamic> updateSipProposal() async {
    updateSipResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = await getEditSipPayload();
      apiKey ??= await getApiKey();

      final response =
          await ClientListRepository().updateSipProposal(apiKey!, payload);
      // status code coming as 202
      final isSuccess =
          ((WealthyCast.toInt(response['status']) ?? 0) ~/ 100) == 2;
      if (isSuccess) {
        updateSipProposalLink =
            WealthyCast.toStr(response['response']['customer_url']);
        updateSipResponse.state = NetworkState.loaded;
      } else {
        updateSipResponse.message =
            getErrorMessageFromResponse(response['response']);
        updateSipResponse.state = NetworkState.error;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      updateSipResponse.message = genericErrorMessage;
      updateSipResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getSipMandates() async {
    sipMandateResponse.state = NetworkState.loading;
    update();

    try {
      apiKey ??= await getApiKey() ?? '';
      QueryResult response = await ClientProfileRepository().getClientMandates(
        apiKey: apiKey!,
        userId: client.taxyID!,
        sipMetaExternalId: selectedSip.id ?? '',
        fetchConfirmedOnly: true,
      );

      if (response.hasException) {
        sipMandateResponse.message =
            response.exception!.graphqlErrors[0].message;
        sipMandateResponse.state = NetworkState.error;
      } else {
        sipMandateList = [];
        final userMandates =
            WealthyCast.toList(response.data!['taxy']['userMandates']);

        final now = DateTime.now();

        if (userMandates.isNotNullOrEmpty) {
          for (final userMandateJson in userMandates) {
            final mandateModel = ClientMandateModel.fromJson(userMandateJson);

            if (_isMandateValid(mandateModel, now)) {
              sipMandateList.add(mandateModel);
            }
          }
        }

        sipMandateList.sort(
          (a, b) {
            return a.statusText == 'Active'
                ? -1
                : b.statusText == 'Active'
                    ? 1
                    : 0;
          },
        );

        // update selectedMandate
        selectedMandate = sipMandateList.firstWhereOrNull(
          (mandate) =>
              mandate.paymentBankId == selectedSip.paymentBankAccountId,
        );
        if (selectedMandate != null) {
          currentMandate = ClientMandateModel.copy(selectedMandate!);
        }

        sipMandateResponse.state = NetworkState.loaded;
      }
    } catch (error) {
      LogUtil.printLog('error==>${error.toString()}');
      sipMandateResponse.message = 'Something went wrong';
      sipMandateResponse.state = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateSelectedSIPDay(List<int> days) {
    updatedSipData.updateSelectedSipDays(days);
    update();
  }

  void updateEndDate(DateTime endDate) {
    endDateController.value = endDateController.value.copyWith(
      text: getFormattedDate(endDate),
    );
    pickedEndDate = endDate;
    update();
  }

  void updateStartDate(DateTime startDate) {
    startDateController.value = startDateController.value.copyWith(
      text: getFormattedDate(startDate),
    );

    if (startDate.isAfter(pickedEndDate)) {
      updateEndDate(startDate.add(Duration(days: 1)));
    }

    pickedStartDate = startDate;
    update();
  }

  void addCustomFunds() {
    if (addedCustomFunds
        .any((element) => element.id == selectedCustomFund?.id)) {
      showToast(text: 'Fund updated');
      update();
      return;
    }
    addedCustomFunds.add(selectedCustomFund!);
    update();
    // clear after adding
    selectedCustomFund = null;
    customFundAmountController.clear();
  }

  void deleteCustomFunds(SchemeMetaModel fund) {
    addedCustomFunds.remove(fund);
    update();
  }

  void onChangeCustomFundAmountController(String? value) {
    if (value.isNullOrEmpty) {
    } else {
      if (value![0] == '₹') {
        value = value.substring(2);
      }

      if (value.length > 1 && double.parse(value) > 999) {
        value = '${WealthyAmount.formatNumber(value)}';
      }
      customFundAmountController.value =
          customFundAmountController.value.copyWith(
        text: '$value',
        selection: TextSelection.collapsed(offset: value.length),
      );
      update();
    }
  }

  void onSelectCustomFund(String? fundName) {
    selectedCustomFund = customFundsData!.schemeMetas!
        .where((element) => element.displayName == fundName)
        .first;

    String minAmount = selectedCustomFund!.minDepositAmt.toString();

    if (minAmount.length > 1 && double.parse(minAmount) > 999) {
      minAmount = '${WealthyAmount.formatNumber(minAmount)}';
    }
    customFundAmountController.value =
        customFundAmountController.value.copyWith(
      text: '$minAmount',
      selection: TextSelection.collapsed(offset: minAmount.length),
    );
    update();
  }

  Future<Map<String, dynamic>> getEditSipPayload() async {
    // Check This
    final title =
        "Edit Sip for ${isAnyFund ? selectedSip.sipMetaFunds?.first.schemeName : selectedSip.goalName}";
    String? agentExternalId = client.agent?.externalId;
    if (agentExternalId.isNullOrEmpty) {
      agentExternalId = await getAgentExternalId();
    }
    final sipAmount =
        fundSelection == FundSelection.manual ? customFundAmount : amount;
    List<Map<String, dynamic>> schemes = [];
    if (addedCustomFunds.isNotNullOrEmpty) {
      for (int i = 0; i < (addedCustomFunds.length); i++) {
        final Map<String, dynamic> schemeObject = {
          'wschemecode': addedCustomFunds[i].wschemecode,
          'amount': addedCustomFunds[i].amountEntered?.toInt(),
        };
        schemes.add(schemeObject);
      }
    } else {
      for (int i = 0; i < (selectedSip.sipMetaFunds!.length); i++) {
        final Map<String, dynamic> schemeObject = {
          'wschemecode': selectedSip.sipMetaFunds![i].wschemecode,
          'amount': selectedSip.sipMetaFunds?.length == 1
              ? amount.toInt()
              : selectedSip.sipMetaFunds![i].amount,
        };
        schemes.add(schemeObject);
      }
    }
    // using proposal api for edit sip
    Map<String, dynamic> data = {
      'id': selectedSip.id,
      // 'proposal_name': title,
      'agent_external_id': agentExternalId,
      'user_id': client.taxyID,
      'sip_days': updatedSipData.selectedSipDays,
      'end_date': pickedEndDate.toIso8601String().split('T')[0],
      'sip_amount': sipAmount.toInt(),
      'schemes': schemes,
      'stepper_enabled': updatedSipData.isStepUpSipEnabled,
      'pause': !isSelectedSipActive,
    };
    if (updatedSipData.isStepUpSipEnabled) {
      data['increment_percentage'] = updatedSipData.stepUpPercentage;
      data['increment_period'] = updatedSipData.formattedStepUpPeriod;
    }
    if (!isWealthyFund) {
      data['auto_fund_selection'] = false;
    }
    if (selectedMandate != null &&
        selectedMandate?.paymentBankId != selectedSip.paymentBankAccountId) {
      data['payment_bank_account_id'] = selectedMandate!.paymentBankId;
    }

    // if date is not edited then dont pass it
    if (!DateUtils.isSameDay(pickedStartDate, selectedSip.startDate)) {
      data['start_date'] = pickedStartDate.toIso8601String().split('T')[0];
    }
    return data;
  }

  void preFillStartEndDate() {
    DateTime startDate;
    DateTime endDate;
    if (selectedSip.startDate != null) {
      startDate = selectedSip.startDate!;
    } else {
      startDate = DateTime.now().add(Duration(days: 2));
    }

    if (selectedSip.endDate != null) {
      endDate = selectedSip.endDate!;
    } else {
      endDate = DateTime.now().add(Duration(days: (365 * 20) + 2));
    }
    startDateController = TextEditingController(
      text: getFormattedDate(startDate),
    );
    endDateController = TextEditingController(
      text: getFormattedDate(endDate),
    );
  }

  /// Validates if a mandate is valid for SIP operations
  ///
  /// A mandate is considered valid if:
  /// - Current status is 'active'
  /// - Mandate hasn't expired or expiry date is in the future
  bool _isMandateValid(ClientMandateModel mandate, DateTime currentTime) {
    final isStatusActive = mandate.currentStatus?.toLowerCase() == 'active';
    final isNotExpired = mandate.mandateExpiredAt == null ||
        mandate.mandateExpiredAt!.isAfter(currentTime);

    return isStatusActive && isNotExpired;
  }
}
