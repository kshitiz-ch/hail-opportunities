import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/new_client_model.dart';
import 'package:core/modules/dashboard/models/branding_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class CalculatorController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ApiResponse brandingResponse = ApiResponse();
  BrandingModel? branding;

  ApiResponse reportPdfResponse = ApiResponse();
  File? pdfFile;

  final tabs = ['Input', 'Result'];
  int selectedTabIndex = 0;
  late TabController tabController;

  // Current active calculator type
  final Rx<CalculatorType> currentCalculatorType = CalculatorType.SipStepUp.obs;

  // Graph/Table tab selection (0 = Graph, 1 = Table)
  final RxInt selectedGraphTableTabIndex = 0.obs;

  // ========== Cached Calculation Result ==========
  // Stores the last calculated result for any calculator type
  final Rx<dynamic> cachedCalculationResult = Rx<dynamic>(null);

  // ========== SIP Calculator Fields ==========
  // Used by: calculateSIPData, calculateSIPSWPData, calculateSipLumpsumPlan
  final RxInt monthlyInvestment = 20000.obs;
  final int minMonthlyInvestment = 1000;
  final int maxMonthlyInvestment = 200000;

  // Used by: calculateLumpsumData, calculateSIPSWPData, calculateSipLumpsumPlan
  final RxInt lumpsumInvestment = 50000.obs;
  final int minLumpsumInvestment = 1000;
  final int maxLumpsumInvestment = 2000000;

  // ========== Common Investment Fields ==========
  // Used by: All calculators (SIP, Lumpsum, SWP, SIP+SWP, Goal Planning)
  final RxInt investmentPeriod = 5.obs;
  final int minInvestmentPeriod = 1; // 1 year
  final int maxInvestmentPeriod = 60; // 60 years

  // Used by: All calculators (SIP, Lumpsum, SWP, SIP+SWP, Goal Planning)
  final RxDouble expectedRateOfReturn = 12.0.obs;
  final double minExpectedRateOfReturn = 3.0; // 3%
  final double maxExpectedRateOfReturn = 13.0; // 13%

  // ========== Step-up Fields ==========
  // Used by: calculateSIPData, calculateSIPSWPData, calculateSipLumpsumPlan
  final RxDouble stepUpPercentage = 10.0.obs;
  final double minStepUpPercentage = 0.0; // 0%
  final double maxStepUpPercentage = 100.0; // 100%

  // Used by: calculateSIPData (step-up frequency)
  final RxString selectedFrequency = '6M'.obs;
  final List<String> frequencyOptions = ['6M', '1Y'];

  // ========== SWP (Systematic Withdrawal Plan) Fields ==========
  // Used by: calculateSWPData
  final RxInt currentCorpus = 2000000.obs;
  final int minCorpus = 100000;
  final int maxCorpus = 100000000;

  // Used by: calculateSWPData, calculateSIPSWPData
  final RxInt currentAge = 35.obs;
  final int minAge = 18;
  final int maxAge = 100;

  // Used by: calculateSWPData
  final RxDouble expectedReturnBeforeWithdrawal = 12.0.obs;
  final double minReturnBeforeWithdrawal = 3.0;
  final double maxReturnBeforeWithdrawal = 13.0;

  // Used by: calculateSWPData, calculateSIPSWPData
  final RxInt withdrawalStartAge = 55.obs;
  final int minWithdrawalStartAge = 18;
  final int maxWithdrawalStartAge = 100;

  // Used by: calculateSWPData, calculateSIPSWPData
  final RxInt monthlyWithdrawalAmount = 60000.obs;
  final int minMonthlyWithdrawal = 5000;
  final int maxMonthlyWithdrawal = 2000000;

  // Used by: calculateSWPData, calculateSIPSWPData
  final RxDouble yearlyIncreaseInWithdrawal = 5.0.obs;
  final double minYearlyIncrease = 0.0;
  final double maxYearlyIncrease = 100.0;

  // Used by: calculateSWPData, calculateSIPSWPData
  final RxDouble expectedReturnDuringWithdrawal = 10.0.obs;
  final double minReturnDuringWithdrawal = 3.0;
  final double maxReturnDuringWithdrawal = 13.0;

  // ========== SIP + SWP Combined Calculator Fields ==========
  // Used by: calculateSIPSWPData (age to stop SIP investments)
  final RxInt sipEndAge = 50.obs;
  final int minSipEndAge = 18;
  final int maxSipEndAge = 100;

  // ========== Goal Planning Calculator Fields ==========
  // Used by: calculateSipLumpsumPlan, calculateLumpsumPlan
  final RxInt targetCorpus = 10000000.obs; // 1 Crore
  final int minTargetCorpus = 100000; // 1 Lakh
  final int maxTargetCorpus = 20000000; // 20 Crore

  // Used by: calculateSipLumpsumPlan (years to continue SIP, can be < target period)
  final RxInt sipPeriod = 5.obs;
  final int minSipPeriod = 1;
  final int maxSipPeriod = 50;

  // Used by: calculateSipLumpsumPlan (whether to adjust target for inflation)
  final RxBool isInflationAdjusted = false.obs;

  // Used by: calculateSipLumpsumPlan (annual inflation rate %)
  final RxDouble inflationRate = 7.0.obs;
  final double minInflationRate = 1.0;
  final double maxInflationRate = 20.0;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
        length: 2, vsync: this, animationDuration: Duration(milliseconds: 100));
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        changeTab(tabController.index);
      }
    });
    getBrandingDetail();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTabIndex = index;
    tabController.animateTo(index);
    update();
  }

  Map<String, String> getCalculatorIconTitle(CalculatorType calculatorType) {
    String icon = AllImages().calculatorSipIcon;
    String title = 'SIP & Step-Up';

    switch (calculatorType) {
      case CalculatorType.SipStepUp:
        icon = AllImages().calculatorSipIcon;
        title = 'SIP & Step-Up';
        break;

      case CalculatorType.Lumpsum:
        icon = AllImages().calculatorLumpsumIcon;
        title = 'Lumpsum';
        break;

      case CalculatorType.SWP:
        icon = AllImages().calculatorSwpIcon;
        title = 'SWP';
        break;

      case CalculatorType.SipSwp:
        icon = AllImages().calculatorSipSwpIcon;
        title = 'SIP + SWP';
        break;

      case CalculatorType.GoalPlanningLumpsum:
        icon = AllImages().calculatorGoalLumpsumIcon;
        title = 'Goal Planning Lumpsum';
        break;
      case CalculatorType.GoalPlanningSIPLumpsum:
        icon = AllImages().calculatorGoalPlanningIcon;
        title = 'Goal Planning SIP Lumpsum';
        break;
    }

    return {
      'icon': icon,
      'title': title,
    };
  }

  List<Map<String, double>> calculateSIPData() {
    List<Map<String, double>> data = [];

    try {
      final totalMonths = (12 * investmentPeriod.value).toInt();
      if (totalMonths <= 0) {
        print('Error: Tenure must be positive.');
        return data;
      }

      // Convert frequency string to number of months
      int frequencyMonths = 0;
      if (selectedFrequency.value.isNotEmpty) {
        if (selectedFrequency.value == '6M') {
          frequencyMonths = 6;
        } else if (selectedFrequency.value == '1Y') {
          frequencyMonths = 12;
        }
      }

      // Calculate monthly equivalent rate for compound interest
      final monthlyRate =
          pow(1 + (expectedRateOfReturn.value / 100), 1 / 12) - 1;

      // Calculate monthly data
      List<Map<String, dynamic>> monthlyData = [];

      for (int monthIndex = 0; monthIndex < totalMonths; monthIndex++) {
        final month = monthIndex + 1;
        final year = (monthIndex / 12).floor() + 1;

        // Calculate total investment and value until this month
        double totalInvestment = 0;
        double previousTotalValue = 0;

        for (int i = 0; i <= monthIndex; i++) {
          final stepUpsForMonth =
              frequencyMonths > 0 ? (i / frequencyMonths).floor() : 0;
          final monthAmount = monthlyInvestment.value *
              pow(1 + (stepUpPercentage.value / 100), stepUpsForMonth);
          totalInvestment += monthAmount;

          // Add current month's investment to previous total value
          previousTotalValue += monthAmount;
          // Apply monthly return on the accumulated value
          previousTotalValue *= (1 + monthlyRate);
        }

        final gain = previousTotalValue.round() - totalInvestment.round();

        monthlyData.add({
          'month': month,
          'year': year,
          'investment': totalInvestment.round().toDouble(),
          'gain': gain.toDouble(),
          'total_value': previousTotalValue.round().toDouble(),
        });
      }

      // Group data by year if period > 1, otherwise return monthly data
      if (investmentPeriod.value > 1) {
        // Return yearly data
        for (int yearIndex = 0;
            yearIndex < investmentPeriod.value;
            yearIndex++) {
          final year = yearIndex + 1;
          final yearEndMonth = (yearIndex + 1) * 12 - 1;

          // Get the last month data of the year
          final lastMonthIndex = yearEndMonth < monthlyData.length
              ? yearEndMonth
              : monthlyData.length - 1;
          final lastMonthData = monthlyData[lastMonthIndex];

          data.add({
            'year': year.toDouble(),
            'investment': lastMonthData['investment'],
            'gain': lastMonthData['gain'],
            'total_value': lastMonthData['total_value'],
          });
        }
      } else {
        // Return monthly data
        for (int i = 0; i < monthlyData.length; i++) {
          final monthData = monthlyData[i];
          data.add({
            'month': monthData['month'].toDouble(),
            'year': monthData['year'].toDouble(),
            'investment': monthData['investment'],
            'gain': monthData['gain'],
            'total_value': monthData['total_value'],
          });
        }
      }
    } catch (e) {
      print('Error in calculateSIPData: $e');
    } finally {
      cachedCalculationResult.value = data;
      return data;
    }
  }

  List<Map<String, double>> calculateLumpsumData() {
    List<Map<String, double>> data = [];

    try {
      final yearlyRate = expectedRateOfReturn.value / 100;

      // Calculate yearly data directly using compound interest formula
      for (int yearIndex = 0; yearIndex < investmentPeriod.value; yearIndex++) {
        final year = yearIndex + 1;

        // For lumpsum, investment is made only once at the start
        final totalInvestment = lumpsumInvestment.value;

        // Calculate value after compound interest: A = P * (1 + r)^n
        final totalValue = lumpsumInvestment.value * pow(1 + yearlyRate, year);
        final gain = totalValue.round() - totalInvestment.round();

        data.add({
          'year': year.toDouble(),
          'investment': totalInvestment.round().toDouble(),
          'gain': gain.toDouble(),
          'total_value': totalValue.round().toDouble(),
        });
      }
    } catch (e) {
      print('Error in calculateLumpsumData: $e');
    } finally {
      cachedCalculationResult.value = data;
      return data;
    }
  }

  Map<String, dynamic> calculateSWPData() {
    try {
      List<Map<String, dynamic>> yearlyData = [];
      double corpus = currentCorpus.value.toDouble();
      double monthlyWithdrawal = monthlyWithdrawalAmount.value.toDouble();
      double corpusBeforeSwp = currentCorpus.value.toDouble();
      double corpusUsed = 0;
      int sustainTillAge = currentAge.value.toInt();
      double finalCorpus = 0;

      for (int age = currentAge.value.toInt(); age <= 100; age++) {
        bool isWithdrawalPhase = age >= withdrawalStartAge.value;
        double yearlyWithdrawalAmount = 0;
        double corpusEnd = 0;
        double investedAmount = corpus;
        double gainAmount = 0;

        if (!isWithdrawalPhase) {
          // Accumulation phase
          corpusEnd = corpus * (1 + expectedReturnBeforeWithdrawal.value / 100);
          gainAmount = corpusEnd - corpus;
        } else {
          // Withdrawal phase
          if (age > withdrawalStartAge.value) {
            monthlyWithdrawal *= (1 + yearlyIncreaseInWithdrawal.value / 100);
          }
          yearlyWithdrawalAmount = monthlyWithdrawal * 12;
          corpusEnd =
              corpus * (1 + expectedReturnDuringWithdrawal.value / 100) -
                  yearlyWithdrawalAmount;
          gainAmount = corpus * (expectedReturnDuringWithdrawal.value / 100);
        }

        // Store corpus before withdrawal starts
        if (age == withdrawalStartAge.value - 1) {
          corpusBeforeSwp = corpusEnd;
        }

        // Stop if corpus is depleted during withdrawal phase
        if (corpusEnd < 0 && isWithdrawalPhase) {
          // Both sustainTillAge and finalCorpus are already set to the correct values
          // from the last successful year in the previous iteration
          break;
        }

        // Calculate total corpus used during withdrawal
        if (isWithdrawalPhase) {
          corpusUsed += yearlyWithdrawalAmount;
        }

        final yearData = {
          'year': age,
          'monthly':
              isWithdrawalPhase ? monthlyWithdrawal.round().toDouble() : 0.0,
          'yearly': yearlyWithdrawalAmount.round().toDouble(),
          'year_end_corpus': corpusEnd.round().toDouble(),
          'investment': investedAmount.round().toDouble(),
          'gain': gainAmount.round().toDouble(),
          'total_value': corpusEnd.round().toDouble(),
        };
        yearlyData.add(yearData);

        // Update sustainTillAge and finalCorpus for successful years
        if (corpusEnd >= 0) {
          sustainTillAge = age;
          finalCorpus = corpusEnd;
        }

        corpus = corpusEnd;
      }

      final result = {
        'return_data': yearlyData,
        'sustain_till_age': sustainTillAge,
        'final_corpus': finalCorpus.round().toDouble(),
        'corpus_before_swp': corpusBeforeSwp.round().toDouble(),
        'corpus_used': corpusUsed.round().toDouble(),
      };

      cachedCalculationResult.value = result;
      return result;
    } catch (e) {
      print('Error in calculateSWPData: $e');
      cachedCalculationResult.value = {};
      return {};
    }
  }

  Map<String, dynamic> calculateSIPSWPData() {
    try {
      double corpus = lumpsumInvestment.value.toDouble();
      double totalInvested = lumpsumInvestment.value.toDouble();
      double withdrawal = monthlyWithdrawalAmount.value.toDouble();
      List<Map<String, dynamic>> yearlyData = [];
      double? corpusAtSipEnd;
      double? corpusBeforeSwp;
      double corpusUsed = 0;
      double leftoverCorpus = 0;
      int sustainTillAge = currentAge.value.toInt();

      for (int age = currentAge.value.toInt(); age <= 100; age++) {
        final isSip = age <= sipEndAge.value;
        final isSwp = age >= withdrawalStartAge.value;
        final thisYearSip = isSip
            ? monthlyInvestment.value *
                pow(1 + stepUpPercentage.value / 100, age - currentAge.value)
            : 0.0;
        double yearInvested = 0;
        double yearWithdrawn = 0;
        final yearStartCorpus = corpus;

        // Monthly compounding and SIP addition
        for (int m = 0; m < 12; m++) {
          if (isSip) {
            corpus += thisYearSip;
            yearInvested += thisYearSip;
          }
          corpus *= pow(
              1 +
                  (isSwp
                          ? expectedReturnDuringWithdrawal.value
                          : expectedRateOfReturn.value) /
                      100,
              1 / 12);
        }

        // Yearly withdrawal at year end (if in SWP phase)
        if (isSwp) {
          final yearlyWithdrawal = withdrawal * 12;
          if (corpus < yearlyWithdrawal) {
            yearWithdrawn = corpus;
            corpus = 0;
            // Both sustainTillAge and leftoverCorpus will already be set to the correct
            // values from the last successful iteration, so we don't need to set them here

            // Add final year data before breaking
            totalInvested += yearInvested;
            // yearlyData not added as corpus is depleted
            // yearlyData.add({
            //   'year': age - currentAge.value.toInt() + 1,
            //   'year_label': '$age',
            //   'year_start_corpus': yearStartCorpus.round().toDouble(),
            //   'investment': totalInvested.round().toDouble(),
            //   'gain': (yearStartCorpus - totalInvested).round().toDouble(),
            //   'corpus': corpus.round().toDouble(),
            //   'yearly_withdrawal': yearWithdrawn.round().toDouble(),
            //   'monthly_sip': thisYearSip.round().toDouble(),
            //   'yearly_sip': (thisYearSip * 12).round().toDouble(),
            //   'monthly_withdrawal': withdrawal.round().toDouble(),
            //   'phase': isSip && isSwp
            //       ? 'SIP+SWP'
            //       : isSip
            //           ? 'SIP'
            //           : isSwp
            //               ? 'SWP'
            //               : 'HOLD',
            // });
            break;
          } else {
            corpus -= yearlyWithdrawal;
            yearWithdrawn = yearlyWithdrawal;
            corpusUsed += yearlyWithdrawal;
          }
        }

        totalInvested += yearInvested;
        yearlyData.add({
          'year': age - currentAge.value.toInt() + 1,
          'year_label': '$age',
          'year_start_corpus': yearStartCorpus.round().toDouble(),
          'investment': totalInvested.round().toDouble(),
          'gain': (yearStartCorpus - totalInvested).round().toDouble(),
          'corpus': corpus.round().toDouble(),
          'yearly_withdrawal': isSwp ? yearWithdrawn.round().toDouble() : 0.0,
          'monthly_sip': thisYearSip.round().toDouble(),
          'yearly_sip': (thisYearSip * 12).round().toDouble(),
          'monthly_withdrawal': isSwp ? withdrawal.round().toDouble() : 0.0,
          'phase': isSip && isSwp
              ? 'SIP+SWP'
              : isSip
                  ? 'SIP'
                  : isSwp
                      ? 'SWP'
                      : 'HOLD',
        });

        if (age == sipEndAge.value.toInt()) corpusAtSipEnd = corpus;
        if (age == withdrawalStartAge.value.toInt() - 1)
          corpusBeforeSwp = corpus;

        // Update sustainTillAge and leftoverCorpus for successful years
        if (corpus > 0) {
          sustainTillAge = age;
          leftoverCorpus = corpus;
        }

        if (corpus == 0) break;
        if (isSwp) withdrawal *= (1 + yearlyIncreaseInWithdrawal.value / 100);
      }

      // Fallbacks if SIP or SWP never started
      corpusAtSipEnd ??= corpus;
      corpusBeforeSwp ??= corpus;

      final result = {
        'return_data': yearlyData,
        'sustain_till_age': sustainTillAge,
        'leftover_corpus': leftoverCorpus.round().toDouble(),
        'corpus_before_swp': corpusBeforeSwp.round().toDouble(),
        'corpus_used': corpusUsed.round().toDouble(),
        'corpus_at_sip_end': corpusAtSipEnd.round().toDouble(),
      };

      cachedCalculationResult.value = result;
      return result;
    } catch (e) {
      print('Error in calculateSIPSWPData: $e');
      cachedCalculationResult.value = {};
      return {};
    }
  }

  Map<String, dynamic> calculateSipLumpsumPlan() {
    try {
      final years = investmentPeriod.value.toInt();
      final inflationRateValue =
          isInflationAdjusted.value ? inflationRate.value : 0.0;

      // Calculate inflation-adjusted target
      final adjustedTarget = targetCorpus.value.toDouble() *
          pow(1 + (inflationRateValue / 100.0), years);
      final monthlyRate =
          pow(1 + (expectedRateOfReturn.value / 100), 1 / 12) - 1;
      final stepUpFactor = 1 + stepUpPercentage.value / 100;

      print('adjustedTarget: $adjustedTarget');

      // Helper: Calculate FV of step-up SIP for a given PMT
      double fvStepUpSIP(double pmt) {
        double fv = 0;
        for (int k = 0; k < years; k++) {
          final isSip = k < sipPeriod.value;
          final sipThisYear = isSip ? pmt * pow(stepUpFactor, k) : 0.0;

          for (int m = 0; m < 12; m++) {
            fv += sipThisYear;
            fv *= (1 + monthlyRate);
          }
        }
        return fv;
      }

      // Helper: Calculate FV of lumpsum
      double fvLumpsum() {
        return (lumpsumInvestment.value.toDouble() *
            pow(1 + expectedRateOfReturn.value / 100.0, years));
      }

      // Find required initial SIP using binary search
      double low = 0;
      double high = adjustedTarget;
      double initialSip = 0;

      for (int i = 0; i < 30; i++) {
        // 30 iterations is enough for convergence
        final mid = (low + high) / 2;
        final fvSIP = fvStepUpSIP(mid);
        final fvLS = fvLumpsum();
        if (fvSIP + fvLS < adjustedTarget) {
          low = mid;
        } else {
          high = mid;
        }
        initialSip = mid;
      }

      // Year-wise data
      final List<Map<String, dynamic>> yearWiseData = [];
      double sipInvested = 0;
      double sipTotal = 0;
      double sipGain = 0;

      for (int y = 0; y < years; y++) {
        // SIP calculations
        final isSip = y < sipPeriod.value;
        final sipThisYear = isSip ? initialSip * pow(stepUpFactor, y) : 0.0;

        for (int m = 0; m < 12; m++) {
          sipTotal += sipThisYear;
          sipTotal *= pow(1 + expectedRateOfReturn.value / 100, 1 / 12);
        }

        sipInvested += sipThisYear * 12;
        sipGain = sipTotal - sipInvested;

        // Lumpsum calculations
        final lumpsumTotal = lumpsumInvestment.value *
            pow(1 + expectedRateOfReturn.value / 100, y + 1);
        final lumpsumGain = lumpsumTotal - lumpsumInvestment.value;

        // Total calculations
        final totalInvested = sipInvested + lumpsumInvestment.value;
        final totalGain = sipGain + lumpsumGain;
        final totalAmount = sipTotal + lumpsumTotal;

        yearWiseData.add({
          'year': y + 1,
          'sip_invested': sipInvested.round().toDouble(),
          'sip_gain': sipGain.round().toDouble(),
          'sip_total': sipTotal.round().toDouble(),
          'lumpsum_invested': lumpsumInvestment.value.round().toDouble(),
          'lumpsum_gain': lumpsumGain.round().toDouble(),
          'lumpsum_total': lumpsumTotal.round().toDouble(),
          'total_invested': totalInvested.round().toDouble(),
          'total_gain': totalGain.round().toDouble(),
          'total_amount': totalAmount.round().toDouble(),
        });
      }

      final result = {
        'initial_sip': initialSip.round().toDouble(),
        'adjusted_target': adjustedTarget.round().toDouble(),
        'return_data': yearWiseData,
      };

      cachedCalculationResult.value = result;
      return result;
    } catch (e) {
      print('Error in calculateSipLumpsumPlan: $e');
      cachedCalculationResult.value = {};
      return {};
    }
  }

  Map<String, dynamic> calculateLumpsumPlan() {
    try {
      final years = investmentPeriod.value.toInt();

      // No inflation adjustment
      final adjustedTarget = targetCorpus.value;
      final yearlyRate = expectedRateOfReturn.value / 100;

      // Calculate required lumpsum using FV = PV * (1 + r)^n => PV = FV / (1 + r)^n
      final initialLumpsum = adjustedTarget / pow(1 + yearlyRate, years);

      // Year-wise data
      final List<Map<String, dynamic>> yearWiseData = [];
      final lumpsumInvested = initialLumpsum;

      for (int y = 0; y < years; y++) {
        final lumpsumTotal = initialLumpsum * pow(1 + yearlyRate, y + 1);
        final lumpsumGain = lumpsumTotal - initialLumpsum;
        final totalInvested = initialLumpsum;
        final totalGain = lumpsumGain;
        final totalAmount = lumpsumTotal;

        yearWiseData.add({
          'year': y + 1,
          'sip_invested': 0.0,
          'sip_gain': 0.0,
          'sip_total': 0.0,
          'lumpsum_invested': lumpsumInvested.round().toDouble(),
          'lumpsum_gain': lumpsumGain.round().toDouble(),
          'lumpsum_total': lumpsumTotal.round().toDouble(),
          'total_invested': totalInvested.round().toDouble(),
          'total_gain': totalGain.round().toDouble(),
          'total_amount': totalAmount.round().toDouble(),
        });
      }

      final result = {
        'initial_lumpsum': initialLumpsum.round().toDouble(),
        'adjusted_target': adjustedTarget.round().toDouble(),
        'return_data': yearWiseData,
      };

      cachedCalculationResult.value = result;
      return result;
    } catch (e) {
      print('Error in calculateLumpsumPlan: $e');
      cachedCalculationResult.value = {};
      return {};
    }
  }

  void updateMonthlyInvestment(int newValue) {
    // Allow values greater than max for monthly investment (currency field)
    // Allow minimum of 0, no upper limit
    if (newValue >= 0) {
      monthlyInvestment.value = newValue;
    }
  }

  void updateLumpsumInvestment(int newValue) {
    // Allow values greater than max for lumpsum investment (currency field)
    // Allow minimum of 0, no upper limit
    if (newValue >= 0) {
      lumpsumInvestment.value = newValue;
    }
  }

  void updateInvestmentPeriod(int newValue) {
    investmentPeriod.value =
        newValue.clamp(minInvestmentPeriod, maxInvestmentPeriod);
  }

  void updateExpectedRateOfReturn(double newValue) {
    if (newValue < minExpectedRateOfReturn ||
        newValue > maxExpectedRateOfReturn) {
      showToast(
          text:
              'The Expected Rate of Return must be greater than ${minExpectedRateOfReturn.toStringAsFixed(1)}% or less than ${maxExpectedRateOfReturn.toStringAsFixed(1)}%');
    }
    expectedRateOfReturn.value =
        newValue.clamp(minExpectedRateOfReturn, maxExpectedRateOfReturn);
  }

  void updateStepUpPercentage(double newValue) {
    stepUpPercentage.value =
        newValue.clamp(minStepUpPercentage, maxStepUpPercentage);
  }

  void updateSelectedFrequency(String newValue) {
    if (frequencyOptions.contains(newValue)) {
      selectedFrequency.value = newValue;
    }
  }

  void updateCurrentCorpus(int newValue) {
    // Allow values greater than max for corpus (currency field)
    // Allow minimum of 0, no upper limit
    if (newValue >= 0) {
      currentCorpus.value = newValue;
    }
  }

  void updateCurrentAge(int newValue) {
    currentAge.value = newValue.clamp(minAge, maxAge);
  }

  void updateExpectedReturnBeforeWithdrawal(double newValue) {
    if (newValue < minReturnBeforeWithdrawal ||
        newValue > maxReturnBeforeWithdrawal) {
      showToast(
          text:
              'The Expected Return Before Withdrawal must be greater than ${minReturnBeforeWithdrawal.toStringAsFixed(1)}% or less than ${maxReturnBeforeWithdrawal.toStringAsFixed(1)}%');
    }
    expectedReturnBeforeWithdrawal.value =
        newValue.clamp(minReturnBeforeWithdrawal, maxReturnBeforeWithdrawal);
  }

  void updateWithdrawalStartAge(int newValue) {
    withdrawalStartAge.value =
        newValue.clamp(minWithdrawalStartAge, maxWithdrawalStartAge);
  }

  void updateMonthlyWithdrawalAmount(int newValue) {
    // Allow values greater than max for withdrawal amount (currency field)
    // Allow minimum of 0, no upper limit
    if (newValue >= 0) {
      monthlyWithdrawalAmount.value = newValue;
    }
  }

  void updateYearlyIncreaseInWithdrawal(double newValue) {
    yearlyIncreaseInWithdrawal.value =
        newValue.clamp(minYearlyIncrease, maxYearlyIncrease);
  }

  void updateExpectedReturnDuringWithdrawal(double newValue) {
    if (newValue < minReturnDuringWithdrawal ||
        newValue > maxReturnDuringWithdrawal) {
      showToast(
          text:
              'The Expected Return During Withdrawal must be greater than ${minReturnDuringWithdrawal.toStringAsFixed(1)}% or less than ${maxReturnDuringWithdrawal.toStringAsFixed(1)}%');
    }
    expectedReturnDuringWithdrawal.value =
        newValue.clamp(minReturnDuringWithdrawal, maxReturnDuringWithdrawal);
  }

  // --- SIP + SWP Update Methods ---
  void updateSipEndAge(int newValue) {
    sipEndAge.value = newValue.clamp(minSipEndAge, maxSipEndAge);
  }

  // --- Goal Planning Update Methods ---
  void updateTargetCorpus(int newValue) {
    // Allow values greater than max for target corpus (currency field)
    // Allow minimum of 0, no upper limit
    if (newValue >= 0) {
      targetCorpus.value = newValue;
    }
  }

  void updateSipPeriod(int newValue) {
    sipPeriod.value = newValue.clamp(minSipPeriod, maxSipPeriod);
  }

  void updateIsInflationAdjusted(bool newValue) {
    isInflationAdjusted.value = newValue;
  }

  void updateInflationRate(double newValue) {
    inflationRate.value = newValue.clamp(minInflationRate, maxInflationRate);
  }

  void updateGraphTableTabIndex(int newIndex) {
    selectedGraphTableTabIndex.value = newIndex;
  }

  void changeCalculatorType(CalculatorType newType) {
    currentCalculatorType.value = newType;

    // Reset all fields to their default values
    _resetAllFields();

    // Reset tab controller to Input tab
    if (tabController.index != 0) {
      tabController.animateTo(0);
    }

    update(); // Notify listeners if not using Obx for all UI parts
  }

  /// Resets all input fields to their default values
  void _resetAllFields() {
    // Clear cached calculation result
    cachedCalculationResult.value = null;

    // SIP Calculator Fields
    monthlyInvestment.value = 20000;
    lumpsumInvestment.value = 50000;

    // Common Investment Fields
    investmentPeriod.value = 5;
    expectedRateOfReturn.value = 12.0;

    // Step-up Fields
    stepUpPercentage.value = 10.0;
    selectedFrequency.value = '6M';

    // SWP (Systematic Withdrawal Plan) Fields
    currentCorpus.value = 2000000;
    currentAge.value = 35;
    expectedReturnBeforeWithdrawal.value = 12.0;
    withdrawalStartAge.value = 55;
    monthlyWithdrawalAmount.value = 60000;
    yearlyIncreaseInWithdrawal.value = 5.0;
    expectedReturnDuringWithdrawal.value = 10.0;

    // SIP + SWP Combined Calculator Fields
    sipEndAge.value = 50;

    // Goal Planning Calculator Fields
    targetCorpus.value = 10000000;
    sipPeriod.value = 5;
    isInflationAdjusted.value = false;
    inflationRate.value = 6.0;

    // Reset graph/table tab to graph
    selectedGraphTableTabIndex.value = 0;

    selectedTabIndex = 0;
  }

  Future<void> getBrandingDetail() async {
    branding = null;
    brandingResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      final response =
          await AdvisorRepository().getBrandingDetail(apiKey, preview: false);

      if (response != null && response['status'] == '200') {
        brandingResponse.state = NetworkState.loaded;
        branding = BrandingModel.fromJson(response['response']);
      } else {
        brandingResponse.state = NetworkState.error;
        brandingResponse.message = 'No branding data received';
      }
    } catch (error) {
      brandingResponse.state = NetworkState.error;
      brandingResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  Map<String, dynamic> getUserAgentData({NewClientModel? selectedClient}) {
    final agentModel = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().advisorOverviewModel
        : null;
    final userAgentData = {
      'user_name': selectedClient?.name ?? 'NA',
      'crn': selectedClient?.crn,
      'agent_name': branding?.brandName ?? agentModel?.agent?.name ?? 'NA',
      'display_image': branding?.brandingLogoUrl,
      'arn': agentModel?.partnerArn?.arn ?? 'NA',
      'phone_number':
          branding?.businessNumber ?? agentModel?.agent?.phoneNumber,
      'email': agentModel?.agent?.email,
    };

    return userAgentData;
  }

  Map<String, dynamic> getCalculatorPayload({
    bool isIncludeTable = true,
    NewClientModel? selectedClient,
  }) {
    final calcType = currentCalculatorType.value;

    // Get user agent data
    final userAgentData = getUserAgentData(selectedClient: selectedClient);

    // Route to specific handler based on calculator type
    switch (calcType) {
      case CalculatorType.SipStepUp:
      case CalculatorType.Lumpsum:
        return _buildSipLumpsumPayload(calcType, userAgentData, isIncludeTable);

      case CalculatorType.GoalPlanningLumpsum:
      case CalculatorType.GoalPlanningSIPLumpsum:
        return _buildGoalPlanningPayload(
            calcType, userAgentData, isIncludeTable);

      case CalculatorType.SWP:
        return _buildSwpPayload(calcType, userAgentData, isIncludeTable);

      case CalculatorType.SipSwp:
        return _buildSipSwpPayload(calcType, userAgentData, isIncludeTable);
    }
  }

  /// Helper method to build SIP/Lumpsum payload
  Map<String, dynamic> _buildSipLumpsumPayload(
    CalculatorType calcType,
    Map<String, dynamic> userAgentData,
    bool isIncludeTable,
  ) {
    final isSip = calcType == CalculatorType.SipStepUp;
    final returnData = cachedCalculationResult.value;

    // Validate cached data
    if (returnData == null ||
        returnData is! List ||
        returnData.isEmpty ||
        returnData.first is! Map<String, double>) {
      print('Error: No valid cached calculation result found for SIP/Lumpsum');
      return {};
    }

    final data = returnData as List<Map<String, double>>;
    final finalValue = data.last;
    final finalInvestment = finalValue['investment'] ?? 0.0;
    final finalGain = finalValue['gain'] ?? 0.0;
    final finalTotalValue = finalValue['total_value'] ?? 0.0;
    final gainPercentage =
        finalInvestment > 0 ? (finalGain / finalInvestment) * 100 : 0.0;
    final periodLabelKey = investmentPeriod.value > 1 ? 'year' : 'month';

    // Prepare chart data
    final chartData = {
      'period_label': data.map((d) {
        final label =
            '${d[periodLabelKey]?.toStringAsFixed(0) ?? ''} $periodLabelKey';
        return label;
      }).toList(),
      'invested_amount': data.map((d) => d['investment'] ?? 0.0).toList(),
      'gained_amount': data.map((d) => d['gain'] ?? 0.0).toList(),
    };

    // Prepare table rows
    final tableRows = data.map((d) {
      final label =
          '${d[periodLabelKey]?.toStringAsFixed(0) ?? ''} $periodLabelKey';
      return {
        'period': label,
        'amount': d['investment'] ?? 0.0,
        'gain': d['gain'] ?? 0.0,
        'future_value': d['total_value'] ?? 0.0,
      };
    }).toList();

    // Build context
    final context = {
      ...userAgentData,
      'investment_period': '${investmentPeriod.value} Years',
      'expected_rate_of_return': expectedRateOfReturn.value,
      'your_future_value': finalTotalValue,
      'invested_amount': finalInvestment,
      'gain_amount': finalGain,
      'gain_percentage': '${gainPercentage.toStringAsFixed(2)}%',
      'chartdata': chartData,
      if (isIncludeTable)
        'tabledata': {
          'rows': tableRows,
        },
    };

    // Add calculator-specific fields
    if (isSip) {
      context['monthly_investment'] = monthlyInvestment.value;
      if (stepUpPercentage.value > 0) {
        context['step_up'] = stepUpPercentage.value;
        final frequencyMonths = selectedFrequency.value == '6M' ? 6 : 12;
        context['step_up_frequency'] = '$frequencyMonths Months';
      }
    } else {
      context['investment_amount'] = lumpsumInvestment.value;
    }

    return {
      'template_name': calcType.templateName,
      'context': context,
    };
  }

  /// Helper method to build Goal Planning payload
  Map<String, dynamic> _buildGoalPlanningPayload(
    CalculatorType calcType,
    Map<String, dynamic> userAgentData,
    bool isIncludeTable,
  ) {
    final isLumpsum = calcType == CalculatorType.GoalPlanningLumpsum;
    final cachedData = cachedCalculationResult.value;

    // Validate cached data
    if (cachedData == null || cachedData is! Map<String, dynamic>) {
      print(
          'Error: No valid cached calculation result found for Goal Planning');
      return {};
    }

    final returnData = cachedData['return_data'] as List<dynamic>?;
    final adjustedTarget = cachedData['adjusted_target'] ?? targetCorpus.value;
    final initialLumpsum = cachedData['initial_lumpsum'];
    final initialSip = cachedData['initial_sip'];

    if (returnData == null || returnData.isEmpty) {
      print('Error: No return data found in cached result');
      return {};
    }

    final finalValue = returnData.last as Map<String, dynamic>;
    final finalInvestment = finalValue['total_invested'] ?? 0.0;
    final finalGain = finalValue['total_gain'] ?? 0.0;
    final gainPercentage =
        finalInvestment > 0 ? (finalGain / finalInvestment) * 100 : 0.0;

    // Prepare chart data
    final chartData = {
      'period_label': returnData.map((d) => d['year'].toString()).toList(),
      'invested_amount':
          returnData.map((d) => d['total_invested'] ?? 0.0).toList(),
      'gained_amount': returnData.map((d) => d['total_gain'] ?? 0.0).toList(),
    };

    // Prepare table rows
    final tableRows = isLumpsum
        ? returnData.map((data) {
            return {
              'period': data['year'].toString(),
              'invested_value': data['total_invested'] ?? 0.0,
              'year_end_wealth': data['total_amount'] ?? 0.0,
              'gain': data['total_gain'] ?? 0.0,
            };
          }).toList()
        : returnData.map((data) {
            return {
              'period': data['year'].toString(),
              'sip_investment': data['total_invested'] ?? 0.0,
              'year_end_wealth': data['total_amount'] ?? 0.0,
              'gain': data['total_gain'] ?? 0.0,
            };
          }).toList();

    // Build context
    final context = {
      ...userAgentData,
      'target_corpus': targetCorpus.value,
      'adjusted_corpus': adjustedTarget,
      'time_to_reach_target': '${investmentPeriod.value} Years',
      'expected_rate_of_return': '${expectedRateOfReturn.value} %',
      'required_investment': isLumpsum ? initialLumpsum : initialSip,
      'invested_amount': finalInvestment,
      'gain_amount': finalGain,
      'gain_percentage': gainPercentage.toStringAsFixed(2),
      'chartdata': chartData,
      if (isIncludeTable)
        'tabledata': {
          'rows': tableRows,
        },
    };

    // Add SIP-specific fields only for SIP+Lumpsum calculator
    if (!isLumpsum) {
      context['lumpsum_investment'] = lumpsumInvestment.value;
      context['sip_period'] = '${sipPeriod.value} Years';
      context['annual_step_up'] = '${stepUpPercentage.value} %';
      context['inflation'] =
          isInflationAdjusted.value ? inflationRate.value : 0;
    }

    return {
      'template_name': calcType.templateName,
      'context': context,
    };
  }

  /// Helper method to build SWP payload
  Map<String, dynamic> _buildSwpPayload(
    CalculatorType calcType,
    Map<String, dynamic> userAgentData,
    bool isIncludeTable,
  ) {
    final cachedData = cachedCalculationResult.value;

    // Validate cached data
    if (cachedData == null || cachedData is! Map<String, dynamic>) {
      print('Error: No valid cached calculation result found for SWP');
      return {};
    }

    final returnData = cachedData['return_data'] as List<dynamic>?;
    final sustainTillAge = cachedData['sustain_till_age'] ?? currentAge.value;
    final corpusBeforeSwp = cachedData['corpus_before_swp'] ?? 0.0;
    final corpusUsed = cachedData['corpus_used'] ?? 0.0;
    final finalCorpus = cachedData['final_corpus'] ?? 0.0;

    if (returnData == null || returnData.isEmpty) {
      print('Error: No return data found in cached result');
      return {};
    }

    // Prepare chart data
    final chartData = {
      'period_label': returnData.map((d) => d['year'].toString()).toList(),
      'invested_amount': returnData.map((d) => d['investment'] ?? 0.0).toList(),
      'gained_amount': returnData.map((d) => d['gain'] ?? 0.0).toList(),
    };

    // Prepare table rows
    final tableRows = returnData.map((data) {
      return {
        'age': data['year'],
        'withdrawal_monthly': data['monthly'] ?? 0.0,
        'withdrawal_yearly': data['yearly'] ?? 0.0,
        'year_end_corpus': data['year_end_corpus'] ?? 0.0,
      };
    }).toList();

    return {
      'template_name': calcType.templateName,
      'context': {
        ...userAgentData,
        'investment_value': currentCorpus.value,
        'current_age': '${currentAge.value} Years',
        'expected_return_before_withdrawal':
            '${expectedReturnBeforeWithdrawal.value} %',
        'withdraw_start_age': '${withdrawalStartAge.value}',
        'monthly_withdrawal': monthlyWithdrawalAmount.value,
        'yearly_increase_in_withdrawl': '${yearlyIncreaseInWithdrawal.value} %',
        'expected_return_before_withdrawal_phase':
            '${expectedReturnDuringWithdrawal.value} %',
        'corpus_before_withdrawal': corpusBeforeSwp,
        'sustainable_till_age': '$sustainTillAge',
        'corpus_used_by_end': corpusUsed,
        'corpus_left_by_end': finalCorpus,
        'chartdata': chartData,
        if (isIncludeTable)
          'tabledata': {
            'rows': tableRows,
          },
      },
    };
  }

  /// Helper method to build SIP+SWP payload
  Map<String, dynamic> _buildSipSwpPayload(
    CalculatorType calcType,
    Map<String, dynamic> userAgentData,
    bool isIncludeTable,
  ) {
    final cachedData = cachedCalculationResult.value;

    // Validate cached data
    if (cachedData == null || cachedData is! Map<String, dynamic>) {
      print('Error: No valid cached calculation result found for SIP+SWP');
      return {};
    }

    final returnData = cachedData['return_data'] as List<dynamic>?;
    final sustainTillAge = cachedData['sustain_till_age'] ?? currentAge.value;
    final corpusAtSipEnd = cachedData['corpus_at_sip_end'] ?? 0.0;
    final corpusBeforeSwp = cachedData['corpus_before_swp'] ?? 0.0;
    final corpusUsed = cachedData['corpus_used'] ?? 0.0;
    final leftoverCorpus = cachedData['leftover_corpus'] ?? 0.0;

    if (returnData == null || returnData.isEmpty) {
      print('Error: No return data found in cached result');
      return {};
    }

    // Prepare table rows
    final tableRows = returnData.map((data) {
      return {
        'age': data['year_label'] ?? '',
        'lumpsum': 0,
        'sip_monthly': data['monthly_sip'] ?? 0.0,
        'sip_yearly': data['yearly_sip'] ?? 0.0,
        'withdrawal_monthly': data['monthly_withdrawal'] ?? 0.0,
        'withdrawal_yearly': data['yearly_withdrawal'] ?? 0.0,
        'year_beginning_corpus': data['year_start_corpus'] ?? 0.0,
        'year_end_corpus': data['corpus'] ?? 0.0,
      };
    }).toList();

    return {
      'template_name': calcType.templateName,
      'context': {
        ...userAgentData,
        'monthly_sip_amount': monthlyInvestment.value,
        'current_age': currentAge.value,
        'sip_end_age': sipEndAge.value,
        'annual_expected_return': expectedRateOfReturn.value,
        'step_up_frequency': stepUpPercentage.value,
        'monthly_withdrawal': monthlyWithdrawalAmount.value,
        'swp_start_age': withdrawalStartAge.value,
        'yearly_increase': yearlyIncreaseInWithdrawal.value,
        'withdrawal_return_rate': expectedReturnDuringWithdrawal.value,
        'corpus_at_sip_end': corpusAtSipEnd,
        'corpus_before_withdrawal': corpusBeforeSwp,
        'swp_end_age': sustainTillAge,
        'corpus_used_by_end': corpusUsed,
        'corpus_left_by_end': leftoverCorpus,
        'start_age': currentAge.value,
        'sip_amount': monthlyInvestment.value,
        'swp_amount': monthlyWithdrawalAmount.value,
        'annual_return': expectedRateOfReturn.value,
        'lumpsum_amount': lumpsumInvestment.value,
        // chart data not required for sip swp
        // 'chartdata': chartData,
        if (isIncludeTable)
          'tabledata': {
            'rows': tableRows,
          },
      },
    };
  }

  Future<void> downloadCalculatorReportPdf({
    required bool isIncludeTable,
    NewClientModel? selectedClient,
  }) async {
    reportPdfResponse.state = NetworkState.loading;
    update(['report-pdf']);

    try {
      final apiKey = await getApiKey() ?? '';
      final payload = getCalculatorPayload(
        isIncludeTable: isIncludeTable,
        selectedClient: selectedClient,
      );

      final response = await AdvisorRepository()
          .downloadCalculatorReportPdf(apiKey, payload);

      if (response != null && response['status'] == '200') {
        pdfFile = await savePdfReport(
          pdfBytes: response['response'],
          selectedClient: selectedClient,
        );
        reportPdfResponse.state = NetworkState.loaded;
      } else {
        reportPdfResponse.state = NetworkState.error;
        reportPdfResponse.message = 'No report data received';
      }
    } catch (error) {
      reportPdfResponse.state = NetworkState.error;
      reportPdfResponse.message = genericErrorMessage;
    } finally {
      update(['report-pdf']);
    }
  }

  Future<File?> savePdfReport({
    required Uint8List pdfBytes,
    NewClientModel? selectedClient,
  }) async {
    try {
      // Check storage permission
      PermissionStatus storageStatus = await getStorePermissionStatus();
      if (!storageStatus.isGranted) {
        LogUtil.printLog('Storage permission not granted');
        showToast(text: 'Please grant storage permission');
        return null;
      }

      // Get download path
      final downloadPath = await getDownloadPath();

      // Generate file name
      String finalFileName = currentCalculatorType.value.calculatorFileName;

      // Add CRN if client is provided
      if (selectedClient != null && selectedClient.crn != null) {
        finalFileName += '_${selectedClient.crn}';
      }

      // Add timestamp
      final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
      finalFileName = '${finalFileName}_$date';

      // Create file path
      final filePath = '$downloadPath/$finalFileName.pdf';

      // Save file
      final pdfFile = File(filePath);
      await pdfFile.writeAsBytes(pdfBytes);

      LogUtil.printLog('PDF saved successfully at: $filePath');

      return pdfFile;
    } catch (error) {
      LogUtil.printLog('Error saving PDF report: ${error.toString()}');
      showToast(text: 'Error saving file. Please try again');
      return null;
    }
  }

  String? precheckErrorMessage() {
    if (currentCalculatorType.value == CalculatorType.SipSwp) {
      final isAgeInvalid = withdrawalStartAge.value <= currentAge.value;
      if (isAgeInvalid) {
        return 'SWP start age must be greater than current age';
      }
      final isSipEndAgeInvalid = sipEndAge.value >= withdrawalStartAge.value;
      if (isSipEndAgeInvalid) {
        return 'SIP end age should be less than SWP start age';
      }
    }
    if (currentCalculatorType.value == CalculatorType.SWP) {
      final isAgeInvalid = withdrawalStartAge.value < currentAge.value;
      if (isAgeInvalid) {
        return 'Withdrawal start age cannot be less than current age.';
      }
    }
    if (currentCalculatorType.value == CalculatorType.GoalPlanningSIPLumpsum) {
      final isInvalidSIPPeriod = sipPeriod.value > investmentPeriod.value;
      if (isInvalidSIPPeriod) {
        return 'SIP period should be less than or equal to Time to Reach Target period.';
      }
    }
    return null;
  }
}
