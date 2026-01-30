import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/partner_referral_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/advisor/models/partner_referral_faq_term_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ReferralRewardsFaqTermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'FAQs and T&C',
        subtitleText: 'Common doubts regarding referral program',
      ),
      body: GetBuilder<PartnerReferralController>(
        id: 'referral-faq',
        builder: (controller) {
          if (controller.referralFaqTermResponse.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (controller.referralFaqTermResponse.isError) {
            return Center(
              child: RetryWidget(
                controller.referralFaqTermResponse.message,
                onPressed: () {
                  controller.getReferralFaqTerms();
                },
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabs(context, controller),
              SizedBox(height: 10),
              Expanded(
                child: _buildTabBarView(context, controller),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBarView(
    BuildContext context,
    PartnerReferralController controller,
  ) {
    switch (controller.tabController.index) {
      case 0:
        return _buildFaqList(
          context,
          controller.faqTermModel!.faqs,
        );
      case 1:
        return _buildTermsAndConditions(
          context,
          controller.faqTermModel!.termsAndConditions,
        );

      default:
        return _buildFaqList(
          context,
          controller.faqTermModel!.faqs,
        );
    }
  }

  Widget _buildTabs(
    BuildContext context,
    PartnerReferralController controller,
  ) {
    return Container(
      height: 54,
      color: Colors.white,
      child: TabBar(
        dividerHeight: 0,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        controller: controller.tabController,
        isScrollable: false,
        unselectedLabelColor: ColorConstants.tertiaryBlack,
        unselectedLabelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.tertiaryBlack),
        indicatorWeight: 1,
        indicatorColor: ColorConstants.primaryAppColor,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: ColorConstants.black,
        labelStyle: context.headlineSmall!
            .copyWith(color: ColorConstants.black, fontWeight: FontWeight.w600),
        tabs: List<Widget>.generate(
          2,
          (index) => Tab(
            text: controller.faqTermTabs[index],
            iconMargin: EdgeInsets.zero,
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildFaqList(
    BuildContext context,
    List<Faqs>? faqs,
  ) {
    if (faqs.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(
          message: 'No Faq Found',
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: faqs!.length,
      itemBuilder: (context, index) {
        final title = faqs[index].question ?? '';
        final subtitle = faqs[index].answer ?? '';

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // tilePadding: EdgeInsets.all(16),
            backgroundColor: ColorConstants.secondaryWhite,
            title: Text(
              title,
              style: context.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorConstants.black,
              ),
            ),
            expandedAlignment: Alignment.topLeft,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16)
                    .copyWith(bottom: 16),
                child: Text(
                  subtitle,
                  style: context.headlineSmall?.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    height: 1.4,
                  ),
                ),
              )
            ],
          ),
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 10),
    );
  }

  Widget _buildTermsAndConditions(
    BuildContext context,
    List<String>? termsAndConditions,
  ) {
    if (termsAndConditions.isNullOrEmpty) {
      return Center(
        child: EmptyScreen(
          message: 'No Faq Found',
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: termsAndConditions!.length,
      itemBuilder: (context, index) {
        final termsCondition = termsAndConditions[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$bulletPointUnicode  ',
              style: context.headlineSmall!.copyWith(
                fontWeight: FontWeight.w400,
                color: ColorConstants.black,
              ),
            ),
            Expanded(
              child: Text(
                termsCondition,
                style: context.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.tertiaryBlack,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
      separatorBuilder: (_, __) => SizedBox(height: 10),
    );
  }
}
