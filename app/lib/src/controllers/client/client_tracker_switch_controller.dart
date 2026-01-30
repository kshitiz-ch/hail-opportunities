import 'dart:async';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_tracker_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/main.dart';
import 'package:core/modules/clients/models/client_tracker_fund_model.dart';
import 'package:core/modules/clients/models/client_tracker_switch_model.dart';
import 'package:core/modules/clients/resources/client_list_repository.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum FundSwitchMethod {
  Amount,
  Unit,
  Full,
}

class ClientTrackerSwitchController extends GetxController {
  final Client client;

  String? apiKey;
  late ClientListRepository clientListRepository;

  final List<ClientTrackerFundModel> clientTrackerHoldings;

  NetworkState? fundListSwitchState;
  String? fundListSwitchErrorMessage;

  int selectedSwitchFundIndex = -1;
  int selectedTrackerFundIndex = -1;
  FundSwitchMethod selectedFundSwitchMethod = FundSwitchMethod.Amount;

  late TextEditingController switchFundSearchController;
  String searchQuery = '';
  List<SchemeMetaModel> availableSwitchFunds = [];

  late TextEditingController fundSwitchInputFieldController;
  GlobalKey<FormState> switchFundFormKey = GlobalKey<FormState>();

  late TextEditingController editSwitchFundFieldController;
  GlobalKey<FormState> editSwitchFundFormKey = GlobalKey<FormState>();
  late FundSwitchMethod editFundSwitchMethod;

  List<Map<String, dynamic>> switchBasket = [];
  // Map<int, Map<String, dynamic>> switchBasket = {};

  NetworkState? trackerSwitchProposalState;
  String? trackerSwitchProposalErrorMessage;

  ClientTrackerSwitchModel? clientTrackerSwitchModel;
  Timer? _debounce;

  DateTime? lastSyncedAt;

  ClientTrackerSwitchController(this.client, this.clientTrackerHoldings);

  @override
  void onInit() async {
    super.onInit();

    clientListRepository = ClientListRepository();
    if (Get.isRegistered<ClientTrackerController>()) {
      lastSyncedAt = Get.find<ClientTrackerController>().familyReport?.syncDate;
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    apiKey = await getApiKey();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  double getTextFieldAmount(TextEditingController controller) {
    return controller.text.isEmpty
        ? 0
        : controller.text[0] == '₹'
            ? (double.tryParse(
                    controller.text.substring(2).replaceAll(',', '')) ??
                0)
            : (double.tryParse(controller.text.replaceAll(',', '')) ?? 0);
  }

  void onFundSearch(String query) {
    if (query.isEmpty) {
      searchQuery = query;
      getFundListForSwitch();

      _debounce!.cancel();
    } else {
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
      }

      _debounce = Timer(
        const Duration(milliseconds: 500),
        () {
          searchQuery = query;
          getFundListForSwitch();
        },
      );
    }
  }

  Future<void> getFundListForSwitch() async {
    availableSwitchFunds = [];
    fundListSwitchState = NetworkState.loading;
    update();
    try {
      String amcCode = clientTrackerHoldings[selectedTrackerFundIndex]
              .schemeMetaModel!
              .amcCode ??
          '';

      // in UI we have to show 3 minimum to select
      // then if user wants some other funds to select for that he can search
      final filters = {"amc": amcCode};

      final response = await StoreRepository().searchMutualFunds(
        apiKey: apiKey,
        query: searchQuery,
        filters: filters,
        sorting: '',
      );

      if (response['status'] == "200") {
        List result = response['response']['data'];
        // fix race condition
        // user types focuse & focused within some milliseconds
        // availableSwitchFunds for focused mayn't be empty
        // which may result into duplicate entries
        availableSwitchFunds = [];
        for (int i = 0; i < result.length; i++) {
          final fundSchemeData = result[i];

          if (fundSchemeData['scheme_code'] ==
              clientTrackerHoldings[selectedTrackerFundIndex].schemeCode) {
            // fund list for switch shouldn't have selected tracker funds
            continue;
          }
          final folioOverviews = (fundSchemeData['folioOverviews'] as List?);
          fundSchemeData['folioOverview'] =
              folioOverviews.isNotNullOrEmpty ? folioOverviews!.first : null;

          availableSwitchFunds.add(SchemeMetaModel.fromJson(fundSchemeData));
        }

        fundListSwitchState = NetworkState.loaded;
      } else {
        fundListSwitchState = NetworkState.error;
        fundListSwitchErrorMessage =
            getErrorMessageFromResponse(response['response']);
      }
    } catch (error) {
      LogUtil.printLog('error: ' + error.toString());
      fundListSwitchState = NetworkState.error;
      fundListSwitchErrorMessage = genericErrorMessage;
    } finally {
      update();
    }
  }

  Future<void> sendTrackerSwitchProposal() async {
    trackerSwitchProposalState = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = getTrackerSwitchPayload();
      final data = await ClientListRepository()
          .sendTrackerSwitchProposal(apiKey!, payload);

      if (data['status'] == '200') {
        clientTrackerSwitchModel =
            ClientTrackerSwitchModel.fromJson(data['response']);

        trackerSwitchProposalState = NetworkState.loaded;
      } else {
        if (data['response'] is String) {
          trackerSwitchProposalErrorMessage = data['response'];
        } else {
          trackerSwitchProposalErrorMessage =
              getErrorMessageFromResponse(data['response']);
        }
        trackerSwitchProposalState = NetworkState.error;
      }
    } catch (error) {
      trackerSwitchProposalErrorMessage = 'Something went wrong';
      trackerSwitchProposalState = NetworkState.error;
    } finally {
      update();
    }
  }

