import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_detail_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/fund_score_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/fund_breakdown/breakdown_header.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopCategoryFunds extends StatelessWidget {
  const TopCategoryFunds({Key? key, this.expandByDefault = false})
      : super(key: key);

  final bool expandByDefault;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FundScoreController>(
      id: 'top-category-funds',
      initState: (_) {
        FundScoreController controller = Get.find<FundScoreController>();
        if (controller.fetchTopCategoryFundState != NetworkState.loaded) {
          controller.getTopCategoryFunds();
        }
      },
      builder: (controller) {
        return BreakdownHeader(
          isExpanded:
              Get.find<FundDetailController>().activeNavigationSection ==
                  FundNavigationTab.Peers,
          onToggleExpand: () {
            Get.find<FundDetailController>()
                .updateNavigationSection(FundNavigationTab.Peers);
          },
          title: 'Peer Comparison',
          subtitle: 'Comparison with other top funds in the same category',
          expandByDefault: expandByDefault,
          child: Container(
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(
                        'Fund Details',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      Spacer(),
                      _buildReturnDropdown(context, controller)
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (controller.fetchTopCategoryFundState ==
                    NetworkState.loading)
                  ListView.separated(
                    padding: EdgeInsets.only(bottom: 20),
                    itemCount: 6,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      return SkeltonLoaderCard(
                        height: 60,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        radius: 5,
                      );
                    },
                  )
                else if (controller.fetchTopCategoryFundState ==
                    NetworkState.error)
                  RetryWidget(
                    'Failed to load Funds. Please try again',
                    onPressed: controller.getTopCategoryFunds,
                  )
                else if (controller.topCategoryFunds.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'No Funds Found',
                      style: Theme.of(context).primaryTextTheme.headlineSmall,
                    ),
                  )
                else
                  ListView.separated(
                    itemCount: controller.topCategoryFunds.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: ColorConstants.secondarySeparatorColor,
                      );
                    },
                    itemBuilder: (context, index) {
                      SchemeMetaModel scheme =
                          controller.topCategoryFunds[index];
                      return _buildFundTile(context, scheme, controller);
                    },
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReturnDropdown(
      BuildContext context, FundScoreController controller) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ColorConstants.primaryAppColor,
              size: 12,
            ),
            Text(
              '${controller.topCategoryFundReturnYearSelected} Y Return',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(color: ColorConstants.primaryAppColor),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: ColorConstants.primaryAppColor,
              size: 12,
            ),
          ],
        ),
        items: (controller.categoryReturnYearOptions)
            .map(
              (int year) => DropdownMenuItem(
                value: year,
                onTap: () {
                  if (controller.fetchTopCategoryFundState !=
                      NetworkState.loading) {
                    controller.updatetopCategoryFundReturnYearSelected(year);
                  }
                },
                child: Text(
                  '$year Y Return',
                  style: Theme.of(context).primaryTextTheme.titleLarge,
                ),
              ),
            )
            .toList(),
        onChanged: (value) {},
        dropdownStyleData: DropdownStyleData(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          offset: const Offset(-40, -10),
        ),
        menuItemStyleData: MenuItemStyleData(
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }

  Widget _buildFundTile(BuildContext context, SchemeMetaModel scheme,
      FundScoreController controller) {
    return InkWell(
      onTap: () {
        // AutoRouter.of(context).push(
        //   FundDetailRoute(
        //     fund: scheme,
        //     isTopUpPortfolio: false,
        //     basketBottomBar: BasketBottomBar(
        //       controller: Get.find<BasketController>(),
        //       fund: scheme,
        //     ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.displayName ?? '-',
                    maxLines: 3,
                    style: Theme.of(context).primaryTextTheme.headlineSmall,
                  ),
                  SizedBox(height: 6),
                  CommonMfUI.buildMfRating(
                    context,
                    scheme,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              getPercentageText(
                getSchemeReturnByYear(
                  scheme,
                  controller.topCategoryFundReturnYearSelected,
                ),
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).primaryTextTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  double? getSchemeReturnByYear(
      SchemeMetaModel scheme, int returnYearSelected) {
    switch (returnYearSelected) {
      case 1:
        return scheme.returns?.oneYrRtrns;
      case 3:
        return scheme.returns?.threeYrRtrns;
      case 5:
        return scheme.returns?.fiveYrRtrns;
      default:
        return null;
    }
  }
}
