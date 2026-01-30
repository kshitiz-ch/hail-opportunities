import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/advisor/newsletter_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewsLetterTabs extends StatefulWidget {
  final int initialIndex;

  const NewsLetterTabs({Key? key, this.initialIndex = 0}) : super(key: key);
  @override
  State<NewsLetterTabs> createState() => _NewsLetterTabsState();
}

class _NewsLetterTabsState extends State<NewsLetterTabs>
    with TickerProviderStateMixin {
  final newsLetterController = Get.find<NewsLetterController>();

  @override
  void initState() {
    super.initState();
    newsLetterController.tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    newsLetterController.tabController?.addListener(() {
      if (newsLetterController.tabController?.indexIsChanging == true) {
        final tabText =
            newsLetterTabs[newsLetterController.tabController?.index ?? 0]
                ['title']!;
        newsLetterController.onTabUpdate(tabText);
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
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: newsLetterController.tabController,
        isScrollable: false,
        dividerHeight: 0,
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
            child: GetBuilder<NewsLetterController>(
              builder: (controller) {
                String tabText = newsLetterTabs[index]['title']!;
                int? count;
                if (index == controller.tabController?.index) {
                  count = controller.newsLetterMetaData.totalCount;
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
