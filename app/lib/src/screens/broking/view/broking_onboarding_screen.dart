import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/controllers/broking/broking_search_controller.dart';
import 'package:app/src/screens/broking/widgets/broking_client_filter_bottomsheet.dart';
import 'package:app/src/screens/broking/widgets/broking_onboarded_clients.dart';
import 'package:app/src/screens/broking/widgets/broking_search_bar.dart';
import 'package:app/src/screens/broking/widgets/broking_search_results.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class BrokingOnboardingScreen extends StatelessWidget {
  final brokingSearchController =
      Get.put<BrokingSearchController>(BrokingSearchController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) {
        onPopInvoked(didPop, () {
          onBackPress();
          AutoRouter.of(context).popForced();
        });
      },
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        appBar: CustomAppBar(
          titleText: 'Client Onboarding',
          onBackPress: () {
            onBackPress();
            AutoRouter.of(context).popForced();
          },
        ),
        body: GetBuilder<BrokingController>(
          initState: (_) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                Get.find<BrokingController>().initBrokingOnboarding();
              },
            );
          },
          builder: (controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: _buildHeader(context, controller),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: BrokingSearchBar(
                    onClearText: () {
                      controller.getBrokingOnboardingData();
                    },
                    onFilterTap: () {
                      controller.updateClientFilter(controller.savedFilter);
                      CommonUI.showBottomSheet(
                        context,
                        child: BrokingClientFilterBottomSheet(),
                      );
                    },
                  ),
                ),
                GetBuilder<BrokingSearchController>(
                  builder: (searchController) {
                    return Expanded(
                      child: searchController.isInSearchMode
                          ? BrokingSearchResults(type: 'onboarding')
                          : BrokingOnboardedClients(),
                    );
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BrokingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Get Results By',
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        PartnerOfficeDropdown(
          tag: 'Broking',
          title: 'Onboarded Clients',
          onEmployeeSelect: controller.updatePartnerEmployeeSelected,
          canSelectAllEmployees: true,
          canSelectPartnerOffice: true,
        ),
      ],
    );
  }

  void onBackPress() {
    final controller = Get.find<BrokingController>();
    controller.clearClientFilter();
    brokingSearchController.clearSearchBar();
    controller.getBrokingOnboardingData();
  }
}
