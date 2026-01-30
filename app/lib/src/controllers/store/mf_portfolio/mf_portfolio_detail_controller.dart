import 'package:api_sdk/api_collection/store_api.dart';
import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart' as constants;
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/client/add_client_controller.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/models/api_response_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/mutual_funds/models/store_fund_allocation.dart';
import 'package:core/modules/mutual_funds/resources/mutual_funds_repo.dart';
import 'package:core/modules/proposals/models/proposal_model.dart';
import 'package:core/modules/proposals/resources/proposals_repository.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';

class MFPortfolioDetailController extends GetxController {
  String? proposalUrl = '';
  String? portfolioName;

  final GoalSubtypeModel portfolio;
  final bool? isSmartSwitch;
  bool isTopUpPortfolio = false;

  /// Only used for Update Proposal Flow
  bool isUpdateProposal = false;
  ProposalModel? proposal;

  bool isMicroSIP;

  String? apiKey = '';
  int? agentId;

  NetworkState? fundsState;
  NetworkState? createProposalState;
  NetworkState? userMandateState;
  NetworkState? updateProposalState;

  List<ProposalModel> similarProposalsList = [];
  bool hasCheckedSimilarProposals = false;
  bool fromClientScreen = false;
  bool showSelectInvestmentTypeErrorText = false;

  StoreFundAllocation fundsResult = StoreFundAllocation();
  String fundsErrorMessage = '';
  String? userMandateStatus = '';
  String updateProposalErrorMessage = '';
  int fundsListCount = 0;

  InvestmentType? investmentType;
  InvestmentType? investmentTypeAllowed;

  final List<int> sipDays = [5, 10, 15, 20, 25];
  int? selectedSipDay = 5;

  final List<int> possibleSwitchPeriods = [3, 6, 9, 12];
  int? selectedSwitchPeriod;

  Client? selectedClient;

  late FundGraphView selectedGraphView;
  DateTime? basketMaxStartNavDate;

  TextEditingController? amountController;
  ScrollController? scrollController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> microSipFormKey = GlobalKey<FormState>();

  final Map<String?, SchemeMetaModel> microSIPBasket = {};

  SipData sipdata = SipData();
  RxList<int> allowedSipDays = RxList<int>();

  List<int> categoryReturnYearOptions = [1, 3, 5];
  int categoryReturnYearSelected = 1;

  // Constructor
  MFPortfolioDetailController({
    required this.portfolio,
    this.isSmartSwitch = false,
    this.selectedClient,
    this.fromClientScreen = false,
    this.isTopUpPortfolio = false,
    this.isUpdateProposal = false,
    this.investmentTypeAllowed,
    this.proposal,
  })  : assert(isUpdateProposal ? proposal != null : true),
        isMicroSIP = portfolio.productVariant == constants.microSipGoalSubtype;

  bool get isMfBasketPortfolio =>
      mfBasketPortfolioSubtypes.contains(portfolio.productVariant);

  // Getters
  double get allotmentAmount => amountController!.text.isEmpty
      ? 0
      : amountController!.text[0] == '₹'
          ? double.parse(
              amountController!.text.substring(2).replaceAll(',', ''))
          : double.parse(amountController!.text.replaceAll(',', ''));

  /// get total amount in the [microSIPBasket]
  double get totalMicroSIPAmount {
    var total = 0.0;
    microSIPBasket.forEach((key, fund) {
      total += (fund.amountEntered ?? 0);
    });
    return total;
  }

  /// Whether to show the Chart or not
  bool get showChart {
    if (isMicroSIP)
      return false;
    else if (isSmartSwitch!) {
      return false;
    } else
      return true;
  }

  // Whether to disable the Action button on MF Form Screen
  bool get disableActionButton {
    if (fundsState == NetworkState.loading) {
      return true;
    } else if (isMicroSIP) {
      return microSIPBasket.isEmpty;
    } else if (isSmartSwitch!) {
      if (portfolio.possibleSwitchPeriods!.isEmpty)
        return false;
      else
        return selectedSwitchPeriod == null;
    } else
      return false;
  }

