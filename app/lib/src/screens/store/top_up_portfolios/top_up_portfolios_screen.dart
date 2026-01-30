import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolios_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/product_card_new.dart';
import 'package:app/src/widgets/loader/screen_loader.dart';
import 'package:app/src/widgets/text/bottom_data.dart';
import 'package:app/src/widgets/text/section_header.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/top_up_portfolio/models/portfolio_user_products_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

@RoutePage()
class TopUpPortfoliosScreen extends StatelessWidget {
  final Client? client;

  TopUpPortfoliosScreen({Key? key, this.client}) : super(key: key);

  final MFPortfoliosController controller = Get.put(MFPortfoliosController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        showBackButton: true,
        titleText: client!.name!.toTitleCase(),
      ),
      body: GetBuilder<MFPortfoliosController>(
        id: GetxId.topUpPortfolios,
        dispose: (_) {
          Get.delete<MFPortfoliosController>();
        },
        initState: (_) async {
          controller.getTopUpPortfolios(client!);
        },
        builder: (controller) {
          if (controller.topUpPortfoliosState == NetworkState.loading) {
            return _buildLoadingIndicator();
          }

          if (controller.topUpPortfolios!.length == 0) {
            return _buildEmptyState(context);
          }

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
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  title: 'Mutual Funds',
                  titleStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.tertiaryBlack,
                      ),
                  onTraiClick: () {},
                  trailingTextStyle:
                      Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                            color: ColorConstants.tertiaryBlack,
                            fontWeight: FontWeight.w400,
                          ),
                  trailingText:
                      '${controller.topUpPortfolios!.length} Portfolio${controller.topUpPortfolios!.length == 1 ? '' : 's'}'),
              Expanded(
                child: ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20).copyWith(top: 24),
                  itemCount: controller.topUpPortfolios!.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    PortfolioUserProductsModel userProduct =
                        controller.topUpPortfolios![index];

                    String activatedDateDescription = 'N/A';

                    if (userProduct.activatedAt != null) {
                      DateTime startDateFormatted =
                          DateTime.parse(userProduct.activatedAt!);
                      activatedDateDescription =
                          DateFormat('MMM dd yyyy').format(startDateFormatted);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProductCardNew(
                        showSeparator: false,
                        title: userProduct.displayName,
                        onTap: () async {
                          _navigateToTopUpFlow(context, userProduct);
                        },
                        titleStyle: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                              color: ColorConstants.black,
                            ),
                        descriptionStyle: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                        description: userProduct.name,
                        bgColor: ColorConstants.primaryCardColor,
                        // description: '',
                        trailingWidget: SizedBox(
                          width: 80,
                          height: 36,
                          child: ActionButton(
                            customLoader: SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: ColorConstants.primaryAppColor,
                              ),
                            ),
                            // showProgressIndicator: controller
                            //             .portfolioDetailState ==
                            //         NetworkState.loading &&
                            //     userProduct.externalId ==
                            //         controller.selectedPortfolio?.externalId,
                            showBorder: true,
                            borderColor: ColorConstants.primaryAppColor,
                            borderRadius: 50,
                            onPressed: () async {
                              _navigateToTopUpFlow(context, userProduct);
                              // bool isFetchingPortfolioDetail =
                              //     controller.portfolioDetailState ==
                              //         NetworkState.loading;
                              // if (isFetchingPortfolioDetail) {
                              //   return null;
                              // }

                              // await controller
                              //     .setSelectedPortfolio(userProduct);

                              // await controller.getPortfolioDetails(client);
                              // if (controller.portfolioDetailState ==
                              //     NetworkState.error) {
                              //   return showToast(
                              //     context: context,
                              //     text: controller.portfolioErrorMessage,
                              //   );
                              // }
                              // if (controller.portfolioDetailState ==
                              //     NetworkState.loaded) {
                              //   if (userProduct.extras?.goalType ==
                              //       GoalType.CUSTOM) {
                              //     if (controller.customPortfolioFunds.length ==
                              //         0) {
                              //       return showToast(
                              //         context: context,
                              //         text:
                              //             'This portfolio cannot be accessed at the moment. Please try after some time',
                              //       );
                              //     } else {
                              //       Get.delete<BasketController>();
                              //       AutoRouter.of(context).push(FundListRoute(
                              //         portfolio:
                              //             controller.selectedPortfolioDetail,
                              //         funds: controller.customPortfolioFunds,
                              //         client: client,
                              //         isTopUpPortfolio: true,
                              //         isCustomPortfolio: true,
                              //       ));
                              //     }
                              //   } else {
                              //     AutoRouter.of(context).push(
                              //         MFPortfolioDetailRoute(
                              //             portfolio: controller
                              //                 .selectedPortfolioDetail,
                              //             client: client,
                              //             isTopUpPortfolio: true,
                              //             isSmartSwitch: controller
                              //                 .selectedPortfolioDetail!
                              //                 .isSmartSwitch));
                              //   }
                              // }
                            },
                            margin: EdgeInsets.zero,
                            bgColor: ColorConstants.secondaryAppColor,
                            text: 'Top Up',
                            textStyle: Theme.of(context)
                                .primaryTextTheme
                                .headlineSmall!
                                .copyWith(
                                  color: ColorConstants.primaryAppColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        bottomData: [
                          BottomData(
                            title: activatedDateDescription,
                            subtitle: "Activated",
                            align: BottomDataAlignment.center,
                            titleStyle: titleStyle,
                            subtitleStyle: subtitleStyle,
                          ),
                          BottomData(
                            title: WealthyAmount.currencyFormat(
                              userProduct.currentInvestedValue,
                              0,
                            ),
                            subtitle: "Invested",
                            flex: 1,
                            align: BottomDataAlignment.center,
                            titleStyle: titleStyle,
                            subtitleStyle: subtitleStyle,
                          ),
                          BottomData(
                            title: WealthyAmount.currencyFormat(
                              userProduct.currentValue,
                              0,
                            ),
                            subtitle: "Returns",
                            align: BottomDataAlignment.center,
                            titleStyle: titleStyle,
                            subtitleStyle: subtitleStyle,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _navigateToTopUpFlow(
      BuildContext context, PortfolioUserProductsModel userProduct) async {
    AutoRouter.of(context).pushNativeRoute(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => ScreenLoader(),
      ),
    );

    try {
      bool isFetchingPortfolioDetail =
          controller.portfolioDetailState == NetworkState.loading;
      if (isFetchingPortfolioDetail) {
        return null;
      }

      await controller.getGoalDetails(
          userId: client?.taxyID ?? '', goalId: userProduct.externalId!);

      if (controller.portfolioDetailState == NetworkState.error) {
        return showToast(
          context: context,
          text: controller.portfolioErrorMessage.isNotNullOrEmpty
              ? controller.portfolioErrorMessage
              : 'Something went wrong',
        );
      }

      if (controller.selectedPortfolio!.isTaxSaver &&
          controller.isTaxSaverDeprecated) {
        return showToast(
            text:
                '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment, you can only invest into current year Tax Saver portfolio.');
      }

      if (!controller.canTopUp) {
        return showToast(
            text:
                '${controller.selectedPortfolio?.title ?? 'This portfolio'} is no longer available for additional investment');
      }

      if (controller.selectedPortfolio!.goalType == GoalType.CUSTOM) {
        if (controller.portfolioFunds.length == 0) {
          return showToast(
            context: context,
            text:
                '${controller.selectedPortfolio?.title ?? 'This portfolio'} cannot be accessed at the moment. Please try after some time',
          );
        } else {
          Get.delete<BasketController>();
          AutoRouter.of(context).push(FundListRoute(
            portfolio: controller.selectedPortfolio,
            funds: controller.portfolioFunds,
            client: client,
            isTopUpPortfolio: true,
            isCustomPortfolio: true,
            fromClientInvestmentScreen: true,
            portfolioInvestment: controller.portfolioInvestment,
          ));
        }
      } else {
        AutoRouter.of(context).push(
          MfPortfolioDetailRoute(
            portfolio: controller.selectedPortfolio,
            client: client,
            isTopUpPortfolio: true,
            isSmartSwitch: controller.selectedPortfolio?.isSmartSwitch ?? false,
            fromClientInvestmentScreen: true,
            portfolioInvestment: controller.portfolioInvestment,
          ),
        );
      }
    } catch (error) {
      LogUtil.printLog(error);
    } finally {
      AutoRouter.of(context).popForced();
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No Portfolios found',
          style: Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                color: ColorConstants.black,
              ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                AutoRouter.of(context).push(
                  StoreRoute(
                    client: client,
                    showBackButton: true,
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                margin: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: ColorConstants.primaryAppColor,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: ColorConstants.primaryAppColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      ('ADD NEW PORTFOLIOS').toTitleCase(),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.primaryAppColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
