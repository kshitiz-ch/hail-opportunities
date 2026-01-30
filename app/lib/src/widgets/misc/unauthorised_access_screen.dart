import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class UnauthorisedAccessScreen extends StatelessWidget {
  final String title;

  const UnauthorisedAccessScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    final homeController =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final rmPhoneNo =
        homeController?.advisorOverviewModel?.agent?.pst?.phoneNumber ?? '';
    final rmName = homeController?.advisorOverviewModel?.agent?.pst?.name;
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(titleText: title),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'This feature is not available for your account.',
              textAlign: TextAlign.center,
              style: context.headlineMedium?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: rmPhoneNo.isNotNullOrEmpty
                ? ActionButton(
                    text: 'Contact RM',
                    onPressed: () async {
                      if (rmPhoneNo.isNotNullOrEmpty) {
                        bool isCountryCodeMissing = rmPhoneNo.length == 10;

                        final link = WhatsAppUnilink(
                          phoneNumber:
                              '${isCountryCodeMissing ? '+91' : ''}$rmPhoneNo',
                          text: "Hey, ${rmName ?? 'there'}",
                        );

                        await launch('$link');
                      }
                    },
                    margin: EdgeInsets.zero,
                  )
                : Text(
                    'Please contact RM',
                    textAlign: TextAlign.center,
                    style: context.headlineMedium?.copyWith(
                      color: ColorConstants.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
