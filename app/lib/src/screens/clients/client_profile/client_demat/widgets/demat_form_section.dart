import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/line_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DematFormSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientDematController>(
      builder: (controller) {
        return Form(
          key: controller.addEditDematFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonClientUI.borderTextFormField(
                context,
                hintText: 'DP ID',
                controller: controller.dpIdController!,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      "[0-9a-zA-Z]",
                    ),
                  ),
                  LengthLimitingTextInputFormatter(8),
                ],
                validator: (value) {
                  if (value!.length < 8) {
                    return 'DP ID should be 8 characters long';
                  }

                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: CommonClientUI.borderTextFormField(
                  context,
                  hintText: 'Client ID',
                  controller: controller.clientIdController!,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  validator: (value) {
                    if (value!.length < 8) {
                      return 'Client id should be 8 digits long';
                    }

                    return null;
                  },
                ),
              ),
              _buildUploadUI(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadUI(
      BuildContext context, ClientDematController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 25),
          padding: EdgeInsets.symmetric(vertical: 25),
          decoration: BoxDecoration(
            color: ColorConstants.primaryAppv3Color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: (controller.fileName == null)
                ? _buildPreAttachWidget(context, controller)
                : _buildPostAttachWidget(context, controller),
          ),
        ),
        Text(
          'Upload a screenshot of the client’s CMR/CML Details as shown on their investment platform for us to cross check and validate.',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w500,
              ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: LineDash(
            width: 2,
            color: ColorConstants.borderColor2,
          ),
        ),
        Text(
          '*Upload only in jpg, png and pdf formats',
          style: Theme.of(context).primaryTextTheme.titleMedium?.copyWith(
                color: ColorConstants.tertiaryBlack,
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
        )
      ],
    );
  }

  Widget _buildPreAttachWidget(
      BuildContext context, ClientDematController controller) {
    return InkWell(
      onTap: controller.openFileExplorer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AllImages().uploadIcon,
            width: 52,
            height: 39,
          ),
          SizedBox(height: 10),
          Text(
            'Attach CMR/CML Here',
            style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                  color: ColorConstants.primaryAppColor,
                ),
          )
        ],
      ),
    );
  }

  Widget _buildPostAttachWidget(
      BuildContext context, ClientDematController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AllImages().verifiedRoundedIcon,
            width: 14,
            height: 14,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                controller.fileName!,
                maxLines: 2,
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          overflow: TextOverflow.ellipsis,
                        ),
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: controller.deleteSelectedFile,
              child: Image.asset(
                AllImages().deleteRoundedIcon,
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
