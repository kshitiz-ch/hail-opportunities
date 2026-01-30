import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobTabs extends StatefulWidget {
  @override
  State<TicobTabs> createState() => _TicobTabsState();
}

class _TicobTabsState extends State<TicobTabs> with TickerProviderStateMixin {
  final ticobController = Get.find<TicobController>();

  @override
  void initState() {
    super.initState();
    ticobController.tabController = TabController(length: 2, vsync: this);
    ticobController.tabController?.addListener(() {
      if (ticobController.tabController?.indexIsChanging == true) {
        ticobController.onTabChange();
      }
    });
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
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: ticobController.tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle:
            Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: ColorConstants.black,
        labelStyle: Theme.of(context)
            .primaryTextTheme
            .headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          2,
          (index) => Container(
            width: SizeConfig().screenWidth! / 2,
            alignment: Alignment.center,
            child: GetBuilder<TicobController>(
              builder: (controller) {
                String tabText = controller.tabs[index];
                int? count;
                if (index == controller.tabController?.index) {
                  count = controller.ticobMetaData.totalCount;
                }

                if (count.isNotNullOrZero) {
                  tabText += ' ($count)';
                }
                return Tab(
                  text: tabText,
                  iconMargin: EdgeInsets.zero,
                );
              },
            ),
          ),
        ).toList(),
      ),
    );
  }
}
