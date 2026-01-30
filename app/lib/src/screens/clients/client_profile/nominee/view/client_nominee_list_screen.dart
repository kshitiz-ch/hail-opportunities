import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_address_controller.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/nominee_list_section.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/nominee_breakdown_card.dart';

@RoutePage()
class ClientNomineeListScreen extends StatelessWidget {
  const ClientNomineeListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Client? client;
    if (Get.isRegistered<ClientDetailController>()) {
      client = Get.find<ClientDetailController>().client;
    }

    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Nominees',
      ),
      body: GetBuilder<ClientNomineeController>(
        init: ClientNomineeController(client),
        initState: (_) {
          // initialised here to ensure that the clientAddressModelList is available
          Get.put<ClientAddressController>(ClientAddressController(client!),
              tag: 'client_nominee');
        },
        dispose: (_) {
          Get.delete<ClientAddressController>(tag: 'client_nominee');
        },
        builder: (controller) {
          if (controller.nomineeListResponse.state == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.nomineeListResponse.state == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Something went wrong',
                onPressed: () {
                  controller.getClientNominees();
                },
              ),
            );
          }

          if (controller.nomineeListResponse.state == NetworkState.loaded &&
              controller.userNominees.isEmpty) {
            return Center(
              child: EmptyScreen(
                message: 'Nominees not found',
                actionButtonText: 'Add Nominee',
                onClick: () {
                  AutoRouter.of(context).push(ClientNomineeFormRoute());
                },
              ),
            );
          }

          return Container(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.mfNominees.isNotEmpty ||
                      controller.mfNominees.isNotEmpty)
                    _buildBreakdown(context, controller),
                  NomineeListSection(nomineesList: controller.userNominees)
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildAddNomineeButton(context),
    );
  }

  Widget _buildBreakdown(context, ClientNomineeController controller) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(top: 30, bottom: 50),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nominees Breakdown',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineLarge!
                  .copyWith(fontSize: 14),
            ),
            SizedBox(height: 27),
            Container(
              constraints: BoxConstraints(maxHeight: 280),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    NomineeBreakdownCard(
                      nomineeType: NomineeType.MF,
                      nomineesList: controller.mfNominees,
                    ),
                    if (controller.mfNominees.isNotEmpty &&
                        controller.brokingNominees.isNotEmpty)
                      SizedBox(width: 20),
                    NomineeBreakdownCard(
                      nomineeType: NomineeType.TRADING,
                      nomineesList: controller.brokingNominees,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddNomineeButton(context) {
    return GetBuilder<ClientNomineeController>(
      builder: (controller) {
        if (controller.nomineeListResponse.state != NetworkState.loaded ||
            controller.userNominees.isEmpty) {
          return SizedBox();
        }

        return ActionButton(
          onPressed: () {
            AutoRouter.of(context).push(ClientNomineeFormRoute());
          },
          text: 'Add Nominee',
          bgColor: ColorConstants.secondaryButtonColor,
          textStyle: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
              color: ColorConstants.primaryAppColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w700),
        );
      },
    );
  }
}
