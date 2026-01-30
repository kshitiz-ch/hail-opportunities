import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrandingCreationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (isEmployeeLoggedIn()) {
      return SizedBox();
    }
    return GetBuilder<HomeController>(
      id: 'branding-status',
      builder: (controller) {
        if (controller.brandingResponse.isLoading) {
          return SkeltonLoaderCard(height: 100);
        }

        if (controller.isBrandingEnabled == false) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InkWell(
              onTap: () {
                AutoRouter.of(context).push(BrandingWebViewRoute());
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEECB),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AllImages().brandingCreationIcon,
                      height: 30,
                      width: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Text(
                        'Build your own brand today',
                        style: context.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 22),
                      child: Text(
                        'Start now',
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
        }
        return SizedBox();
      },
    );
  }
}
