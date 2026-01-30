import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/client/personal_form_controller.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EditWarningBottomSheet extends StatelessWidget {
  const EditWarningBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderText(context),
          _buildWarningContent(context),
          _buildProceedButton(context)
        ],
      ),
    );
  }

  Widget _buildHeaderText(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Edit Personal Details',
            style: Theme.of(context)
                .primaryTextTheme
                .displaySmall!
                .copyWith(fontSize: 18),
          ),
          Center(
            child: Icon(
              Icons.close,
              size: 20,
              color: ColorConstants.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 45),
      padding: EdgeInsets.fromLTRB(28, 20, 28, 42),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: ColorConstants.lightYellowColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AllImages().clientEditWarningIcon,
            width: 48,
          ),
          SizedBox(height: 25),
          Text(
            'Please be advised that if any modifications are needed, it may be necessary to undergo the KYC process again.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .primaryTextTheme
                .displaySmall!
                .copyWith(fontSize: 14),
          )
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: ActionButton(
        text: 'Proceed',
        margin: EdgeInsets.zero,
        onPressed: () {
          Get.find<ClientPersonalFormController>().toggleEditFlow(true);
          AutoRouter.of(context).popForced();
        },
      ),
    );
  }
}
