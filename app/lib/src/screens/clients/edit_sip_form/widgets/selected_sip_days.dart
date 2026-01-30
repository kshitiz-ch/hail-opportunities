import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/client/client_edit_sip_controller.dart';
import 'package:app/src/screens/store/common_new/widgets/choose_investment_dates.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedSipDays extends StatelessWidget {
  final controller = Get.find<ClientEditSipController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSIPDateHeader(context),
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: _buildSIPDateSelector(context),
        ),
      ],
    );
  }

  Widget _buildSIPDateSelector(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: controller.updatedSipData.selectedSipDays
          .map(
            (date) => _buildSelectedDateUI(date, context),
          )
          .toList(),
    );
  }

  Widget _buildSelectedDateUI(int date, BuildContext context) {
    return Container(
      width: ((SizeConfig().screenWidth! - 72) / 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.primaryAppv3Color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        date.numberPattern,
        textAlign: TextAlign.center,
        style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
              color: ColorConstants.primaryAppColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSIPDateHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Selected SIP Date(s)',
          style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                color: ColorConstants.tertiaryBlack,
              ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: CommonUI.buildProfileDataSeperator(
            height: 12,
            width: 1,
            color: ColorConstants.secondarySeparatorColor,
          ),
        ),
        if (!controller.isAnyFund) ...[
          Text(
            controller.fundSelection!.name.toTitleCase(),
            style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                  color: ColorConstants.tertiaryBlack,
                ),
          ),
          SizedBox(width: 4),
          InkWell(
            onTap: () {
              CommonUI.showBottomSheet(
                context,
                child: _buildFundSelectionBottomSheet(
                  controller.fundSelection!,
                  context,
                ),
              );
            },
            child: Icon(
              Icons.info_outline_rounded,
              color: ColorConstants.primaryAppColor,
            ),
          ),
        ],
        Expanded(
          child: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                CommonUI.showBottomSheet(
                  context,
                  child: ChooseInvestmentDate(
                    disableMultipleSelect: !controller.isSipV2Enabled,
                    allowedSipDays: controller.allowedSipDays.toList(),
                    selectedSipDays: controller.updatedSipData.selectedSipDays,
                    onUpdateSipDays: (selectedDays) {
                      controller.updateSelectedSIPDay(selectedDays);
                    },
                  ),
                );
              },
              child: Text(
                'Edit',
                style:
                    Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
                          color: ColorConstants.primaryAppColor,
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFundSelectionBottomSheet(
      FundSelection fundSelection, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 32, 30, 48),
      child: Text(
        fundSelection == FundSelection.manual
            ? 'Select the funds and amount that you want to modify your SIP with.'
            : 'All the funds in this SIP will be allocated automatically on the basis of the performance of the individual funds.',
        style: Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              color: ColorConstants.black,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
