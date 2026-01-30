import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/ticob_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChoosePanBottomSheet extends StatelessWidget {
  final Client selectedClient;

  const ChoosePanBottomSheet({Key? key, required this.selectedClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Choose PAN to Generate COB ',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineMedium
                    ?.copyWith(color: ColorConstants.black),
              ),
              CommonUI.bottomsheetCloseIcon(context),
            ],
          ),
          SizedBox(height: 20),
          GetBuilder<TicobController>(
            initState: (_) {
              final controller = Get.find<TicobController>();
              controller.selectedClient = selectedClient;
              controller.selectedPan = null;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.getSyncedPanInfo();
              });
            },
            builder: (controller) {
              if (controller.syncedPanResponse.state == NetworkState.loading) {
                return SkeltonLoaderCard(height: 200);
              }
              if (controller.syncedPanResponse.state == NetworkState.error) {
                return SizedBox(
                  height: 200,
                  child: RetryWidget(
                    controller.syncedPanResponse.message,
                    onPressed: () {
                      controller.getSyncedPanInfo();
                    },
                  ),
                );
              }
              if (controller.syncedPanResponse.state == NetworkState.loaded) {
                if (controller.syncedPanInfo.isNullOrEmpty) {
                  return SizedBox(
                    height: 200,
                    child: EmptyScreen(message: 'No Synced PAN found'),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.syncedPanInfo.length,
                        itemBuilder: (context, index) {
                          return _buildClientDetails(
                            context,
                            controller,
                            index,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 12);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: _buildNote(context),
                    ),
                    ActionButton(
                      isDisabled: controller.selectedPan == null,
                      text: 'Generate COB',
                      onPressed: () {
                        AutoRouter.of(context).push(TicobFolioRoute());
                      },
                      margin: EdgeInsets.symmetric(horizontal: 24),
                    )
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientDetails(
      BuildContext context, TicobController controller, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.secondarySeparatorColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: _buildRadioButtonTile(context, controller, index),
          ),
          CommonUI.buildProfileDataSeperator(
              color: ColorConstants.secondarySeparatorColor),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: _buildTrackerDetails(context, controller, index),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButtonTile(
      BuildContext context, TicobController controller, int index) {
    final data = controller.syncedPanInfo[index];
    return Theme(
      data: Theme.of(context).copyWith(
        unselectedWidgetColor: ColorConstants.lightGrey,
      ),
      child: InkWell(
        onTap: () {
          if (controller.selectedPan?.pan != data.pan) {
            controller.selectedPan = data;
            controller.update();
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: Radio(
                activeColor: ColorConstants.primaryAppColor,
                value: data.pan ?? '',
                groupValue: controller.selectedPan?.pan,
                onChanged: (String? value) {
                  if (controller.selectedPan?.pan != data.pan) {
                    controller.selectedPan = data;
                    controller.update();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                data.name ?? '-',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                          color: ColorConstants.black,
                        ),
              ),
            ),
            Text(
              data.pan ?? '-',
              style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerDetails(
      BuildContext context, TicobController controller, int index) {
    final data = controller.syncedPanInfo[index];

    final titleStyle = Theme.of(context)
        .primaryTextTheme
        .titleLarge
        ?.copyWith(color: ColorConstants.tertiaryBlack);
    final subtitleStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall
        ?.copyWith(color: ColorConstants.black);

    return Row(
      children: [
        Expanded(
          child: CommonUI.buildColumnTextInfo(
            title: 'Tracked Amount',
            subtitle: WealthyAmount.currencyFormat(data.mfCurrentValue, 0),
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: CommonUI.buildColumnTextInfo(
            title: 'Oppurtunity',
            titleSuffixIcon: CommonUI.buildInfoToolTip(
              toolTipMessage:
                  'Opportunity includes only Regular Funds, excluding Direct Funds',
              titleText: '',
              rightPadding: 10,
            ),
            subtitle: WealthyAmount.currencyFormat(data.mfOpportunity, 0),
            titleStyle: titleStyle,
            subtitleStyle: subtitleStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildNote(BuildContext context) {
    final style = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          color: ColorConstants.tertiaryBlack,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
        );

    return Container(
      width: SizeConfig().screenWidth,
      decoration: BoxDecoration(
        color: ColorConstants.lightScaffoldBackgroundColor,
        border: Border.all(
          color: ColorConstants.tertiaryBlack,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 14),
      child: Text(
        "** Note : Ensure the client with the selected PAN is already added to Wealthy. If not, add the client first to avoid creating a new, unassigned client after the transaction.",
        style: style,
      ),
    );
  }
}
