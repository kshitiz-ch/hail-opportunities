import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart'
    hide InvestmentType;
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/advisor/models/soa_folio_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/resources/mutual_funds_repo.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class BasketController extends GetxController {
  // Fields
  String? apiKey = '';
  int? agentId;

  String? proposalUrl = '';
  String? customPortfolioName;

  final Map<String?, SchemeMetaModel> basket;
  final Map<String?, FolioModel?> basketFolioMapping = {};
  Map<String?, SchemeMetaModel>? tempBasket;

  File? localFile;

  FileState? basketState;
  NetworkState? createProposalState;
  NetworkState? updateProposalState;
  NetworkState? userMandateState;

  GoalSubtypeModel? portfolio;
  bool isTopUpPortfolio = false;
  bool fromClientScreen = false;
  bool fromCustomPortfolios = false;

  bool showSelectInvestmentTypeErrorText = false;
  // bool showMinAmountErrorText = false;

  /// Only used for Update Proposal Flow
  bool isUpdateProposal = false;
  ProposalModel? proposal;

  List<ProposalModel> similarProposalsList = [];
  bool hasCheckedSimilarProposals = false;

  String createProposalErrorMessage = '';
  String? updateProposalErrorMessage = '';
  String? userMandateStatus = '';

  InvestmentType? investmentType = InvestmentType.SIP;
  InvestmentType? investmentTypeAllowed;

  TextEditingController? portfolioNameController;

  final List<int> sipDays = [5, 10, 15, 20, 25];
  RxList<int> allowedSipDays = RxList<int>();
  int? selectedSipDay = 5;

  Client? selectedClient;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// For AnimatedList
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  SipData customPortFolioSipData = SipData();
  Map<String, SipData> anyFundSipData = {};

  // Getters
  /// get total item count in the [basket]
  int get itemCount => basket.length;

  bool get isCustomPortfolio =>
      fromCustomPortfolios ||
      portfolio?.productVariant == otherFundsGoalSubtype;

  /// get total amount in the [basket]
  double get totalAmount {
    var total = 0.0;
    basket.forEach((key, fund) {
      total += (fund.amountEntered ?? 0);
    });
    return total;
  }

  double get totalMonthlyAmount {
    var total = 0.0;
    basket.forEach((key, fund) {
      if (investmentType == InvestmentType.SIP) {
        if (isCustomPortfolio) {
          total += (fund.amountEntered ?? 0) *
              customPortFolioSipData.selectedSipDays.length;
        } else {
          SipData? sipData = anyFundSipData[fund.basketKey];
          total += (fund.amountEntered ?? 0) *
              (sipData?.selectedSipDays ?? [1]).length;
        }
      } else {
        total += (fund.amountEntered ?? 0);
      }
    });

    return total;
  }

  List<SchemeMetaModel> get oneTimeBlockedFunds {
    List<SchemeMetaModel> blockedFunds = [];
    basket.entries.forEach((element) {
      if (element.value.isPaymentAllowed == false) {
        blockedFunds.add(element.value);
      }
    });

    return blockedFunds;
  }

  bool get hasOneTimeBlockedFunds {
    return oneTimeBlockedFunds.isNotEmpty;
  }

  bool get hasTaxSaverFunds {
    return basket.entries.any((element) => element.value.isTaxSaver == true);
  }

  List<SchemeMetaModel> get sipBlockedFunds {
    List<SchemeMetaModel> blockedFunds = [];
    basket.entries.forEach((element) {
      if (element.value.isSipAllowed == false) {
        blockedFunds.add(element.value);
      }
    });

    return blockedFunds;
  }

  bool get hasSipBlockedFunds {
    return sipBlockedFunds.isNotEmpty;
  }

  bool get hasNonNfoInBasket {
    return basket.entries.any((element) => element.value.isNfo != true);
  }

  bool get hasNfoInBasket {
    return basket.entries.any((element) => element.value.isNfo == true);
  }

  bool get hasUnStartedFundInBasket {
    return basket.entries
        .any((element) => element.value.sipRegistrationStartDate != null);
  }

  void shakeInvestmentTypeSelector() {
    update(['investment-type']);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    LogUtil.printLog(directory);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/basket.json');
  }

  // Constructor
  BasketController({
    Map<String?, SchemeMetaModel>? basket,
    this.portfolio,
    this.selectedClient,
    this.isTopUpPortfolio = false,
    this.fromClientScreen = false,
    this.isUpdateProposal = false,
    this.investmentTypeAllowed,
    this.proposal,
  })  : assert(isUpdateProposal ? proposal != null : true),
        investmentType = investmentTypeAllowed ?? InvestmentType.SIP,
        basket = basket ?? {};

  @override
  void onInit() {
    basketState = FileState.loading;
    createProposalState = NetworkState.cancel;
    updateProposalState = NetworkState.cancel;

    portfolioNameController = TextEditingController();

    // If Update Proposal Flow, initialize params
    if (isUpdateProposal) {
      tempBasket = {...basket};
      portfolio = GoalSubtypeModel(
        title: proposal!.displayName,
        minAmount: proposal?.productInfo?.minAmount ?? 0,
        productVariant: proposal!.productTypeVariant,
      );

      investmentType = getInvestmentTypeFromString(
        proposal!.productExtrasJson!['order_type'],
      );
      selectedSipDay = proposal!.productExtrasJson!['sip'] != null
          ? proposal!.productExtrasJson!['sip']['sip_day']
          : 5;
      updateStepperSipFromProposal();
    }
    allowedSipDays = Get.find<CommonController>().allowedSipDays;
    super.onInit();
  }

  @override
  void onReady() async {
    localFile = await _localFile;

    apiKey = await getApiKey();
    agentId = await getAgentId();
    if (!isTopUpPortfolio && !isUpdateProposal) {
      await getFunds();
    }

    super.onReady();
  }

  @override
  void dispose() {
    portfolioNameController!.dispose();

    super.dispose();
  }

  /// Get funds from File Storage
  Future<void> getFunds() async {
    try {
      basketState = FileState.loading;
      final File file = localFile ?? await _localFile;

      String jsonData = await file.readAsString();
      Map<String, dynamic> data = json.decode(jsonData);
      data.forEach((key, value) {
        basket[key] = SchemeMetaModel.fromJson(value);
      });
    } catch (error) {
      LogUtil.printLog("Error fetching basket data from File Storage!");
    } finally {
      basketState = FileState.loaded;
      update(['basket']);
    }
  }

  /// Add fund & amount to the [basket].
  /// Also used to update the [basket]
  void addFundToBasket(
      SchemeMetaModel fund, BuildContext context, double? amount,
      {String? toastMessage = "Fund Added Successfully!",
      bool isCustomFlow = false}) async {
    try {
      final file = localFile ?? await _localFile;

      // if (isUpdateProposal) {
      //   // Create a copy of fund before adding it to the basket
      //   basket[fund.basketKey] = fund.copyWith()..amountEntered = amount;
      // } else
      basket[fund.basketKey] = fund..amountEntered = amount;

      if (!isTopUpPortfolio && !isUpdateProposal) {
        // storing funds into local file
        await file.writeAsString('${json.encode(basket)}');
      }

      // Show Toast
      if (toastMessage != null) {
        showToast(
          context: context,
          text: toastMessage,
        );
      }
    } catch (error) {
      LogUtil.printLog("Something went wrong");
    } finally {
      if (!isCustomFlow) {
        update(['basket', 'total-investment', 'investment-type']);
      }
    }
  }

  /// Remove fund from [basket]
  Future<SchemeMetaModel?> removeFundFromBasket(SchemeMetaModel fund) async {
    SchemeMetaModel? removedItem;

    try {
      final file = localFile ?? await _localFile;

      if (isTopUpPortfolio && (fund.folioOverview?.exists ?? false)) {
        removedItem = basket.remove(fund.basketKey);
      } else {
        removedItem = basket.remove(fund.wschemecode);
      }

      if (anyFundSipData.containsKey(fund.basketKey)) {
        anyFundSipData.remove(fund.basketKey);
      }

      if (!isTopUpPortfolio && !isUpdateProposal) {
        await file.writeAsString('${json.encode(basket)}');
      }
    } catch (error) {
      LogUtil.printLog("Something went wrong");
    } finally {
      update(['basket', 'total-investment', 'investment-type']);
    }

    return removedItem;
  }

  /// Clears the [basket]
  Future<void> clearBasket() async {
    try {
      final file = localFile ?? await _localFile;

      basket.clear();
      anyFundSipData.clear();
      customPortFolioSipData = SipData();

      if (!isTopUpPortfolio && !isUpdateProposal) {
        file.writeAsString('${json.encode(basket)}');
      }
    } catch (error) {
      LogUtil.printLog("Something went wrong");
    } finally {
      update(['basket']);
    }
  }

  /// Reset [BasketController] paramaters
  Future<void> clearPortfolioParams() async {
    isTopUpPortfolio = false;
    isUpdateProposal = false;
    fromClientScreen = false;
    portfolio = null;
    selectedSipDay = 5;
  }

  /// Restore [basket] content for Proposal Flow
  void restoreBasket() {
    if (!isUpdateProposal) return;

    basket.addAll({...tempBasket!});

    List? schemes = proposal!.productExtrasJson!['order_funds'];

    basket.forEach((key, value) {
      var scheme =
          schemes!.firstWhereOrNull((scheme) => scheme["wschemecode"] == key);
      if (scheme != null) {
        value.amountEntered = scheme['amount'];
      }
    });
    investmentType = getInvestmentTypeFromString(
      proposal!.productExtrasJson!['order_type'],
    );
    selectedSipDay = proposal!.productExtrasJson!['sip'] != null
        ? proposal!.productExtrasJson!['sip']['sip_day']
        : 5;
    ;

    update(['basket']);
  }

  /// Update the selected Investment Type
  void updateInvestmentType(InvestmentType? type) {
    investmentType = type;
    updateShowSelectInvestmentTypeErrorText(false);
  }

  void updateShowSelectInvestmentTypeErrorText(bool val) {
    showSelectInvestmentTypeErrorText = val;
    update([
      'investment-type',
      'error-text',
      'total-investment',
      'basket',
    ]);
  }

  // void updateShowMinAmountErrorText(bool val) {
  //   showMinAmountErrorText = val;
  //   update(['error-text']);
  // }

  /// Update the selected SIP Day
  void updateSIPDay(int day) {
    selectedSipDay = day;

    update(['sip-day']);
  }

  Map<String, dynamic> _createProductExtrasMap({required bool isAnyFundFlow}) {
    Map<String, dynamic> productExtrasMap = {};

    if (isTopUpPortfolio) {
      productExtrasMap["goal_id"] = portfolio!.externalId;
    }

    // Required for update proposal flow and to make sure that goal_id
    // is there in the product_extras
    if (isUpdateProposal && proposal!.productExtrasJson!['goal_id'] != null) {
      productExtrasMap["goal_id"] = proposal!.productExtrasJson!['goal_id'];
    }

    productExtrasMap["order_type"] = investmentType!.name.toLowerCase();

    // bool isAnyFundFlow = !isOtherFundsFlow;
    // if (!isOtherFundsFlow && portfolio.productVariant != null)
    if (isAnyFundFlow && investmentType == InvestmentType.SIP) {
      productExtrasMap["order_funds"] = basket.entries
          .map(
            (basketFund) => {
              "amount": basketFund.value.amountEntered,
              "wschemecode": basketFund.value.wschemecode,
              if (basketFund.value.folioOverview?.exists ?? false)
                "folio_number": basketFund.value.folioOverview?.folioNumber,
              "scheme_display_name": basketFund.value.displayName,
              "sip": Map<String, dynamic>.from(
                {
                  'sip_days': anyFundSipData[basketFund.key]?.selectedSipDays,
                  'amount': basketFund.value.amountEntered,
                  'start_date': anyFundSipData[basketFund.key]
                      ?.startDate!
                      .toIso8601String()
                      .split('T')[0],
                  'end_date': anyFundSipData[basketFund.key]
                      ?.endDate!
                      .toIso8601String()
                      .split('T')[0],
                },
              ),
              "stepper": anyFundSipData[basketFund.key]!.isStepUpSipEnabled
                  ? Map<String, dynamic>.from(
                      {
                        'increment_period': anyFundSipData[basketFund.key]
                            ?.formattedStepUpPeriod,
                        'increment_percentage':
                            anyFundSipData[basketFund.key]?.stepUpPercentage
                      },
                    )
                  : {},
            },
          )
          .toList();
    } else {
      productExtrasMap["order_funds"] = basket.entries
          .map((basketFund) => {
                "amount": basketFund.value.amountEntered,
                "wschemecode": basketFund.value.wschemecode,
                if (basketFund.value.folioOverview?.exists ?? false)
                  "folio_number": basketFund.value.folioOverview?.folioNumber,
                if (isAnyFundFlow)
                  "scheme_display_name": basketFund.value.displayName
              })
          .toList();
    }

    if (investmentType == InvestmentType.SIP && !isAnyFundFlow) {
      productExtrasMap["sip"] = {
        "sip_days": customPortFolioSipData.selectedSipDays,
        'amount': totalAmount,
        'start_date':
            customPortFolioSipData.startDate!.toIso8601String().split('T')[0],
        'end_date':
            customPortFolioSipData.endDate!.toIso8601String().split('T')[0],
      };
      productExtrasMap["stepper"] = customPortFolioSipData.isStepUpSipEnabled
          ? {
              'increment_period': customPortFolioSipData.formattedStepUpPeriod,
              'increment_percentage': customPortFolioSipData.stepUpPercentage,
            }
          : {};

      productExtrasMap['portfolio'] = {"funds": []};
    }

    productExtrasMap['version'] = 'v2';

    // TODO: update start date & end date in payload for proposal

    return productExtrasMap;
  }

  /// Send proposal to Client
  Future<void> createProposal({bool fromSimilarProposalsList = false}) async {
    createProposalState = NetworkState.loading;
    update(['create-proposal']);

    try {
      String? productVariant = getProductVariant();

      // bool shouldCheckSimilarProposals =
      //     !hasCheckedSimilarProposals && !selectedClient!.isSourceContacts;
      // if (shouldCheckSimilarProposals) {
      //   hasCheckedSimilarProposals = true;
      //   await findSimilarProposals(productVariant);
      // }

      // bool isSimilarProposalsFound = similarProposalsList.length > 0;
      // if (isSimilarProposalsFound && !fromSimilarProposalsList) {
      //   createProposalState = NetworkState.error;
      //   return null;
      // }

      if (selectedClient?.isSourceContacts ?? false) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      bool useProposalV2 = true;

      Map<String, dynamic> extraDataMap = getProposalExtraData(
          isAnyFundFlow: productVariant == anyFundGoalSubtype,
          isProposalV2: useProposalV2);

      var data = await StoreRepository().addProposals(
        agentId!,
        selectedClient!.taxyID!,
        productVariant,
        apiKey!,
        extraDataMap,
        useProposalV2: useProposalV2,
        isSip: investmentType == InvestmentType.SIP,
      );

      if (data['status'] == "200" || data['status'] == "202") {
        createProposalState = NetworkState.loaded;

        if (useProposalV2) {
          Map<String, dynamic> proposalData = data['response']['data'];
          proposalUrl = proposalData['customer_url'];
          customPortfolioName =
              WealthyCast.toStr(proposalData['proposal_name']);
        } else {
          proposalUrl = data['response']['customer_url'];
          customPortfolioName =
              WealthyCast.toStr(data['response']['display_name']);
        }

        // Clear the basket
        // clearBasket();
      } else {
        var message = getErrorMessageFromResponse(data['response']);
        if ((message ?? "").toLowerCase().contains("wpc is invalid")) {
          MixPanelAnalytics.trackWithAgentId("wpc_invalid_error");
        }
        showToast(
          text: message,
        );
        createProposalState = NetworkState.error;
      }
    } catch (error) {
      showToast(
        text: 'Something went wrong',
      );
      createProposalState = NetworkState.error;
    } finally {
      update(['create-proposal']);
    }
  }

  String getProductVariant() {
    String? productVariant = portfolio?.productVariant;
    if (productVariant == null) {
      if (isCustomPortfolio) {
        productVariant = otherFundsGoalSubtype;
      } else {
        productVariant = anyFundGoalSubtype;
      }
    }

    return productVariant;
  }

  void setHasCheckedSimilarProposals() {
    hasCheckedSimilarProposals = true;
    update(['create-proposal']);
  }

  /// Update Proposal
  Future<void> updateProposal() async {
    updateProposalState = NetworkState.loading;
    update([GetxId.updateProposal]);

    try {
      final response = await ProposalRepository().updateProposal(
        apiKey!,
        agentId!,
        proposal!.externalId!,
        totalAmount.toString(),
        _createProductExtrasMap(
            isAnyFundFlow: proposal?.productTypeVariant == anyFundGoalSubtype),
      );

      if (response['status'] == '200') {
        final data = response['response'];
        proposalUrl = data['customer_url'];
        updateProposalState = NetworkState.loaded;
      } else {
        updateProposalErrorMessage = response['response']['message'];
        updateProposalState = NetworkState.error;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      updateProposalErrorMessage = 'Something went wrong';
      updateProposalState = NetworkState.error;
    } finally {
      if (updateProposalState == NetworkState.error) {
        showToast(
          text: updateProposalErrorMessage,
        );
      }
      update([GetxId.updateProposal]);
    }
  }

  findSimilarProposals(String productVariant) async {
    try {
      var data = await StoreRepository().findSimilarProposals(
        agentId!,
        selectedClient!.taxyID!,
        otherFundsGoalSubtype.toString(),
        apiKey!,
        getProposalExtraData(
            isAnyFundFlow: productVariant == anyFundGoalSubtype),
      );

      if (data['status'] == "200") {
        List<ProposalModel> proposalList = [];
        data['response'].forEach((element) {
          proposalList.add(ProposalModel.fromJson(element));
        });
        similarProposalsList = proposalList;
      } else {
        return handleApiError(data);
      }
    } finally {
      update();
    }
  }

  Future<void> getUserMandateStatus() async {
    userMandateState = NetworkState.loading;
    try {
      final data = await MutualFundsRepository().getUserSipData(
        apiKey!,
        {
          "sip_day": selectedSipDay,
          "sip_amount": totalAmount,
          "user_id": selectedClient?.taxyID
        },
      );

      if (data['status'] == '200') {
        // TODO: check user mandate required field
        userMandateStatus = data['response']['message'];
        userMandateState = NetworkState.loaded;
      } else {
        userMandateState = NetworkState.error;
      }
    } catch (error) {
      userMandateState = NetworkState.error;
    } finally {
      update();
    }
  }

  getProposalExtraData(
      {required bool isAnyFundFlow, bool isProposalV2 = false}) {
    if (isProposalV2) {
      String? goalId;
      if (isTopUpPortfolio) {
        goalId = portfolio!.externalId;
      }

      // Required for update proposal flow and to make sure that goal_id
      // is there in the product_extras
      if (isUpdateProposal && proposal!.productExtrasJson!['goal_id'] != null) {
        goalId = proposal!.productExtrasJson!['goal_id'];
      }

      if (isAnyFundFlow) {
        return {
          "amount": totalAmount.toInt(),
          "user_id": selectedClient?.taxyID,
          if (goalId.isNotNullOrEmpty) "goal_id": goalId,
          "funds": basket.entries
              .map(
                (basketFund) => {
                  "amount": basketFund.value.amountEntered?.toInt(),
                  "wpc": basketFund.value.wpc,
                  if (isTopUpPortfolio &&
                      (basketFund.value.folioOverview?.exists ?? false))
                    "folio_number": basketFund.value.folioOverview?.folioNumber
                  else if (basketFolioMapping[basketFund.value.wschemecode]
                          ?.folioNumber !=
                      null)
                    "folio_number":
                        basketFolioMapping[basketFund.value.wschemecode]
                            ?.folioNumber,
                  if (investmentType == InvestmentType.SIP)
                    ...getSipDetailsPayload(anyFundSipData[basketFund.key])
                },
              )
              .toList(),
          "goal_subtype_id": getProductVariant()
        };
      } else {
        return {
          "amount": totalAmount.toInt(),
          "user_id": selectedClient?.taxyID,
          if (goalId.isNotNullOrEmpty) "goal_id": goalId,
          if (investmentType == InvestmentType.SIP)
            ...getSipDetailsPayload(customPortFolioSipData),
          "funds": basket.entries
              .map(
                (basketFund) => {
                  "amount": basketFund.value.amountEntered?.toInt(),
                  "wpc": basketFund.value.wpc,
                  if (isTopUpPortfolio &&
                      (basketFund.value.folioOverview?.exists ?? false))
                    "folio_number": basketFund.value.folioOverview?.folioNumber
                  else if (basketFolioMapping[basketFund.value.wschemecode]
                          ?.folioNumber !=
                      null)
                    "folio_number":
                        basketFolioMapping[basketFund.value.wschemecode]
                            ?.folioNumber,
                },
              )
              .toList(),
          "goal_subtype_id": getProductVariant()
        };
      }
    } else {
      return {
        "product_type": "mf",
        "product_category": "Invest",
        "lumsum_amount": totalAmount,
        "product_extras": _createProductExtrasMap(isAnyFundFlow: isAnyFundFlow)
      };
    }
  }

  Future<bool> addClientFromContacts() async {
    RestApiResponse clientCreatedResponse =
        await AddClientController().addClientFromContacts(selectedClient!);
    if (clientCreatedResponse.status == 1) {
      selectedClient = clientCreatedResponse.data;
      update([GetxId.createProposal]);
      return true;
    } else {
      // CommonUI.showMessageToast(
      //     clientCreatedResponse.message, ColorConstants.black);
      createProposalState = NetworkState.cancel;
      return false;
    }
  }

  void initAnyFundsSipMapping() {
    basket.entries.forEach((element) {
      if (!anyFundSipData.containsKey(element.key!)) {
        anyFundSipData[element.key!] = SipData();
      }
    });
    update(['basket']);
  }

  void updateStepperSipFromProposal() {
    // TODO: update start and end date
    final isAnyFundFlow = proposal!.productTypeVariant == anyFundGoalSubtype;
    if (isAnyFundFlow) {
      final orderFunds =
          (proposal?.productExtrasJson?['order_funds'] ?? []) as List;
      for (int i = 0; i < orderFunds.length; i++) {
        final tempData = SipData();
        final sipDataJson = orderFunds[i]?['sip'];
        if (sipDataJson != null) {
          final isSipDaysPresent =
              sipDataJson != null && sipDataJson['sip_days'] != null;
          if (isSipDaysPresent) {
            tempData.selectedSipDays = (sipDataJson['sip_days'] as List)
                .map((e) => WealthyCast.toInt(e)!)
                .toList();
          }
          // update start date and end date
          final startDate = WealthyCast.toDate(sipDataJson['start_date']);
          final endDate = WealthyCast.toDate(sipDataJson['end_date']);
          if (startDate != null) {
            tempData.updateStartDate(startDate);
          }
          if (endDate != null) {
            tempData.updateEndDate(endDate);
          }
        }

        final isStepperPresent = orderFunds[i]!['stepper'] != null &&
            orderFunds[i]!['stepper']['increment_period'] != null &&
            orderFunds[i]!['stepper']['increment_percentage'] != null;
        if (isStepperPresent) {
          final percentage = WealthyCast.toInt(
              orderFunds[i]!['stepper']['increment_percentage']);
          final period =
              WealthyCast.toStr(orderFunds[i]!['stepper']['increment_period']);
          tempData.isStepUpSipEnabled = true;
          tempData.stepUpPercentage = percentage ?? 0;
          tempData.stepUpPercentageController =
              TextEditingController(text: (percentage ?? 0).toString());
          tempData.stepUpPeriod = period == '1Y' ? '1 Year' : '6 Months';
        }
        String fundIdentifier;
        String wschemecode = orderFunds[i]["wschemecode"];
        String? folioNumber = WealthyCast.toStr(orderFunds[i]['folio_number']);
        if (isTopUpPortfolio && folioNumber != null) {
          fundIdentifier = '$wschemecode$folioNumber';
        } else {
          fundIdentifier = wschemecode;
        }

        anyFundSipData[fundIdentifier] = tempData;
      }
    } else {
      anyFundSipData = {};
      customPortFolioSipData = SipData();
      final sipDataJson = proposal?.productExtrasJson?['sip'];
      if (sipDataJson != null) {
        final isSipDaysPresent = sipDataJson['sip_days'] != null;
        if (isSipDaysPresent) {
          customPortFolioSipData.selectedSipDays =
              (sipDataJson['sip_days'] as List)
                  .map((e) => WealthyCast.toInt(e)!)
                  .toList();
        }
        // update start date and end date
        final startDate = WealthyCast.toDate(sipDataJson['start_date']);
        final endDate = WealthyCast.toDate(sipDataJson['end_date']);
        if (startDate != null) {
          customPortFolioSipData.updateStartDate(startDate);
        }
        if (endDate != null) {
          customPortFolioSipData.updateEndDate(endDate);
        }
      }

      final isStepperPresent = proposal?.productExtrasJson?['stepper'] !=
              null &&
          proposal!.productExtrasJson!['stepper']['increment_period'] != null &&
          proposal!.productExtrasJson!['stepper']['increment_percentage'] !=
              null;
      if (isStepperPresent) {
        final percentage = WealthyCast.toInt(
            proposal!.productExtrasJson!['stepper']['increment_percentage']);
        final period = WealthyCast.toStr(
            proposal!.productExtrasJson!['stepper']['increment_period']);
        customPortFolioSipData.isStepUpSipEnabled = true;
        customPortFolioSipData.stepUpPercentage = percentage ?? 0;
        customPortFolioSipData.stepUpPercentageController =
            TextEditingController(text: (percentage ?? 0).toString());
        customPortFolioSipData.stepUpPeriod =
            period == '1Y' ? '1 Year' : '6 Months';
      }
    }
  }

  bool isSipFieldsValid({bool hideToast = false}) {
    if (isCustomPortfolio) {
      if (customPortFolioSipData.selectedSipDays.isNullOrEmpty) {
        if (!hideToast) {
          showToast(text: 'Choose SIP days');
        }
        return false;
      }

      if (customPortFolioSipData.isStepUpSipEnabled) {
        if (customPortFolioSipData.stepUpPercentage.isNullOrZero) {
          if (!hideToast) {
            showToast(text: 'Choose SIP Step Up Percentage');
          }
          return false;
        }
      }

      if (customPortFolioSipData.startDate == null ||
          customPortFolioSipData.endDate == null) {
        if (!hideToast) {
          showToast(text: 'Choose Start and End Date');
        }
        return false;
      }

      SchemeMetaModel? nfoFund = basket.entries
          .firstWhereOrNull((element) =>
              element.value.isNfo == true &&
              element.value.reopeningDate != null)
          ?.value;
      if (hasNfoInBasket &&
          customPortFolioSipData.startDate!.isBefore(nfoFund!.reopeningDate!)) {
        if (!hideToast) {
          showToast(
              text: 'Please select start date after Fund reopens for SIP');
        }
        return false;
      }

      SchemeMetaModel? fund = basket.entries
          .firstWhereOrNull(
              (element) => element.value.sipRegistrationStartDate != null)
          ?.value;
      if (hasUnStartedFundInBasket &&
          customPortFolioSipData.startDate!
              .isBefore(fund!.sipRegistrationStartDate!)) {
        if (!hideToast) {
          showToast(
              text:
                  'Please select start date after SIP Registration start date',
              duration: Duration(seconds: 3));
        }
        return false;
      }

      return true;
    } else {
      if (anyFundSipData.isEmpty) return true;
      bool isSipValid = true;
      for (var key in anyFundSipData.keys) {
        if (anyFundSipData[key]?.isSaved == false) {
          isSipValid = false;
          break;
        }
      }

      if (isSipValid == false && !hideToast) {
        showToast(text: 'Please enter SIP details for all funds');
      }

      return isSipValid;
    }
  }

  Future<void> getUserFolios() async {
    resetBasketSchemeFolios();

    update(['basket']);

    Map<String, List<SoaFolioModel>> folios = {};
    try {
      String apiKey = await getApiKey() ?? "";

      var response =
          await StoreRepository().getUserFolios(apiKey, selectedClient?.taxyID);
      if (response['status'] == '200') {
        final List data = response['response'];
        data.forEach((x) {
          SoaFolioModel folio = SoaFolioModel.fromJson(x);
          String? amc = AmcNumberCode[folio.amcCode];
          if (amc != null) {
            if (folios.containsKey(amc)) {
              folios[amc]!.add(folio);
              folios[amc]!.sort((a, b) {
                return (b.totalCurrentValue ?? 0)
                    .compareTo(a.totalCurrentValue ?? 0);
              });
            } else {
              folios[amc] = [folio];
            }
          }
        });

        basket.entries.forEach((x) {
          if (folios.containsKey(x.value.amc)) {
            List<SoaFolioModel> folioOverviews = folios[x.value.amc]!;

            // x.value.folioOverview = FolioModel(
            //   currentValue: folioOverviews.first.totalCurrentValue,
            //   units: folioOverviews.first.totalUnits,
            //   folioNumber: folioOverviews.first.folioNumber,
            // );

            basketFolioMapping[x.value.wschemecode] = FolioModel(
              currentValue: folioOverviews.first.totalCurrentValue,
              units: folioOverviews.first.totalUnits,
              folioNumber: folioOverviews.first.folioNumber,
            );

            x.value.folioOverviews = folioOverviews.map((x) {
              return FolioModel(
                currentValue: x.totalCurrentValue,
                units: x.totalUnits,
                folioNumber: x.folioNumber,
              );
            }).toList();
          }
        });
      }

      LogUtil.printLog(basket);
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update(['basket']);
    }
  }

  resetBasketSchemeFolios() {
    basketFolioMapping.clear();

    basket.entries.forEach((x) {
      x.value.folioOverview = null;
      x.value.folioOverviews = [];
    });
  }
}
