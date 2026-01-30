import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/advisor/ticob/widgets/choose_pan_bottomsheet.dart';
import 'package:app/src/screens/advisor/ticob/widgets/cob_steps.dart';
import 'package:app/src/screens/advisor/ticob/widgets/manual_folio_entry_bottomsheet.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class GenerateCobOptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicobController>(
      builder: (controller) {
        final cobOptions = controller.cobOptions.entries.toList();
        return Scaffold(
          backgroundColor: ColorConstants.white,
          appBar: CustomAppBar(titleText: 'Choose Option'),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(
                  cobOptions.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildOptions(
                      context,
                      cobOptions[index],
                      controller,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CobSteps(),
                ),
                _buildInfo(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _buildNotes(context),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ActionButton(
            text: 'Proceed',
            isDisabled: controller.selectedCobOption == null,
            margin: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            onPressed: () {
              final isTrackerFlow =
                  controller.selectedCobOption == CobType.Tracker;
              AutoRouter.of(context).push(
                SelectClientRoute(
                  showTrackerSyncClients: isTrackerFlow,
                  showClientFamilyList: true,
                  showSearchContactSwitch: false,
                  showAddNewClient: false,
                  skipSelectClientConfirmation: true,
                  enablePartnerOfficeSupport: true,
                  onClientSelected: (Client? client, _) {
                    if (isTrackerFlow) {
                      CommonUI.showBottomSheet(
                        context,
                        child: ChoosePanBottomSheet(selectedClient: client!),
                      );
                    } else {
                      CommonUI.showBottomSheet(
                        context,
                        child: ManualFolioEntryBottomSheet(
                            selectedClient: client!),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOptions(
    BuildContext context,
    MapEntry<CobType, String> option,
    TicobController controller,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioButtonTile(context, option.key, controller),
        SizedBox(height: 10),
        Text(
          option.value,
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        )
      ],
    );
  }

  Widget _buildRadioButtonTile(
    BuildContext context,
    CobType value,
    TicobController controller,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: ColorConstants.lightGrey,
      ),
      child: InkWell(
        onTap: () {
          controller.updateSelectedCobOption(value);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: Radio(
                activeColor: ColorConstants.primaryAppColor,
                value: value,
                groupValue: controller.selectedCobOption,
                onChanged: (CobType? value) {
                  if (value != null) {
                    controller.updateSelectedCobOption(value);
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                value.name,
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final color = Color(0xffFFBE82);
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: color),
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            AllImages().ticobInfoIcon1,
            height: 16,
            width: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Generally, Nav Allocation of change of broker transaction take 7-10 working days',
              maxLines: 2,
              style: Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context) {
    final notes = [
      'Digital/e-signature of clients are invalid ',
      'For joint account, Signature of all holders are required',
      'For minor account, Signature of Guardian is required',
      'Change of Broker of Demat folio is not available ',
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.secondarySeparatorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes :',
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.black,
                ),
          ),
          SizedBox(height: 10),
          ...List.generate(
            notes.length,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                '${index + 1}. ${notes[index]}',
                style: Theme.of(context)
                    .primaryTextTheme
                    .titleLarge
                    ?.copyWith(color: ColorConstants.tertiaryBlack),
              ),
            ),
          )
        ],
      ),
    );
  }
}
