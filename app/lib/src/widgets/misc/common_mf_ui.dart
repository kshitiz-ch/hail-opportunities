import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/utils/mf.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/screens/store/basket/widgets/select_folio_bottomsheet.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/utils/sip_data.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/ribbon.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/client_mandate_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_ui.dart';

class CommonMfUI {
  static Widget buildMfLobbyBottomNavigationBar({
    bool fromCustomPortfolios = false,
  }) {
    return GetBuilder<BasketController>(
      id: 'basket',
      builder: (controller) {
        return AnimatedSize(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
          child: controller.basket.isEmpty
              ? SizedBox()
              : BasketBottomBar(
                  controller: controller,
                  fromCustomPortfolios: fromCustomPortfolios,
                  tag: null,
                  fund: null,
                ),
        );
      },
    );
  }

  static Widget buildMfRating(BuildContext context, SchemeMetaModel scheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryAppColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                height: 1,
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w500),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              Icons.star,
              color: ColorConstants.primaryAppColor,
              size: 14,
            ),
          ),
          Text(
            scheme.wRating.isNotNullOrZero
                ? scheme.wRating!.toStringAsFixed(2)
                : '-',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                height: 1,
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  static Widget buildDisclaimerText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        '*Disclaimer- Wealthy Scores are published by WealthyIN Broking under Research Analyst Licence INH000012175\n\nInvestment decisions should not be made purely basis the Wealthy Score. WealthyIN Broking reserves the right to change the scoring methodology at any point of time without prior intimation.',
        style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
            color: ColorConstants.tertiaryBlack, fontWeight: FontWeight.w600),
      ),
    );
  }

  static Widget buildBasketFundAmcLogo(
    BuildContext context,
    SchemeMetaModel scheme,
  ) {
    return GetBuilder<BasketController>(
      init: Get.find<BasketController>(),
      id: 'basket',
      global: true,
      builder: (controller) {
        bool isFundAddedInBasket =
            controller.basket.containsKey(scheme.basketKey);

        if (isFundAddedInBasket) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorConstants.lightGrey),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CommonUI.buildRoundedFullAMCLogo(
                  radius: 16,
                  amcName: scheme.displayName,
                  amcCode: scheme.amc,
                ),
              ),
              Positioned(
                right: 7,
                top: 0,
                child: Image.asset(
                  AllImages().cartAddedIcon,
                  width: 14,
                  height: 14,
                ),
              )
            ],
          );
        } else {
          return Container(
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ColorConstants.lightGrey),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CommonUI.buildRoundedFullAMCLogo(
              radius: 16,
              amcName: scheme.displayName,
              amcCode: scheme.amc,
            ),
          );
        }
      },
    );
  }

  static Widget buildAddBasketButton(
      BuildContext context, SchemeMetaModel scheme,
      {Function? onTap}) {
    return GetBuilder<BasketController>(
      init: Get.find<BasketController>(),
      id: 'basket',
      global: true,
      builder: (controller) {
        bool isFundAddedInBasket =
            controller.basket.containsKey(scheme.basketKey);

        return InkWell(
          onTap: () async {
            if (onTap != null) {
              onTap();
            }
            if (!isFundAddedInBasket) {
              validateAndAddFund(
                context,
                controller,
                scheme,
                () {
                  controller.addFundToBasket(
                    scheme,
                    context,
                    null,
                    toastMessage: null,
                  );
                },
              );
            } else {
              await deleteFund(
                context: context,
                // listKey: listKey,
                controller: controller,
                // index: index,
                // isCustomDetailScreen: isCustomDetailScreen,
                fund: scheme,
                // tag: null,
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isFundAddedInBasket
                  ? ColorConstants.redAccentColor.withOpacity(0.05)
                  : ColorConstants.secondaryAppColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!isFundAddedInBasket)
                  Icon(
                    Icons.add,
                    color: ColorConstants.primaryAppColor,
                    size: 12,
                  ),
                Text(
                  isFundAddedInBasket ? 'Remove' : 'Add',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          color: isFundAddedInBasket
                              ? ColorConstants.redAccentColor
                              : ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w500,
                          height: 1),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildStepperInfoUI(
      BuildContext context, SipUserDataModel sipUserData) {
    bool isEnabled = (sipUserData.stepperEnabled ?? false) &&
        (sipUserData.incrementPeriod.isNotNullOrEmpty &&
            sipUserData.incrementPercentage != null);

    if (!isEnabled) {
      return SizedBox();
    }

    int incrementMonth = getStepUpMonths(sipUserData.incrementPeriod!);

    String stepperInfoText =
        'Current SIP of ${WealthyAmount.currencyFormat(sipUserData.sipAmount, 1)} will increase every ${incrementMonth} Months by ${sipUserData.incrementPercentage}%';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: ColorConstants.tertiaryBlack.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(6),
      child: Text(
        stepperInfoText,
        style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  static Widget buildCategoryAvgText(
      BuildContext context, String? returnInYear, dynamic categoryAvgReturns,
      {required String? category}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      margin: EdgeInsets.only(bottom: 12),
      color: ColorConstants.primaryCardColor,
      child: Row(
        children: [
          Icon(
            Icons.bar_chart,
            color: ColorConstants.tertiaryBlack,
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${category ?? 'Category'} Average Return',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                  TextSpan(
                    text: ' ($returnInYear)',
                    style: Theme.of(context).primaryTextTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            getReturnPercentageText(
              categoryAvgReturns,
            ),
            style: Theme.of(context).primaryTextTheme.titleLarge!,
          )
        ],
      ),
    );
  }

  static Widget buildSipSummaryCard({
    required SipData data,
    required BuildContext context,
    bool? isSipActive,
    ClientMandateModel? selectedMandate,
  }) {
    final stepUpPeriod = !data.isStepUpSipEnabled ? '-' : data.stepUpPeriod;
    final stepUpPercentage =
        !data.isStepUpSipEnabled ? '-' : '${data.stepUpPercentage}%';
    String sipDays = '';
    if (data.selectedSipDays.isNotNullOrEmpty) {
      if (data.selectedSipDays.length > 3) {
        sipDays = data.selectedSipDays.sublist(0, 3).join(', ');
      } else {
        sipDays = data.selectedSipDays.join(', ');
      }
      final remainingDays = data.selectedSipDays.length - 3;
      if (remainingDays > 0) {
        sipDays += ', +$remainingDays days';
      }
    }
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          color: ColorConstants.tertiaryGrey,
          fontWeight: FontWeight.w400,
          overflow: TextOverflow.ellipsis,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                title: 'SIP Day(s)',
                subtitle: sipDays,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
                subtitleMaxLength: 2,
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                title: 'Start Date',
                subtitleMaxLength: 2,
                subtitle: getFormattedDate(data.startDate),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
              ),
            ),
            SizedBox(width: 4),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                title: 'End Date',
                subtitleMaxLength: 2,
                subtitle: getFormattedDate(data.endDate),
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          children: [
            if (isSipActive != null)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: CommonUI.buildColumnTextInfo(
                    title: 'SIP Status',
                    subtitle: isSipActive ? 'Active' : 'Pause',
                    titleStyle: titleStyle,
                    subtitleStyle: subtitleStyle,
                    subtitleMaxLength: 2,
                  ),
                ),
              ),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                title: 'Step up Period',
                subtitle: stepUpPeriod,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
              ),
            ),
            Expanded(
              child: CommonUI.buildColumnTextInfo(
                title: 'Step up Percentage',
                titleMaxLength: 2,
                subtitle: stepUpPercentage,
                titleStyle: titleStyle,
                subtitleStyle: subtitleStyle,
              ),
            ),
          ],
        ),
        SizedBox(height: 15),

        // Mandate Details
        Text('Bank', style: titleStyle),
        SizedBox(height: 6),
        if (selectedMandate == null)
          Text('-', style: subtitleStyle)
        else
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 12,
                child: CachedNetworkImage(
                  imageUrl: getBankLogo(selectedMandate.paymentBankName),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 7),
              CommonUI.buildColumnTextInfo(
                title: selectedMandate.paymentBankName ?? '-',
                titleStyle: subtitleStyle,
                subtitleStyle: titleStyle,
                gap: 6,
                subtitle:
                    '${selectedMandate.maskedPaymentBankAccountNumber} $smallBulletPointUnicode ${WealthyAmount.currencyFormat(selectedMandate.amount, 0)} $smallBulletPointUnicode ${selectedMandate.method}',
              )
            ],
          ),
      ],
    );
  }

  static Widget buildFundLogo(BuildContext context, SchemeMetaModel fund) {
    return CommonUI.buildRoundedFullAMCLogo(
      radius: 18,
      amcName: fund.displayName,
    );
  }

  static Widget buildFundName(
    BuildContext context,
    SchemeMetaModel fund, {
    bool showFolio = false,
    String? folioNumber,
    Function()? onAddNewFolio,
    Function(FolioModel)? onSelectFolio,
  }) {
    String fundDescription = getFundDescription(fund);

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
            if (showFolio)
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    if (folioNumber.isNotNullOrEmpty)
                      Flexible(
                        child: MarqueeWidget(
                          child: Text(
                            "Folio ${folioNumber}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .titleLarge!
                                .copyWith(
                                  color: ColorConstants.tertiaryBlack,
                                ),
                          ),
                        ),
                      )
                    else
                      Text(
                        "New Folio",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                    if (fund.folioOverviews.isNotNullOrEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: ClickableText(
                          text: 'Change Folio',
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: ColorConstants.primaryAppColor,
                          ),
                          onClick: () {
                            CommonUI.showBottomSheet(
                              context,
                              child: SelectFolioBottomSheet(
                                onAddNewFolio: onAddNewFolio,
                                onSelectFolio: onSelectFolio,
                                folioOverviews: fund.folioOverviews!,
                                defaultFolioNumber: folioNumber,
                              ),
                            );
                          },
                        ),
                      )
                  ],
                ),
              )
            else if (fundDescription.trim().isNotNullOrEmpty)
              Padding(
                padding: EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getFundDescription(fund),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget buildBasketDeleteWidget(
      BasketController controller, SchemeMetaModel fund, int index,
      {Function? onTap}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () async {
            if (onTap != null) {
              onTap();
            }

            bool minOneFundRequired = (controller.isUpdateProposal ||
                (controller.isTopUpPortfolio &&
                    !controller.fromCustomPortfolios));
            if (minOneFundRequired && controller.basket.length == 1) {
              return showToast(text: 'At least one fund is required');
            }

            // open delete fund bottom sheet
            CommonUI.showBottomSheet(
              context,
              child: DeleteFundBottomSheet(
                onCancel: () {
                  AutoRouter.of(context).popForced();
                },
                onDelete: () async {
                  await deleteFund(
                    context: context,
                    controller: controller,
                    index: index,
                    fund: fund,
                    // tag: tag,
                  );

                  // pop DeleteBottomSheet
                  AutoRouter.of(context).popForced();
                  // show toast
                  showCustomToast(
                    context: context,
                    child: Container(
                      width: SizeConfig().screenWidth,
                      // margin: const EdgeInsets.only(bottom: 136.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: ColorConstants.black.withOpacity(0.9),
                      ),
                      child: Text(
                        "Fund Deleted from Basket ✅",
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.white,
                            ),
                      ),
                    ),
                  );

                  if (controller.anyFundSipData.containsKey(fund.basketKey)) {
                    controller.anyFundSipData.remove(fund.basketKey);
                  }
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
    );
  }

  static Widget buildFundDisabledRibbon(SchemeMetaModel fund) {
    if (fund.isPaymentAllowed == false) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: RibbonShape(
          text: 'One Time Disabled',
          bgColor: ColorConstants.greyBlue,
        ),
      );
    } else if (fund.isSipAllowed == false) {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        child: RibbonShape(
          text: 'SIP Disabled',
          bgColor: ColorConstants.greyBlue,
        ),
      );
    }

    return SizedBox();
  }
}
