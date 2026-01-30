import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/mf_portfolio/mf_portfolio_detail_controller.dart';
import 'package:app/src/screens/store/basket/widgets/delete_fund_bottom_sheet.dart';
import 'package:app/src/screens/store/mf_portfolio_form/widgets/micro_sip_basket_amount_section.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MicroSipBasketFundListTile extends StatelessWidget {
  final int index;
  final controller = Get.find<MFPortfolioDetailController>();
  final SchemeMetaModel fund;
  final bool isLastItem;
  final GlobalKey<AnimatedListState>? listKey;

  MicroSipBasketFundListTile({
    Key? key,
    required this.index,
    required this.fund,
    this.isLastItem = false,
    this.listKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFundLogo(context),
              _buildFundName(context),
              buildDeleteWidget(context),
            ],
          ),
          SizedBox(height: 20),
          MicroSipBasketAmountSection(fund: fund),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFundLogo(context) {
    return CommonUI.buildRoundedFullAMCLogo(
      radius: 18,
      amcName: fund.displayName,
    );
  }

  Widget _buildFundName(context) {
    return Expanded(
      // flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fund.displayName ?? '',
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
              style:
                  Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorConstants.black,
                      ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${fundTypeDescription(fund.fundType)} ${fund.fundCategory != null ? " | ${fund.fundCategory}" : ""}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                              color: ColorConstants.tertiaryBlack,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeleteWidget(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () async {
            if (controller.isUpdateProposal &&
                controller.microSIPBasket.length == 1) {
              return showToast(text: 'At least one fund is required');
            }

            // open delete fund bottom sheet
            CommonUI.showBottomSheet(
              context,
              child: DeleteFundBottomSheet(
                onCancel: () {
                  AutoRouter.of(context).popForced();
                },
                onDelete: () async {
                  controller.removeMicroSIPFundFromBasket(fund);

                  // pop DeleteBottomSheet
                  AutoRouter.of(context).popForced();

                  // Show Toast
                  showToast(
                    context: context,
                    text: 'Fund Removed from Basket!',
                  );
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 119, 119, 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              AllImages().deleteIcon,
              height: 12,
              width: 10,
              // fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
    );
  }
}
