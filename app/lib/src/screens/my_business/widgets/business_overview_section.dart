import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/controllers/my_business/business_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessOverViewSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: ColorConstants.white,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
            height: 120,
            color: ColorConstants.tertiaryCardColor,
            child: _buildTotalAum(context),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: SizedBox(
              height: 48,
              child: _buildCTACardList(context),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTotalAum(BuildContext context) {
    return GetBuilder<BusinessController>(
      id: BusinessSectionId.TotalAum,
      builder: (controller) {
        if (controller.totalAumResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 50);
        }
        if (controller.totalAumResponse.state == NetworkState.error) {
          return RetryWidget(
            controller.totalAumResponse.message,
            onPressed: () {
              controller.getPartnerTotalAum();
            },
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              padding: EdgeInsets.symmetric(horizontal: 9, vertical: 11),
              decoration: BoxDecoration(
                color: ColorConstants.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                AllImages().myBusinessAumIcon,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10),
            CommonUI.buildColumnTextInfo(
              title: 'Total AUM ',
              subtitle: WealthyAmount.currencyFormat(
                controller.totalAumModel?.currentValue,
                2,
              ),
              gap: 4,
              titleStyle:
                  Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.tertiaryBlack,
                      ),
              subtitleStyle:
                  Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.black,
                        fontSize: 20,
                      ),
            )
          ],
        );
      },
    );
  }

  Widget _buildCTACardList(BuildContext context) {
    // remove revenue sheet and payout in app for all employees
    final isNonEmployee = !isEmployeeLoggedIn();
    final homeController = Get.find<HomeController>();

    final Map<String, Map<String, dynamic>> actionList = {
      if (isNonEmployee && !homeController.hasLimitedAccess)
        'Revenue': {
          'image': AllImages().myBusinessRevenueIcon,
          'onTap': () {
            AutoRouter.of(context).push(RevenueSheetRoute());
          },
        },
      if (isNonEmployee && !homeController.hasLimitedAccess)
        'Payouts': {
          'image': AllImages().myBusinessPayoutIcon,
          'onTap': () {
            AutoRouter.of(context).push(PayoutRoute());
          },
        },
      'Reports': {
        'image': AllImages().myBusinessBrokingIcon,
        'onTap': () {
          AutoRouter.of(context).push(BusinessReportTemplateRoute());
        },
      },
    };

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: actionList.length,
      itemBuilder: (context, index) {
        final data = actionList.entries.elementAt(index);
        return InkWell(
          onTap: data.value['onTap'],
          child: Container(
            width: (SizeConfig().screenWidth! - 70) / 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorConstants.white,
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.darkBlack.withOpacity(0.08),
                  offset: Offset(0.0, 2.0),
                  spreadRadius: 0.0,
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    data.value['image'].toString(),
                    height: 20,
                    width: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    data.key,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall
                        ?.copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w500,
                        ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(width: 10);
      },
    );
  }
}
