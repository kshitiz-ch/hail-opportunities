import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/client/client_demat_controller.dart';
import 'package:app/src/screens/clients/client_profile/client_demat/widgets/demat_form_section.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class AddEditDematScreen extends StatelessWidget {
  final int? editIndex;
  AddEditDematScreen({
    Key? key,
    this.editIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText:
            editIndex != null ? 'Edit Demat Account' : 'Add New Demat Account',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 40),
          child: DematFormSection(),
        ),
      ),
      bottomNavigationBar: _buildAddDematButton(context),
    );
  }

  Widget _buildAddDematButton(BuildContext context) {
    return GetBuilder<ClientDematController>(
      builder: (controller) {
        return ActionButton(
          text: editIndex != null
              ? 'Edit Demat Account'
              : 'Add New Demat Account',
          onPressed: () async {
            if (controller.addEditDematFormKey!.currentState!.validate()) {
              await controller.addEditDematAccount(editIndex: editIndex);
              if (controller.addEditDemat.state == NetworkState.loaded) {
                controller.resetDematForm();
                AutoRouter.of(context).popForced();
                controller.getExternalDemats();
              }
            }
          },
          showProgressIndicator:
              controller.addEditDemat.state == NetworkState.loading,
          margin: EdgeInsets.symmetric(vertical: 24, horizontal: 30),
        );
      },
    );
  }
}
