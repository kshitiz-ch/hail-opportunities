import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/profile_controller.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

@RoutePage()
class ChangeDisplayNameScreen extends StatefulWidget {
  const ChangeDisplayNameScreen({
    Key? key,
    this.currentDisplayName,
  }) : super(key: key);

  final String? currentDisplayName;

  @override
  State<ChangeDisplayNameScreen> createState() =>
      _ChangeDisplayNameScreenState();
}

class _ChangeDisplayNameScreenState extends State<ChangeDisplayNameScreen> {
  TextEditingController displayNameController = TextEditingController();

  void initState() {
    if (widget.currentDisplayName.isNotNullOrEmpty) {
      displayNameController.text = widget.currentDisplayName.toTitleCase();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      id: GetxId.name,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            titleText: 'Change Display/Business Name',
          ),
          body: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                CommonClientUI.borderTextFormField(
                  context,
                  controller: displayNameController,
                  hintText: 'Display Name',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(
                        "[0-9a-zA-Z ]",
                      ),
                    ),
                  ],
                ),
                _buildInfoText(),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            text: 'Update',
            showProgressIndicator: controller.changeDisplayNameResponse.state ==
                NetworkState.loading,
            onPressed: () async {
              if (displayNameController.text.isEmpty) {
                return showToast(text: 'Please enter a valid name');
              }

              await controller
                  .changePartnerDisplayName(displayNameController.text);

              if (controller.changeDisplayNameResponse.state ==
                  NetworkState.loaded) {
                showToast(text: 'Display Name updated successfully');
                AutoRouter.of(context).popForced();
              } else if (controller.changeDisplayNameResponse.state ==
                  NetworkState.error) {
                showToast(text: controller.changeDisplayNameResponse.message);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoText() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: CommonUI.buildInfoText(
        context,
        "Your display/business name will be used on all client-facing materials like proposals, business cards, and shared documents.",
      ),
    );
  }
}
