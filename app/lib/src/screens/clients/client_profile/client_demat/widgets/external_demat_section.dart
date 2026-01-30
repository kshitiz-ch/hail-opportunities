import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExternalDematSection extends StatelessWidget {
  final controller = Get.find<ClientDematController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'External Demat',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        SizedBox(height: 24),
      ]
        // External Demat Card List
        ..addAll(
          List<Widget>.generate(
            controller.externalDematList.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildExternalDematCard(context, index),
              );
            },
          ),
        )
        ..add(
          _buildAddDematButton(context),
        ),
    );
  }

  Widget _buildExternalDematCard(BuildContext context, int index) {
    final isVerified = controller.externalDematList[index].isVerified == true;
    final titleStyle = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          color: ColorConstants.tertiaryBlack,
        );
    final subtitleStyle =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w400,
            );
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonUI.buildColumnTextInfo(
                  title: 'Depositary Participant',
                  subtitle: controller.externalDematList[index].stockBroker ??
                      notAvailableText,
                  subtitleStyle: subtitleStyle,
                  titleStyle: titleStyle,
                ),
                isVerified
                    ? _buildVerifiedUI(context)
                    : _buildEditUI(context, index),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 20),
            child: CommonUI.buildColumnTextInfo(
              title: 'External Demat ID',
              subtitle: controller.externalDematList[index].dematId ??
                  notAvailableText,
              subtitleStyle: subtitleStyle,
              titleStyle: titleStyle,
            ),
          ),
          // CommonUI.buildProfileDataSeperator(
          //   width: double.infinity,
          //   height: 1,
          //   color: ColorConstants.black.withOpacity(0.1),
          // ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(vertical: 10),
          //         child: Center(
          //           child: ClickableText(
          //             text: 'View Uploaded Documents',
          //             fontWeight: FontWeight.w400,
          //             fontSize: 14,
          //             onClick: () {
          //               String? docUrl =
          //                   controller.externalDematList[index].docUrl;
          //               if (docUrl.isNotNullOrEmpty) {
          //                 launch(docUrl!);
          //               } else {
          //                 showToast(text: 'Document not available');
          //               }
          //             },
          //           ),
          //         ),
          //       ),
          //     ),
          //     // TODO: uncomment when reqd
          //     // CommonUI.buildProfileDataSeperator(
          //     //   height: 75,
          //     //   width: 1,
          //     //   color: ColorConstants.black.withOpacity(0.1),
          //     // ),
          //     // Expanded(
          //     //   child: Center(
          //     //     child: ClickableText(
          //     //       text: 'Add New\nDocument',
          //     //       fontWeight: FontWeight.w500,
          //     //       fontSize: 14,
          //     //       onClick: () {},
          //     //     ),
          //     //   ),
          //     // ),
          //   ],
          // )
        ],
      ),
    );
  }

  Widget _buildVerifiedUI(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.greenAccentColor,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(2),
          child: Icon(
            Icons.done,
            color: ColorConstants.white,
            size: 12,
          ),
        ),
        SizedBox(width: 4),
        Text(
          'Verified',
          style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                color: ColorConstants.greenAccentColor,
              ),
        ),
      ],
    );
  }

  Widget _buildEditUI(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        controller.initDematInputForm(editIndex: index);
        AutoRouter.of(context).push(
          AddEditDematRoute(
            editIndex: index,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          AllImages().fdEditIcon,
          width: 10,
          height: 10,
        ),
      ),
    );
  }

  Widget _buildAddDematButton(BuildContext context) {
    return ActionButton(
      textStyle: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: ColorConstants.primaryAppColor,
          ),
      text: '+ Add New Demat Account',
      bgColor: ColorConstants.primaryAppv3Color,
      margin: EdgeInsets.symmetric(horizontal: 30),
      onPressed: () {
        controller.initDematInputForm();
        AutoRouter.of(context).push(
          AddEditDematRoute(),
        );
      },
    );
  }
}
