import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_investment_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/divider/smart_switch_divider.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:overflow_view/overflow_view.dart';

enum OnClick { TopUp, ViewFunds }

class PortfolioInvestmentCard extends StatefulWidget {
  PortfolioInvestmentCard({
    required this.portfolio,
    this.showEmptyFolios = false,
    required this.showAbsoluteReturn,
  });

  final PortfolioInvestmentModel portfolio;

  final bool showEmptyFolios;

  final bool showAbsoluteReturn;

  @override
  State<PortfolioInvestmentCard> createState() =>
      _PortfolioInvestmentCardState();
}

class _PortfolioInvestmentCardState extends State<PortfolioInvestmentCard> {
  OnClick? onClickedFrom;

  final ClientDetailController clientDetailController =
      Get.find<ClientDetailController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MfInvestmentController>(
      init: MfInvestmentController(clientDetailController.client),
      tag: widget.portfolio.externalId,
      global: false,
      builder: (controller) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: ProductCardNew(
            onTap: () {
              _navigateToGoalScreen(context);
            },
            bgColor: ColorConstants.primaryCardColor,
            title: widget.portfolio.portfolioName,
            description: widget.portfolio.productName,
            titleMaxLines: 3,
            leadingWidget: widget.portfolio.schemes.isNotNullOrEmpty
                ? OverflowView.flexible(
                    spacing: -10,
                    children: widget.portfolio.schemes!
                        .sublist(
                            0,
                            widget.portfolio.schemes!.length > 3
                                ? 3
                                : widget.portfolio.schemes!.length)
                        .map<Widget>(
                      (fund) {
                        if (fund != null) {
                          return CommonUI.buildRoundedFullAMCLogo(
                              radius: 12, amcName: fund.displayName);
                        }
                        return SizedBox();
                      },
                    ).toList(),
                    builder: (_, remaining) => SizedBox(),
                  )
                : null,
            // trailingWidget: SizedBox(
            //   width: 80,
            //   height: 36,
            //   child: ActionButton(
            //     customLoader: SizedBox(
            //       height: 15,
            //       width: 15,
            //       child: CircularProgressIndicator(
            //         strokeWidth: 1,
            //         color: ColorConstants.primaryAppColor,
            //       ),
            //     ),
            //     onPressed: () {
            //       LogUtil.printLog("click here");
            //       setState(() {
            //         onClickedFrom = OnClick.TopUp;
            //       });
            //       getPortfolioDetails(controller, navigateToTopUpFlow: true);
            //     },
            //     showProgressIndicator: onClickedFrom == OnClick.TopUp &&
            //         controller.portfolioDetailState == NetworkState.loading,
            //     showBorder: true,
            //     borderColor: ColorConstants.primaryAppColor,
            //     borderRadius: 50,
            //     margin: EdgeInsets.zero,
            //     bgColor: ColorConstants.secondaryAppColor,
            //     text: 'Top Up',
            //     textStyle:
            //         Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
            //               color: ColorConstants.primaryAppColor,
            //               fontWeight: FontWeight.w700,
            //             ),
            //   ),
            // ),
            // onTap: () async {
            //   setState(() {
            //     onClickedFrom = OnClick.TopUp;
            //   });
            //   getPortfolioDetails(controller, navigateToTopUpFlow: true);
            // },
            bottomData: [
              BottomData(
                title: WealthyAmount.currencyFormat(
                    widget.portfolio.currentInvestedValue, 0),
                subtitle: "Invested Value",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
              BottomData(
                title: WealthyAmount.currencyFormat(
                    widget.portfolio.currentValue, 0),
                subtitle: "Current Value",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
              BottomData(
                title: getReturnPercentageText(widget.showAbsoluteReturn
                    ? widget.portfolio.currentAbsoluteReturns
                    : widget.portfolio.currentIrr),
                subtitle:
                    widget.showAbsoluteReturn ? "Absolute Returns" : "IRR",
                align: BottomDataAlignment.left,
                flex: 1,
              ),
            ],
            additionalBottomData: _buildAdditionalProductData(
                widget.portfolio, controller,
                showEmptyFolios: widget.showEmptyFolios),
          ),
        );
      },
    );
  }

  Widget _buildAdditionalProductData(
      PortfolioInvestmentModel product, MfInvestmentController controller,
      {bool? showEmptyFolios}) {
    String? lastUpdateFormatted;

    if (widget.portfolio.currentAsOn != null) {
      lastUpdateFormatted =
          DateFormat('dd MMM yyyy').format(widget.portfolio.currentAsOn!);
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.portfolio.schemes.isNotNullOrEmpty)
                      Text(
                        '${widget.portfolio.schemes!.length.toString()} Mutual Funds',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.primaryAppColor,
                            ),
                      ),
                    if (lastUpdateFormatted != null)
                      Text(
                        'Last Update on $lastUpdateFormatted',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                      )
                  ],
                ),
                Spacer(),
                InkWell(
                  onTap: () async {
                    // To prevent rage clicking
                    if (controller.portfolioDetailState ==
                        NetworkState.loading) {
                      return null;
                    }
                    ;

                    if (controller.portfolioDetailState ==
                        NetworkState.loaded) {
                      controller.toggleFundExpanded();
                      return;
                    }

                    if (controller.portfolioDetailState == NetworkState.error) {
                      return showToast(
                        context: context,
                        text: controller.portfolioErrorMessage,
                      );
                    }

                    // setState(() {
                    //   onClickedFrom = OnClick.ViewFunds;
                    // });

                    await getPortfolioDetails(controller);

                    if (controller.portfolioDetailState ==
                        NetworkState.loaded) {
                      controller.toggleFundExpanded();
                    }
                  },
                  child: Container(
                    // color: Colors.red,
                    padding: EdgeInsets.only(
                        top: 5, left: 10, right: 10, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          controller.isFundExpanded ? 'Hide' : 'View',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displayMedium!
                              .copyWith(
                                  fontSize: 12,
                                  color: ColorConstants.primaryAppColor),
                        ),
                        SizedBox(width: 4),
                        RotatedBox(
                          quarterTurns: controller.isFundExpanded ? 2 : 0,
                          child: Icon(
                            Icons.expand_more,
                            size: 20,
                            color: ColorConstants.primaryAppColor,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          if (controller.portfolioDetailState == NetworkState.loading)
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 15,
              width: 15,
              child: CircularProgressIndicator(
                color: ColorConstants.primaryAppColor,
                strokeWidth: 2,
              ),
            )
          else if (controller.isFundExpanded &&
              controller.portfolioDetailState == NetworkState.loaded)
            _buildFundSection(controller, showEmptyFolios),
        ],
      ),
    );
  }

  void _navigateToGoalScreen(BuildContext context) {
    ClientDetailController clientDetailController =
        Get.find<ClientDetailController>();
    AutoRouter.of(context).push(
      ClientGoalRoute(
        client: clientDetailController.client!,
        goalId: widget.portfolio.externalId ?? '',
        mfInvestmentType: MfInvestmentType.Portfolios,
      ),
    );
  }

  Widget _buildFundSection(
      MfInvestmentController controller, bool? showEmptyFolios) {
    if (controller.portfolioFunds.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Failed to fetch funds',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 400),
          child: ListView.separated(
            shrinkWrap: true,
            primary: true,
            padding: EdgeInsets.only(top: 10),
            itemCount: controller.portfolioFunds.length,
            separatorBuilder: (BuildContext context, int index) {
              bool isSmartSwitch =
                  controller.selectedPortfolio?.isSmartSwitch ?? false;
              bool showSmartSwitchIcon = false;
              if ((controller.selectedPortfolio?.isSmartSwitch ?? false) &&
                  index.isEven) {
                showSmartSwitchIcon = true;
              }

              if (showSmartSwitchIcon) {
                return SmartSwitchDivider(
                  indent: 30,
                  endIndent: 30,
                );
              } else {
                return SizedBox(height: isSmartSwitch ? 20 : 6);
              }
            },
            itemBuilder: (BuildContext context, int index) {
              SchemeMetaModel fund = controller.portfolioFunds[index];

              if (showEmptyFolios == true ||
                  (controller.selectedPortfolio?.isSmartSwitch ?? false)) {
                return _buildFundCard(fund);
              } else if ((fund.currentValue ?? 0) > 0) {
                return _buildFundCard(fund);
              } else {
                return SizedBox();
              }
            },
          ),
        ),
        // ActionButton(
        //   borderRadius: 6,
        //   margin: EdgeInsets.only(top: 15),
        //   text: 'Top Up',
        //   onPressed: () {
        //     getPortfolioDetails(controller, navigateToTopUpFlow: true);
        //   },
        // ),
      ],
    );
  }

  Widget _buildFundCard(SchemeMetaModel fund) {
    final titleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontWeight: FontWeight.w400,
            );

    return ProductCardNew(
      borderRadius: 16,
      bgColor: ColorConstants.white,
      leadingWidget: SizedBox(
        height: 36,
        width: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: CachedNetworkImage(
            // amc code not coming
            // so can't use getAmcLogoNew
            imageUrl: getAmcLogo(fund.displayName),
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: fund.displayName,
      titleMaxLines: 4,
      description:
          '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "| ${fund.fundCategory}" : ""}',
      onTap: () {
        AutoRouter.of(context).push(
          FundDetailRoute(
              viaFundList: true,
              isTopUpPortfolio: false,
              fund: fund,
              showBottomBasketAppBar: false),
        );
      },
      bottomData: [
        BottomData(
            title: WealthyAmount.currencyFormat(fund.currentInvestedValue, 1),
            subtitle: "Invested",
            align: BottomDataAlignment.left,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            flex: 1),
        BottomData(
            title: WealthyAmount.currencyFormat(fund.currentValue, 1),
            subtitle: "Current",
            align: BottomDataAlignment.left,
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
            flex: 1),
        BottomData(
          title: getReturnPercentageText(fund.currentAbsoluteReturns),
          subtitle: "Abs. Return",
          align: BottomDataAlignment.left,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          // flex: 1
        ),
      ],
    );
  }

  Future<void> getPortfolioDetails(MfInvestmentController controller,
      {bool navigateToTopUpFlow = false}) async {
    if (controller.portfolioDetailState == NetworkState.loading) {
      return null;
    }

    await controller.getGoalDetails(
        userId: clientDetailController.client!.taxyID!,
        goalId: widget.portfolio.externalId!);

    if (controller.portfolioDetailState == NetworkState.error) {
      return showToast(
        context: context,
        text: controller.portfolioErrorMessage.isNotNullOrEmpty
            ? controller.portfolioErrorMessage
            : 'Something went wrong',
      );
    }
  }

  // void _navigateToTopUpFlow(MfInvestmentController controller) {
  //   if (controller.selectedPortfolio!.isTaxSaver &&
  //       controller.isTaxSaverDeprecated) {
  //     return showToast(
  //         text:
  //             '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment, you can only invest into current year Tax Saver portfolio.');
  //   }

  //   if (!controller.canTopUp) {
  //     return showToast(
  //         text:
  //             '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment');
  //   }

  //   if (controller.selectedPortfolio!.goalType == GoalType.CUSTOM) {
  //     if (controller.portfolioFunds.length == 0) {
  //       return showToast(
  //         context: context,
  //         text:
  //             '${controller.selectedPortfolio?.title ?? 'This portfolio'} cannot be accessed at the moment. Please try after some time',
  //       );
  //     } else {
  //       Get.delete<BasketController>();
  //       AutoRouter.of(context).push(FundListRoute(
  //           portfolio: controller.selectedPortfolio,
  //           funds: controller.portfolioFunds,
  //           client: clientDetailController.client,
  //           isTopUpPortfolio: true,
  //           isCustomPortfolio: true,
  //           fromClientInvestmentScreen: true,
  //           portfolioInvestment: widget.portfolio));
  //     }
  //   } else {
  //     AutoRouter.of(context).push(
  //       MFPortfolioDetailRoute(
  //         portfolio: controller.selectedPortfolio,
  //         client: clientDetailController.client,
  //         isTopUpPortfolio: true,
  //         isSmartSwitch: controller.selectedPortfolio?.isSmartSwitch ?? false,
  //         fromClientInvestmentScreen: true,
  //         portfolioInvestment: widget.portfolio,
  //       ),
  //     );
  //   }
  // }
}
