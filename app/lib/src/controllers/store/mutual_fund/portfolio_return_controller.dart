import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/fund_return_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:core/modules/store/resources/store_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortfolioReturnController extends GetxController {
  late InvestmentType selectedInvestmentType;
  late TextEditingController amountController;
  late TextEditingController periodController;

  late int sliderAmount;
  late int sliderPeriod;

  double? sliderAmountFromInput;
  double? sliderPeriodFromInput;

  String? amountErrorText;
  String? periodErrorText;

  ApiResponse portfolioReturnResponse = ApiResponse();

  List<int> availableAmountValues = <int>[
    100,
    500,
    1000,
    5000,
    10000,
    50000,
    100000,
    1000000,
    5000000,
    10000000
  ];
  List<int> availableSliderPeriodValues = <int>[1, 3, 5, 10, 20, 30, 40];

  List<int> sliderAmountValues = <int>[];
  List<int> sliderPeriodValues = <int>[];

  final GoalSubtypeModel portfolio;
  List<SchemeMetaModel> schemes = [];

  FundReturnModel? portfolioReturn;

  int maxSlider(FundReturnInputType type) {
    if (type == FundReturnInputType.Period) {
      return sliderPeriodValues.length - 1;
    }
    return sliderAmountValues.length - 1;
  }

  final minSlider = 0;

  String lastQueryParam = '';

  FocusNode periodFocusNode = FocusNode();

  DateTime? maxStartNavDate;

  PortfolioReturnController(this.portfolio, this.schemes, this.maxStartNavDate);

  @override
  void onInit() {
    super.onInit();
    sliderAmount = 0;
    sliderPeriod = 0;
    selectedInvestmentType =
        portfolio.isSmartSwitch ? InvestmentType.oneTime : InvestmentType.SIP;
    updateSliderAmount();
    updateSliderPeriod();
    amountController = TextEditingController(
      text: WealthyAmount.currencyFormat(sliderAmountValues[sliderAmount], 0),
    );
    periodController = TextEditingController(
        text: getPeriodText(sliderPeriodValues[sliderPeriod]));
    getPortfolioReturn();

    periodFocusNode.addListener(() {
      if (periodFocusNode.hasFocus) {
        final periodValue = getPeriodValue(periodController.text);
        periodController.value = periodController.value.copyWith(
          text: periodController.text,
          selection: TextSelection.collapsed(
            offset: periodValue.length,
          ),
        );
      }
    });
  }

  Future<void> getPortfolioReturn() async {
    portfolioReturnResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, int> allocationDetails = {};
      schemes.forEach((SchemeMetaModel scheme) {
        allocationDetails[scheme.wschemecode!] = scheme.idealWeight ?? 0;
      });
      // {"MABSB261GGR": 50, "MICIP2373GR": 50}
      final apiKey = await getApiKey() ?? '';
      Map<String, dynamic> payload = {
        "id_type": "wschemecode",
        "allocation_type": "percentage",
        "allocation_details": allocationDetails,
        "amount": WealthyCast.toInt(getAmountValue(amountController.text)),
        "period": WealthyCast.toInt(getPeriodValue(periodController.text)),
        "investment_type":
            selectedInvestmentType == InvestmentType.SIP ? "sip" : "onetime",
        if (selectedInvestmentType == InvestmentType.SIP) "sip_day": 28
      };

      final response = await StoreRepository().getBasketReturn(apiKey, payload);

      if (response["status"] == "200") {
        final jsonData = response['response'];
        if (jsonData != null) {
          portfolioReturn = FundReturnModel.fromJson(jsonData);
        }

        portfolioReturnResponse.state = NetworkState.loaded;
      } else {
        portfolioReturnResponse.state = NetworkState.error;
        portfolioReturnResponse.message = getErrorMessageFromResponse(response);
      }
    } catch (error) {
      portfolioReturnResponse.state = NetworkState.error;
      portfolioReturnResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  void updateInvestmentType(InvestmentType type) {
    if (type != selectedInvestmentType) {
      selectedInvestmentType = type;
      updateSliderAmount();

      // reset amount input & slider
      final amount = WealthyAmount.currencyFormat(sliderAmountValues.first, 0);

      amountController.value = amountController.value.copyWith(
        text: amount,
        selection: TextSelection.collapsed(offset: amount.length),
      );

      amountErrorText = null;
      sliderAmount = 0;
      sliderAmountFromInput = null;

      // update();
      getPortfolioReturn();
    }
  }

  void updateSliderAmount() {
    // update amount in slider values based on fund min amount
    sliderAmountValues = <int>[];
    late int minAmount;
    if (selectedInvestmentType == InvestmentType.oneTime) {
      minAmount = portfolio.minAmount?.toInt() ?? availableAmountValues.first;
    } else {
      minAmount =
          portfolio.minSipAmount?.toInt() ?? availableAmountValues.first;
    }
    sliderAmountValues.add(minAmount);

    for (int amount in availableAmountValues) {
      if (amount > minAmount) {
        sliderAmountValues.add(amount);
      }
    }
  }

  void updateSliderPeriod() {
    sliderPeriodValues = <int>[];
    if (maxStartNavDate == null) {
      // if max start nav date is null, period 1, 3, 5, 10 is used
      sliderPeriodValues = availableSliderPeriodValues.sublist(0, 4);
      return;
    }
    // max period is total period from launch date
    final maxPeriod =
        (DateTime.now().difference(maxStartNavDate!).inDays / 365).floor();

    if (maxPeriod == 1 || maxPeriod == 0) {
      // for same year launch sliderPeriodValues: [1]
      // min==max in slider
      // assertion error thrown
      // fix: add [0,1] as slider values
      sliderPeriodValues = [0, 1];
      // selecting 1 year by default
      sliderPeriod = 1;
      return;
    }

    for (final period in availableSliderPeriodValues) {
      if (period < maxPeriod) {
        sliderPeriodValues.add(period);
      } else {
        break;
      }
    }
    sliderPeriodValues.add(maxPeriod);
  }

  void updateReturnFromSlider(FundReturnInputType inputType, int value,
      {bool isEndReached = false}) {
    if (inputType == FundReturnInputType.Amount) {
      sliderAmount = value;
      sliderAmountFromInput = null;
      amountErrorText = null;
      final text =
          WealthyAmount.currencyFormat(sliderAmountValues[sliderAmount], 0);
      amountController.value = amountController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      if (sliderPeriodValues[value] < 1) {
        showToast(text: '0 year as period not allowed');
        return;
      }
      sliderPeriod = value;
      sliderPeriodFromInput = null;
      periodErrorText = null;
      final actualValue = sliderPeriodValues[sliderPeriod];
      final text = getPeriodText(actualValue);
      periodController.value = periodController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(
          offset: actualValue.toString().length,
        ),
      );
    }
    update();
    if (isEndReached) {
      getPortfolioReturn();
    }
  }

  void updateReturnFromTextField(FundReturnInputType inputType, String value) {
    if (inputType == FundReturnInputType.Amount) {
      value = getAmountValue(value);
    } else {
      value = getPeriodValue(value);
    }
    final textFieldValue = WealthyCast.toDouble(value) ?? 0;

    final valid = inputValidator(textFieldValue, inputType);
    if (valid.isNotNullOrEmpty) {
      if (textFieldValue.isNullOrZero) {
        if (inputType == FundReturnInputType.Amount) {
          amountController.value = amountController.value.copyWith(
            text: '',
            selection: TextSelection.collapsed(offset: 0),
          );
        } else {
          periodController.value = periodController.value.copyWith(
            text: '',
            selection: TextSelection.collapsed(offset: 0),
          );
        }
      } else {
        if (inputType == FundReturnInputType.Amount) {
          final text = WealthyAmount.currencyFormat(value, 0);
          amountController.value = amountController.value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        } else {
          final period = textFieldValue.toInt();
          value = getPeriodText(period);
          periodController.value = periodController.value.copyWith(
            text: value,
            selection:
                TextSelection.collapsed(offset: period.toString().length),
          );
        }
      }
      update();
      return;
    }

    // we have to move slider based on text field value
    // so we have to map text field value between slider min and max
    // we will find the upper bound of text field value in sliderAmountValues/sliderPeriodValues
    // ie first index where text field value is >= sliderAmountValues/sliderPeriodValues
    // let it be x
    // so upto index x-1 slider will have full active width
    // between x-1 & x slider will have partial active width
    // total partial width = total partial text field value/total allowed value b/w index x-1 & x

    if (inputType == FundReturnInputType.Amount) {
      final text = WealthyAmount.currencyFormat(value, 0);
      amountController.value = amountController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      final upperBoundSliderValue = sliderAmountValues.indexWhere(
        (test) => test >= textFieldValue,
      );
      double remainingSliderValue = 0;
      if (upperBoundSliderValue > minSlider) {
        // calculating active partial width
        remainingSliderValue =
            (textFieldValue - sliderAmountValues[upperBoundSliderValue - 1]) /
                (sliderAmountValues[upperBoundSliderValue] -
                    sliderAmountValues[upperBoundSliderValue - 1]);
      }
      sliderAmountFromInput =
          (upperBoundSliderValue - 1 + remainingSliderValue);
      // handle corner case under flow
      if (sliderAmountFromInput! < minSlider) {
        sliderAmountFromInput = minSlider.toDouble();
      }
    } else {
      final period = textFieldValue.toInt();
      value = getPeriodText(period);
      periodController.value = periodController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: period.toString().length),
      );
      final upperBoundSliderValue = sliderPeriodValues.indexWhere(
        (test) => test >= textFieldValue,
      );
      double remainingSliderValue = 0;
      if (upperBoundSliderValue > minSlider) {
        // calculating active partial width
        remainingSliderValue =
            (textFieldValue - sliderPeriodValues[upperBoundSliderValue - 1]) /
                (sliderPeriodValues[upperBoundSliderValue] -
                    sliderPeriodValues[upperBoundSliderValue - 1]);
      }
      sliderPeriodFromInput =
          (upperBoundSliderValue - 1 + remainingSliderValue);
      if (sliderPeriodFromInput! < minSlider) {
        sliderPeriodFromInput = minSlider.toDouble();
      }
    }
    // update();
    getPortfolioReturn();
  }

  String? inputValidator(
      double? textFieldValue, FundReturnInputType inputType) {
    if (inputType == FundReturnInputType.Amount) {
      if (textFieldValue.isNullOrZero) {
        amountErrorText = 'Amount is required';
      } else if (!(textFieldValue! >= sliderAmountValues.first &&
          textFieldValue <= sliderAmountValues.last)) {
        amountErrorText =
            'Amount should be between ${sliderAmountValues.first} and ${sliderAmountValues.last}';
      } else {
        amountErrorText = null;
      }
      return amountErrorText;
    } else {
      if (textFieldValue.isNullOrZero) {
        periodErrorText = 'Period is required';
      } else if (!(textFieldValue! >= sliderPeriodValues.first &&
          textFieldValue <= sliderPeriodValues.last)) {
        periodErrorText =
            'Period should be between ${sliderPeriodValues.first} and ${sliderPeriodValues.last}';
      } else {
        periodErrorText = null;
      }
      return periodErrorText;
    }
  }

  String getQueryParam() {
    String queryParam = '';

    queryParam += "amount=${getAmountValue(amountController.text)}";
    queryParam += "&period=${getPeriodValue(periodController.text)}";
    queryParam +=
        "&investment_type=${selectedInvestmentType.name.toLowerCase()}";
    if (selectedInvestmentType == InvestmentType.SIP) {
      queryParam += "&sip_day=${DateTime.now().day}";
    }
    return queryParam;
  }

  String getPeriodText(int period) {
    if (period > 1) {
      return '$period years';
    } else {
      return '$period year';
    }
  }

  String getPeriodValue(String value) {
    return value.replaceAll(' ', '').replaceAll('year', '').replaceAll('s', '');
  }

  String getAmountValue(String value) {
    return value.replaceAll(',', '').replaceAll(' ', '').replaceAll('₹', '');
  }
}