  Map<String, dynamic> getTrackerSwitchPayload() {
    // final keys = switchBasket.keys.toList();
    Map<String, dynamic> payload = {
      "user_id": client.taxyID,
      "schemes": List<Map<String, dynamic>>.generate(
        switchBasket.length,
        (index) {
          SchemeMetaModel switchOutFund = switchBasket[index]['switch_out'];
          SchemeMetaModel switchInFund = switchBasket[index]['switch_in'];
          double? switchInUnits = switchBasket[index]['units'];
          double? switchInAmount = switchBasket[index]['amount'];
          FundSwitchMethod switchMethod = switchBasket[index]['switch_method'];
          Map<String, dynamic> data = {};
          data['switchout'] = {
            'wschemecode': switchOutFund.wschemecode,
            'folio_number': switchOutFund.folioOverview?.folioNumber,
            'full': switchMethod == FundSwitchMethod.Full,
          };
          if (switchMethod == FundSwitchMethod.Amount) {
            data['switchout']['amount'] = switchInAmount;
          } else if (switchMethod == FundSwitchMethod.Unit) {
            data['switchout']['units'] = switchInUnits;
          }
          data['switchin'] = {
            'wschemecode': switchInFund.wschemecode,
            'full': switchMethod == FundSwitchMethod.Full,
            'folio_number': switchOutFund.folioOverview?.folioNumber,
          };

          return data;
        },
      )
    };
    LogUtil.printLog('payload==>${payload.toString()}');
    return payload;
  }

  void updateSelectedTrackerFund(int selectedFundIndex) {
    // Close the expansion if clicked twice on the fund
    if (selectedTrackerFundIndex == selectedFundIndex) {
      selectedTrackerFundIndex = -1;
      selectedSwitchFundIndex = -1;
      searchQuery = '';
      availableSwitchFunds = [];
      switchFundSearchController = TextEditingController();
      fundSwitchInputFieldController = TextEditingController();
      update();
    } else {
      selectedTrackerFundIndex = selectedFundIndex;
      switchFundSearchController = TextEditingController();
      searchQuery = '';
      availableSwitchFunds = [];
      selectedSwitchFundIndex = 0;
      fundSwitchInputFieldController = TextEditingController();
      getFundListForSwitch();
    }
  }

  void updateSelectedSwitchFund(int selectedIndex) {
    selectedSwitchFundIndex = selectedIndex;
    fundSwitchInputFieldController = TextEditingController();
    update();
  }

  void clearSearchBar() {
    searchQuery = '';
    switchFundSearchController.clear();
    availableSwitchFunds = [];
    update();
    getFundListForSwitch();
  }

  void updateSelectedSwitchMethod(FundSwitchMethod selectedSwitchMethod) {
    selectedFundSwitchMethod = selectedSwitchMethod;
    fundSwitchInputFieldController.clear();
    update();
  }

