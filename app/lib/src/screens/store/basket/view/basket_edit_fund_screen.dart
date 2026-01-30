import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_edit_fund_controller.dart';
import 'package:app/src/screens/store/basket/widgets/select_tenure_bottomsheet.dart';
import 'package:app/src/screens/store/common_new/widgets/activate_step_up_sip.dart';
import 'package:app/src/screens/store/common_new/widgets/sip_day_selector_new.dart';
import 'package:app/src/screens/store/common_new/widgets/step_up_sip_info.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/select_start_month_bottomsheet.dart';

@RoutePage()
class BasketEditFundScreen extends StatelessWidget {
  const BasketEditFundScreen({
    Key? key,
    required this.fund,
    required this.basketController,
    required this.index,
  }) : super(key: key);

  final int index;
  final BasketController basketController;
  final SchemeMetaModel fund;

  @override
  Widget build(BuildContext context) {
    SipData? anyFundSipData = basketController.anyFundSipData[fund.basketKey];
    SipData sipData = SipData();
    if (anyFundSipData?.isSaved == true) {
      sipData.tenure = anyFundSipData?.tenure ?? 20;
      sipData.isCustomTenure = anyFundSipData?.isCustomTenure ?? false;
      sipData.isIndefiniteTenure = anyFundSipData?.isIndefiniteTenure ?? false;
      sipData.startDate = anyFundSipData?.startDate;
      sipData.endDate = anyFundSipData?.endDate;
      sipData.selectedSipDays = anyFundSipData?.selectedSipDays ?? [];
      if (anyFundSipData?.isStepUpSipEnabled == true) {
        sipData.isStepUpSipEnabled = true;
        sipData.activateStepUpSip(
          anyFundSipData?.stepUpPeriod ?? '',
          anyFundSipData?.stepUpPercentage ?? 0,
        );
      }
    }
    return GetBuilder<BasketEditFundController>(
      init: BasketEditFundController(
        basketController.selectedClient,
        sipData,
        fund.amountEntered,
      ),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'Edit Fund',
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildFundLogo(context),
                          _buildFundName(context),
                        ],
                      ),
                      SizedBox(height: 32),
                      _buildAmountTextField(context, controller),
                      SizedBox(height: 40),
                      _buildStepUpSip(context, controller),
                      SizedBox(height: 32),
                      _buildChooseSIPDays(context, controller),
                      SizedBox(height: 32),
                      _buildSipPeriod(context, controller)
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton:
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            if (isKeyboardVisible) {
              return SizedBox();
            }
            return ActionButton(
              isDisabled: controller.isSipDataMissing,
              onPressed: () {
                if (controller.formKey.currentState!.validate()) {
                  if (controller.isSipDataMissing) {
                    return showToast(
                        text: 'Please provide all the sip details');
                  }

                  if (fund.isNfo == true &&
                      fund.reopeningDate != null &&
                      fund.reopeningDate!
                          .isAfter(controller.sipData.startDate!)) {
                    return showToast(
                        text:
                            'Please select start date on or after ${DateFormat('dd MMM yyyy').format(fund.reopeningDate!)} when Fund reopens for SIP');
                  }

                  if (fund.sipRegistrationStartDate != null &&
                      fund.sipRegistrationStartDate!
                          .isAfter(controller.sipData.startDate!)) {
                    return showToast(
                        text:
                            'Please select start date on or after SIP Registration start date ${DateFormat('dd MMM yyyy').format(fund.sipRegistrationStartDate!)}');
                  }

                  basketController.anyFundSipData[fund.basketKey] =
                      controller.sipData;
                  basketController.basket[fund.basketKey]?.amountEntered =
                      controller.amount;
                  basketController.update(['basket']);
                  AutoRouter.of(context).popForced();
                }
              },
              text: 'Update',
            );
          }),
        );
      },
    );
  }

  Widget _buildFundLogo(context) {
    return CommonUI.buildRoundedFullAMCLogo(
      radius: 18,
      amcName: fund.displayName,
    );
  }

  Widget _buildFundName(context) {
    return Expanded(
      // flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund.displayName ?? '',
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
            ),
            // SizedBox(height: 5),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Text(
            //         getFundDescription(fund),
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //         style:
            //             Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            //                   color: ColorConstants.tertiaryBlack,
            //                 ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountTextField(
      BuildContext context, BasketEditFundController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Installment Amount',
              style: Theme.of(context)
                  .primaryTextTheme
                  .titleLarge!
                  .copyWith(color: ColorConstants.primaryAppColor),
            ),
            Tooltip(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: ColorConstants.black,
                  borderRadius: BorderRadius.circular(6)),
              triggerMode: TooltipTriggerMode.tap,
              textStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
              message: 'Amount that will debit on each SIP day',
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4).copyWith(top: 2),
                child: Icon(
                  Icons.info,
                  color: ColorConstants.tertiaryBlack,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            focusNode: controller.amountFocusNode,
            controller: controller.amountController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
            textAlign: TextAlign.left,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              errorStyle: Theme.of(context)
                  .primaryTextTheme
                  .titleMedium!
                  .copyWith(color: ColorConstants.redAccentColor),
              contentPadding: EdgeInsets.only(bottom: 10),
              isDense: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text("\₹ "),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: 'Enter Amount',
              hintStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: ColorConstants.secondaryLightGrey,
                        height: 1.4,
                      ),
            ),
            onChanged: (value) {
              onChanged(value, context, controller);
            },
            validator: (value) {
              return validator(value, controller);
            },
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Minimum SIP Amount ',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: ColorConstants.tertiaryBlack,
                    ),
              ),
              TextSpan(
                text: WealthyAmount.currencyFormat(fund.minSipDepositAmt, 0),
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                      color: ColorConstants.black,
                    ),
              )
            ],
          ),
        )
      ],
    );
  }

  void onChanged(
      String value, BuildContext context, BasketEditFundController controller) {
    if (value.isEmpty) {
    } else {
      value = value.replaceAll(',', '').replaceAll(' ', '').replaceAll('₹', '');
      value = '${WealthyAmount.currencyFormat(value, 0)}';
      // controller.amountController.value =
      //     controller.amountController.value.copyWith(
      //   text: '$value',
      //   selection: TextSelection.collapsed(offset: value.length),
      // );

      controller.update();
    }
  }

  String? validator(String? value, BasketEditFundController controller) {
    if (value?.isNullOrEmpty ?? true) {
      return 'Amount is required.';
    }

    double minAmount = getMinAmount(fund, basketController.investmentType,
        basketController.isTopUpPortfolio);

    if (controller.amount < minAmount) {
      return 'Minimum ${basketController.investmentType == InvestmentType.SIP ? 'sip ' : ''}amount is ${WealthyAmount.currencyFormat(minAmount, 0)}';
    }

    if (fund.isTaxSaver == true && controller.amount % (500) != 0) {
      return 'Amount must be in multiples of 500 for Tax Saving funds';
    }

    return null;
  }

  Widget _buildStepUpSip(
      BuildContext context, BasketEditFundController controller) {
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryGrey,
            );
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
            );

    SipData sipData = controller.sipData;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.secondaryWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: StepUpSipInfo(),
                  );
                },
                icon: Icon(Icons.info_outline),
                iconSize: 16,
                color: ColorConstants.primaryAppColor,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (sipData.isStepUpSipEnabled) {
                      openActivateStepUpSip(context, controller);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: sipData.isStepUpSipEnabled
                        ? Text.rich(
                            TextSpan(
                              text: 'Step-up SIP is ',
                              style: titleStyle,
                              children: [
                                TextSpan(
                                  text: 'Active',
                                  style: titleStyle?.copyWith(
                                    color: ColorConstants.greenAccentColor,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Text(
                            'Activate Step-up SIP',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstants.tertiaryBlack,
                                ),
                          ),
                  ),
                ),
              ),
              Container(
                height: 25,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: controller.sipData.isStepUpSipEnabled
                          ? ColorConstants.greenAccentColor.withOpacity(0.15)
                          : ColorConstants.secondaryLightGrey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 6,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: FittedBox(
                  child: CupertinoSwitch(
                    thumbColor: sipData.isStepUpSipEnabled
                        ? ColorConstants.greenAccentColor
                        : ColorConstants.secondaryLightGrey,
                    trackColor: Colors.white,
                    value: sipData.isStepUpSipEnabled,
                    activeColor: Colors.white,
                    onChanged: (value) async {
                      if (fund.isTaxSaver == true) {
                        return showToast(
                            text:
                                "Step-up is not allowed under tax saver funds");
                      }

                      if (value) {
                        openActivateStepUpSip(context, controller);
                      } else {
                        controller.sipData.updateIsStepUpSipEnabled(value);
                        controller.update();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        if (sipData.isStepUpSipEnabled &&
            sipData.stepUpPeriod.isNotNullOrEmpty &&
            sipData.stepUpPercentage != null)
          Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text.rich(
              TextSpan(
                text: 'Step up Period ',
                style: subtitleStyle,
                children: [
                  TextSpan(
                    text: sipData.stepUpPeriod,
                    style: subtitleStyle?.copyWith(
                      color: ColorConstants.black,
                    ),
                  ),
                  TextSpan(
                    text: ', Step up Percentage ',
                    style: subtitleStyle,
                  ),
                  TextSpan(
                    text: '${sipData.stepUpPercentage}%',
                    style: subtitleStyle?.copyWith(
                      color: ColorConstants.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void openActivateStepUpSip(
      BuildContext context, BasketEditFundController controller) {
    // SipData? anyFundSipData = controller.anyFundSipData[fund.basketKey];
    // double? amountEntered = controller.basket[fund.basketKey]?.amountEntered;

    if (controller.sipData.stepUpPercentage == 0) {
      controller.sipData.stepUpPercentageController.clear();
    } else {
      controller.sipData.stepUpPercentageController.text =
          controller.sipData.stepUpPercentage.toString();
    }

    CommonUI.showBottomSheet(
      context,
      child: ActivateStepUpSip(
        onUpdateStepUpPeriod: (stepUpPeriod, stepUpPercentage) {
          controller.sipData.activateStepUpSip(
            stepUpPeriod,
            stepUpPercentage,
          );
          controller.sipData.updateIsStepUpSipEnabled(true);
          controller.update();
          AutoRouter.of(context).popForced();
        },
        selectedStepUpPeriod: controller.sipData.stepUpPeriod,
        sipAmount: controller.amount,
        stepUpPercentage: controller.sipData.stepUpPercentage,
        stepUpPercentageController:
            controller.sipData.stepUpPercentageController,
      ),
    );
  }

  Widget _buildChooseSIPDays(
      BuildContext context, BasketEditFundController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SipDaySelectorNew(
          allowedSipDays: basketController.allowedSipDays.toList(),
          sipAmount: controller.amount,
          selectedSipDays: controller.sipData.selectedSipDays,
          onUpdateSipDays: (selectedDays) {
            controller.sipData.updateSelectedSipDays(selectedDays);
            controller.sipData.startDate = null;
            controller.sipData.endDate = null;
            controller.getSipStartMonth();
          },
        ),
        if (fund.isNfo == true &&
            fund.reopeningDate != null &&
            fund.reopeningDate!.isAfter(DateTime.now()))
          _buildStartDateInfo(context, fund.reopeningDate!)
        else if (fund.sipRegistrationStartDate != null &&
            fund.sipRegistrationStartDate!.isAfter(DateTime.now()))
          _buildStartDateInfo(context, fund.sipRegistrationStartDate!)
      ],
    );
  }

  Widget _buildStartDateInfo(BuildContext context, DateTime date) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: fund.isNfo == true
                  ? 'The fund will reopen for SIP from '
                  : 'SIP Registration Starts from ',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            TextSpan(
              text: DateFormat('dd MMM yyyy').format(date),
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.black,
                  ),
            ),
            TextSpan(
              text: '. Please Select Start Date after that',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    height: 1.4,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSipPeriod(
      BuildContext context, BasketEditFundController controller) {
    dynamic tenure = getSelectedTenure(controller, showCustomText: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select SIP Period',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Text(
          'Choose the investment duration',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: SelectTenureBottomSheet(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: ColorConstants.secondaryWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: ColorConstants.primaryAppColor,
                      ),
                      SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenure',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.tertiaryBlack),
                          ),
                          Text(
                            tenure is String ? '$tenure' : '$tenure Years',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: ColorConstants.black,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () {
                  if (controller.sipData.selectedSipDays.isEmpty) {
                    return showToast(text: 'Please select SIP days first');
                  }
                  CommonUI.showBottomSheet(
                    context,
                    child: SelectStartMonthBottomSheet(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                      color: ColorConstants.secondaryWhite,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Month',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: ColorConstants.tertiaryBlack),
                          ),
                          if (controller.sipData.startDate != null)
                            Text(
                              DateFormat('MMM yyyy')
                                  .format(controller.sipData.startDate!),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.w500),
                            )
                          else
                            Text('-')
                        ],
                      ),
                      Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: ColorConstants.black,
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 16),
        if (controller.sipStartEndDateResponse.state == NetworkState.loading)
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Checking Start and End Date',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                )
              ],
            ),
          )
        else if (controller.sipStartEndDateResponse.state == NetworkState.error)
          RetryWidget(
            controller.sipStartEndDateResponse.message,
            onPressed: controller.getSipStartEndDate,
          )
        else if (controller.sipData.startDate != null &&
            controller.sipData.endDate != null)
          Container(
            margin: EdgeInsets.only(top: 16),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: ColorConstants.sandColor,
              border: Border.all(color: ColorConstants.blondColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _buildStartEndDateText(context, controller),
          ),
      ],
    );
  }

  Widget _buildStartEndDateText(
      BuildContext context, BasketEditFundController controller) {
    String startMonth =
        getMonthDescription(controller.sipData.startDate?.month);
    int startYear = controller.sipData.startDate!.year;
    String startDay = getOrdinalNumber(controller.sipData.startDate!.day);

    String endMonth = getMonthDescription(controller.sipData.endDate?.month);
    int endYear = controller.sipData.endDate!.year;
    String endDay = getOrdinalNumber(controller.sipData.endDate!.day);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          color: ColorConstants.orangeColor,
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            'SIP will start from $startDay $startMonth $startYear  and ends on $endDay $endMonth $endYear',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
        ),
      ],
    );
  }
}
