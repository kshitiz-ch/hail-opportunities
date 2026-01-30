import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'anyfund_sip_card.dart';
import 'basket_amount_section_new.dart';

class BasketView extends StatelessWidget {
  final String? tag;
  late BasketController controller;
  final bool showAddButton;

  final bool fromCustomPortfolios;

  BasketView({
    Key? key,
    this.tag,
    required this.fromCustomPortfolios,
    required this.showAddButton,
  }) : super(key: key) {
    controller = Get.find<BasketController>(tag: tag);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: _buildBasketList(context),
    );
  }

  Widget _buildBasketList(BuildContext context) {
    if (controller.investmentType == InvestmentType.oneTime) {
      // Logic for grouping SIF funds
      final allFunds = controller.basket.values.toList();
      final normalFunds = allFunds.where((f) => f.isSif != true).toList();
      final sifFunds = allFunds.where((f) => f.isSif == true).toList();

      // Group SIF funds by their AMC Name or Code to handle them as a collective unit
      final groupedSifFunds =
          groupBy(sifFunds, (SchemeMetaModel f) => f.amcName ?? f.amc);

      List<Widget> children = [];

      // 1. Add Normal Funds
      for (int i = 0; i < normalFunds.length; i++) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: _buildBasketTile(context, normalFunds[i], i),
          ),
        );
      }

      // 2. Add Grouped SIF Funds
      groupedSifFunds.forEach((amc, funds) {
        if (funds.isNotEmpty) {
          // Calculate Min Amount for the group
          // Priority: minAmcDepositAmt > minDepositAmt of first fund
          double minAmount = funds.first.minAmcDepositAmt ?? 0;
          if (minAmount <= 0) {
            minAmount = funds.first.minDepositAmt ?? 0;
          }

          children.add(
            Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.borderColor),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parent Header with Min Amount
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorConstants.lightGrey.withOpacity(0.3),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            funds.first.amcName ?? funds.first.amc ?? '',
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge! // titleMedium equivalent
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.black,
                                ),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Minimum Amount ',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: ColorConstants.tertiaryBlack,
                                      fontSize: 12,
                                    ),
                              ),
                              TextSpan(
                                text:
                                    WealthyAmount.currencyFormat(minAmount, 0),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorConstants.black,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List of Funds in this Group
                  ...funds.map((fund) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: ColorConstants.borderColor, width: 1),
                        ),
                      ),
                      child: _buildBasketTileContent(
                        context,
                        fund,
                        0,
                        isGrouped: true,
                        // Logic: If multiple funds are present in the same AMC group,
                        // each fund must effectively meet the 1 Lakh limit individually (likely a business requirement),
                        // otherwise if it's a single fund, it just needs to meet the AMC minimum.
                        minAmount: funds.length == 1 ? minAmount : 100000,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }
      });

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    // Default Behavior for non-OneTime (SIP, etc)
    final fundList = controller.basket.values.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(
        controller.basket.length,
        (index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _buildBasketTile(context, fundList[index], index),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasketTile(
      BuildContext context, SchemeMetaModel fund, int index) {
    if (controller.investmentType == InvestmentType.SIP &&
        !controller.isCustomPortfolio) {
      return AnyFundSipCard(
        controller: controller,
        fund: fund,
        index: index,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorConstants.borderColor,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: _buildBasketTileContent(context, fund, index),
      );
    }
  }

  Widget _buildBasketTileContent(
      BuildContext context, SchemeMetaModel fund, int index,
      {bool isGrouped = false, double? minAmount}) {
    return Column(
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
                showFolio: !controller.isTopUpPortfolio,
                folioNumber: controller
                    .basketFolioMapping[fund.wschemecode]?.folioNumber,
                onAddNewFolio: () {
                  if (controller.basketFolioMapping
                      .containsKey(fund.wschemecode)) {
                    controller.basketFolioMapping.remove(fund.wschemecode);
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
              ),
              CommonMfUI.buildBasketDeleteWidget(
                controller,
                fund,
                index,
                onTap: () {},
              ),
            ],
          ),
        ),
        CommonMfUI.buildFundDisabledRibbon(fund),
        Container(
          padding: EdgeInsets.all(16).copyWith(top: 0),
          child: InkWell(
            splashColor: ColorConstants.white,
            focusColor: ColorConstants.white,
            onTap: () {
              if (controller.selectedClient == null) {
                showToast(text: "Please select a client first");
              }
            },
            child: IgnorePointer(
              ignoring: controller.selectedClient == null,
              child: BasketAmountSectionNew(
                basketController: controller,
                fund: fund,
                minAmount: minAmount,
              ),
            ),
          ),
        ),
        if (fund.isNfo == true && fund.reopeningDate != null)
          _buildFundDate(context, fund.reopeningDate!, isNfo: true),
        if (fund.sipRegistrationStartDate != null &&
            fund.sipRegistrationStartDate!.isAfter(DateTime.now()))
          _buildFundDate(context, fund.sipRegistrationStartDate!)
      ],
    );
  }

  Widget _buildFundDate(BuildContext context, DateTime date,
      {bool isNfo = false}) {
    return Padding(
      padding: EdgeInsets.only(left: 10, bottom: 16),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            color: ColorConstants.primaryAppColor.withOpacity(0.6),
            size: 16,
          ),
          SizedBox(width: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: isNfo
                      ? 'NFO Reopening Date '
                      : 'SIP Registration Start Date ',
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            height: 1.4,
                            color: ColorConstants.tertiaryBlack,
                          ),
                ),
                TextSpan(
                  text: DateFormat("dd MMM yyyy").format(date),
                  style:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
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
      ),
    );
  }
}
