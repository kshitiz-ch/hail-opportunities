import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/client_family_controller.dart';
import 'package:app/src/screens/clients/client_detail/widgets/add_family_bottomsheet.dart';
import 'package:app/src/screens/clients/client_detail/widgets/verify_account_bottomsheet.dart';
import 'package:app/src/screens/clients/client_profile/client_family/widgets/family_list.dart';
import 'package:app/src/screens/clients/client_profile/client_family/widgets/part_of_family.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientFamilyDetailScreen extends StatelessWidget {
  final Client? client;

  const ClientFamilyDetailScreen({Key? key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Family Details',
      ),
      body: GetBuilder<ClientFamilyController>(
        init: ClientFamilyController(client),
        builder: (controller) {
          if (controller.fetchFamilyState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (controller.fetchFamilyState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                controller.fetchFamilyErrorMessage,
                onPressed: () {
                  controller.fetchClientFamily();
                },
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Flexible(
                  flex: 3,
                  child: FamilyList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: CommonUI.buildProfileDataSeperator(
                    width: double.infinity,
                    height: 1,
                    color: ColorConstants.black.withOpacity(0.1),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: PartOfFamily(),
                ),
                SizedBox(height: 50)
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAddMoreFamily(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAddMoreFamily(BuildContext context) {
    return GetBuilder<ClientFamilyController>(
      builder: (controller) {
        if (controller.fetchFamilyState != NetworkState.loaded ||
            controller.familyMembersList.isNullOrEmpty) {
          return SizedBox();
        }

        return ActionButton(
          text: '+ Add More Family Member ',
          onPressed: () {
            final clientDetailController = Get.find<ClientDetailController>();
            CommonUI.showBottomSheet(
              context,
              child: clientDetailController.isValidForfamilyAddition
                  ? AddFamilyBottomSheet()
                  : VerifyAccountBottomSheet(),
            );
          },
          margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        );
      },
    );
  }
}
