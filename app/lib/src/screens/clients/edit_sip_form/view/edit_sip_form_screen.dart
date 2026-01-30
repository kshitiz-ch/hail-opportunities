import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/custom_fund_detail.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/edit_sip_form_field.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/selected_sip_days.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/sip_status.dart';
import 'package:app/src/screens/clients/edit_sip_form/widgets/sip_stepper_edit.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/bottomsheet/client_non_individual_warning_bottomsheet.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/clients/models/sip_user_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

@RoutePage()
class EditSipFormScreen extends StatelessWidget {
  final SipUserDataModel selectedSip;
  final Client client;

  EditSipFormScreen({required this.selectedSip, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: CustomAppBar(
        titleText: 'Edit SIP',
        subtitleText: 'Easily customize your SIP',
      ),
      body: GetBuilder<ClientEditSipController>(
        init: ClientEditSipController(this.selectedSip, this.client),
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(30).copyWith(top: 20),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWealthyPortfolioText(controller, context),
                  SelectedSipDays(),
                  EditSIPFormField(),
                  SizedBox(height: 30),
                  SIPStatus(),
                  if (!selectedSip.isTaxSaver) SipStepperEdit(),
                  if (controller.fundSelection == FundSelection.manual)
                    CustomFundDetail(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FixedCenterDockedFabLocation(),
      floatingActionButton: _buildActionButton(context),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GetBuilder<ClientEditSipController>(
      builder: (ClientEditSipController controller) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            return ActionButton(
              heroTag: kDefaultHeroTag,
              text: 'Proceed',
              isDisabled: controller.fundSelection == FundSelection.manual
                  ? controller.addedCustomFunds.isEmpty
                  : false,
              showProgressIndicator:
                  controller.updateSipResponse.state == NetworkState.loading,
              margin: EdgeInsets.symmetric(
                vertical: isKeyboardVisible ? 0 : 24.0,
                horizontal: isKeyboardVisible ? 0 : 30.0,
              ),
              borderRadius: isKeyboardVisible ? 0.0 : 51.0,
              onPressed: () async {
                if (!controller.client.isProposalEnabled) {
                  CommonUI.showBottomSheet(
                    context,
                    child: ClientNonIndividualWarningBottomSheet(),
                  );
                } else {
                  AutoRouter.of(context).push(EditSipSummaryRoute());
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWealthyPortfolioText(
      ClientEditSipController controller, BuildContext context) {
    // if wealthy portfolio is changed to custom funds
    // then we have to proceed by manually selecting funds
    final isCustomFund = controller.isCustomFund;
    final wasWealthyFund = controller.selectedSip.sipMetaFunds?.length == 0;
    if (isCustomFund && wasWealthyFund) {
      final style = Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
            color: ColorConstants.black,
            fontWeight: FontWeight.w400,
            height: 1.4,
          );
      return Container(
        decoration: BoxDecoration(
          color: ColorConstants.secondaryAppColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 30),
        child: Text.rich(
          TextSpan(
            text: 'This portfolio was formerly categorized under the ',
            style: style,
            children: [
              TextSpan(
                text: 'Wealthy Portfolio ',
                style: style?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    'classification, wherein the SIP (Systematic Investment Plan) amount for each scheme was determined automatically by the system. Presently, this portfolio has been reclassified as Custom.',
                style: style,
              ),
              TextSpan(
                text:
                    'Consequently, to modify the SIP, users are required to specify the SIP amount for each scheme individually.',
                style: style?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Proceed below to manual flow.',
                style: style,
              )
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }
}
