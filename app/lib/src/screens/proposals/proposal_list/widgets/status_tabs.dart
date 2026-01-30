import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/proposal/proposal_controller.dart';
import 'package:app/src/screens/clients/client_detail/view/client_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tag = isPageAtTopStack(context, ClientDetailRoute.name)
        ? clientProposalControllerTag
        : null;
    return GetBuilder<ProposalsController>(
      tag: tag,
      builder: (controller) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 30).copyWith(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTab(
                tabStatus: 'ALL',
                label: 'All',
                controller: controller,
                context: context,
              ),
              _buildTab(
                tabStatus: 'open',
                label: 'Under Process',
                controller: controller,
                context: context,
              ),
              _buildTab(
                tabStatus: 'won',
                label: 'Completed',
                controller: controller,
                context: context,
              ),
              _buildTab(
                tabStatus: 'lost',
                label: 'Deleted',
                controller: controller,
                context: context,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required String tabStatus,
    required String label,
    required ProposalsController controller,
    required BuildContext context,
  }) {
    final isSelected = controller.selectedTabStatus == tabStatus;
    return InkWell(
      onTap: () {
        controller.updateTabStatus(tabStatus);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? Border.all(color: ColorConstants.primaryAppColor)
                : null,
            color: isSelected
                ? ColorConstants.primaryAppColor.withOpacity(0.05)
                : hexToColor("#F9F9F9")),
        child: Text(
          label,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? ColorConstants.black
                    : ColorConstants.tertiaryBlack,
              ),
        ),
      ),
    );
  }
}
