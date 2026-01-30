import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/client/client_mandate_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'enter_amount_section.dart';
import 'select_bank_section.dart';

class MandateProposalBottomSheet extends StatelessWidget {
  const MandateProposalBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientMandateController>(
      id: GetxId.proposal,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 150,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleAndCloseIcon(context, controller),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child:
                      controller.proposalFormView == ProposalFormView.SelectBank
                          ? SelectBankSection()
                          : EnterAmountSection(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleAndCloseIcon(
      BuildContext context, ClientMandateController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.proposalFormView == ProposalFormView.SelectBank
                ? 'Select Bank for Mandate'
                : 'Share Proposal',
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          CommonUI.bottomsheetCloseIcon(context)
        ],
      ),
    );
  }
}
