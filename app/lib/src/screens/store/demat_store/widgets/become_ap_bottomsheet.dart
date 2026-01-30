import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';

import 'demat_contact_phone_bottomsheet.dart';

class BecomeApBottomSheet extends StatelessWidget {
  const BecomeApBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: CommonUI.bottomsheetCloseIcon(context),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hexToColor("#CAF7C8"),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      AllImages().apAvatar,
                      width: 30,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Become an Authorised Person',
                      style: context.headlineSmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'An Authorized Person (AP) is appointed by a stockbroker to connect with clients, assist in onboarding, and provide trade-related support.',
                  style: context.headlineSmall!
                      .copyWith(color: ColorConstants.tertiaryGrey),
                )
              ],
            ),
          ),
          // Image.network(
          //   "https://res.cloudinary.com/dti7rcsxl/image/upload/v1739950966/hyl3e8d9yvmukydhjbqp.png",
          // ),
          SizedBox(height: 20),
          Container(
            // padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to Become an Authorised Person',
                  style: context.headlineSmall!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _buildStep(
                  context,
                  stepNumber: '1',
                  title: 'Submit Your Documents',
                  description:
                      'Provide your PAN, Aadhaar, qualification proof, address details, etc.',
                ),
                const SizedBox(height: 20),
                _buildStep(
                  context,
                  stepNumber: '2',
                  title: 'Sign the Agreement',
                  description:
                      'Review and sign the agreement provided by Wealthy.',
                ),
                const SizedBox(height: 20),
                _buildStep(
                  context,
                  stepNumber: '3',
                  title: 'Registration Assistance',
                  description:
                      'Wealthy will get your registration done from NSE.',
                ),
                const SizedBox(height: 32),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Call us to learn more—our team will guide you through the process at no cost!',
                        textAlign: TextAlign.center,
                        style: context.headlineSmall!
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                ActionButton(
                  text: 'Call us to learn more',
                  margin: EdgeInsets.zero,
                  onPressed: () {
                    CommonUI.showBottomSheet(
                      context,
                      child: DematContactPhoneBottomSheet(),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step $stepNumber: $title',
          style: context.headlineSmall!.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: context.headlineSmall!.copyWith(
              fontWeight: FontWeight.w500, color: ColorConstants.tertiaryBlack),
        ),
      ],
    );
  }
}
