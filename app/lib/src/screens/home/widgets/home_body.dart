import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/route_name.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/delete_partner_controller.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/screens/advisor/newsletter/widgets/newsletter_common_ui.dart';
import 'package:app/src/screens/commons/delete_partner/cancel_delete_partner.dart';
import 'package:app/src/screens/home/partner_referral.dart/widgets/referral_card.dart';
import 'package:app/src/screens/home/widgets/banner_carousel.dart';
import 'package:app/src/screens/home/widgets/branding_creation_banner.dart';
import 'package:app/src/screens/home/widgets/complete_empanelment_card.dart';
import 'package:app/src/screens/home/widgets/featured_section.dart';
import 'package:app/src/screens/home/widgets/home_business_section.dart';
import 'package:app/src/screens/home/widgets/insurance_section.dart';
import 'package:app/src/screens/home/widgets/learn_with_wealthy_section.dart';
import 'package:app/src/screens/home/widgets/quick_action_section.dart';
import 'package:app/src/screens/home/widgets/whatsapp_community_banner.dart';
import 'package:app/src/screens/profile/widgets/relationship_manager.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'new_feature_list_bottomsheet.dart';
import 'tnc_bottomsheet.dart';

class HomeBody extends StatefulWidget {
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final deletePartnerController = Get.isRegistered<DeletePartnerController>()
      ? Get.find<DeletePartnerController>()
      : Get.put<DeletePartnerController>(DeletePartnerController());

