import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/choose_pan_bottomsheet.dart';
import 'package:app/src/screens/advisor/ticob/widgets/ticob_oppurtunity_card.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicobOpportunityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        if (!controller.isPaginating &&
            controller.ticobOpportunityResponse.state == NetworkState.loading) {
          return SkeltonLoaderCard(height: 500);
        }
        if (controller.ticobOpportunityResponse.state == NetworkState.error) {
          return Center(
            child: RetryWidget(
              controller.ticobOpportunityResponse.message,
              onPressed: () {
                controller.fetchData();
              },
            ),
          );
        }
        if (controller.ticobOpportunityResponse.state == NetworkState.loaded &&
            controller.ticobOpportunityList.isNullOrEmpty) {
          return Center(
            child: EmptyScreen(message: 'No opportunities found'),
          );
        }
        return Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final client = controller.ticobOpportunityList[index];
                  return TicobOpportunityCard(
                    client: client,
                    onGenerateCob: () {
                      CommonUI.showBottomSheet(
                        context,
                        child: ChoosePanBottomSheet(selectedClient: client),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) =>
                    CommonUI.buildProfileDataSeperator(
                        color: ColorConstants.borderColor),
                itemCount: controller.ticobOpportunityList.length,
                controller: controller.scrollController,
              ),
            ),
            if (controller.isPaginating) CommonUI.buildInfiniteLoader(),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Text(
            'Client Details',
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          SizedBox(width: 10),
          Expanded(
              child: Text(
            'Tracked Amt.',
            style: style,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
          SizedBox(width: 10),
          Expanded(
            child: CommonUI.buildInfoToolTip(
              toolTipMessage:
                  'Opportunity includes only Regular Funds, excluding Direct Funds',
              titleStyle: style,
              titleText: 'Opportunity',
              rightPadding: 10,
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    );
  }
}
