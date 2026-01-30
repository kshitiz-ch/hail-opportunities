import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/demat_store/widgets/pricing_plan_table.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingPlanCard extends StatelessWidget {
  const PricingPlanCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pricing Plan',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(height: 10),
        GetBuilder<DematProposalController>(builder: (controller) {
          if (controller.brokingPlansResponse.state == NetworkState.loading) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SkeltonLoaderCard(height: 200),
            );
          }

          if (controller.brokingPlansResponse.state == NetworkState.error) {
            return RetryWidget(
              controller.brokingPlansResponse.message,
              onPressed: controller.getBrokingPlans,
            );
          }

          if (controller.brokingPlans.isEmpty) {
            return EmptyScreen(
              message: "No plans found",
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Your default plan will be used for your future clients.',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ),
              SizedBox(height: 10),
              // if (!controller.isAuthorised) _buildNonApText(context),
              PricingPlanTable(controller: controller),
              if (controller.planSelected?.planCode != null &&
                  controller.planSelected?.planCode !=
                      controller.defaultPlan?.planCode)
                _buildUpdateDefaultPlanButton(context, controller),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildNonApText(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: hexToColor("#FAF5F5"),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: ColorConstants.tertiaryBlack,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            'To Explore other Plans you need to be an authorised person',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack),
          )
        ],
      ),
    );
  }

  Widget _buildUpdateDefaultPlanButton(
      BuildContext context, DematProposalController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: ActionButton(
          showProgressIndicator: controller.defaultBrokingPlanResponse.state ==
              NetworkState.loading,
          progressIndicatorColor: ColorConstants.primaryAppColor,
          text:
              'Make ${controller.planSelected!.planName!.replaceAll("\n", " ")} as Default Plan',
          textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
          bgColor: ColorConstants.secondaryAppColor,
          onPressed: () async {
            await controller.updateDefaultBrokingPlan();
            if (controller.defaultBrokingPlanResponse.state ==
                NetworkState.loaded) {
              return showToast(text: "Default Plan Updated");
            }

            if (controller.defaultBrokingPlanResponse.state ==
                NetworkState.error) {
              return showToast(
                  text: controller.defaultBrokingPlanResponse.message);
            }
          },
        ),
      ),
    );
  }
}
