import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/store/debenture/debenture_controller.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/text/grid_data.dart';
import 'package:core/modules/store/models/debenture_model.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:intl/src/intl/date_format.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({
    Key? key,
    this.product,
    this.controller,
  }) : super(key: key);

  final DebentureModel? product;
  final DebentureController? controller;

  @override
  Widget build(BuildContext context) {
    String tradeDateFormatted = '-';
    String paymentEndDateFormatted = '-';

    if (product?.tradeDate != null) {
      DateTime tradeDateParsed = DateTime.parse(product!.tradeDate!);
      tradeDateFormatted = DateFormat('dd MMM yyyy').format(tradeDateParsed);
    }

    if (product?.paymentEndDate != null) {
      DateTime paymentEndDateParsed = DateTime.parse(product!.paymentEndDate!);
      paymentEndDateFormatted =
          DateFormat('dd MMM yyyy').format(paymentEndDateParsed);
    }

    // DateTime confirmationDateParsed;
    // String confirmationDateFormatted = '-';
    // if (product?.confirmationDate != null) {
    //   confirmationDateParsed = DateTime.parse(product.confirmationDate);
    //   confirmationDateFormatted = DateFormat('dd-MMM-yy').format(confirmationDateParsed);
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GridView
        Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 2.8,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: [
              GridData(
                title: "Price per unit",
                subtitle: "${WealthyAmount.currencyFormat(
                  product!.sellPrice,
                  0,
                  showSuffix: false,
                )}",
              ),
              GridData(
                title: "ISIN Code",
                subtitle: product!.isin,
              ),
              GridData(
                title: "Last Payment date",
                subtitle: paymentEndDateFormatted,
              ),
              if (product?.tradeDate != null)
                GridData(
                  title: "Trade Date",
                  subtitle: tradeDateFormatted,
                ),
              if (controller!.isConfirmationDateNotElapsed)
                GridData(
                  title: "Min. Booking Amount",
                  subtitle: "${WealthyAmount.currencyFormat(
                    product!.confirmationAmount ?? 0,
                    0,
                    showSuffix: false,
                  )}",
                ),
              if (product!.lotCheckEnabled! && product!.lotAvailable! >= 0)
                GridData(
                    title: "Units Available",
                    subtitle: product!.lotAvailable!.toStringAsFixed(0)),
              if (controller?.minimumSecurities != null)
                GridData(
                  title: "Min. Securities",
                  subtitle: controller!.minimumSecurities.toString(),
                ),
              if (controller?.product?.productUrl?.isNotNullOrEmpty ?? false)
                GridData(
                  title: "Report",
                  customSubtitle: InkWell(
                    onTap: () {
                      launch(controller!.product!.productUrl!);
                    },
                    child: Row(
                      children: [
                        Text(
                          'View Report',
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ColorConstants.primaryAppColor),
                        ),
                        SizedBox(
                          width: 1,
                        ),
                        Icon(Icons.open_in_new,
                            color: ColorConstants.primaryAppColor)
                      ],
                    ),
                  ),
                ),
              // GridData(
              //   title: "${WealthyAmount.currencyFormat(
              //     product.confirmationAmount,
              //     0,
              //     showSuffix: false,
              //   )}",
              //   subtitle: "Confirmation Amount",
              // ),
              // GridData(
              //   title: confirmationDateFormatted,
              //   subtitle: "Confirmation Date",
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
