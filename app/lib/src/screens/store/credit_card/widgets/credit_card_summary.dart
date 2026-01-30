import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/credit_card/credit_cards_controller.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/store/models/credit_card_summary_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreditCardSummary extends StatelessWidget {
  const CreditCardSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreditCardsController>(
        builder: (CreditCardsController controller) {
      if (controller.creditCardSummaryState == NetworkState.loading) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          height: 200,
          decoration: BoxDecoration(
            color: ColorConstants.lightBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ).toShimmer(
          baseColor: ColorConstants.lightBackgroundColor,
          highlightColor: ColorConstants.white,
        );
      }
      if (controller.creditCardSummaryState == NetworkState.error) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          height: 200,
          child: RetryWidget(
            controller.creditCardSummaryErrorMessage,
            onPressed: () {
              controller.getCreditCardSummary();
            },
          ),
        );
      }
      if (controller.creditCardSummaryState == NetworkState.loaded) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Summary',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              _buildSummaryCard(
                context,
                controller.creditCardSummaryModel!,
              ),
            ],
          ),
        );
      }
      return SizedBox();
    });
  }

  Widget _buildSummaryCard(
    BuildContext context,
    CreditCardSummaryModel creditCardSummaryModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 24),
      margin: EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AllImages().creditCardSummaryIcon,
                height: 60,
                width: 60,
                fit: BoxFit.fill,
              ),
              SizedBox(width: 10),
              CommonUI.buildColumnTextInfo(
                title: 'Total Cards Issued',
                subtitle:
                    '${creditCardSummaryModel.productsIssued} Card${(creditCardSummaryModel.productsIssued ?? 0) > 1 ? "s" : ""}',
                titleStyle:
                    Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                subtitleStyle:
                    Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.black,
                        ),
                gap: 6,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonUI.buildColumnTextInfo(
                  title: 'Leads in Process',
                  subtitle:
                      '${creditCardSummaryModel.leadsInProgress} Lead${(creditCardSummaryModel.leadsInProgress ?? 0) > 1 ? "s" : ""}',
                  titleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.tertiaryBlack,
                          ),
                  subtitleStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                      ),
                  gap: 6,
                ),
                CommonUI.buildColumnTextInfo(
                  title: 'Applications Submitted',
                  subtitle:
                      '${creditCardSummaryModel.applicationSubmitted} Application${(creditCardSummaryModel.applicationSubmitted ?? 0) > 1 ? "s" : ""}',
                  titleStyle:
                      Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.tertiaryBlack,
                          ),
                  subtitleStyle: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.black,
                      ),
                  gap: 6,
                ),
              ],
            ),
          ),
          CommonUI.buildProfileDataSeperator(),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClickableText(
                  text: 'View Details',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  onClick: () {
                    AutoRouter.of(context).push(
                      ProposalListRoute(
                        showBackButton: true,
                        // selectedProductCategory: ProductCategoryType.LOAN,
                      ),
                    );
                  },
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 20,
                  color: ColorConstants.primaryAppColor,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