  void clearSwitchInputField() {
    fundSwitchInputFieldController.clear();
    update();
  }

  void updateSwitchInputField(String value) {
    if (selectedFundSwitchMethod == FundSwitchMethod.Amount &&
        value.isNotNullOrEmpty) {
      if (value[0] == '₹') {
        value = value.substring(2);
      }

      if (value.length > 1 && double.parse(value) > 999) {
        value = '${WealthyAmount.formatNumber(value)}';
      }
      fundSwitchInputFieldController.value =
          fundSwitchInputFieldController.value.copyWith(
        text: '$value',
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    update();
  }

  void resetLocalState() {
    // reset values
    selectedTrackerFundIndex = -1;
    selectedSwitchFundIndex = -1;
    selectedFundSwitchMethod = FundSwitchMethod.Amount;
    update();
  }

  void addSwitchFundToBasket() {
    double? units = selectedFundSwitchMethod == FundSwitchMethod.Unit
        ? getTextFieldAmount(fundSwitchInputFieldController)
        : null;
    double? amount = selectedFundSwitchMethod == FundSwitchMethod.Amount
        ? getTextFieldAmount(fundSwitchInputFieldController)
        : null;

    switchBasket.add({
      'switch_out':
          clientTrackerHoldings[selectedTrackerFundIndex].schemeMetaModel!,
      'switch_in': availableSwitchFunds[selectedSwitchFundIndex],
      'switch_method': selectedFundSwitchMethod,
      'units': units,
      'amount': amount,
    });

    LogUtil.printLog(switchBasket);
    update();
  }

  void deleteSwitchFundFromBasket(int basketIndex) {
    // if (switchBasket.containsKey(basketIndex)) {
    switchBasket.removeAt(basketIndex);
    update();
    // }
  }

  void initialiseEditSwitchFundField(int basketIndex) {
    // if (switchBasket.containsKey(basketIndex)) {
    Map<String, dynamic> switchObject = switchBasket[basketIndex];

    editSwitchFundFormKey = GlobalKey<FormState>();
    editFundSwitchMethod = switchObject['switch_method'];
    editSwitchFundFieldController = TextEditingController();
    String value = '';
    if (editFundSwitchMethod == FundSwitchMethod.Unit) {
      value = (switchObject['units'] ?? 0).toString();
    } else if (editFundSwitchMethod == FundSwitchMethod.Amount) {
      value = (switchObject['amount'] ?? 0).toString();
      if (value.length > 1 && double.parse(value) > 999) {
        value = '${WealthyAmount.formatNumber(value)}';
      }
    }
    editSwitchFundFieldController.value =
        editSwitchFundFieldController.value.copyWith(
      text: '$value',
      selection: TextSelection.collapsed(offset: value.length),
    );
    update();
    // }
  }

  void updateEditSwitchMethod(FundSwitchMethod selectedSwitchMethod) {
    editFundSwitchMethod = selectedSwitchMethod;
    editSwitchFundFieldController.clear();
    update();
  }

  void clearEditSwitchInputField() {
    editSwitchFundFieldController.clear();
    update();
  }

  void updateEditSwitchInputField(String value) {
    if (editFundSwitchMethod == FundSwitchMethod.Amount && value.isNotEmpty) {
      if (value[0] == '₹') {
        value = value.substring(2);
      }

      if (value.length > 1 && double.parse(value) > 999) {
        value = '${WealthyAmount.formatNumber(value)}';
      }
      editSwitchFundFieldController.value =
          fundSwitchInputFieldController.value.copyWith(
        text: '$value',
        selection: TextSelection.collapsed(offset: value.length),
      );
      update();
    }
  }

  void editSwitchFundBasket(int basketIndex) {
    Map<String, dynamic> switchObject = switchBasket[basketIndex];
    // if (switchBasket.containsKey(basketIndex)) {
    switchObject['switch_method'] = editFundSwitchMethod;
    switchObject['units'] = editFundSwitchMethod == FundSwitchMethod.Unit
        ? getTextFieldAmount(editSwitchFundFieldController)
        : null;
    switchObject['amount'] = editFundSwitchMethod == FundSwitchMethod.Amount
        ? getTextFieldAmount(editSwitchFundFieldController)
        : null;

    update();
    // }
  }
}
