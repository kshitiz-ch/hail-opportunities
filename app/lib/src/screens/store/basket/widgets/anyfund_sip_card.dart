import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnyFundSipCard extends StatelessWidget {
  const AnyFundSipCard({
    Key? key,
    required this.fund,
    required this.controller,
    required this.index,
  }) : super(key: key);

  final BasketController controller;
  final SchemeMetaModel fund;
  final int index;

  @override
  Widget build(BuildContext context) {
    SipData? sipData = controller.anyFundSipData[fund.basketKey] ?? SipData();

    return Container(
      decoration: BoxDecoration(
        border: !sipData.isSaved
            ? Border.all(
                color: ColorConstants.borderColor,
              )
            : null,
        borderRadius: BorderRadius.circular(15),
        color:
            sipData.isSaved ? ColorConstants.secondaryAppColor : Colors.white,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorConstants.borderColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonMfUI.buildFundLogo(context, fund),
                      CommonMfUI.buildFundName(
                        context,
                        fund,
                        // showFolio: false,
                        showFolio: (!controller.isUpdateProposal &&
                            !controller.isTopUpPortfolio),
                        onAddNewFolio: () {
                          if (controller.basketFolioMapping
                              .containsKey(fund.wschemecode)) {
                            controller.basketFolioMapping
                                .remove(fund.wschemecode);
                          }

                          controller.update(['basket']);
                          AutoRouter.of(context).popForced();
                        },
                        onSelectFolio: (FolioModel folioOverview) {
                          controller.basketFolioMapping[fund.wschemecode] =
                              FolioModel.clone(folioOverview);
                          controller.update(['basket']);
                          AutoRouter.of(context).popForced();
                        },
                        folioNumber: controller
                            .basketFolioMapping[fund.wschemecode]?.folioNumber,
                      ),
                      _buildActions(context, isSaved: sipData.isSaved),
                    ],
                  ),
                ),
                CommonMfUI.buildFundDisabledRibbon(fund)
              ],
            ),
          ),
          _buildSipDetails(context, sipData),
          if (sipData.isSaved != true)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ActionButton(
                text: 'Enter SIP Details',
                onPressed: () {
                  if (controller.selectedClient == null) {
                    return showToast(text: 'Please select a client first');
                  }

                  if (fund.isSipAllowed == false) {
                    return showToast(text: 'SIP is disabled for this fund');
                  }

                  AutoRouter.of(context).push(
                    BasketEditFundRoute(
                      fund: fund,
                      basketController: controller,
                      index: index,
                    ),
                  );
                },
              ),
            ),
          if (fund.isSif == true) _buildSifNote(context)
        ],
      ),
    );
  }

  Widget _buildSifNote(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: ColorConstants.primaryAppColor,
            size: 20,
          ),
          SizedBox(width: 2),
          Expanded(
            child: Text(
              'Minimum ₹10 L holdings in this scheme required to set up an SIP.',
              style: context.titleLarge!.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipDetails(BuildContext context, SipData sipData) {
    String sipDays = '';
    bool showSipDayTooltip = false;
    if (sipData.selectedSipDays.isNotNullOrEmpty) {
      if (sipData.selectedSipDays.length > 3) {
        sipDays = sipData.selectedSipDays.sublist(0, 3).join(', ');
      } else {
        sipDays = sipData.selectedSipDays.join(', ');
      }
      final remainingDays = sipData.selectedSipDays.length - 3;
      if (remainingDays > 0) {
        sipDays += ', +$remainingDays days';
        showSipDayTooltip = true;
      }
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildColumnText(
                  context,
                  customLabel: Tooltip(
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
                    child: Row(
                      children: [
                        Text(
                          'Installment Amount',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                  height: 1.4,
                                  fontSize: 14),
                        ),
                        SizedBox(width: 5),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.info,
                            color: ColorConstants.tertiaryBlack,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  value: fund.amountEntered != null
                      ? WealthyAmount.currencyFormat(
                          fund.amountEntered.toString(), 0)
                      : '-',
                ),
              ),
              Expanded(
                child: _buildColumnText(
                  context,
                  label: 'Investment Type',
                  value: 'SIP',
                ),
              )
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildColumnText(
                  context,
                  label: 'Tenure',
                  value: sipData.tenure.isNotNullOrZero
                      ? '${sipData.tenure} years'
                      : '-',
                ),
              ),
              Expanded(
                child: _buildColumnText(
                  context,
                  label: 'Start & End Date',
                  value: (sipData.startDate != null && sipData.endDate != null)
                      ? '${DateFormat('dd MMM yyyy').format(sipData.startDate!)} - ${DateFormat('dd MMM yyyy').format(sipData.endDate!)}'
                      : '-',
                ),
              )
            ],
          ),
          SizedBox(height: 16),
          if (sipData.isSaved == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildColumnText(
                    context,
                    label: 'SIP Days',
                    customValue: sipData.selectedSipDays.isNotEmpty
                        ? Tooltip(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: ColorConstants.black,
                                borderRadius: BorderRadius.circular(6)),
                            triggerMode: TooltipTriggerMode.tap,
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                            message:
                                '${sipData.selectedSipDays.sublist(0, sipData.selectedSipDays.length).map((day) => day.numberPattern).join(' ,')}',
                            child: Row(
                              children: [
                                Text(
                                  sipDays,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                ),
                                if (showSipDayTooltip)
                                  Container(
                                    margin: EdgeInsets.only(top: 2, left: 5),
                                    child: Icon(
                                      Icons.info,
                                      color: ColorConstants.tertiaryBlack,
                                      size: 12,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Text('-'),
                  )
                  // value: sipData.selectedSipDays.isNotEmpty
                  //     ? '${sipData.selectedSipDays.length} Debit/Month'
                  //     : '-',
                  ,
                ),
                Expanded(
                  child: _buildColumnText(
                    context,
                    label: 'Step Up',
                    value: sipData.isStepUpSipEnabled == true
                        ? '${sipData.stepUpPercentage}% increase in ${sipData.stepUpPeriod}'
                        : '-',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildColumnText(
    BuildContext context, {
    String? label,
    Widget? customLabel,
    String? value,
    Widget? customValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customLabel != null)
          customLabel
        else
          Text(
            label ?? '-',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                  height: 1.4,
                  fontSize: 14,
                ),
          ),
        SizedBox(
          height: 6,
        ),
        if (customValue != null)
          customValue
        else
          Text(
            value ?? '-',
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, {bool isSaved = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isSaved)
          Row(
            children: [
              ClickableText(
                text: 'Edit',
                fontSize: 14,
                onClick: () {
                  if (controller.selectedClient == null) {
                    return showToast(text: 'Please select a client first');
                  }

                  AutoRouter.of(context).push(
                    BasketEditFundRoute(
                      fund: fund,
                      basketController: controller,
                      index: index,
                    ),
                  );
                },
              ),
              if (isSaved)
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: ColorConstants.primaryAppColor,
                    size: 18,
                  ),
                )
            ],
          ),
        SizedBox(height: 10),
        CommonMfUI.buildBasketDeleteWidget(controller, fund, index)
      ],
    );
  }
}
