import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/nfos_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/top_funds_nfo_controller.dart';
import 'package:app/src/screens/store/fund_detail/widgets/basket_icon.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/lazy_indexed_stack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/nfo_section.dart';

@RoutePage()
class TopFundsNfoScreen extends StatelessWidget {
  const TopFundsNfoScreen({Key? key, this.activeTab}) : super(key: key);

  final MfListType? activeTab;

  void _deleteBuilders() {
    if (Get.isRegistered<NfosController>()) {
      Get.delete<NfosController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          _deleteBuilders();
          AutoRouter.of(context).popForced();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          titleText: 'NFO',
          onBackPress: () {
            _deleteBuilders();
            AutoRouter.of(context).popForced();
          },
          trailingWidgets: [
            BasketIcon(
              onTap: () {
                AutoRouter.of(context).push(
                  BasketOverViewRoute(),
                );
              },
            )
          ],
        ),
        body: GetBuilder<TopFundsNfoController>(
          init: TopFundsNfoController(activeTab: activeTab ?? MfListType.Nfo),
          builder: (controller) {
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildTopSellingNfoTabs(context),

                  // Indexed Stack is used to maintain the state between the two child widgets
                  Expanded(
                    child: LazyIndexedStack(
                      sizing: StackFit.expand,
                      index: 0,
                      // controller.activeTab == MfListType.TopSelling ? 0 : 1,
                      children: [
                        // TopSellingFundsSection(),
                        NfoSection(),
                      ],
                    ),
                  )
                  // Expanded(
                  //   child: SingleChildScrollView(
                  //     child:,
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: CommonMfUI.buildMfLobbyBottomNavigationBar(),
      ),
    );
  }

  Widget _buildTopSellingNfoTabs(BuildContext context) {
    return GetBuilder<TopFundsNfoController>(
      builder: (controller) {
        return Row(
          children: [
            _buildTab(
              context,
              text: 'Top Selling Funds',
              isSelected: controller.activeTab == MfListType.TopSelling,
              onTap: () {
                controller.updateActiveTab(MfListType.TopSelling);
              },
            ),
            _buildTab(
              context,
              text: 'NFO',
              isSelected: controller.activeTab == MfListType.Nfo,
              onTap: () {
                controller.updateActiveTab(MfListType.Nfo);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required void Function() onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            border: Border(
              bottom: isSelected
                  ? BorderSide(color: ColorConstants.primaryAppColor)
                  : BorderSide.none,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? ColorConstants.black
                    : ColorConstants.tertiaryBlack),
          ),
        ),
      ),
    );
  }
}
