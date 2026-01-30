import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_detail_controller.dart';
import 'package:app/src/controllers/client/nominee_controller.dart';
import 'package:app/src/controllers/client/nominee_form_controller.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/nominee_address_detail.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/nominee_guardian_detail.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/nominee_id_detail.dart';
import 'package:app/src/screens/clients/client_profile/nominee/widgets/nominee_personal_details.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/client_nominee_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class ClientNomineeFormScreen extends StatelessWidget {
  const ClientNomineeFormScreen({Key? key, this.nominee}) : super(key: key);

  final ClientNomineeModel? nominee;

  @override
  Widget build(BuildContext context) {
    Client? client;

    if (Get.isRegistered<ClientDetailController>()) {
      client = Get.find<ClientDetailController>().client;
    }

    return GetBuilder<ClientNomineeFormController>(
      init: ClientNomineeFormController(nominee, client),
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(
            titleText: '${controller.isEditFlow ? 'Update' : 'Add'} Nominee',
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 90),
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    NomineePersonalDetails(),
                    NomineeIdDetail(),
                    NomineeGuardianDetail(),
                    NomineeAddressDetail(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: _buildSoaNote(controller, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButton(context, controller),
        );
      },
    );
  }

  Widget _buildSoaNote(
    ClientNomineeFormController controller,
    BuildContext context,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 10),
      child: Row(
        children: [
          Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: controller.includeNomineeInSoa,
            onChanged: (value) {
              controller.includeNomineeInSoa = value ?? false;
              controller.update();
            },
          ),
          Expanded(
            child: Text(
              'Include nominee details in all my statements of account (SOA)',
              style: context.headlineSmall?.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, ClientNomineeFormController controller) {
    return ActionButton(
      showProgressIndicator:
          controller.nomineeFormResponse.state == NetworkState.loading,
      text: '${controller.isEditFlow ? 'Update' : 'Add'}',
      onPressed: () async {
        // First validate the form fields
        if (controller.formKey.currentState!.validate()) {
          await controller.addNomineeDetails();

          if (controller.nomineeFormResponse.state == NetworkState.loaded) {
            showToast(
              text:
                  'Nominee Account ${controller.isEditFlow ? 'Updated' : 'Added'}',
            );

            // Show Above Toast for 1 sec
            await Future.delayed(Duration(seconds: 1));

            AutoRouter.of(context).popUntilRouteWithName(
              ClientNomineeListRoute.name,
            );

            // Refetch Nominees List
            if (Get.isRegistered<ClientNomineeController>()) {
              Get.find<ClientNomineeController>().getClientNominees();
            }

            // Refetch Investment Status
            if (Get.isRegistered<ClientDetailController>()) {
              Get.find<ClientDetailController>().getClientInvestmentStatus();
            }
          } else {
            showToast(text: controller.nomineeFormResponse.message);
          }
        } else {
          // Show validation error toast if form validation fails
          showToast(text: 'Please correct the errors in the form');
        }
      },
    );
  }
}
