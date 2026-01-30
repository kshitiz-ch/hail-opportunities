import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/crisil_bottom_sheet.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/fd_form_download_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/store/models/fixed_deposit_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OfflineFDCard extends StatelessWidget {
  final FixedDepositModel? product;

  const OfflineFDCard({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.07),
      elevation: 5,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              offset: Offset(0, 3),
              blurRadius: 10,
            )
          ],
          border: Border.all(
            width: 0.5,
            color: ColorConstants.tertiaryBlack.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product!.displayName!,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineMedium!
                              .copyWith(
                                color: ColorConstants.black,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        _buildBulletList(
                          context: context,
                          textList: [
                            (product?.productOverview?.interestRate
                                        ?.maxInterestRate !=
                                    null)
                                ? 'Earn interest rates upto ${product!.productOverview!.interestRate!.maxInterestRate}% '
                                : 'Earn interest rates upto $notAvailableText',
                            'Flexible tenures and payout options',
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 16),
                    child: product!.icon!.endsWith('.svg')
                        ? SvgPicture.network(
                            product!.icon!,
                            fit: BoxFit.fitWidth,
                            width: 54,
                          )
                        : CachedNetworkImage(
                            imageUrl: product!.icon!,
                            fit: BoxFit.fitWidth,
                            width: 54,
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CommonUI.buildProfileDataSeperator(
                color: ColorConstants.borderColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCrisilRating(context),
                  if (product!.pdfUrl.isNotNullOrEmpty)
                    FDFormDownloadButton(
                      pdfUrl: product!.pdfUrl,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletList(
      {BuildContext? context, required List<String> textList}) {
    Widget _buildBullet() {
      return Container(
        height: 2,
        width: 2,
        decoration: BoxDecoration(
          color: ColorConstants.tertiaryBlack,
          shape: BoxShape.circle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[].toList()
          ..addAll(
            textList.map<Widget>(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      // fix:
                      // alignment of bullet points with bullet text
                      // height == height of bullet text
                      height: (18 / 12) * 14,
                      child: Center(
                        child: _buildBullet(),
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '$text',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context!)
                            .primaryTextTheme
                            .headlineSmall!
                            .copyWith(
                              color: ColorConstants.tertiaryBlack,
                              height: 18 / 12,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildCrisilRating(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (product?.crisilRating ?? notAvailableText).toUpperCase(),
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                color: ColorConstants.black,
                fontWeight: FontWeight.w700,
              ),
        ),
        Row(
          children: [
            Text(
              'Crisil Rating',
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
            SizedBox(width: 4),
            InkWell(
              onTap: () {
                CommonUI.showBottomSheet(
                  context,
                  child: CrisilBottomSheet(),
                  isScrollControlled: false,
                );
              },
              child: Icon(
                Icons.info_outline,
                color: ColorConstants.tertiaryBlack,
                size: 12,
              ),
            )
          ],
        ),
      ],
    );
  }
}
