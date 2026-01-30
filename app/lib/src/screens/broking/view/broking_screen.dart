import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/broking/broking_controller.dart';
import 'package:app/src/screens/broking/widgets/broking_summary.dart';
import 'package:app/src/screens/broking/widgets/latest_clients.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/partner_office_dropdown.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/my_team/models/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class BrokingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrokingController>(
      init: BrokingController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: 'Broking',
            trailingWidgets: [
              PartnerOfficeDropdown(
                tag: 'Broking',
                title: 'Broking',
                onEmployeeSelect: (PartnerOfficeModel partnerOfficeModel) {
                  MixPanelAnalytics.trackWithAgentId(
                    "employee_filter",
                    screen: 'broking',
                    screenLocation: 'broking',
                  );

                  controller.updatePartnerEmployeeSelected(partnerOfficeModel);
                },
                canSelectAllEmployees: true,
                canSelectPartnerOffice: true,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildProductList(context, controller),
                BrokingSummary(),
                // TopStocks(),
                LatestClients(),
                SizedBox(height: 30)
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.aliceBlueColor,
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'Manage your broking business here',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, BrokingController controller) {
    List<Map<String, dynamic>> productData = [
      {
        'title': 'Demat\nProposal',
        'image': AllImages().dematProposalIcon,
        'onclick': () {
          MixPanelAnalytics.trackWithAgentId(
            "demat_proposal",
            screen: 'broking',
            screenLocation: 'broking',
          );
          AutoRouter.of(context).push(
            ProposalListRoute(
                selectedProductCategory: ProductCategoryType.DEMAT),
          );
        }
      },
      {
        'title': 'Broking\nResearch',
        'image': AllImages().brokingResearchIcon,
        'onclick': () {
          MixPanelAnalytics.trackWithAgentId(
            "broking_research",
            screen: 'broking',
            screenLocation: 'broking',
          );
          showToast(text: "Coming Soon...");
        }
      },
      {
        'title': 'Client\nOnboarding',
        'image': AllImages().brokingOnboardingIcon,
        'onclick': () {
          MixPanelAnalytics.trackWithAgentId(
            "client_onboarding",
            screen: 'broking',
            screenLocation: 'broking',
          );
          AutoRouter.of(context).push(BrokingOnboardingRoute());
        }
      },
      if (!isEmployeeLoggedIn())
        {
          'title': 'Brokerage',
          'image': AllImages().brokerageIcon,
          'onclick': () {
            MixPanelAnalytics.trackWithAgentId(
              "brokerage",
              screen: 'broking',
              screenLocation: 'broking',
            );

            AutoRouter.of(context).push(BrokingActivityRoute());
          }
        },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
        top: 20,
        bottom: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: productData.map(
          (data) {
            return Expanded(
              child: InkWell(
                onTap: data['onclick'],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      data['image'],
                      height: 48,
                      width: 48,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        data['title'],
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge
                            ?.copyWith(
                              color: ColorConstants.black,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

Widget buildSectionHeader({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Function onViewAll,
  bool showViewAll = true,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.black,
                ),
          ),
          if (showViewAll)
            ClickableText(
              text: 'View All',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              onClick: onViewAll,
            )
        ],
      ),
      if (subtitle.isNotNullOrEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle!,
            style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
        )
    ],
  );
}
