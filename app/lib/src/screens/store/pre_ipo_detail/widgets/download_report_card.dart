import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:core/modules/store/models/unlisted_stocks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DownloadReportCard extends StatelessWidget {
  const DownloadReportCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  final UnlistedProductModel? product;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 80,
      padding: EdgeInsets.only(left: 20, right: 50, top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: ColorConstants.secondaryWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pre IPO Report',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Download and share the Pre IPO stock report with your client',
            style: Theme.of(context)
                .primaryTextTheme
                .titleLarge!
                .copyWith(color: ColorConstants.tertiaryBlack),
          ),
          SizedBox(
            height: 16,
          ),
          InkWell(
            onTap: () {
              launch(product!.reportUrl!);
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  AllImages().downloadIcon,
                  width: 14,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Download Report',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorConstants.primaryAppColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
