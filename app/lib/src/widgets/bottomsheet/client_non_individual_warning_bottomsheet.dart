import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/widgets/bottomsheet/contact_rm_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientNonIndividualWarningBottomSheet extends StatelessWidget {
  const ClientNonIndividualWarningBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPstExists =
        Get.find<HomeController>().advisorOverviewModel?.agent?.pst?.id != null;
    return Container(
      margin: EdgeInsets.all(30).copyWith(top: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: CommonUI.bottomsheetCloseIcon(context),
          ),
          Image.asset(
            AllImages().restrictedIcon,
            width: 60,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'The requested operation is not permissible for clients with account types classified as Joint, Minor, Corporate, and HUF. We kindly advise that you contact your designated relationship manager to obtain further information regarding this matter',
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                  color: ColorConstants.black,
                  height: 24 / 14,
                ),
          ),
          if (isPstExists)
            ActionButton(
              margin: EdgeInsets.symmetric(horizontal: 30).copyWith(top: 30),
              onPressed: () async {
                CommonUI.showBottomSheet(context,
                    child: ContactRmBottomSheetScreen(
                        advisorModel:
                            Get.find<HomeController>().advisorOverviewModel));
              },
              text: 'Contact RM',
            ),
        ],
      ),
    );
  }
}
