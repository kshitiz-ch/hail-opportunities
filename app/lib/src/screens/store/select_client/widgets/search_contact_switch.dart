import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/common/select_client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchContactSwitch extends StatelessWidget {
  final bool? enableSearchContact;

  SearchContactSwitch({Key? key, this.enableSearchContact}) : super(key: key);

  final SelectClientController controller = Get.find<SelectClientController>();

  void onSwitchClick(bool value, BuildContext context) async {
    if (enableSearchContact!) {
      controller.toggleSearchContactSwitch(false);
    } else {
      try {
        List<Permission> permissionList = [
          Permission.contacts,
        ];

        Map<Permission, PermissionStatus> permissionStatuses =
            await permissionList.request();

        if (permissionStatuses[Permission.contacts]!.isGranted) {
          controller.toggleSearchContactSwitch(true);
        } else if (permissionStatuses[Permission.contacts]!
                .isPermanentlyDenied ||
            permissionStatuses[Permission.contacts]!.isDenied) {
          showToast(
            context: context,
            text: 'Please give permission to access contacts',
          );
        }
      } catch (error) {
        showToast(
          context: context,
          text: 'Please give permission to access contacts',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: enableSearchContact!,
          activeColor: ColorConstants.primaryAppColor,
          onChanged: (showContacts) async {
            onSwitchClick(showContacts, context);
          },
        ),
        Text(
          'Search Contacts',
          textAlign: TextAlign.left,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ColorConstants.black,
              ),
        )
      ],
    );
  }
}
