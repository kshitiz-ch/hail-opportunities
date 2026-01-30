import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:core/modules/rewards/models/reward_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

import 'reward_active_card.dart';

List<String> tabs = ['Ongoing Rewards', 'Won Rewards'];

class RewardListing extends StatefulWidget {
  final String? fromScreen;

  const RewardListing({this.fromScreen, Key? key}) : super(key: key);

  @override
  _RewardListingState createState() => _RewardListingState();
}

class _RewardListingState extends State<RewardListing>
    with TickerProviderStateMixin {
  List<Widget> tabList = [
    ...tabs.map(
      (title) => Container(
        width: SizeConfig().screenWidth! / 2,
        child: Tab(text: title),
      ),
    )
  ];

  TabController? _tabController;

  @override
  void initState() {
    // getRewards();

    _tabController = TabController(length: tabList.length, vsync: this);

    super.initState();
  }

  void dispose() {
    super.dispose();

    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RewardsController>(
      id: 'rewards-listing',
      initState: (_) {
        if (_tabController!.index == 0) {
          Get.find<RewardsController>().getActiveRewards();
        } else if (_tabController!.index == 1) {
          Get.find<RewardsController>().getCompletedRewards();
        }
      },
      builder: (controller) {
        return Column(
          children: [
            _buildTabs(controller),
            SizedBox(height: 16),
            Expanded(
              child: controller.rewardsState == NetworkState.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : controller.rewards.length == 0
                      ? _buildEmptyState(
                          isRewardsWon: _tabController!.index == 1)
                      : controller.rewardsState == NetworkState.error
                          ? _buildEmptyState()
                          : _buildList(controller),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabs(RewardsController controller) {
    return TabBar(
      dividerHeight: 0,
      controller: _tabController,
      labelPadding: EdgeInsets.zero,
      unselectedLabelColor: ColorConstants.tertiaryBlack,
      unselectedLabelStyle: Theme.of(context)
          .primaryTextTheme
          .headlineMedium!
          .copyWith(fontWeight: FontWeight.w400),
      indicatorWeight: 1,
      indicatorColor: ColorConstants.primaryAppColor,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: ColorConstants.black,
      labelStyle: Theme.of(context)
          .primaryTextTheme
          .headlineMedium!
          .copyWith(fontWeight: FontWeight.w600),
      tabs: tabList,
      onTap: (val) {
        if (val == 0) {
          controller.getActiveRewards();
        } else if (val == 1) {
          controller.getCompletedRewards();
        }
      },
    );
  }

  Widget _buildList(RewardsController controller) {
    return ListView.separated(
      padding: EdgeInsets.only(top: 0, bottom: 50),
      shrinkWrap: true,
      itemCount: controller.rewards.length,
      itemBuilder: (BuildContext context, int index) {
        RewardModel reward = controller.rewards[index];

        if (reward.earnedAt != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: _buildCompletedRewardCard(reward),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RewardActiveCard(
              reward: reward,
            ),
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 24,
        );
      },
    );
  }

  Widget _buildEmptyState({bool isRewardsWon = false}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AllImages().rewardsEmptyNew,
              width: 90,
            ),
            SizedBox(height: 20),
            Text(
              'No Rewards yet!',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              isRewardsWon
                  ? 'Make your first sale to win your first reward'
                  : 'Sorry, there are no active rewards at the moment',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 12, color: ColorConstants.tertiaryBlack),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedRewardCard(RewardModel reward) {
    DateTime earnedAtParsed;
    String? earnedDateFormatted;

    if (reward.earnedAt != null) {
      earnedAtParsed = DateTime.parse(reward.earnedAt!);
      earnedDateFormatted = DateFormat('dd MMM yyyy').format(earnedAtParsed);
    }

    return Container(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.name!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                if (earnedDateFormatted != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      earnedDateFormatted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: 12,
                              color: ColorConstants.tertiaryBlack),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            WealthyAmount.currencyFormat(reward.rewardValue, 0),
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
