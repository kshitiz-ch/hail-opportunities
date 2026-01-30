import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:core/modules/dashboard/models/dashboard_content_model.dart';
import 'package:core/modules/dashboard/resources/advisor_overview_repository.dart';
import 'package:core/modules/store/models/fixed_deposit_list_model.dart';
import 'package:core/modules/store/models/popular_products_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FixedDepositsController extends GetxController {
  // Fields

  // TODO: remove when old fd list screen is removed
  FixedDepositsModel fdsResult = FixedDepositsModel(products: []);

  FixedDepositListModel? fdListModel;

  String? defaultProviderId;

  AdvisorVideoModel? productVideo;

  NetworkState? fdsState;
  NetworkState? productVideoState;

  bool isProductVideoViewed = false;

  String? apiKey = '';
  String fdsErrorMessage = '';
  FixedDepositModel? selectedProduct;
  int? selectedTenureMonthPeriod;
  bool isSeniorCitizen = false;
  bool isMale = true;

  GlobalKey<FormState> tenureFormKey = GlobalKey<FormState>();
  TextEditingController monthInputController = TextEditingController();

  Map? chartData = {};
  double? highestInterestRate;

  GlobalKey<FormState> amountFormKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  int amount = 100000; // 1 lakh

  NetworkState? chartDataState;
  String? chartErrorMessage;
  NetworkState? proposalUrlState;
  String proposalUrl = '';
  int? agentId;

  bool isScreenLoading = true;

  NetworkState? fetchFDBannerState;
  List<BannerModel>? fdBannerList;

  final String downloadPortName = "download-fd-form";

  // to get latest chart data
  CancelToken? cancelToken;

  FixedDepositsController(this.defaultProviderId);

  @override
  void onInit() {
    fdsState = NetworkState.loading;
    super.onInit();
  }

  @override
  void onReady() async {
    apiKey = await getApiKey();
    agentId = await getAgentId();
    await fetchFDBanners();
    await getProductVideo();
    await getFds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isMonthInputValid() {
    final noOfMonths = int.tryParse(monthInputController.text);
    return noOfMonths != null &&
        noOfMonths >= fdListModel!.tenureMonths!.min! &&
        noOfMonths <= fdListModel!.tenureMonths!.max!;
  }

  /// get fds from the API
  Future<void> getFds() async {
    fdsState = NetworkState.loading;
    update();

    try {
      var response = await StoreRepository().getFdData(apiKey!);

      if (response['status'] == '200') {
        fdListModel = FixedDepositListModel.fromJson(response['response']);
        selectedTenureMonthPeriod = fdListModel!.tenureMonths!.min;
        monthInputController.text = selectedTenureMonthPeriod.toString();
        final amountText = WealthyAmount.formatNumber(amount.toString());
        amountController.value = amountController.value.copyWith(
          text: amountText,
          selection: TextSelection.collapsed(offset: amountText.length),
        );

        await getChartData();

        for (FixedDepositModel fd in fdListModel?.available ?? []) {
          if ((fd.fdProvider ?? '').toLowerCase() == defaultProviderId) {
            selectedProduct = fd;
            break;
          }
        }
        fdsState = NetworkState.loaded;
      } else {
        fdsErrorMessage = getErrorMessageFromResponse(response['response']);
        fdsState = NetworkState.error;
      }
    } catch (error) {
      fdsErrorMessage = 'Something went wrong';
      fdsState = NetworkState.error;
    } finally {
      update();
    }
  }

  Future<void> getProductVideo() async {
    try {
      productVideoState = NetworkState.loading;
      update();
      var videoResponse = await AdvisorOverviewRepository()
          .getProductVideos(ProductVideosType.FIXED_DEPOSIT);
      if (videoResponse['status'] == '200') {
        var video = videoResponse['response'];
        productVideo = AdvisorVideoModel.fromJson(video);

        isProductVideoViewed =
            await checkProductVideoViewed(ProductVideosType.FIXED_DEPOSIT);

        productVideoState = NetworkState.loaded;
      } else {
        productVideoState = NetworkState.error;
      }
    } catch (error) {
      productVideoState = NetworkState.error;
    } finally {
      update();
    }
  }

  void updateTenurePeriod(
      {int? month, bool isFromSlider = false, bool callApi = false}) {
    // if tenure is coming from slider make it multiple of 6
    // if tenure is coming from input text field use as it is
    if (isFromSlider) {
      int remainder = month! % 6;
      if (remainder != 0) {
        // move to next multiple of 6 ie upper bound
        // if input is not multiple of 6
        month += (6 - remainder);
      }
    }
    if (month != selectedTenureMonthPeriod) {
      selectedTenureMonthPeriod = month;
      final _newValue = month.toString();
      monthInputController.value = TextEditingValue(
        text: _newValue,
        selection: TextSelection.fromPosition(
          TextPosition(
            offset: _newValue.length,
          ),
        ),
      );
      if (callApi) {
        getChartData();
      } else {
        update();
      }
    } else {
      if (callApi) {
        getChartData();
      }
    }
  }

  void updateSelectedProduct(String newFdProvider) {
    if (selectedProduct?.fdProvider != newFdProvider) {
      selectedProduct = fdListModel?.available
          ?.firstWhereOrNull((element) => element.fdProvider == newFdProvider);
      update();
    }
  }

  Future<void> getChartData() async {
    if (cancelToken != null) {
      cancelToken!.cancel();
    }
    cancelToken = CancelToken();

    chartDataState = NetworkState.loading;
    // its possible that selected product is not present
    // in next chart data response due to even a slight change in payload data
    selectedProduct = null;
    update();

    try {
      Map<dynamic, dynamic> payload = {
        "is_senior_citizen": isSeniorCitizen.toString(),
        "gender": isMale ? "Male" : "Female",
        "tenure": selectedTenureMonthPeriod.toString(),
        "interest_payout_frequency": "Cumulative",
        "deposit_amount": amount.toString(),
      };

      final response = await StoreRepository().getFdInterestData(
        apiKey!,
        payload,
        cancelToken,
      );

      final bool isRequestCancelled = response?['isRequestCancelled'] ?? false;
      if (isRequestCancelled) return;

      if (response['status'] == '200') {
        chartData = response['response'];
        if (chartData != null && chartData!.isNotEmpty) {
          updateDefaultProduct();
        }

        chartDataState = NetworkState.loaded;
      } else {
        chartErrorMessage = getErrorMessageFromResponse(response['response']);
        chartDataState = NetworkState.error;
      }
    } catch (error) {
      chartErrorMessage = 'Something went wrong';
      chartDataState = NetworkState.error;
    } finally {
      isScreenLoading = false;
      update();
    }
  }

  void updateDefaultProduct() {
    //by default select highest interest rate product
    final sortedByInterestMap = Map.fromEntries(
      chartData!.entries.toList()
        ..sort(
          (e1, e2) =>
              e2.value['interest_rate'].compareTo(e1.value['interest_rate']),
        ),
    );
    String newFdProvider = sortedByInterestMap.entries.first.key;
    // calculate highest interest rate which will be used to
    // calculate height of graph dynamically
    highestInterestRate =
        (sortedByInterestMap.entries.first.value['interest_rate'] as double?);

    if (newFdProvider.isNotNullOrEmpty) {
      selectedProduct = fdListModel?.available
          ?.firstWhereOrNull((element) => element.fdProvider == newFdProvider);
    }
  }

  void updateGender(bool value) {
    if (value != isMale) {
      isMale = value;
      getChartData();
    }
  }

  void updateSeniorCitizen(bool value) {
    if (value != isSeniorCitizen) {
      isSeniorCitizen = value;
      getChartData();
    }
  }

  void updateAmount(String value) {
    amount = WealthyCast.toInt(value.replaceAll(',', '')) ?? 0;
    final amountText = WealthyAmount.formatNumber(
      value.isNullOrEmpty ? '' : amount.toString(),
    );

    amountController.value = amountController.value.copyWith(
      text: amountText,
      selection: TextSelection.collapsed(offset: amountText.length),
    );
    getChartData();
  }

  String? validateAmount(String? value) {
    if (value.isNullOrEmpty) {
      return 'Amount field is required';
    }
    final amountEntered = WealthyCast.toInt(value?.replaceAll(',', '')) ?? 0;

    final minAmount = fdListModel?.minAmount ?? defaultFdMinAmount;
    final maxAmount = fdListModel?.maxAmount ?? defaultFdMaxAmount;

    if (amountEntered < minAmount) {
      return 'Minimum deposit amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';
    }
    if (amountEntered > maxAmount) {
      return 'Maximum deposit amount is ${WealthyAmount.currencyFormat(maxAmount, 0)}';
    }

    if ((amountEntered % 1000) != 0) {
      return 'Amount should be in multiples of 1,000';
    }

    return null;
  }

  Future<void> getProposalUrl() async {
    try {
      proposalUrlState = NetworkState.loading;
      proposalUrl = '';
      update();

      // initiate screen loader
      AutoRouter.of(getGlobalContext()!).pushNativeRoute(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
        ),
      );

      int? agentId = await getAgentId();
      String apiKey = (await getApiKey())!;

      Map payload = {
        "agent_id": agentId.toString(),
        "user_id": null,
        "product_category": "Invest",
        "product_type": "fd",
        "product_type_variant": "fixed_deposit",
        "lumsum_amount": 0,
        "product_extras": null
      };
      final response = await StoreRepository().getCreateProposalUrl(
        apiKey,
        agentId,
        payload,
      );

      if (response['status'] == "200") {
        proposalUrl = response['response']['customer_url'];
        addQueryParam();
        proposalUrlState = NetworkState.loaded;
        showToast(
          text: 'Opening Fixed Deposit',
        );
      } else {
        handleApiError(response, showToastMessage: true);
        proposalUrlState = NetworkState.error;
      }
    } catch (error) {
      proposalUrlState = NetworkState.error;
      showToast(text: "Failed to create proposal. Please try again.");
    } finally {
      AutoRouter.of(getGlobalContext()!).popForced();
      update();
    }
  }

  void addQueryParam() async {
    proposalUrl += '&tenure=$selectedTenureMonthPeriod';
    proposalUrl += '&gender=${isMale ? 'Male' : 'Female'}';
    proposalUrl += '&is_senior_citizen=$isSeniorCitizen';
    proposalUrl += '&provider=${selectedProduct!.fdProvider}';
    proposalUrl += '&agent_id=$agentId';
    proposalUrl += '&deposit_amount=$amount';

    if (!proposalUrl.contains('app_version')) {
      String appVersion = await fetchAppVersion();
      proposalUrl += '&app_version=$appVersion';
    }
    if (!proposalUrl.contains('auth_code')) {
      proposalUrl += '&auth_code=$apiKey';
    }
    LogUtil.printLog('proposalUrl==>$proposalUrl');
  }

  Future<String> fetchAppVersion() async {
    PackageInfo packageInfo = await initPackageInfo();
    if (Platform.isAndroid) {
      return 'android-${packageInfo.version}';
    } else {
      return 'ios-${packageInfo.version}';
    }
  }

  Future<void> fetchFDBanners() async {
    try {
      fetchFDBannerState = NetworkState.loading;
      update();

      final data = await StoreRepository().fetchFDBanners();

      if (data['status'] == "200") {
        final bannerList = (SizeConfig().isTabletDevice
            ? data['response']['tablet']
            : data['response']['mobile']) as List;
        fdBannerList = bannerList
            .map<BannerModel>(
              (item) => BannerModel.fromJson(item),
            )
            .toList();
        fetchFDBannerState = NetworkState.loaded;
      } else {
        fetchFDBannerState = NetworkState.error;
      }
    } catch (error) {
      fetchFDBannerState = NetworkState.error;
    } finally {
      update();
    }
  }
}
