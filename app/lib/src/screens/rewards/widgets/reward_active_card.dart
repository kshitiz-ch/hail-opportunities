import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/rewards/models/reward_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_framework/responsive_framework.dart' as Responsive;

class RewardActiveCard extends StatelessWidget {
  const RewardActiveCard({Key? key, this.reward}) : super(key: key);

  final RewardModel? reward;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCardBody(context),
          Divider(color: ColorConstants.lightGrey),
          _buildCardFooter(context),
        ],
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(deviceSpecificValue(context, 20, 30)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: ColorConstants.orangeColor,
                borderRadius: BorderRadius.circular(6)),
            child: SvgPicture.asset(
              AllImages().rewardsTrophySmall,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward!.name!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                if (reward!.description != null) _buildDescription(context),
              ],
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            WealthyAmount.currencyFormat(reward!.rewardValue, 0),
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Responsive.ResponsiveVisibility(
      hiddenConditions: const [
        Responsive.Condition.largerThan(name: Responsive.TABLET),
      ], //
      child: Container(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          reward!.description!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontSize: 12, color: ColorConstants.tertiaryBlack),
        ),
      ),
      replacement: Container(
        padding: const EdgeInsets.only(top: 4.0),
        constraints: BoxConstraints(maxWidth: SizeConfig().screenWidth! * 0.3),
        child: Text(
          reward!.description!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .primaryTextTheme
              .headlineSmall!
              .copyWith(fontSize: 12, color: ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expiry: ${reward!.endAt != null ? reward!.endAt : 'No Expiry'}',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 12, color: ColorConstants.tertiaryBlack),
          ),
          InkWell(
            onTap: () {
              AutoRouter.of(context).push(
                RewardsDetailsRoute(reward: reward),
              );
            },
            child: Text(
              'View Details',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(color: ColorConstants.primaryAppColor),
            ),
          )
        ],
      ),
    );
  }
}
