import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/store/mutual_fund/basket_controller.dart';
import 'package:app/src/controllers/store/mutual_fund/nfos_controller.dart';
import 'package:app/src/widgets/misc/common_mf_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';
import 'package:core/modules/store/models/mf/nfo_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

class NfoList extends StatelessWidget {
  const NfoList({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final NfosController controller;

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
          if (controller.nfos.isNotEmpty)
            _buildNfoList(context, controller)
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No NFOs Found',
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
            ),
          if (controller.isPaginating) _buildInfiniteLoader(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    TextStyle textStyle = Theme.of(context)
        .primaryTextTheme
        .headlineSmall!
        .copyWith(
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

  Widget _buildNfoList(BuildContext context, NfosController controller) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.nfos.length,
        controller: controller.scrollController,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(color: ColorConstants.borderColor);
        },
        itemBuilder: (BuildContext context, int index) {
          NfoModel nfo = controller.nfos[index];
          return _buildNfoTile(context, nfo);
        },
      ),
    );
  }

  Widget _buildNfoTile(BuildContext context, NfoModel nfo) {
    SchemeMetaModel scheme = SchemeMetaModel(
      schemeName: nfo.schemeName,
      displayName: nfo.schemeName,
      fundType: nfo.fundType,
      wpc: nfo.wpc,
      minDepositAmt: nfo.minDepositAmt,
      minSipDepositAmt: nfo.minDepositAmt,
      wschemecode: nfo.isin,
    );
    return Padding(
      padding: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).push(
            NfoDetailRoute(nfo: nfo),
          );
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
                          nfo.schemeName ?? '-',
                          // maxLines: 3,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(fontSize: 14),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    nfo.category ?? '-',
                    textAlign: TextAlign.right,
                    maxLines: 4,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .titleLarge!
                        .copyWith(
                            color: ColorConstants.tertiaryBlack,
                            overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 40, top: 15),
              child: Row(
                children: [
                  _buildOpenClosingDateText(context, nfo),
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

  Widget _buildOpenClosingDateText(BuildContext context, NfoModel nfo) {
    String date = '';

    if (nfo.launchDate != null) {
      date += '${DateFormat('dd MMM yyyy').format(nfo.launchDate!)} - ';
    }

    if (nfo.closeDate != null) {
      date += '${DateFormat('dd MMM yyyy').format(nfo.closeDate!)}';
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
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
