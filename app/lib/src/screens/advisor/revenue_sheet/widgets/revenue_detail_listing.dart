import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/mixpanel/mixpanel.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/advisor/revenue_detail_controller.dart';
import 'package:app/src/screens/advisor/revenue_sheet/widgets/revenue_filter_bottomsheet.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/misc/skelton_loader_card.dart';
import 'package:collection/collection.dart';
import 'package:core/modules/advisor/models/revenue_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenueDetailListing extends StatelessWidget {
  late TextStyle titleStyle;
  late TextStyle subtitleStyle;
  final controller = Get.find<RevenueDetailController>();

  @override
  Widget build(BuildContext context) {
    titleStyle = Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w500,
          color: ColorConstants.black,
          overflow: TextOverflow.ellipsis,
        );
    subtitleStyle = Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
          overflow: TextOverflow.ellipsis,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: _buildAppliedFilter(context),
        ),
        _buildListing(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Revenue Listing',
            style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                  color: ColorConstants.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildAppliedFilter(BuildContext context) {
    final savedFilterCount = controller.savedFilterCount;
    if (savedFilterCount > 0) {
      return InkWell(
        onTap: () {
          CommonUI.showBottomSheet(
            context,
            isScrollControlled: false,
            child: RevenueFilterBottomSheet(),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
              color: ColorConstants.primaryAppColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20)),
          child: Text(
            '$savedFilterCount Filter${savedFilterCount > 1 ? 's' : ''} Applied',
            style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                  color: ColorConstants.primaryAppColor,
                ),
          ),
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildFilterButton(BuildContext context) {
    return GetBuilder<RevenueDetailController>(
      id: GetxId.filter,
      builder: (detailController) {
        if (detailController.enableFilterFab) {
          return SizedBox();
        }
        return InkWell(
          onTap: () {
            CommonUI.showBottomSheet(
              context,
              isScrollControlled: false,
              child: RevenueFilterBottomSheet(),
            );
          },
          child: Row(
            children: [
              Stack(
                children: [
                  Image.asset(
                    AllImages().fundFilterIcon,
                    height: 14,
                    width: 14,
                    color: ColorConstants.primaryAppColor,
                  ),
                  if (controller.savedFilterCount > 0)
                    CommonUI.buildRedDot(rightOffset: 0)
                ],
              ),
              SizedBox(
                width: 9,
              ),
              Text(
                'Filter',
                style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                      color: ColorConstants.primaryAppColor,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListing() {
    if (controller.clientRevenueResponse.state == NetworkState.loading &&
        !controller.isPaginating) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SkeltonLoaderCard(height: 300),
      );
    }
    if (controller.clientRevenueResponse.state == NetworkState.error &&
        !controller.isPaginating) {
      return Center(
        child: RetryWidget(
          controller.clientRevenueResponse.message,
          onPressed: () {
            controller.getClientRevenueDetail();
          },
        ),
      );
    }
    if (controller.clientRevenueResponse.state == NetworkState.loaded ||
        controller.isPaginating) {
      if (controller.clientRevenueList.isNullOrEmpty) {
        return Center(
          child: EmptyScreen(
            message: 'No revenue data available',
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        itemCount: (controller.clientRevenueList).length,
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 70),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRevenueDetailCard(
                context,
                controller.clientRevenueList[index],
              ),
              if (controller.isPaginating &&
                  (index + 1) == controller.clientRevenueList.length)
                Center(child: CircularProgressIndicator())
            ],
          );
        },
        separatorBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CommonUI.buildProfileDataSeperator(
              height: 1,
              width: double.infinity,
              color: ColorConstants.borderColor,
            ),
          );
        },
      );
    }
    return SizedBox();
  }

  Widget _buildRevenueDetailCard(
    BuildContext context,
    RevenueDetailModel model,
  ) {
    final revenueDetailUI = _buildRevenueDetails(model.mappedUIData!);
    final emptyWidget = Expanded(child: SizedBox());
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: _buildRevenueTitle(model),
        children: List<Widget>.generate(
          (revenueDetailUI.length / 3).ceil(),
          (index) {
            final startIndex = index * 3;
            return Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((startIndex) < revenueDetailUI.length)
                    revenueDetailUI[startIndex],
                  if ((startIndex + 1) < revenueDetailUI.length)
                    revenueDetailUI[startIndex + 1]
                  else
                    emptyWidget,
                  if ((startIndex + 2) < revenueDetailUI.length)
                    revenueDetailUI[startIndex + 2]
                  else
                    emptyWidget
                ],
              ),
            );
          },
        ),
        onExpansionChanged: (value) {
          if (value) {
            MixPanelAnalytics.trackWithAgentId(
              "revenue_entry_click",
              screen: 'revenue_details',
              screenLocation: 'revenue_listing',
            );
          }
        },
      ),
    );
  }

  Widget _buildRevenueTitle(RevenueDetailModel model) {
    final revenueData = model.mappedUIData!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                revenueData['Product Name'],
                style: titleStyle,
                maxLines: 2,
              ),
              SizedBox(height: 7),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order ID ',
                    style: subtitleStyle,
                  ),
                  Expanded(
                    child: MarqueeWidget(
                      child: Text(
                        '${revenueData['Order ID']}',
                        style: subtitleStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              revenueData['Revenue Amount'],
              style: titleStyle.copyWith(
                color: model.doesReleasedDateExist
                    ? ColorConstants.greenAccentColor
                    : ColorConstants.secondaryRedAccentColor,
              ),
            ),
            if (!model.doesReleasedDateExist)
              CommonUI.buildInfoToolTip(
                toolTipMessage: model.revenueDisplay?.row1?.info ?? '',
                toolTipIcon: Image.asset(
                  AllImages().lockedIcon,
                  width: 16,
                  height: 16,
                ),
              )
          ],
        ),
      ],
    );
  }

  List<Widget> _buildRevenueDetails(Map<String, dynamic> revenueData) {
    return revenueData.entries.skip(3).map(
      (dataItem) {
        final key = dataItem.key;
        String value = dataItem.value;
        if (dataItem.key == 'Product Type') {
          value = dataItem.value.toString().toTitleCase();
          final productData = revenueProductMapping.entries.firstWhereOrNull(
              (element) => element.key.toLowerCase() == value);
          if (productData != null) {
            value = productData.value;
          }
        }
        return Expanded(
          child: CommonUI.buildColumnTextInfo(
            title: key,
            subtitle: value,
            titleStyle: subtitleStyle,
            subtitleStyle: subtitleStyle.copyWith(color: ColorConstants.black),
            expandTextWidget: true,
            titleMaxLength: 2,
            subtitleMaxLength: 4,
          ),
        );
      },
    ).toList();
  }
}
