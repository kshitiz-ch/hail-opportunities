import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/app_resources/app_resources_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResourcesTabs extends StatefulWidget {
  @override
  State<ResourcesTabs> createState() => _ResourcesTabsState();
}

class _ResourcesTabsState extends State<ResourcesTabs>
    with TickerProviderStateMixin {
  final appResourcesController = Get.find<AppResourcesController>();
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = appResourcesController.isMarketingKitSelected ? 0 : 1;
    tabController =
        TabController(length: 2, vsync: this, initialIndex: initialIndex);
    tabController?.addListener(() {
      if (tabController?.indexIsChanging == true) {
        final index = tabController?.index ?? 0;
        appResourcesController.onTabChange(index);
      }
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTabs(context);
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: 54,
      color: Colors.white,
      child: TabBar(
        onTap: (index) {
          MixPanelAnalytics.trackWithAgentId(
            index == 0 ? "marketing_kit" : "sales_kit",
            screen: 'resources',
            screenLocation: 'resources',
          );
        },
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.tertiaryBlack),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: ColorConstants.black,
        labelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          2,
          (index) => Container(
            width: SizeConfig().screenWidth! / 2,
            alignment: Alignment.center,
            child: GetBuilder<AppResourcesController>(
              builder: (controller) {
                final tabText = controller.tabs[index];
                final count = tabText == 'Poster Gallery'
                    ? controller.creativesMetaData.totalCount
                    : controller.resourceMetaData.totalCount;
                return Tab(
                  child: _buildTab(tabIndex: index, count: count),
                  iconMargin: EdgeInsets.zero,
                );
              },
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildTab({
    required int tabIndex,
    required int? count,
  }) {
    final tabText = appResourcesController.tabs[tabIndex];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$tabText${count != null && count > 0 ? ' ($count)' : ''}'),
      ],
    );
  }
}
