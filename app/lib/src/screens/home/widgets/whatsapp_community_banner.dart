import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsappCommunityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        id: 'whatsapp-community',
        builder: (controller) {
          if (controller.whatsappLinkResponse.isLoading) {
            return SkeltonLoaderCard(height: 100);
          }
          // if (controller.whatsappLinkResponse.isError) {
          //   return Center(
          //     child: RetryWidget(
          //       controller.whatsappLinkResponse.message,
          //       onPressed: () {
          //         controller.getWhatsappCommunityLink();
          //       },
          //     ),
          //   );
          // }
          if (controller.whatsappCommunityLink.isNullOrEmpty) return SizedBox();

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              onTap: () {
                MixPanelAnalytics.trackWithAgentId(
                  'Whatsapp_Community',
                  properties: {"screen_location": "Home", "screen": "Home"},
                );
                launch(controller.whatsappCommunityLink);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECF7ED),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AllImages().whatsappIconNew,
                      height: 30,
                      width: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Text(
                        'Join Whatsapp Community',
                        style: context.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                      ),
                    ),
                    CommonUI.buildNewTag(context),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 22),
                      child: Text(
                        'Join Now',
                        style: context.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.primaryAppColor),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
