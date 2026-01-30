import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/screens/store/demat_store/widgets/demat_ap_banners.dart';
import 'package:app/src/screens/store/demat_store/widgets/incentive_table.dart';
import 'package:app/src/screens/store/demat_store/widgets/pricing_plan_card.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class DematStoreScreen extends StatelessWidget {
  const DematStoreScreen({Key? key, this.client}) : super(key: key);
  final Client? client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        titleText: 'Broking Demat Account',
        subtitleHeight: 10,
        subtitleText: 'Open your Clients Demat Account for free',
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: GetBuilder<DematProposalController>(
          init: DematProposalController(client: client),
          builder: (controller) {
            if (controller.dematDetailsResponse.state == NetworkState.loading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.dematDetailsResponse.state == NetworkState.error) {
              return Center(
                child: RetryWidget(
                  'Something went wrong. Please try again',
                  onPressed: () {
                    controller.getStoreDematDetails();
                  },
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  PricingPlanCard(),
                  DematApBanners(),
                  IncentiveTable(),
                  _buildProceedButton(context, controller),
                  // FeatureBanners(controller: controller),
                  SafeArea(
                    child: Image.asset(AllImages().dematBottomBackground),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProceedButton(
      BuildContext context, DematProposalController controller) {
    return ActionButton(
      margin: EdgeInsets.only(left: 40, right: 40, top: 34, bottom: 52),
      text: 'Proceed',
      isDisabled: controller.planSelected == null,
      onPressed: () {
        if (client != null) {
          AutoRouter.of(context).push(
            DematOverviewRoute(selectedClients: [client!]),
          );
        } else {
          AutoRouter.of(context).push(DematSelectClientRoute());
        }
      },
    );
  }
}
