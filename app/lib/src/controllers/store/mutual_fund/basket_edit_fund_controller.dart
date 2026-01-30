import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BasketEditFundController extends GetxController {
  ApiResponse sipStartEndDateResponse = ApiResponse();
  Client? client;
  TextEditingController amountController = TextEditingController();
  double? amountEntered;

  SipData sipData = SipData();

  List<DateTime> startMonths = [];
  List<int> startYearsAvailable = [];

  FocusNode amountFocusNode = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  BasketEditFundController(this.client, this.sipData, this.amountEntered);

  void onInit() {
    if (amountEntered.isNotNullOrZero) {
      amountController.text = amountEntered!.toStringAsFixed(0);
    } else {
      amountController.text = '';
    }

    if (sipData.startDate != null) {
      getSipStartMonth();
    }
    super.onInit();
  }

  bool get isSipDataMissing {
    return amount.isNullOrZero ||
        sipData.startDate == null ||
        sipData.endDate == null ||
        sipData.selectedSipDays.isEmpty;
  }

  double get amount {
    return amountController.text.isEmpty
        ? 0
        : double.parse(amountController.text
            .replaceAll(',', '')
            .replaceAll(' ', '')
            .replaceAll('₹', ''));
  }

  void updateTenure(
    int tenure, {
    bool isIndefiniteTenure = false,
    bool isCustomTenure = false,
  }) {
    sipData.tenure = tenure;
    sipData.isIndefiniteTenure = isIndefiniteTenure;
    sipData.isCustomTenure = isCustomTenure;
    if (sipData.startDate != null) {
      getSipStartEndDate();
    }
    update();
  }

  void updateStartDate(DateTime date) {
    sipData.startDate = date;

    if (sipData.isIndefiniteTenure) {
      // indefinite == year 2100
      final indefiniteTenure =
          2100 - (sipData.startDate ?? DateTime.now()).year;
      sipData.tenure = indefiniteTenure;
    }

    getSipStartEndDate();
    update();
  }

  Future<void> getSipStartMonth() async {
    startMonths.clear();
    startYearsAvailable.clear();

    try {
      String apiKey = await getApiKey() ?? '';

      String queryParam = '?';
      queryParam += 'sip_days=${sipData.selectedSipDays.join(",")}';
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      queryParam += '&current_date=$currentDate';

      var data = await StoreRepository().getSipStartMonth(
        apiKey,
        queryParam,
        client?.taxyID ?? '',
      );

      if (data['status'] == '200') {
        data["response"]["start_months"].forEach(
          (x) {
            int year = int.parse(x.split("-").first);
            int month = int.parse(x.split("-")[1]);
            DateTime monthDate = DateTime(year, month);
            startMonths.add(monthDate);
            if (!startYearsAvailable.contains(year)) {
              startYearsAvailable.add(year);
            }
          },
        );
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      update();
    }
  }

  Future<void> getSipStartEndDate() async {
    sipStartEndDateResponse.state = NetworkState.loading;
    update();
    // startMonths.clear();
    // startYearsAvailable.clear();

    try {
      String apiKey = await getApiKey() ?? '';

      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String queryParam = '?';
      queryParam += 'sip_days=${sipData.selectedSipDays.join(",")}';
      queryParam += '&start_month=${sipData.startDate?.month}';
      queryParam += '&start_year=${sipData.startDate?.year}';
      queryParam += '&tenure=${sipData.tenure}';
      queryParam += '&current_date=${currentDate}';

      var data = await StoreRepository().getSipStartEndDate(
        apiKey,
        queryParam,
        client?.taxyID ?? '',
      );

      if (data['status'] == '200') {
        sipData.startDate = WealthyCast.toDate(data["response"]["start_date"]);
        sipData.endDate = WealthyCast.toDate(data["response"]["end_date"]);
        sipStartEndDateResponse.state = NetworkState.loaded;
      } else {
        sipStartEndDateResponse.message =
            getErrorMessageFromResponse(data["response"]);
        sipStartEndDateResponse.state = NetworkState.error;
      }
    } catch (error) {
      sipStartEndDateResponse.message = genericErrorMessage;
      sipStartEndDateResponse.state = NetworkState.loaded;
    } finally {
      update();
    }
  }
}