  // Setters
  set allotmentAmount(double amt) {
    String string = amt.toStringAsFixed(0);

    if (string.length > 1 && double.parse(string) > 9999)
      string = '${WealthyAmount.formatNumber(string)}';

    amountController!.value = amountController!.value.copyWith(
      text: '${string}',
      selection: TextSelection.collapsed(offset: string.length + 2),
    );
  }

  @override
  void onInit() {
    selectedGraphView =
        showChart ? FundGraphView.Historical : FundGraphView.Custom;
    fundsState = NetworkState.loading;
    createProposalState = NetworkState.cancel;
    updateProposalState = NetworkState.cancel;

    if (investmentTypeAllowed != null) {
      investmentType = investmentTypeAllowed;
    } else {
      investmentType =
          isSmartSwitch! ? InvestmentType.oneTime : InvestmentType.SIP;
    }

    fundsListCount = isSmartSwitch! ? 4 : 3;
    amountController = TextEditingController();
    sipdata = SipData();
    if (isUpdateProposal) {
      updateSipDataFromProposal();
    }

    scrollController = ScrollController();
    allowedSipDays = Get.find<CommonController>().allowedSipDays;

    super.onInit();
  }

  @override
  Future<void> onReady() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();
  }

  @override
  void dispose() {
    amountController!.dispose();
    scrollController!.dispose();
    super.dispose();
  }

  void updateInvestmentType(InvestmentType type) {
    investmentType = type;
    updateShowSelectInvestmentTypeErrorText(false);
  }

  updateCategoryReturnYearSelected(int year) {
    categoryReturnYearSelected = year;
    update(['funds']);
  }

  void updateSelectedGraphView(FundGraphView graphView) {
    selectedGraphView = graphView;
    update(['graph-view']);
  }

  void updateSIPDay(int day) {
    selectedSipDay = day;

    update(['sip-day']);
  }

  void updateFundsListCount(int itemCount) {
    fundsListCount = itemCount;
    update(['funds']);
  }

  void updateSelectedSwitchPeriod(int switchPeriod) {
    selectedSwitchPeriod = switchPeriod;
    update(['possible-switch-period', 'action-button']);
  }

  Future<void> fetchStoreFunds(
    List schemes, [
    String userId = '',
  ]) async {
    String wSchemeCodes = '';
    String delimeter = ",";

    fundsState = NetworkState.loading;
    update(['funds', 'action-button']);

    try {
      if (schemes.isNotEmpty) {
        schemes.forEach((scheme) {
          wSchemeCodes += scheme["wschemecode"] + delimeter;
        });
      }

      final QueryResult response =
          await StoreAPI.getSchemeData(apiKey!, userId, wSchemeCodes);

      if (response.hasException) {
        response.exception!.graphqlErrors.forEach((graphqlError) {
          LogUtil.printLog(graphqlError.message);
        });
        fundsErrorMessage = "Something went wrong";
        fundsState = NetworkState.error;
      } else {
        fundsResult = StoreFundAllocation.fromJson(response.data!['metahouse']);

        if (isMfBasketPortfolio) {
          await getBasketMaxStartNavDate(fundsResult.schemeMetas!);
        }

        fundsResult.schemeMetas!.forEach((schemeMeta) {
          Iterable temp = schemes.where(
            (scheme) => schemeMeta.wschemecode == scheme['wschemecode'],
          );
          if (temp.isNotEmpty) {
            schemeMeta.idealWeight =
                temp.first["ideal_weight"] ?? temp.first["idealWeight"];
          }
        });

        // Sort by ideal weight
        if (isSmartSwitch!) {
          fundsResult.schemeMetas!.sort((a, b) {
            if (a.idealWeight != null && b.idealWeight != null) {
              return a.idealWeight!.compareTo(b.idealWeight!);
            }
            return 0;
          });
        }

        // Sort by AMC
        fundsResult.schemeMetas!.sort((a, b) => a.amc!.compareTo(b.amc!));
        // fundsResult.schemeMetas!.sort((a, b) => a.amc!.compareTo(b.amc!));

        // Sort by fund type (Debt fund should come first, then equity)
        // if (isSmartSwitch) {
        //   fundsResult.schemeMetas.sort((a, b) {
        //     if (a.amc == b.amc && a.fundType == "D") {
        //       return -1;
        //     }

        //     return 1;
        //   });
        // }

        LogUtil.printLog(fundsResult.schemeMetas);
        fundsState = NetworkState.loaded;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      fundsErrorMessage = "Something went wrong";
      fundsState = NetworkState.error;
    } finally {
      update(['funds', 'action-button']);
    }
  }

  Future<void> getBasketMaxStartNavDate(List<SchemeMetaModel> schemes) async {
    List<String> wSchemeCodes = [];

    try {
      if (schemes.isNotEmpty) {
        schemes.forEach((scheme) {
          wSchemeCodes.add(scheme.wschemecode!);
        });
      }

      String queryParam = '?wschemecodes=${wSchemeCodes.join(',')}';

      final data = await StoreAPI.getBasketMaxStartNavDate(apiKey!, queryParam);

      if (data["status"] == "200") {
        basketMaxStartNavDate =
            WealthyCast.toDate(data["response"]["data"]["nav_date"]);
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
    }
  }

  void updateFundsList(List<SchemeMetaModel> schemes) {
    fundsResult.schemeMetas = List.from(schemes);
    fundsState = NetworkState.loaded;
    update(['funds', 'action-button']);
  }

  /// Add fund & amount to the [microSIPBasket]
  void addMicroSIPFundToBasket(
    SchemeMetaModel fund,
    double? amount, {
    String toastMessage = "Fund Added Successfully!",
  }) {
    fund.amountEntered = amount;
    microSIPBasket[fund.basketKey] = fund;

    // Show Toast
    showToast(
      text: toastMessage,
    );

    update(['micro-sip', 'action-button']);
  }

  Map<String, dynamic> _createProductExtrasMap(bool isMicroSIP) {
    Map<String, dynamic> productExtrasMap = {};

    if (isTopUpPortfolio) {
      productExtrasMap["goal_id"] = portfolio.externalId;
    }

    // Required for update proposal flow and to make sure that goal_id
    // is there in the product_extras
    if (isUpdateProposal && proposal!.productExtrasJson!['goal_id'] != null) {
      productExtrasMap["goal_id"] = proposal!.productExtrasJson!['goal_id'];
    }

    productExtrasMap["order_type"] = investmentType!.name.toLowerCase();

    if (investmentType == InvestmentType.SIP) {
      productExtrasMap["sip"] = Map<String, dynamic>.from(
        {
          'sip_days': sipdata.selectedSipDays,
          'amount': isMicroSIP ? totalMicroSIPAmount : allotmentAmount,
          'start_date': sipdata.startDate!.toIso8601String().split('T')[0],
          'end_date': sipdata.endDate!.toIso8601String().split('T')[0],
        },
      );
      productExtrasMap["stepper"] = sipdata.isStepUpSipEnabled
          ? Map<String, dynamic>.from(
              {
                'increment_period': sipdata.formattedStepUpPeriod,
                'increment_percentage': sipdata.stepUpPercentage
              },
            )
          : {};
      productExtrasMap['version'] = 'v2';
    } else if (isSmartSwitch!) {
      productExtrasMap["switch_period"] = selectedSwitchPeriod;
    }

    if (isMicroSIP) {
      productExtrasMap["order_funds"] = microSIPBasket.entries
          .map(
            (basketFund) => {
              "amount": basketFund.value.amountEntered,
              "wschemecode": basketFund.key,
              "folio_number": null
            },
          )
          .toList();
      // if (investmentType == InvestmentType.SIP) {
      //   productExtrasMap['portfolio'] = {
      //     "funds": fundsResult.schemeMetas!
      //         .map((fund) => {"wschemecode": fund.wschemecode, "weight": 0})
      //         .toList()
      //   };
      // }
    }

    // TODO: update start date & end date in payload for proposal

    return productExtrasMap;
  }

  /// Send proposal to Client
  Future<void> createProposal(
      {bool isMicroSIP = false, bool fromSimilarProposalsList = false}) async {
    createProposalState = NetworkState.loading;
    update(['create-proposal']);

    try {
      // bool shouldCheckSimilarProposals = !hasCheckedSimilarProposals &&
      //     !(selectedClient?.isSourceContacts ?? false);
      // if (shouldCheckSimilarProposals) {
      //   hasCheckedSimilarProposals = true;
      //   await findSimilarProposals();
      // }

      bool isSimilarProposalsFound = similarProposalsList.length > 0;
      if (isSimilarProposalsFound && !fromSimilarProposalsList) {
        createProposalState = NetworkState.error;
        return;
      }

      if (selectedClient?.isSourceContacts ?? false) {
        bool isClientCreated = await addClientFromContacts();
        if (!isClientCreated) return;
      }

      bool useProposalV2 = true;

      Map<String, dynamic> extraDataMap = getProposalExtraData(useProposalV2);

      var data = await StoreRepository().addProposals(
        agentId!,
        selectedClient!.taxyID!,
        portfolio.productVariant!,
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
          portfolioName = WealthyCast.toStr(proposalData['proposal_name']);
        } else {
          proposalUrl = data['response']['customer_url'];
          portfolioName = WealthyCast.toStr(data['response']['display_name']);
        }
      } else {
        var message = getErrorMessageFromResponse(data['response']);
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

  /// Update Proposal
  Future<void> updateProposal() async {
    updateProposalState = NetworkState.loading;
    update([constants.GetxId.updateProposal]);

    try {
      bool useProposalV2 = true;
      Map<String, dynamic> extraDataMap = getProposalExtraData(useProposalV2);

      final response = await ProposalRepository().updateProposal(
        apiKey!,
        agentId!,
        proposal!.externalId!,
        allotmentAmount.toString(),
        extraDataMap,
      );

      if (response['status'] == '200') {
        if (useProposalV2) {
          Map<String, dynamic> proposalData = response['response']['data'];
          proposalUrl = proposalData['customer_url'];
          portfolioName = WealthyCast.toStr(proposalData['proposal_name']);
        } else {
          final data = response['response'];
          proposalUrl = data['response']['customer_url'];
          portfolioName = WealthyCast.toStr(data['response']['display_name']);
        }
        updateProposalState = NetworkState.loaded;
      } else {
        updateProposalErrorMessage =
            getErrorMessageFromResponse(response['response']);
        updateProposalState = NetworkState.error;
      }
    } catch (e) {
      LogUtil.printLog(e.toString());
      updateProposalErrorMessage = 'Something went wrong';
      updateProposalState = NetworkState.error;
    } finally {
      update([constants.GetxId.updateProposal]);
    }
  }

  Future<void> getUserMandateStatus() async {
    userMandateState = NetworkState.loading;
    try {
      final data = await MutualFundsRepository().getUserSipData(
        apiKey!,
        {
          "sip_day": selectedSipDay,
          "sip_amount": allotmentAmount,
          "user_id": selectedClient?.taxyID
        },
      );

      if (data['status'] == '200') {
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

  void setHasCheckedSimilarProposals() {
    hasCheckedSimilarProposals = true;
    update(['create-proposal']);
  }

  findSimilarProposals() async {
    try {
      var data = await StoreRepository().findSimilarProposals(
        agentId!,
        selectedClient!.taxyID!,
        portfolio.productVariant.toString(),
        apiKey!,
        getProposalExtraData(false),
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

  getProposalExtraData(bool isProposalV2) {
    if (isProposalV2) {
      String? goalId;
      if (isTopUpPortfolio) {
        goalId = portfolio.externalId;
      }

      // Required for update proposal flow and to make sure that goal_id
      // is there in the product_extras
      if (isUpdateProposal && proposal!.productExtrasJson!['goal_id'] != null) {
        goalId = proposal!.productExtrasJson!['goal_id'];
      }

      return {
        "amount":
            isMicroSIP ? totalMicroSIPAmount.toInt() : allotmentAmount.toInt(),
        "user_id": selectedClient?.taxyID,
        "goal_subtype_id": portfolio.productVariant,
        if (goalId.isNotNullOrEmpty) "goal_id": goalId,
        if (investmentType == InvestmentType.SIP)
          ...getSipDetailsPayload(sipdata),
        if (isSmartSwitch!) "switch_period": selectedSwitchPeriod,
      };
    }

    return {
      "product_type": "mf",
      "product_category": "Invest",
      "lumsum_amount": isMicroSIP ? totalMicroSIPAmount : allotmentAmount,
      "product_extras": _createProductExtrasMap(isMicroSIP)
    };
  }

  Future<bool> addClientFromContacts() async {
    RestApiResponse clientCreatedResponse =
        await AddClientController().addClientFromContacts(selectedClient!);
    if (clientCreatedResponse.status == 1) {
      selectedClient = clientCreatedResponse.data;
      update([constants.GetxId.createProposal]);
      return true;
    } else {
      // CommonUI.showMessageToast(
      //     clientCreatedResponse.message, ColorConstants.black);
      createProposalState = NetworkState.cancel;
      return false;
    }
  }

  /// Remove fund from [microSIPBasket]
  void removeMicroSIPFundFromBasket(SchemeMetaModel fund) {
    microSIPBasket.remove(fund.basketKey);

    update(['micro-sip', 'action-button']);
  }

  /// Reset [allotmentAmount] & [amountController]
  void resetAllotmentAmount() {
    amountController!.clear();
  }

  /// Reset [investmentType]
  void resetInvestmentType() {
    investmentType = isSmartSwitch! ? InvestmentType.oneTime : null;
  }

  /// Reset [selectedSipDay]
  void resetSelectedSipDay() {
    selectedSipDay = 5;
  }

  /// Reset [selectedClient]
  void resetSelectedClient() {
    selectedClient = null;
  }

  void updateShowSelectInvestmentTypeErrorText(bool val) {
    showSelectInvestmentTypeErrorText = val;
    update(['investment-type', 'error-text']);
  }

  /// Reset [allotmentAmount], [investmentType], [selectedClient] & [selectedSipDay]
  void resetMfForm() {
    resetAllotmentAmount();
    resetInvestmentType();
    resetSelectedClient();
    resetSelectedSipDay();
    updateShowSelectInvestmentTypeErrorText(false);
  }

  void updateSelectedSipDays(List<int> data) {
    sipdata.updateSelectedSipDays(data);
    update(['investment-type']);
  }

  void updateIsStepUpSipEnabled(bool data) {
    sipdata.updateIsStepUpSipEnabled(data);
    update(['investment-type']);
  }

  void activateStepUpSip(String stepUpPeriod, int stepUpPercentage) {
    sipdata.activateStepUpSip(stepUpPeriod, stepUpPercentage);
    update(['investment-type']);
  }

  void updateStartDate(DateTime date) {
    sipdata.updateStartDate(date);
    update(['investment-type']);
  }

  void updateEndDate(DateTime date) {
    sipdata.updateEndDate(date);
    update(['investment-type']);
  }

  void updateSipDataFromProposal() {
    // TODO: update start and end date

    Map<String, dynamic>? sipDataJson = proposal!.productExtrasJson!['sip'];
    Map<String, dynamic>? stepperDataJson =
        proposal!.productExtrasJson!['stepper'];

    if (sipDataJson != null) {
      sipdata.selectedSipDays = (sipDataJson['sip_days'] as List)
          .map((day) => WealthyCast.toInt(day)!)
          .toList();
      // update start date and end date
      final startDate = WealthyCast.toDate(sipDataJson['start_date']);
      final endDate = WealthyCast.toDate(sipDataJson['end_date']);
      if (startDate != null) {
        sipdata.updateStartDate(startDate);
      }
      if (endDate != null) {
        sipdata.updateEndDate(endDate);
      }
    }

    bool isStepperPresent = stepperDataJson != null &&
        stepperDataJson['increment_period'] != null &&
        stepperDataJson['increment_percentage'] != null;

    if (isStepperPresent) {
      final percentage =
          WealthyCast.toInt(stepperDataJson['increment_percentage']);
      final period = WealthyCast.toStr(stepperDataJson['increment_period']);

      sipdata.isStepUpSipEnabled = true;
      sipdata.stepUpPercentage = percentage ?? 0;
      sipdata.stepUpPercentageController =
          TextEditingController(text: (percentage ?? 0).toString());
      sipdata.stepUpPeriod = period == '1Y' ? '1 Year' : '6 Months';
    }
  }
}
