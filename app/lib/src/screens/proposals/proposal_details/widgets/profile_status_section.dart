import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/proposal/proposal_detail_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ProfileStatusSection extends StatelessWidget {
  const ProfileStatusSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProposalDetailController>(
      id: 'proposal',
      builder: (controller) {
        if (controller.proposalDetailState == NetworkState.loading) {
          return Container(
            height: 50,
            margin: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ColorConstants.lightGrey,
            ),
          ).toShimmer(
            baseColor: ColorConstants.lightBackgroundColor,
            highlightColor: ColorConstants.white,
          );
        }

        if (controller.proposalDetailState == NetworkState.error) {
          return SizedBox();
        }
        return _buildProfileStatusList(controller, context);
      },
    );
  }

  Widget _buildProfileStatusList(
      ProposalDetailController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30).copyWith(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.proposalDetail.userProfileStatuses!.isNotEmpty)
            Text(
              "Profile Status",
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        fontWeight: FontWeight.w600,
                      ),
            ),
        ]..addAll(
            List<Widget>.generate(
              controller.proposalDetail.userProfileStatuses!.length,
              (statusIndex) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.proposalDetail.userProfileStatuses![statusIndex].title!.toTitleCase()}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              overflow: TextOverflow.ellipsis,
                              color: ColorConstants.tertiaryBlack,
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: SizeConfig().screenWidth! - 200,
                              ),
                              child: Text(
                                '${controller.proposalDetail.userProfileStatuses![statusIndex].displayText!.toTitleCase()}',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      overflow: TextOverflow.fade,
                                      color: ColorConstants.black,
                                    ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Center(
                                child: SvgPicture.asset(
                                  controller
                                          .proposalDetail
                                          .userProfileStatuses![statusIndex]
                                          .isComplete!
                                      ? AllImages().verifiedRoundedIcon
                                      : AllImages().pendingRoundedIcon,
                                  height: 12,
                                  width: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
      ),
    );
  }
}
