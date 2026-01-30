import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyProposalLinkButton extends StatelessWidget {
  final String customerUrl;

  const CopyProposalLinkButton({super.key, required this.customerUrl});

  @override
  Widget build(BuildContext context) {
    return customerUrl.isNotNullOrEmpty
        ? InkWell(
            onTap: () async {
              MixPanelAnalytics.trackWithAgentId(
                "copy_proposal_link",
                screen: 'proposal_details',
                screenLocation: 'proposal_details',
              );

              await Clipboard.setData(
                ClipboardData(text: customerUrl),
              );
              showToast(
                context: context,
                text: 'Copied!',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AllImages().proposalCopyLinkIcon,
                  height: 24,
                  width: 24,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Copy Proposal link',
                    style: context.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ColorConstants.primaryAppColor,
                    ),
                  ),
                )
              ],
            ),
          )
        : SizedBox();
  }
}
