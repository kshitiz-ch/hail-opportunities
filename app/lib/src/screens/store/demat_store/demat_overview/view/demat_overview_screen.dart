import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/demat/demat_proposal_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/proposal_kyc_alert_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/card/client_card.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/demat_details_card.dart';

@RoutePage()
class DematOverviewScreen extends StatelessWidget {
  const DematOverviewScreen({Key? key, required this.selectedClients})
      : super(key: key);

  final List<Client> selectedClients;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DematProposalController>(
      id: 'proposal',
      initState: (_) {
        Get.find<DematProposalController>().selectedClients = selectedClients;
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            showBackButton: true,
            titleText: 'Select Client',
          ),
          body: Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 15, left: 10),
                  child: Text(
                    'Client Details',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.tertiaryBlack,
                        ),
                  ),
                ),
                Flexible(
                  child: _buildClientsList(context, controller),
                ),
                DematDetailsCard()
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButton(context, controller),
        );
      },
    );
  }

  Widget _buildClientsList(
      BuildContext context, DematProposalController controller) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 10),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Client client = selectedClients[index];
          return ClientCard(
            client: client,
            isSelected: false,
            effectiveIndex: index % 7,
          );
          // return _buildClientCard(context, client, index);
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 20);
        },
        itemCount: selectedClients.length,
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, DematProposalController controller) {
    return ActionButton(
      heroTag: kDefaultHeroTag,
      showProgressIndicator:
          controller.proposalApiResponse.state == NetworkState.loading,
      text: 'Send to Client',
      margin: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      onPressed: () async {
        // Check if kyc is approved
        int? agentKycStatus = await getAgentKycStatus();
        if (agentKycStatus != AgentKycStatus.APPROVED) {
          CommonUI.showBottomSheet(context,
              child: ProposalKycAlertBottomSheet());
          return null;
        }

        await controller.createProposal();

        if (controller.proposalApiResponse.state == NetworkState.error) {
          return showToast(
            context: context,
            text: controller.proposalApiResponse.message,
          );
        }

        if (controller.proposalApiResponse.state == NetworkState.loaded) {
          AutoRouter.of(context).push(DematProposalSuccessRoute());
        }
      },
    );
  }
}
