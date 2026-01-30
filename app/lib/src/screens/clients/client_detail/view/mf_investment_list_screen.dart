import 'package:api_sdk/api_constants.dart';
import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/mf_investment_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_investments/fund_investment_card.dart';
import 'package:app/src/screens/clients/client_detail/widgets/client_investments/mf_investment_filter_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/card/client_portfolio_overview_card.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_investments_model.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/mf_investment_model.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/client_investments/portfolio_investment_card.dart';

@RoutePage()
class MfInvestmentListScreen extends StatelessWidget {
  const MfInvestmentListScreen(
      {Key? key, this.mfProducts, this.portfolioOverview, this.asOn})
      : super(key: key);

  final GenericPortfolioOverviewModel? portfolioOverview;
  final DateTime? asOn;

  final MfProductsInvestmentModel? mfProducts;

  @override
  Widget build(BuildContext context) {
    Client? client = Get.find<ClientDetailController>().client;
    return GetBuilder<ClientDetailController>(
      id: GetxId.clientInvestments,
      builder: (clientDetailController) {
        return GetBuilder<MfInvestmentController>(
          init: MfInvestmentController(client),
          builder: (controller) {
            MfProductsInvestmentModel? mfProducts;
            // MfProductsInvestmentModel? mfProducts = clientDetailController
            //     .clientInvestmentsResult.products?.mf?.products;

            String title = '';
            if (controller.filtersSaved.contains(MfInvestmentType.Funds) &&
                controller.filtersSaved.contains(MfInvestmentType.Portfolios)) {
              title = 'All Funds & Portfolio';
            } else if (controller.filtersSaved
                .contains(MfInvestmentType.Funds)) {
              title = 'All Funds';
            } else if (controller.filtersSaved
                .contains(MfInvestmentType.Portfolios)) {
              title = 'All Portfolios';
            }

            return Scaffold(
              backgroundColor: ColorConstants.white,
              appBar: CustomAppBar(
                titleText: 'MF Investments',
                showBackButton: true,
                trailingWidgets: [
                  _buildProductFilter(context, controller),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (portfolioOverview != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20)
                            .copyWith(bottom: 20),
                        child: ClientProductOverviewCard(
                          overview: portfolioOverview!,
                          asOn: asOn,
                          productType: ClientInvestmentProductType.mutualFunds,
                        ),
                      ),
                    _buildFilter(context, controller),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _buildProductList(controller),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductFilter(
      BuildContext context, MfInvestmentController controller) {
    return InkWell(
      onTap: () {
        controller.filtersSelected = List.from(controller.filtersSaved);
        CommonUI.showBottomSheet(
          context,
          borderRadius: 16.0,
          isScrollControlled: true,
          child: MfInvestmentBottomSheet(),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Image.asset(
          AllImages().fundFilterIcon,
          height: 16,
          width: 16,
        ),
      ),
    );
  }

  Widget _buildFilter(BuildContext context, MfInvestmentController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25).copyWith(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                CommonUI.buildCheckbox(
                  value: controller.showEmptyFolios,
                  onChanged: (bool? value) {
                    if (controller.mfInvestmentResponse.state ==
                        NetworkState.loading) {
                      return;
                    }
                    controller.toggleShowEmptyFolios();
                  },
                ),
                Expanded(
                  child: Text(
                    'Show Zero Balance Folios',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge
                        ?.copyWith(color: ColorConstants.tertiaryBlack),
                  ),
                )
              ],
            ),
          ),
          if (controller.mfInvestmentResponse.state != NetworkState.loading)
            CommonClientUI.absoluteAnnualisedSwitch(
              context,
              showAbsoluteReturn: controller.showAbsoluteReturn,
              onTap: () {
                controller.toggleAbsoluteReturn();
              },
            )
        ],
      ),
    );
  }

  Widget _buildProductList(MfInvestmentController controller) {
    if (controller.mfInvestmentResponse.state == NetworkState.loading) {
      return ListView.separated(
        itemCount: 3,
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return SizedBox(height: 20);
        },
        itemBuilder: (context, index) {
          return SkeltonLoaderCard(height: 100);
        },
      );
    }

    if (controller.mfInvestmentResponse.state == NetworkState.error) {
      return RetryWidget(
        'Something went wrong. Please try again',
        onPressed: controller.fetchMfProducts,
      );
    }

    if (controller.mfInvestmentResponse.state == NetworkState.loaded &&
        controller.mfInvestment == null) {
      return EmptyScreen(
        message: 'No Products found',
      );
    }

    List productsList = [];
    MfProductsInvestmentModel? products = controller.mfInvestment?.products;
    if (controller.filtersSaved.contains(MfInvestmentType.Portfolios) &&
        (products?.wealthyPortfolios?.products ?? []).isNotEmpty) {
      productsList.addAll(products!.wealthyPortfolios!.products!);
    }

    if (controller.filtersSaved.contains(MfInvestmentType.Portfolios) &&
        (products?.customPortfolios?.products ?? []).isNotEmpty) {
      productsList.addAll(products!.customPortfolios!.products!);
    }

    if (controller.filtersSaved.contains(MfInvestmentType.Funds) &&
        (products?.otherFunds?.products ?? []).isNotEmpty &&
        products!.otherFunds?.products![0].schemes != null) {
      productsList.addAll(products.otherFunds!.products![0].schemes!);
    }

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (productsList.isNotEmpty)
            ...productsList.map(
              (product) {
                if (product is PortfolioInvestmentModel) {
                  if (controller.showEmptyFolios) {
                    return PortfolioInvestmentCard(
                      portfolio: product,
                      showEmptyFolios: controller.showEmptyFolios,
                      showAbsoluteReturn: controller.showAbsoluteReturn,
                    );
                  } else if ((product.currentValue ?? 0) > 0) {
                    return PortfolioInvestmentCard(
                        portfolio: product,
                        showEmptyFolios: controller.showEmptyFolios,
                        showAbsoluteReturn: controller.showAbsoluteReturn);
                  } else {
                    return SizedBox();
                  }
                } else if (product is SchemeMetaModel) {
                  if (controller.showEmptyFolios) {
                    return FundInvestmentCard(
                      fund: product,
                      anyFundPortfolio: products?.otherFunds!.products!.first,
                      showAbsoluteReturn: controller.showAbsoluteReturn,
                    );
                  } else if ((product.currentValue ?? 0) > 0) {
                    return FundInvestmentCard(
                      fund: product,
                      anyFundPortfolio: products?.otherFunds!.products!.first,
                      showAbsoluteReturn: controller.showAbsoluteReturn,
                    );
                  } else {
                    return SizedBox();
                  }
                }
                return SizedBox();
              },
            )
          else
            _buildEmptyScreen(controller)
        ],
      ),
    );
  }

  Widget _buildEmptyScreen(MfInvestmentController controller) {
    String emptyMessage = '';
    if (controller.filtersSaved.contains(MfInvestmentType.Funds) &&
        controller.filtersSaved.contains(MfInvestmentType.Portfolios)) {
      emptyMessage = 'No Funds / Portfolios Found';
    } else if (controller.filtersSaved.contains(MfInvestmentType.Funds)) {
      emptyMessage = 'No Funds Found';
    } else if (controller.filtersSaved.contains(MfInvestmentType.Portfolios)) {
      emptyMessage = 'No Portfolios Found';
    }

    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: EmptyScreen(
        message: emptyMessage,
      ),
    );
  }
}
