import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../config/constants/color_constants.dart';
import '../../../config/constants/image_constants.dart';

class WealthcaseInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryAppColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, title and learn more button
          Row(
            children: [
              // WealthCase icon
              Image.asset(
                AllImages().wealthCaseIcon,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 7),

              // Title
              Expanded(
                child: Text(
                  'What is Wealthcase?',
                  style: context.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.black,
                  ),
                ),
              ),
              const SizedBox(width: 7),

              // Learn more button
              ClickableText(
                text: 'Learn more',
                onClick: () {
                  AutoRouter.of(context).push(AboutWealthcasesRoute());
                },
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Description text
          Text(
            "It's like an investment playlist, pre-curated stock basket built by experts.",
            style: context.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}
