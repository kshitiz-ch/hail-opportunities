import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/client/client_tracker_switch_controller.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/folio_detail.dart';
import 'package:app/src/screens/clients/client_tracker/widgets/tracker_fund_switch_bottomsheet.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchFundBasketCard extends StatelessWidget {
  final int basketIndex;

  const SwitchFundBasketCard({Key? key, required this.basketIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientTrackerSwitchController>(
      builder: (controller) {
        final switchMethod = controller.switchBasket[basketIndex]
            ['switch_method'] as FundSwitchMethod;
        String text = '';
        if (switchMethod == FundSwitchMethod.Unit) {
          text = "${controller.switchBasket[basketIndex]['units']} units";
        }

        if (switchMethod == FundSwitchMethod.Amount) {
          text = WealthyAmount.currencyFormat(
              controller.switchBasket[basketIndex]['amount'], 0);
        }

        if (switchMethod == FundSwitchMethod.Full) {
          final maxUnits = WealthyCast.toDouble(controller
              .switchBasket[basketIndex]['switch_out']
              .folioOverview
              .withdrawalUnitsAvailable);
          text = '${maxUnits?.toStringAsFixed(2) ?? 'N/A'} units';
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFundTile(
                context: context,
                fund: controller.switchBasket[basketIndex]['switch_out'],
              ),
              _buildSeparator(
                text: text,
                context: context,
              ),
              _buildFundTile(
                context: context,
                fund: controller.switchBasket[basketIndex]['switch_in'],
                showFolioDetails: false,
                onDelete: () {
                  controller.deleteSwitchFundFromBasket(basketIndex);
                },
                onEdit: () {
                  controller.initialiseEditSwitchFundField(basketIndex);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundTile({
    required SchemeMetaModel fund,
    required BuildContext context,
    Function? onDelete,
    Function? onEdit,
    bool showFolioDetails = true,
  }) {
    final headerStyle = context.headlineSmall!.copyWith(
      color: ColorConstants.black,
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = context.titleLarge!.copyWith(
      color: ColorConstants.tertiaryBlack,
      fontWeight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ColorConstants.white,
            border: Border.all(color: ColorConstants.secondarySeparatorColor),
            shape: BoxShape.circle,
          ),
          child: CommonUI.buildRoundedFullAMCLogo(
            radius: 18,
            amcName: fund.displayName,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund.displayName ?? '-',
                  style: headerStyle,
                ),
                SizedBox(height: 4),
                if (showFolioDetails)
                  FolioDetail(fund: fund)
                else
                  Text(
                    '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? "| ${fund.fundCategory}" : ""}',
                    style: subtitleStyle,
                  )
              ],
            ),
          ),
        ),
        if (onDelete != null)
          _buildDeleteButton(
            context: context,
            onDelete: onDelete,
          ),
        if (onEdit != null)
          _buildEditButton(
            context: context,
            onEdit: onEdit,
          )
      ],
    );
  }

  Widget _buildDeleteButton({
    required BuildContext context,
    Function? onDelete,
  }) {
    return InkWell(
      onTap: () async {
        // open delete fund bottom sheet
        CommonUI.showBottomSheet(
          context,
          child: DeleteFundBottomSheet(
            onCancel: () {
              AutoRouter.of(context).popForced();
            },
            onDelete: () async {
              onDelete!();
              // pop DeleteBottomSheet
              AutoRouter.of(context).popForced();
              // show toast
              showCustomToast(
                context: context,
                child: Container(
                  width: SizeConfig().screenWidth,
                  // margin: const EdgeInsets.only(bottom: 136.0),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: ColorConstants.black.withOpacity(0.9),
                  ),
                  child: Text(
                    "Switch Fund Deleted from Basket",
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.white,
                            ),
                  ),
                ),
              );
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 119, 119, 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          AllImages().deleteIcon,
          height: 12,
          width: 10,
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required BuildContext context,
    Function? onEdit,
  }) {
    return InkWell(
      onTap: () {
        onEdit!();

        CommonUI.showBottomSheet(
          context,
          child: TrackerFundSwitchBottomSheet(
            isEdit: true,
            basketIndex: basketIndex,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ColorConstants.primaryAppColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          AllImages().editIcon,
          height: 10,
          width: 10,
          color: ColorConstants.primaryAppColor,
        ),
      ),
    );
  }

  Widget _buildSeparator(
      {required String text, required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CommonUI.buildProfileDataSeperator(
              height: 1,
              width: double.infinity,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ColorConstants.secondarySeparatorColor,
              ),
            ),
            child: Image.asset(
              AllImages().trackerSwitchIcon,
              height: 15,
              width: 15,
            ),
          ),
          SizedBox(width: 13),
          Text(
            text,
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Expanded(
            child: CommonUI.buildProfileDataSeperator(
              height: 1,
              width: double.infinity,
              color: ColorConstants.secondarySeparatorColor,
            ),
          ),
        ],
      ),
    );
  }
}
