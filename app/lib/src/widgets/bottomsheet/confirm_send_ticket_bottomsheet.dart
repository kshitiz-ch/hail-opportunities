import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ConfirmSendTicketBottomSheet extends StatelessWidget {
  const ConfirmSendTicketBottomSheet({
    Key? key,
    required this.title,
    required this.onConfirm,
    required this.isLoading,
    this.viaProposal = false,
  }) : super(key: key);

  final String title;
  final void Function()? onConfirm;
  final bool isLoading;
  final bool viaProposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitleAndCloseIcon(context),
          _buildConfirmationText(context),
          _buildActionButtons(context)
        ],
      ),
    );
  }

  Widget _buildTitleAndCloseIcon(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Confirmation',
          style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        CommonUI.bottomsheetCloseIcon(context)
      ],
    );
  }

  Widget _buildConfirmationText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 40),
      child: Text(
        'Are you sure to create ${title} Proposal?',
        textAlign: TextAlign.center,
        style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorConstants.black,
              height: 24 / 14,
            ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ActionButton(
          responsiveButtonMaxWidthRatio: 0.4,
          text: 'Cancel',
          onPressed: () {
            AutoRouter.of(context).popForced();
          },
          bgColor: ColorConstants.secondaryAppColor,
          borderRadius: 51,
          margin: EdgeInsets.zero,
          textStyle:
              Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primaryAppColor,
                    fontSize: 16,
                  ),
        ),
        SizedBox(
          width: 12,
        ),
        ActionButton(
          responsiveButtonMaxWidthRatio: 0.4,
          showProgressIndicator: isLoading,
          text: viaProposal ? 'Send Proposal' : 'Send Ticket',
          onPressed: onConfirm,
          margin: EdgeInsets.zero,
        ),
      ],
    );
  }
}
