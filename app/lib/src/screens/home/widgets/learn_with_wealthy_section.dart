import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/screens/home/widgets/events_section.dart';
import 'package:app/src/screens/home/widgets/wealthy_academy_section.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';

int maxNoOfEntries = 3;

class LearnWithWealthySection extends StatefulWidget {
  @override
  State<LearnWithWealthySection> createState() =>
      _LearnWithWealthySectionState();
}

class _LearnWithWealthySectionState extends State<LearnWithWealthySection>
    with TickerProviderStateMixin {
  final tabs = ['Events', 'Wealthy Academy'];
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(length: tabs.length, vsync: this);

    tabController?.addListener(() {
      if (tabController?.indexIsChanging == true) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    tabController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
              .copyWith(top: 24),
          child: Text(
            'Learn with Wealthy',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        _buildTabs(context),
        SizedBox(height: 20),
        _buildTabBarView(),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    final textStyle =
        Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: Color(0xff9B9B9B),
            );
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.tertiaryCardColor,
            ColorConstants.tertiaryCardColor.withOpacity(0),
          ],
        ),
      ),
      height: 60,
      child: TabBar(
        dividerHeight: 0,
        // isScrollable: false,
        // tabAlignment: TabAlignment.start,
        labelPadding: EdgeInsets.symmetric(horizontal: 20),
        indicatorPadding: EdgeInsets.zero,
        indicatorColor: ColorConstants.primaryAppColor,
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelStyle: textStyle,
        labelStyle: textStyle.copyWith(
          fontWeight: FontWeight.w600,
          color: ColorConstants.black,
        ),
        tabs: List.generate(
          tabs.length,
          (index) {
            return Tab(
              child: MarqueeWidget(
                child: Text(
                  tabs[index],
                  maxLines: 1,
                ),
              ),
              iconMargin: EdgeInsets.zero,
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _buildTabBarView() {
    switch (tabController!.index) {
      case 0:
        return EventsSection();
      case 1:
        return WealthyAcademySection();
      default:
        return SizedBox();
    }
  }
}

Widget buildViewAllCTA({
  required Function onClick,
  required BuildContext context,
}) {
  return Center(
    child: SizedBox(
      width: 120,
      child: ActionButton(
        text: 'View All',
        showBorder: true,
        borderColor: ColorConstants.primaryAppColor,
        bgColor: ColorConstants.white,
        height: 40,
        margin: EdgeInsets.symmetric(vertical: 20),
        textStyle: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ColorConstants.primaryAppColor,
            ),
        onPressed: () {
          onClick();
        },
      ),
    ),
  );
}
