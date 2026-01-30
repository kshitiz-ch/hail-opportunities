import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/controllers/proposal/proposal_detail_controller.dart';
import 'package:app/src/screens/commons/order_summary/widgets/assigned_fund_list_tile.dart';
import 'package:app/src/utils/shimmer_wrapper.dart';
import 'package:app/src/widgets/divider/smart_switch_divider.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/dynamic_list_builder.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class FundsListSection extends StatefulWidget {
  const FundsListSection({Key? key, this.isSmartSwitch}) : super(key: key);

  final bool? isSmartSwitch;

  @override
  State<FundsListSection> createState() => _FundsListSectionState();
}

class _FundsListSectionState extends State<FundsListSection> {
  ScrollController? _scrollController;

  @override
  initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProposalDetailController>(
      id: 'funds',
      builder: (controller) {
        List<SchemeMetaModel>? funds = controller.fundsResult.schemeMetas;
        int itemCount = funds?.length ?? 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30)
                  .copyWith(top: 32, bottom: 24),
              child: Text(
                'Funds in this Portfolio ($itemCount)',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.tertiaryBlack,
                        ),
              ),
            ),
            controller.fundsState == NetworkState.loading
                ? Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorConstants.lightGrey,
                    ),
                  ).toShimmer(
                    baseColor: ColorConstants.lightBackgroundColor,
                    highlightColor: ColorConstants.white,
                  )
                : controller.fundsState == NetworkState.error
                    ? SizedBox(
                        height: 145,
                        child: RetryWidget(
                          controller.fundsErrorMessage,
                          onPressed: () => controller.getPortfolioFunds(),
                        ),
                      )
                    : DynamicListBuilder(
                        padding:
                            EdgeInsets.only(left: 30, right: 26, bottom: 30),
                        totalCount: itemCount,
                        initialListCount: widget.isSmartSwitch! ? 4 : 3,
                        scrollController: _scrollController,
                        // shrinkWrap: false,
                        itemBuilder: (index, animation) {
                          return _buildFundTile(
                              context: context,
                              fund: funds![index],
                              index: index,
                              isSmartSwitch: widget.isSmartSwitch!);
                        },
                      ),
            if (itemCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CommonUI.buildProposalFundsOverview(
                  context: context,
                  fundCount: itemCount,
                  fundAmount: funds?.fold<double>(
                          0,
                          (double previousValue, SchemeMetaModel element) =>
                              ((element.amountEntered ?? 0) + previousValue)) ??
                      0,
                ),
              ),
            if (controller.fundsState == NetworkState.loaded &&
                funds!.length == 0)
              Center(
                child: Text(
                  'No funds available',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                        color: ColorConstants.black,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFundTile({
    BuildContext? context,
    required SchemeMetaModel fund,
    required bool isSmartSwitch,
    int? index,
  }) {
    return Column(
      children: [
        AssignedFundListTile(
          index: index,
          isEditProposal: true,
          isTopUpPortfolio: false,
          fund: fund,
          allotmentAmount: fund.amountEntered,
        ),
        if (isSmartSwitch && index! % 2 == 0)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: SmartSwitchDivider(
              indent: 0,
              endIndent: 0,
            ),
          )
        else
          SizedBox(
            height: 10,
          )
      ],
    );
  }
}
