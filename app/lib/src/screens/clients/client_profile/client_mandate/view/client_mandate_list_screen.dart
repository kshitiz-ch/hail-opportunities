import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_mandate_controller.dart';
import 'package:app/src/screens/clients/client_profile/client_mandate/widgets/mandate_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/mandate_proposal_bottomsheet.dart';

@RoutePage()
class ClientMandateListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Client? client;

    if (Get.isRegistered<ClientDetailController>()) {
      client = Get.find<ClientDetailController>().client;
    }
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Mandate Details',
      ),
      body: GetBuilder<ClientMandateController>(
        init: ClientMandateController(client!),
        builder: (controller) {
          if (controller.mandates.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.mandates.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Something went wrong',
                onPressed: () {
                  controller.getClientMandates();
                },
              ),
            );
          }

          if (controller.mandates.state == NetworkState.loaded &&
              controller.mandateList.isNullOrEmpty) {
            return Center(
              child: EmptyScreen(
                message: 'Mandate not found',
                actionButtonText: 'Add Mandate',
                onClick: () {
                  CommonUI.showBottomSheet(
                    context,
                    child: MandateProposalBottomSheet(),
                  );
                },
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 100),
            itemCount: controller.mandateList.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) => SizedBox(height: 24),
            itemBuilder: (context, index) {
              return MandateCard(
                mandateModel: controller.mandateList[index],
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddBankButton(context),
    );
  }

  Widget _buildAddBankButton(context) {
    return GetBuilder<ClientMandateController>(
      builder: (controller) {
        if (controller.mandateList.isNullOrEmpty) {
          return SizedBox();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ActionButton(
            onPressed: () {
              CommonUI.showBottomSheet(
                context,
                child: MandateProposalBottomSheet(),
              );
            },
            text: 'Add Mandate',
            bgColor: ColorConstants.secondaryButtonColor,
            textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                color: ColorConstants.primaryAppColor,
                fontSize: 16.0,
                fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}
