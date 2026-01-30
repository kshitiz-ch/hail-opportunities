import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/sif_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/sif_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class SifDetailScreen extends StatelessWidget {
  SifDetailScreen({Key? key, this.sif, @pathParam this.isin})
      : super(key: key) {
    final controller = Get.isRegistered<SifController>()
        ? Get.find<SifController>()
        : Get.put(SifController());
    if (isin.isNotNullOrEmpty) {
      controller.getSifDetails(isin!);
    } else if (sif != null) {
      controller.selectedSif = sif;
    }

    final basketController = Get.find<BasketController>();
    // for sif default to one time investment
    basketController.updateInvestmentType(InvestmentType.oneTime);
  }

  final SifModel? sif;
  final String? isin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(showBackButton: true),
      body: GetBuilder<SifController>(
        builder: (controller) {
          if (controller.sifDetailResponse.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.sifDetailResponse.isError) {
            return Center(
              child: RetryWidget(
                'Failed to load details. Please try again',
                onPressed: () {
                  controller.getSifDetails(isin!);
                },
              ),
            );
          }

          if (controller.sifDetailResponse.isLoaded &&
              controller.selectedSif == null) {
            return Center(
              child: EmptyScreen(message: 'SIF not found'),
            );
          }

          return Column(
            children: [
              _buildSifSchemeName(context, controller.selectedSif!),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Column(
                    children: [
                      _buildSifOverview(context, controller.selectedSif!),
                      Divider(color: ColorConstants.lightGrey),
                      _buildSifObjective(context, controller.selectedSif!),
                      _buildMoreDetailsButton(context),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
      bottomNavigationBar: _buildFloatingActionButton(context),
    );
  }

  Widget _buildSifSchemeName(BuildContext context, SifModel sif) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8),
            height: 36,
            width: 36,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                imageUrl: getAmcLogo(sif.schemeName),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sif.schemeName ?? '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                          // fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black),
                ),
                if (sif.strategyType.isNotNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      sif.strategyType ?? '-',
                      style: context.headlineSmall!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.tertiaryBlack),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSifOverview(BuildContext context, SifModel sif) {
    String navDisplay = '';
    if ((sif.nav ?? 0) == 0) {
      navDisplay = "0";
    } else {
      navDisplay = (sif.nav ?? 0).toStringAsFixed(4);
    }

    String launchNavDisplay = '';
    if ((sif.navAtLaunch ?? 0) == 0) {
      launchNavDisplay = "0";
    } else {
      launchNavDisplay = (sif.navAtLaunch ?? 0).toStringAsFixed(2);
    }

    final gridItems = [
      // GridData(
      //   title: "Strategy Name",
      //   subtitle: sif.strategyName ?? '-',
      // ),
      // GridData(
      //   title: "Category of Investment Strategy",
      //   subtitle: sif.categoryOfInvestmentStrategy ?? '-',
      // ),
      GridData(
        title: "Benchmark",
        subtitle: sif.benchmark ?? '-',
      ),
      GridData(
        title: "Exit Load",
        subtitle: sif.exitLoad ?? '-',
      ),
      GridData(
        title: "Risk Band",
        subtitle: sif.riskBand ?? '-',
      ),
      GridData(
        title: "Benchmark Risk Band",
        subtitle: sif.benchmarkRiskBand ?? '-',
      ),
      GridData(
        title: "Open Date",
        subtitle: getFormattedDate(sif.launchDate),
      ),
      GridData(
        title: "Close Date",
        subtitle: getFormattedDate(sif.closeDate),
      ),
      GridData(
        title: "Minimum Investment Amount",
        subtitle: WealthyAmount.currencyFormat(sif.minDepositAmt, 2),
      ),
      GridData(
        title: "Minimum SIP Amount",
        subtitle: WealthyAmount.currencyFormat(sif.minSipDepositAmt, 2),
      ),
      GridData(
        title: "Allotment Date",
        subtitle: getFormattedDate(sif.allotmentDate),
      ),
      GridData(
        title: "Reopening Date",
        subtitle: getFormattedDate(sif.reopeningDate),
      ),
      GridData(
        title: "Latest NAV",
        customSubtitle: _buildNavSubtitle(
          displayValue: navDisplay,
          hasValue: sif.nav != null,
          context: context,
          date: sif.navDate,
          dateLabel: 'Nav Date',
        ),
      ),
      GridData(
        title: "Launch NAV",
        customSubtitle: _buildNavSubtitle(
          displayValue: launchNavDisplay,
          hasValue: sif.navAtLaunch != null,
          context: context,
          date: sif.launchDate,
          dateLabel: 'Launch Date',
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 20.0,
        children: gridItems
            .map((widget) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 60) /
                      2, // 60 = 20 (left) + 20 (right) + 10 (spacing) + 10 (extra padding)
                  child: widget,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNavSubtitle({
    required String displayValue,
    required bool hasValue,
    required BuildContext context,
    DateTime? date,
    String? dateLabel,
  }) {
    return Row(
      children: [
        Text(
          hasValue ? displayValue : '-',
          style: context.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
        ),
        if (date != null)
          Padding(
            padding: EdgeInsets.only(left: 3),
            child: Tooltip(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: ColorConstants.black,
                  borderRadius: BorderRadius.circular(6)),
              triggerMode: TooltipTriggerMode.tap,
              textStyle:
                  Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
              message: '${dateLabel ?? 'Date'} : ${getFormattedDate(date)}',
              child: Icon(
                Icons.info_outline,
                color: ColorConstants.black,
                size: 16,
              ),
            ),
          )
      ],
    );
  }

  Widget _buildSifObjective(BuildContext context, SifModel sif) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0)
          .copyWith(top: 24, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Objective',
            style: context.headlineMedium!,
          ),
          SizedBox(height: 12),
          Text(
            sif.objective ?? '-',
            textAlign: TextAlign.justify,
            style: context.headlineSmall!.copyWith(
              color: ColorConstants.black,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreDetailsButton(BuildContext context) {
    return Center(
      child: ClickableText(
        text: 'For more details click here',
        fontSize: 14,
        onClick: () async {
          const url =
              'https://drive.google.com/drive/folders/1_4Rfm_u990st6LzrWcVOdyyVBdi7nt1Y?usp=sharing';
          await launch(url);
        },
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return GetBuilder<SifController>(
      builder: (controller) {
        if (controller.selectedSif == null) {
          return SizedBox();
        }

        // if (controller.sifMinSipAmountResponse.state == NetworkState.loading) {
        //   return Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Container(
        //         margin: EdgeInsets.only(bottom: 20),
        //         width: 20,
        //         height: 20,
        //         child: CircularProgressIndicator(),
        //       ),
        //     ],
        //   );
        // }

        final basketController = Get.find<BasketController>();

        final sif = controller.selectedSif!;
        final scheme = SchemeMetaModel(
          schemeName: sif.schemeName,
          displayName: sif.schemeName,
          category: sif.strategyType,
          fundType: sif.strategyType,
          amc: sif.amc,
          wpc: sif.wpc,
          minDepositAmt: sif.minDepositAmt,
          minSipDepositAmt: sif.minSipDepositAmt,
          isSif: true,
          amcName: sif.amcName,
          wschemecode: sif.isin,
          minAmcDepositAmt: sif.minAmcDepositAmt,
        );

        return BasketBottomBar(controller: basketController, fund: scheme);
      },
    );
  }
}
