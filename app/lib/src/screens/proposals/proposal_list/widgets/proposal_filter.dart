import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/screens/proposals/proposal_list/view/proposal_list_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProposalFilter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProposalsController>(
      builder: (controller) {
        return TextButton(
          onPressed: () {
            _buildProposalFilterBottomSheet(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getProposalFilterText(controller.selectedProductCategory!),
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: ColorConstants.primaryAppColor,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Center(
                  child: Icon(
                    Icons.expand_more,
                    color: ColorConstants.secondaryBlack,
                    size: 12,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _buildProposalFilterBottomSheet(BuildContext context) {
    CommonUI.showBottomSheet(
      context,
      backgroundColor: ColorConstants.white,
      child: GetBuilder<ProposalsController>(
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30)
                    .copyWith(top: 30, bottom: 45),
                child: Text(
                  'Sort By',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: ColorConstants.black,
                      ),
                ),
              ),
            ]..addAll(
                controller.productCategoryList
                    .map<Widget>(
                      (productCategory) => Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: InkWell(
                          onTap: () {
                            MixPanelAnalytics.trackWithAgentId(
                              productCategory == "All"
                                  ? "all_products_filter"
                                  : '${productCategory}_filter',
                              screen: 'proposals',
                              screenLocation: 'proposals',
                            );
                            controller
                                .updateSelectedProductCategory(productCategory);
                            controller.getProposals();

                            // Segment Event - productCategory change
                            var properties = <String, dynamic>{
                              "tab": tabTitles[controller.tabController!.index],
                            };
                            if (controller.isDematProposalFilter) {
                              properties['productType'] = 'Demat';
                            } else {
                              properties['productCategory'] =
                                  controller.selectedProductCategory;
                            }

                            // Close Bottomsheet
                            AutoRouter.of(context).popForced();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 34, right: 12),
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: controller.selectedProductCategory!
                                              .toLowerCase() ==
                                          productCategory.toLowerCase()
                                      ? Icon(
                                          Icons.check_sharp,
                                          color: ColorConstants.primaryAppColor,
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                              Text(
                                getProposalFilterText(productCategory),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: controller.selectedProductCategory!
                                                  .toLowerCase() ==
                                              productCategory.toLowerCase()
                                          ? ColorConstants.black
                                          : ColorConstants.tertiaryBlack,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          );
        },
      ),
    );
  }

  String getProposalFilterText(String text) {
    switch (text) {
      case 'All':
        return 'All Products';
      case ProductCategoryType.INSURANCE:
        return 'Insurances';
      case ProductCategoryType.INVEST:
        return 'Investments';
      // case ProductCategoryType.LOAN:
      //   return 'Credit Cards';
      case ProductCategoryType.DEMAT:
        return 'Demats';
      default:
        return 'All Products';
    }
  }
}
