import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/sip_book_controller.dart';
import 'package:app/src/screens/advisor/sip_book/widgets/sip_book_info.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SipBookTabs extends StatefulWidget {
  @override
  State<SipBookTabs> createState() => _SipBookTabsState();
}

class _SipBookTabsState extends State<SipBookTabs>
    with TickerProviderStateMixin {
  final sipBookController = Get.find<SipBookController>();

  @override
  void initState() {
    super.initState();
    sipBookController.tabController = TabController(length: 2, vsync: this);
    sipBookController.tabController?.addListener(() {
      if (sipBookController.tabController?.indexIsChanging == true) {
        sipBookController.update();
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
        onTap: (index) {
          MixPanelAnalytics.trackWithAgentId(
            index == 0 ? "sip_book_summary" : "sip_book",
            screen: 'sip_book',
            screenLocation: 'sip_book',
          );
        },
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: sipBookController.tabController,
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
            child: GetBuilder<SipBookController>(
              builder: (controller) {
                final tabText = controller.tabs[index];
                final count = tabText == 'SIP Book'
                    ? controller.sipListingMetaData.totalCount
                    : 0;
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
    final tabText = sipBookController.tabs[tabIndex];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$tabText ${count.isNotNullOrZero ? '($count)' : ''}'),
        InkWell(
          onTap: () {
            CommonUI.showBottomSheet(
              context,
              child: SipBookInfo(tabIndex: tabIndex),
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 2, right: 10),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
