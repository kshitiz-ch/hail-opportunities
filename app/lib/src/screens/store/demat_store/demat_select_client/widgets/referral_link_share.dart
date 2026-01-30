import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReferralLinkShare extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(
      builder: (controller) {
        if (controller.dematDetails?.referralUrl == null) {
          return SizedBox();
        }

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)
              .copyWith(right: 20),
          decoration: BoxDecoration(
            color: ColorConstants.secondaryCardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share this link with clients to open their demat account',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryGrey,
                          ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 30,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.dematDetails!.referralUrl!,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: ColorConstants.black,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: CommonUI.buildProfileDataSeperator(
                              height: 24,
                              width: 1,
                              color: ColorConstants.secondarySeparatorColor,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              await copyData(
                                data: controller.dematDetails!.referralUrl,
                              );
                            },
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AllImages().copyIconOnboardingLink,
                                  height: 12,
                                  width: 12,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    'Copy',
                                    style: Theme.of(context)
                                        .primaryTextTheme
                                        .titleLarge!
                                        .copyWith(
                                          color: ColorConstants.primaryAppColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  shareText(
                      getDematShareText(controller.dematDetails?.referralUrl) ??
                          '');
                },
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  height: 26,
                  width: 26,
                  child: Image.asset(
                    AllImages().shareIconInviteLink,
                    fit: BoxFit.fill,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
