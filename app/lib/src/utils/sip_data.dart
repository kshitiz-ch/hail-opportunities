import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SipData {
  bool isStepUpSipEnabled = false;
  List<int> selectedSipDays = [];
  late TextEditingController stepUpPercentageController;
  String stepUpPeriod = '6 Months';
  int stepUpPercentage = 0;
  bool get isSaved =>
      startDate != null && endDate != null && selectedSipDays.isNotEmpty;

  DateTime? startDate;
  DateTime? endDate;

  int tenure = 20;
  bool isIndefiniteTenure = false;
  bool isCustomTenure = false;

  late TextEditingController startDateController;
  late TextEditingController endDateController;

  SipData() {
    stepUpPercentageController = TextEditingController();
    // startDate = DateTime.now().add(Duration(days: 2));
    // by default end date will be 20 yrs from start date
    // endDate = startDate.add(Duration(days: 365 * 20));
    startDateController = TextEditingController();
    endDateController = TextEditingController();
  }

  String get formattedStepUpPeriod {
    if (stepUpPeriod == '6 Months') {
      return '6M';
    }
    return '1Y';
  }

  void updateSelectedSipDays(List<int> data) {
    selectedSipDays = data;
  }

  void updateIsStepUpSipEnabled(bool data) {
    isStepUpSipEnabled = data;
    if (!data) {
      this.stepUpPeriod = '6 Months';
      this.stepUpPercentage = 0;
      this.stepUpPercentageController = TextEditingController();
    }
  }

  void activateStepUpSip(String stepUpPeriod, int stepUpPercentage) {
    this.stepUpPeriod = stepUpPeriod;
    this.stepUpPercentage = stepUpPercentage;
    this.stepUpPercentageController.text = stepUpPercentage.toString();
  }

  void updateStartDate(DateTime date) {
    startDate = date;
    final dateText = DateFormat('dd/MM/yyyy').format(date);
    startDateController.value = startDateController.value.copyWith(
        text: dateText,
        selection: TextSelection.collapsed(offset: dateText.length));
  }

  void updateEndDate(DateTime date) {
    endDate = date;
    final dateText = DateFormat('dd/MM/yyyy').format(date);
    endDateController.value = endDateController.value.copyWith(
        text: dateText,
        selection: TextSelection.collapsed(offset: dateText.length));
  }
}
