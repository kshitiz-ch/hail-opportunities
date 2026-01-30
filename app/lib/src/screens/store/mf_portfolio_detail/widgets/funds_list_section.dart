import 'dart:math';

import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/divider/smart_switch_divider.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf_portfolio_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'micro_sip_fund_list_tile.dart';

class FundsListSection extends StatelessWidget {
  // Fields
  final GoalSubtypeModel portfolio;
  final bool? isSmartSwitch;
  final bool isMicroSIP;
  final List<SchemeMetaModel>? portfolioSchemes;

  // Constructor
  const FundsListSection({
    Key? key,
    required this.portfolio,
    this.isSmartSwitch = false,
    this.isMicroSIP = false,
    this.portfolioSchemes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 24.0, 30.0, 16.0),
          child: Text(
            "Scheme Details",
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(color: ColorConstants.tertiaryGrey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GetBuilder<MFPortfolioDetailController>(
            id: 'funds',
            initState: (_) async {
              final controller = Get.find<MFPortfolioDetailController>();

              // TODO: Imrpove this
              await controller.onReady();

              if (portfolioSchemes.isNotNullOrEmpty) {
                controller.updateFundsList(portfolioSchemes!);
              } else {
                await controller.fetchStoreFunds(portfolio.schemes!);
              }
            },
            builder: (controller) {
              List<SchemeMetaModel>? funds = controller.fundsResult.schemeMetas;
              int itemCount = controller.fundsListCount;

              TextStyle textStyle = Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(
                      color: ColorConstants.tertiaryBlack,
                      fontWeight: FontWeight.w600,
                      height: 1.5);

              return Column(
                children: [
                  if (funds?.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.all(16).copyWith(bottom: 5),
                      child: Row(
                        children: [
                          Text(
                            'Scheme Name',
                            style: textStyle,
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Text(
                                'Return',
                                style: textStyle,
                              ),
                              SizedBox(width: 3),
                              _buildReturnDropdown(context, controller)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ListView.separated(
                    itemCount: controller.fundsState == NetworkState.error
                        ? 1
                        : controller.fundsState == NetworkState.loading
                            ? itemCount
                            : min(itemCount, funds!.length),
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    separatorBuilder: (BuildContext context, int index) =>
                        (isSmartSwitch! &&
                                portfolio.possibleSwitchPeriods!.isNotEmpty &&
                                index % 2 == 0)
                            ? SmartSwitchDivider(
                                indent: 30,
                                endIndent: 30,
                              )
                            : Divider(
                                color: ColorConstants.borderColor,
                              ),
                    itemBuilder: (BuildContext context, int index) {
                      return controller.fundsState == NetworkState.loading
                          ? Container(
                              height: 60,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: ColorConstants.lightBackgroundColor,
                              ),
                            ).toShimmer(
                              baseColor: ColorConstants.lightBackgroundColor,
                              highlightColor: ColorConstants.white,
                            )
                          : controller.fundsState == NetworkState.error
                              ? SizedBox(
                                  height: 145,
                                  child: RetryWidget(
                                    controller.fundsErrorMessage,
                                    onPressed: () => controller
                                        .fetchStoreFunds(portfolio.schemes!),
                                  ),
                                )
                              : isMicroSIP
                                  ? MicroSIPFundListTile(fund: funds![index])
                                  : _buildFundTile(
                                      context, funds![index], controller);
                      // : FundListTile(
                      //     fund: funds![index],
                      //     isTopUpPortfolio:
                      //         controller.isTopUpPortfolio,
                      //     showWealthyRating: true,
                      //   );
                    },
                  ),
                  (funds != null && (funds.length - itemCount) > 0)
                      ? InkWell(
                          onTap: (() {
                            controller.updateFundsListCount(funds.length);
                          }),
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            child: Text(
                              'Show ${funds.length - itemCount} More',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: ColorConstants.primaryAppColor,
                                  ),
                            ),
                          ),
                        )
                      // ? Padding(
                      //     padding: const EdgeInsets.only(bottom: 7.0),
                      //     child: Center(
                      //       child: TextButton(
                      //         child: Text(
                      //           'SHOW ${funds.length - itemCount} MORE',
                      //           style: Theme.of(context)
                      //               .primaryTextTheme
                      //               .headline6
                      //               .copyWith(
                      //                 color: ColorConstants.primaryAppColor,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //         ),
                      //         onPressed: () {
                      //           controller.updateFundsListCount(funds.length);
                      //         },
                      //       ),
                      //     ),
                      //   )
                      : SizedBox(height: 8.0),
                  if (controller.fundsState == NetworkState.loaded &&
                      funds!.length == 0)
                    Text(
                      'No funds available',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineMedium!
                          .copyWith(
                            color: ColorConstants.black,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.fromLTRB(30.0, 24.0, 30.0, 16.0),
    //       child: Text(
    //         "Funds in this Portfolio",
    //         style: Theme.of(context)
    //             .primaryTextTheme
    //             .headlineMedium!
    //             .copyWith(color: ColorConstants.tertiaryGrey),
    //       ),
    //     ),
    //     GetBuilder<MFPortfolioDetailController>(
    //       id: 'funds',
    //       initState: (_) async {
    //         final controller = Get.find<MFPortfolioDetailController>();

    //         // TODO: Imrpove this
    //         await controller.onReady();

    //         if (portfolioSchemes.isNotNullOrEmpty) {
    //           controller.updateFundsList(portfolioSchemes!);
    //         } else {
    //           await controller.fetchStoreFunds(portfolio.schemes!);
    //         }
    //       },
    //       builder: (controller) {
    //         List<SchemeMetaModel>? funds = controller.fundsResult.schemeMetas;
    //         int itemCount = controller.fundsListCount;

    //         return Column(
    //           children: [
    //             ListView.separated(
    //               itemCount: controller.fundsState == NetworkState.error
    //                   ? 1
    //                   : controller.fundsState == NetworkState.loading
    //                       ? itemCount
    //                       : min(itemCount, funds!.length),
    //               shrinkWrap: true,
    //               physics: ClampingScrollPhysics(),
    //               separatorBuilder: (BuildContext context, int index) =>
    //                   (isSmartSwitch! &&
    //                           portfolio.possibleSwitchPeriods!.isNotEmpty &&
    //                           index % 2 == 0)
    //                       ? SmartSwitchDivider(
    //                           indent: 30,
    //                           endIndent: 30,
    //                         )
    //                       : SizedBox(),
    //               itemBuilder: (BuildContext context, int index) {
    //                 return controller.fundsState == NetworkState.loading
    //                     ? Container(
    //                         height: 120,
    //                         margin: const EdgeInsets.symmetric(
    //                           horizontal: 24,
    //                           vertical: 12,
    //                         ),
    //                         decoration: BoxDecoration(
    //                           borderRadius: BorderRadius.circular(10),
    //                           color: ColorConstants.lightBackgroundColor,
    //                         ),
    //                       ).toShimmer(
    //                         baseColor: ColorConstants.lightBackgroundColor,
    //                         highlightColor: ColorConstants.white,
    //                       )
    //                     : controller.fundsState == NetworkState.error
    //                         ? SizedBox(
    //                             height: 145,
    //                             child: RetryWidget(
    //                               controller.fundsErrorMessage,
    //                               onPressed: () => controller
    //                                   .fetchStoreFunds(portfolio.schemes!),
    //                             ),
    //                           )
    //                         : isMicroSIP
    //                             ? MicroSIPFundListTile(fund: funds![index])
    //                             : FundListTile(
    //                                 fund: funds![index],
    //                                 isTopUpPortfolio:
    //                                     controller.isTopUpPortfolio,
    //                                 showWealthyRating: true,
    //                               );
    //               },
    //             ),
    //             (funds != null && (funds.length - itemCount) > 0)
    //                 ? InkWell(
    //                     onTap: (() {
    //                       controller.updateFundsListCount(funds.length);
    //                     }),
    //                     child: Container(
    //                       margin: EdgeInsets.only(top: 10),
    //                       padding:
    //                           EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    //                       child: Text(
    //                         'Show ${funds.length - itemCount} More',
    //                         style: Theme.of(context)
    //                             .primaryTextTheme
    //                             .headlineSmall!
    //                             .copyWith(
    //                               fontWeight: FontWeight.w600,
    //                               color: ColorConstants.primaryAppColor,
    //                             ),
    //                       ),
    //                     ),
    //                   )
    //                 // ? Padding(
    //                 //     padding: const EdgeInsets.only(bottom: 7.0),
    //                 //     child: Center(
    //                 //       child: TextButton(
    //                 //         child: Text(
    //                 //           'SHOW ${funds.length - itemCount} MORE',
    //                 //           style: Theme.of(context)
    //                 //               .primaryTextTheme
    //                 //               .headline6
    //                 //               .copyWith(
    //                 //                 color: ColorConstants.primaryAppColor,
    //                 //                 fontWeight: FontWeight.w600,
    //                 //               ),
    //                 //         ),
    //                 //         onPressed: () {
    //                 //           controller.updateFundsListCount(funds.length);
    //                 //         },
    //                 //       ),
    //                 //     ),
    //                 //   )
    //                 : SizedBox(height: 8.0),
    //             if (controller.fundsState == NetworkState.loaded &&
    //                 funds!.length == 0)
    //               Text(
    //                 'No funds available',
    //                 textAlign: TextAlign.center,
    //                 style: Theme.of(context)
    //                     .primaryTextTheme
    //                     .headlineMedium!
    //                     .copyWith(
    //                       color: ColorConstants.black,
    //                       fontWeight: FontWeight.w500,
    //                     ),
    //               ),
    //           ],
    //         );
    //       },
    //     ),
    //   ],
    // );
  }

  Widget _buildFundTile(
      context, SchemeMetaModel scheme, MFPortfolioDetailController controller) {
    double? returnByYear;
    if (controller.categoryReturnYearSelected == 1) {
      returnByYear = scheme.returns?.oneYrRtrns;
    } else if (controller.categoryReturnYearSelected == 3) {
      returnByYear = scheme.returns?.threeYrRtrns;
    } else if (controller.categoryReturnYearSelected == 5) {
      returnByYear = scheme.returns?.fiveYrRtrns;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Displays Amc Logo, Scheme Name, Scheme Rating and Expense Ratio
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAmcLogoNameRating(context, scheme),
                Padding(
                  padding: EdgeInsets.only(left: 50),
                  child: Row(
                    children: [
                      CommonMfUI.buildMfRating(context, scheme),
                      SizedBox(width: 15),
                      _buildAllocationDetails(context, scheme.idealWeight)
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(width: 10),
          // Displays return along with add basket button
          Text(
            returnByYear != null ? getReturnPercentageText(returnByYear) : '-',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationDetails(BuildContext context, int? idealWeight) {
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
            'Allocation',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                height: 1,
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 4),
          Text(
            "${idealWeight == null ? '0%' : '${idealWeight}%'}",
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(height: 1, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _buildAmcLogoNameRating(BuildContext context, SchemeMetaModel scheme) {
    return Row(
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
                scheme.displayName!,
                maxLines: 2,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium!
                    .copyWith(fontSize: 14),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildReturnDropdown(
      BuildContext context, MFPortfolioDetailController controller) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Row(
          children: [
            Text(
              '${controller.categoryReturnYearSelected} Yr',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(color: ColorConstants.primaryAppColor),
            ),
            SizedBox(width: 3),
            Icon(
              Icons.sync_alt,
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
                  controller.updateCategoryReturnYearSelected(year);
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
}
