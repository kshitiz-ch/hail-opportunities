import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/nfo_detail_controller.dart';
import 'package:app/src/screens/commons/empty_screen/empty_screen.dart';
import 'package:app/src/screens/store/fund_list/widgets/basket_bottom_bar.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/nfo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

@RoutePage()
class NfoDetailScreen extends StatelessWidget {
  const NfoDetailScreen({Key? key, this.nfo, @pathParam this.wschemecode})
      : super(key: key);

  final NfoModel? nfo;
  final String? wschemecode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        showBackButton: true,
        // titleText: nfo.schemeName ?? 'NFO',
        // subtitleText: nfo.category ?? '',
        // maxLine: 2,
        // appBarHeight: 70,
      ),
      body: GetBuilder<NfoDetailController>(
        init: NfoDetailController(nfo: nfo, nfoWschemecode: wschemecode),
        builder: (controller) {
          if (controller.fetchNfoDetailsState == NetworkState.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.fetchNfoDetailsState == NetworkState.error) {
            return Center(
              child: RetryWidget(
                'Failed to load details. Please try again',
                onPressed: () {
                  controller.getNfoDetails();
                },
              ),
            );
          }

          if (controller.fetchNfoDetailsState == NetworkState.loaded &&
              controller.nfo == null) {
            return Center(
              child: EmptyScreen(
                message: 'NFO not found',
              ),
            );
          }

          return Column(
            children: [
              _buildNfoSchemeName(context, controller),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Column(
                    children: [
                      _buildNfoOverview(controller),
                      Divider(
                        color: ColorConstants.lightGrey,
                      ),
                      _buildNfoObjective(context, controller)
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

  Widget _buildNfoSchemeName(
      BuildContext context, NfoDetailController controller) {
    NfoModel nfoDetail = controller.nfo!;
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
                // amc code not coming
                // so can't use getAmcLogoNew
                imageUrl: getAmcLogo(nfoDetail.schemeName),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nfoDetail.schemeName ?? '-',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineMedium!
                      .copyWith(
                          // fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black),
                ),
                if (nfoDetail.category.isNotNullOrEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      nfoDetail.category ?? '-',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
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

  Widget _buildNfoOverview(NfoDetailController controller) {
    NfoModel nfoDetail = controller.nfo!;
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 2.8,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          GridData(
            title: "Open Date",
            subtitle: nfoDetail.launchDate != null
                ? DateFormat('dd MMM yyyy').format(nfoDetail.launchDate!)
                : '-',
          ),
          GridData(
            title: "Close Date",
            subtitle: nfoDetail.closeDate != null
                ? DateFormat('dd MMM yyyy').format(nfoDetail.closeDate!)
                : '-',
          ),
          GridData(
            title: "Opening Nav",
            subtitle: nfoDetail.offerPrice,
          ),
          GridData(
            title: "Min Investment Amount",
            subtitle: nfoDetail.minDepositAmt.isNotNullOrZero
                ? WealthyAmount.currencyFormat(nfoDetail.minDepositAmt, 0)
                : '-',
          ),
          GridData(
            title: "Min SIP Amount",
            subtitle: nfoDetail.minSipDepositAmt.isNotNullOrZero
                ? WealthyAmount.currencyFormat(nfoDetail.minSipDepositAmt, 0)
                : '-',
          ),
          if (nfoDetail.reopeningDate != null)
            GridData(
              title: "Reopening Date",
              subtitle: nfoDetail.reopeningDate != null
                  ? DateFormat('dd MMM yyyy').format(nfoDetail.reopeningDate!)
                  : '-',
            ),
        ],
      ),
    );
  }

  Widget _buildNfoObjective(
      BuildContext context, NfoDetailController controller) {
    NfoModel nfoDetail = controller.nfo!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0).copyWith(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fund Objective',
            style: Theme.of(context)
                .primaryTextTheme
                .displaySmall!
                .copyWith(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            nfoDetail.objective!,
            textAlign: TextAlign.justify,
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(height: 1.7, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return GetBuilder<NfoDetailController>(
      builder: (controller) {
        if (controller.nfo == null) {
          return SizedBox();
        }

        if (controller.nfoMinSipAmountResponse.state == NetworkState.loading) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        BasketController basketController = Get.find<BasketController>();

        NfoModel nfo = controller.nfo!;
        SchemeMetaModel scheme = SchemeMetaModel(
          schemeName: nfo.schemeName,
          displayName: nfo.schemeName,
          fundType: nfo.fundType,
          minDepositAmt: nfo.minDepositAmt,
          minSipDepositAmt: nfo.minSipDepositAmt,
          wpc: nfo.wpc,
          wschemecode: nfo.isin,
          isNfo: true,
          reopeningDate: nfo.reopeningDate,
        );

        return BasketBottomBar(
          controller: basketController,
          fund: scheme,
        );
      },
    );
  }
}
