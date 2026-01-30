import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/utils/context_extension.dart';
import 'package:app/src/controllers/store/mutual_fund/sif_controller.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/sif_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SifListSection extends StatelessWidget {
  final controller = Get.find<SifController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.borderColor),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildTableHeader(context),

          // Scheme List
          if (controller.sifs.isNotEmpty)
            _buildSifList(context, controller)
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No SIFs Found',
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
            ),
          if (controller.isPaginating) _buildInfiniteLoader(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final textStyle = context.headlineSmall!.copyWith(
        color: ColorConstants.tertiaryBlack,
        fontWeight: FontWeight.w600,
        height: 1.5);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConstants.borderColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Scheme Name',
            style: textStyle,
          ),
          Spacer(),
          Text(
            'Category',
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildSifList(BuildContext context, SifController controller) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.sifs.length,
        controller: controller.scrollController,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(color: ColorConstants.borderColor);
        },
        itemBuilder: (BuildContext context, int index) {
          final sif = controller.sifs[index];
          return _buildSifTile(context, sif);
        },
      ),
    );
  }

  Widget _buildSifTile(BuildContext context, SifModel sif) {
    final scheme = SchemeMetaModel(
      schemeName: sif.schemeName,
      displayName: sif.schemeName,
      category: sif.strategyType,
      fundType: sif.strategyType,
      amc: sif.amc,
      wpc: sif.wpc,
      minDepositAmt: sif.minDepositAmt,
      minSipDepositAmt: sif.minSipDepositAmt,
      amcName: sif.amcName,
      isSif: true,
      wschemecode: sif.isin,
    );

    return Padding(
      padding: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).push(SifDetailRoute(sif: sif));
        },
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AMC Logo
                      CommonMfUI.buildBasketFundAmcLogo(context, scheme),

                      // Scheme Name
                      Expanded(
                        child: Text(
                          sif.schemeName ?? '-',
                          // maxLines: 3,
                          style: context.headlineMedium!.copyWith(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    sif.strategyType ?? '-',
                    textAlign: TextAlign.right,
                    maxLines: 4,
                    style: context.titleLarge!.copyWith(
                        color: ColorConstants.tertiaryBlack,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  _buildOpenClosingDateText(context, sif),
                  Spacer(),
                  // _buildAddBasketButton(context, scheme)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenClosingDateText(BuildContext context, SifModel sif) {
    String date = '';

    if (sif.launchDate != null) {
      date += '${getFormattedDate(sif.launchDate)} - ';
    }

    if (sif.closeDate != null) {
      date += '${getFormattedDate(sif.closeDate!)}';
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_month_outlined,
          color: ColorConstants.primaryAppColor,
          size: 12,
        ),
        SizedBox(width: 5),
        Text(
          '$date',
          style: Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
              color: ColorConstants.tertiaryBlack,
              fontSize: 11,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAddBasketButton(BuildContext context, SchemeMetaModel scheme) {
    return CommonMfUI.buildAddBasketButton(context, scheme);
  }

  Widget _buildInfiniteLoader() {
    return Container(
      height: 30,
      margin: EdgeInsets.only(bottom: 10, top: 10),
      alignment: Alignment.center,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