  @override
  void initState() {
    // showNewUpdateFeature();

    HomeController homeController = Get.find<HomeController>();

    bool showTncAgreement =
        homeController.advisorOverviewModel?.agent?.hasAcceptedActiveTnc ==
                false &&
            (homeController.advisorOverviewModel?.partnerArn?.isArnActive ==
                true) &&
            homeController.showTncBottomSheet;

    if (showTncAgreement) {
      MixPanelAnalytics.trackWithAgentId("tnc_viewed");
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) async {
          CommonUI.showBottomSheet(
            context,
            // backgroundColor: Colors.transparent,
            child: TncBottomSheet(),
            isDismissible: false,
          );
        },
      );
    } else if (!homeController.isHomeScreenContentFetched) {
      homeController.getHomeScreenContent();
    }

    // if (!homeController.isHomeScreenContentFetched) {
    //   homeController.getHomeScreenContent();
    // }

    super.initState();
  }

  void showNewUpdateFeature() async {
    final SharedPreferences sharedPreferences = await prefs;

    bool shouldShowNewFeatureDetails = sharedPreferences
            .getBool(SharedPreferencesKeys.showNewFeatureDetails) ??
        false;

    bool isNewUpdateFeatureViewed = sharedPreferences
            .getBool(SharedPreferencesKeys.isNewUpdateFeatureViewed) ??
        false;

    bool isHomeScreen =
        AutoRouter.of(context).currentPath == AppRouteName.baseScreen &&
            Get.find<NavigationController>().currentScreen == Screens.HOME;
    // if (isHomeScreen &&
    //     shouldShowNewFeatureDetails &&
    //     !isNewUpdateFeatureViewed) {
    //   WidgetsBinding.instance.addPostFrameCallback(
    //     (timeStamp) async {
    //       sharedPreferences.setBool(
    //           SharedPreferencesKeys.isNewUpdateFeatureViewed, true);

    //       CommonUI.showBottomSheet(
    //         context,
    //         // backgroundColor: Colors.transparent,
    //         child: NewFeatureListBottomSheet(),
    //       );
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCancelUI(),
        Expanded(
          child: GetBuilder<HomeController>(
            builder: (controller) {
              final isAgentActivated =
                  controller.advisorOverviewModel!.agent!.isActivated;

              final isPstAssigned =
                  controller.advisorOverviewModel?.agent?.pst != null &&
                      controller.advisorOverviewModel!.agent!.isActivated;
              final isNonEmployee = !isEmployeeLoggedIn();
              final showReferralCard = isNonEmployee &&
                  controller.isKycDone &&
                  controller.isEmpanelmentCompleted;
              return ListView(
                physics: ClampingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 50, top: 24),
                children: [
                  _buildBanners(context, controller),
                  // if (controller.showNewFeatureBanner)
                  //   _buildNewFeatureBanner(context, controller),
                  if (showReferralCard)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(bottom: 20),
                      child: ReferralCard(),
                    ),
                  if (!controller.hasLimitedAccess && isNonEmployee)
                    CompleteEmpanelmentCard(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: QuickActionSection(),
                  ),

                  _buildLiveChatButton(),

                  if (!isEmployeeLoggedIn())
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: BrandingCreationBanner(),
                    ),

                  if (controller.showWhatsappBanner)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: WhatsappCommunityBanner(),
                    ),

                  if (isAgentActivated)
                    HomeBusinessSection(
                      hasLimitedAccess: controller.hasLimitedAccess,
                    ),
                  _buildNewsLetterSection(context, controller.newsletterStatus),

                  if (isPstAssigned) _buildRMCard(controller),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: _buildMutualFundSection(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInsuranceSection(context),
                      if (controller.isHomeScreenContentFetched)
                        LearnWithWealthySection(),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChatButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorConstants.tertiaryCardColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          onTap: () {
            openFreshChatSupport();
          },
          child: Row(
            children: [
              Image.asset(AllImages().chatBubble, width: 24),
              SizedBox(width: 10),
              Text(
                'Live Chat Support',
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.black,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 22),
                child: Text(
                  'Chat Now',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsuranceSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(context: context, title: 'Explore Insurance'),
        SizedBox(height: 16),
        InsuranceSection(),
      ],
    );
  }

  Widget _buildMutualFundSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context: context,
          title: 'Explore Mutual Funds',
          subTitle: 'Invest in 1000+ mutual funds',
          onTap: () {
            MixPanelAnalytics.trackWithAgentId(
              "mf_view_all",
              properties: {
                "screen_location": "explore_mf",
                "screen": "Home",
              },
            );
            AutoRouter.of(context).push(MfLobbyRoute());
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: FeaturedSection(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? subTitle,
    required BuildContext context,
    Function? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                        overflow: TextOverflow.ellipsis,
                        height: 19 / 16,
                      ),
                ),
                if (subTitle.isNotNullOrEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6.0,
                    ),
                    child: Text(
                      subTitle!,
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.secondaryBlack,
                            overflow: TextOverflow.ellipsis,
                            height: 1,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null)
            ClickableText(
              padding: const EdgeInsets.only(left: 10.0),
              text: 'View All',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              onClick: onTap,
            )
        ],
      ),
    );
  }

  Widget _buildRMCard(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 20, right: 20),
      child: ManagerCard(
        horizontalPadding: 0,
        title: '',
        bgColor: ColorConstants.secondaryCardColor,
        manager: controller.advisorOverviewModel!.agent!.pst,
      ),
    );
  }

  Widget _buildBanners(context, HomeController controller) {
    // show for all

    // if (controller.advisorOverviewModel!.agent!.isActivated &&
    //     !(controller.advisorOverviewModel!.agent!.isAgentNew)) {
    //   return SizedBox();
    // }

    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: BannerCarousel(),
    );
  }

  Widget _buildNewFeatureBanner(
      BuildContext context, HomeController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
      child: InkWell(
        onTap: () {
          MixPanelAnalytics.trackWithAgentId(
            "whats_new_banner",
            properties: {"screen": "Home"},
          );
          CommonUI.showBottomSheet(
            context,
            child: NewFeatureListBottomSheet(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
              color: hexToColor("#FFAB90").withOpacity(0.15),
              borderRadius: BorderRadius.circular(50)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 8, right: 4),
                child: Image.asset(AllImages().newFeatureTag, width: 42),
              ),
              Text(
                'What\'s new in Wealthy Partner ',
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
              Text(
                'v4.0',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(color: ColorConstants.tertiaryBlack),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_sharp,
                size: 20,
                color: ColorConstants.tertiaryBlack,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelUI() {
    return GetBuilder<DeletePartnerController>(
      builder: (controller) {
        if (controller.isAccountDeletionRequestOpen) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32)
                .copyWith(bottom: 16),
            child: CancelDeletePartner(),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildNewsLetterSection(
      BuildContext context, Map<String, bool> newsletterStatus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14).copyWith(bottom: 12),
            child: Text(
              'Newsletters',
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NewsLetterCommonUI.buildTabCard(
              image: AllImages().moneyOrderIcon,
              title: 'Money Order',
              subtitle: 'A weekly newsletter on the biggest economic trends',
              context: context,
              showNewTag: newsletterStatus['money-order'] ?? false,
              onTap: () {
                MixPanelAnalytics.trackWithAgentId(
                  'money-order',
                  screen: "home",
                  screenLocation: "newsletters",
                );

                AutoRouter.of(context).push(
                  NewsLetterRoute(contentType: 'money-order'),
                );
              },
            ),
          ),
          // NOTE: Other newsletter tabs are temporarily commented out.
          // Currently only showing Money Order tab in home screen newsletters section.
          // ...List<Widget>.generate(
          //   newsLetterTabs.length,
          //   (index) {
          //     final tabInfo = newsLetterTabs[index];
          //     final title = tabInfo['title'];
          //     final description = tabInfo['description'];
          //     final image = tabInfo['image'];
          //     final contentType = tabInfo['content_type'];
          //     return Padding(
          //       padding: const EdgeInsets.only(bottom: 12),
          //       child: NewsLetterCommonUI.buildTabCard(
          //         image: image!,
          //         title: title!,
          //         subtitle: description!,
          //         context: context,
          //         showNewTag: newsletterStatus[contentType] ?? false,
          //         onTap: () {
          //           MixPanelAnalytics.trackWithAgentId(
          //             contentType ?? '',
          //             screen: "home",
          //             screenLocation: "newsletters",
          //           );

          //           AutoRouter.of(context).push(
          //             NewsLetterRoute(contentType: contentType),
          //           );
          //         },
          //       ),
          //     );
          //   },
          // )
        ],
      ),
    );
  }
}
