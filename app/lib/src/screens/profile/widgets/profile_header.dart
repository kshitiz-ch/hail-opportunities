import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/screens/clients/client_list/widgets/client_onboarding_bottomsheet.dart';
import 'package:app/src/screens/profile/widgets/choose_profile_picture_bottomsheet.dart';
import 'package:app/src/screens/profile/widgets/profile_name.dart';
import 'package:app/src/screens/profile/widgets/visiting_card_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/advisor_overview_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'change_referral_code_bottomsheet.dart';

class ProfileHeader extends StatelessWidget {
  final Function onBackPress;

  final commonController = Get.find<CommonController>();

  ProfileHeader({Key? key, required this.onBackPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        id: GetxId.profile,
        builder: (controller) {
          final profileName =
              controller.advisorOverview!.agent!.displayName!.toTitleCase();
          final doj = WealthyCast.toDate(
              controller.advisorOverview!.agent!.dateOfActivation);
          final referralUrl = controller.advisorOverview!.agent!.referralUrl;

          return Container(
            padding: EdgeInsets.only(top: 40),
            color: ColorConstants.lavenderSecondaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                _buildProfileImage(controller, context),
                SizedBox(height: 9),
                Center(child: ProfileName(profileName: profileName)),
                SizedBox(height: 6),
                if (doj != null)
                  Center(
                    child: Text(
                      'Partner Since ${doj.year}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                // TODO: uncomment when it is required
                // _buildPartnerOfficeDetails(
                //   context,
                //   controller.advisorOverview!,
                // ),
                _buildVisitingCardBrochure(context),

                Obx(() {
                  if (!commonController.brandingSectionFlag.value) {
                    return SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(top: 10),
                    child: _buildBrandingSection(context),
                  );
                }),

                if (referralUrl.isNotNullOrEmpty)
                  _buildClientInvite(context, controller)
              ],
            ),
          );
        });
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20).copyWith(top: 10),
      child: InkWell(
        onTap: () {
          onBackPress();
        },
        child: Image.asset(
          AllImages().appBackIcon,
          height: 32,
          width: 32,
        ),
      ),
    );
  }

  Widget _buildProfileImage(
      ProfileController controller, BuildContext context) {
    final imageUrl = controller.advisorOverview?.profilePictureUrl ??
        controller.advisorOverview?.agent?.imageUrl;
    final errorWidget = Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(AllImages().profileIcon),
          fit: BoxFit.fill,
        ),
      ),
    );

    return Center(
      child: InkWell(
        onTap: () {
          CommonUI.showBottomSheet(context,
              child: ChooseProfilePictureBottomSheet(),
              isScrollControlled: true,
              isDismissible: false);
        },
        child: Stack(
          children: [
            controller.getImageResponse.state == NetworkState.loading
                ? CommonUI.buildProfilePicLoader(36)
                : CachedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                    placeholder: (_, __) => CommonUI.buildProfilePicLoader(36),
                    errorWidget: (_, __, ___) => errorWidget,
                  ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorConstants.secondaryAppColor,
                ),
                child: Icon(
                  Icons.edit,
                  size: 14,
                  color: ColorConstants.primaryAppColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerOfficeDetails(
    BuildContext context,
    AdvisorOverviewModel advisorOverview,
  ) {
    if (advisorOverview.isEmployee || advisorOverview.isOwner) {
      String officeName =
          advisorOverview.agentDesignation?.partnerOfficeName ?? '';
      if (officeName.isNullOrEmpty) {
        officeName = 'My Team';
      } else if (!officeName.toLowerCase().endsWith('team')) {
        officeName = '$officeName Team';
      }
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Center(
          child: Text(
            '${advisorOverview.isEmployee ? 'Employee' : 'Owner'} at ${officeName.toTitleCase()}',
            textAlign: TextAlign.center,
            style: context.headlineSmall
                ?.copyWith(color: ColorConstants.tertiaryBlack),
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildVisitingCardBrochure(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 18),
      child: Row(
        children: [
          _buildVisitingCardBrochureCard(context, isVisitingCard: true),
          SizedBox(width: 8),
          _buildVisitingCardBrochureCard(context, isVisitingCard: false),
        ],
      ),
    );
  }

  Widget _buildVisitingCardBrochureCard(BuildContext context,
      {required bool isVisitingCard}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          MixPanelAnalytics.trackWithAgentId(
            isVisitingCard ? "visiting_card_click" : "brochure_click",
            screen: 'partner_profile',
            screenLocation: 'partner_profile',
          );

          if (isVisitingCard) {
            CommonUI.showBottomSheet(
              context,
              child: VisitingCardBottomSheet(
                templateName: isVisitingCard
                    ? "PARTNER-VISITING-CARD"
                    : "PARTNER-BROCHURE",
              ),
            );
          } else {
            String brochureUrl = Get.find<ProfileController>().brochureUrl;
            if (brochureUrl.isNotEmpty) {
              launch(brochureUrl);
            } else {
              showToast(text: "Brochure iscurrently not available");
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: ColorConstants.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isVisitingCard
                    ? AllImages().visitingCardOutline
                    : AllImages().brochure,
                height: 16,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                isVisitingCard ? 'Visiting Card' : "Brochure",
                style: Theme.of(context).primaryTextTheme.titleLarge,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(BrandingWebViewRoute());
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: ColorConstants.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Branding',
              style: context.titleLarge?.copyWith(
                color: ColorConstants.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 10),
              child: CommonUI.buildNewTag(context),
            ),
            Text(
              'Update Your logo and brand details',
              style: context.titleLarge?.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildClientInvite(
      BuildContext context, ProfileController controller) {
    return SizedBox(
      height: 130,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SizedBox(),
              ),
              Expanded(
                child: Container(
                  color: ColorConstants.white,
                ),
              )
            ],
          ),
          _buildClientInviteCard(context, controller)
        ],
      ),
    );
  }

  Widget _buildClientInviteCard(
      BuildContext context, ProfileController profileController) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0.0, 1.0),
            spreadRadius: 0.0,
            blurRadius: 7.0,
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Client Invite Link',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .titleLarge!
                              .copyWith(
                                color: ColorConstants.tertiaryBlack,
                              ),
                        ),
                        InkWell(
                          onTap: () {
                            CommonUI.showBottomSheet(
                              context,
                              child: ChangeReferralCodeBottomSheet(),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.edit,
                              color: ColorConstants.primaryAppColor,
                              size: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        profileController.advisorOverview!.agent!.referralUrl ??
                            '',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(
                              color: ColorConstants.black,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 3),
                child: InkWell(
                  onTap: () async {
                    if (profileController
                        .advisorOverview!.agent!.referralUrl.isNotNullOrEmpty) {
                      MixPanelAnalytics.trackWithAgentId(
                        "invite_link_copy",
                        screen: 'partner_profile',
                        screenLocation: 'partner_profile',
                      );
                      await copyData(
                        data: getClientinviteLink(profileController
                            .advisorOverview!.agent!.referralUrl!),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: ColorConstants.white,
                    child: Image.asset(
                      AllImages().copyIcon,
                      height: 24,
                      width: 24,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (profileController
                      .advisorOverview!.agent!.referralUrl.isNotNullOrEmpty) {
                    MixPanelAnalytics.trackWithAgentId(
                      "share_link",
                      screen: 'partner_profile',
                      screenLocation: 'partner_profile',
                    );

                    String referralUrl = getClientinviteLink(
                        profileController.advisorOverview!.agent!.referralUrl!);
                    shareClientInviteLink(referralUrl);
                  }
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: ColorConstants.primaryAppColor,
                  child: Image.asset(
                    AllImages().shareIcon,
                    height: 15,
                    width: 15,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          // Analytics Button
          InkWell(
            onTap: () {
              CommonUI.showBottomSheet(
                context,
                child: ClientOnboardingBottomsheet(),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.borderColor),
              ),
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics,
                    color: ColorConstants.primaryAppColor,
                    size: 24,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Show Onboarding Analytics',
                    style: context.headlineSmall?.copyWith(
                      color: ColorConstants.primaryAppColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
