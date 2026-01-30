import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/animation/marquee_widget.dart';
import 'package:app/src/widgets/misc/common_client_ui.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:core/modules/clients/models/user_profile_view_model.dart';
import 'package:flutter/material.dart';

class PanProfileCard extends StatelessWidget {
  final ProfileModel data;
  final bool isSelected;
  final Function() onTap;

  const PanProfileCard({
    Key? key,
    required this.data,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 16),
        decoration: BoxDecoration(
          color: ColorConstants.white,
          border: Border.all(
            color: isSelected
                ? ColorConstants.primaryAppColor
                : ColorConstants.secondarySeparatorColor,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0.0, 0.0),
                    spreadRadius: 0.0,
                    blurRadius: 4.0,
                  ),
                ]
              : [],
        ),
        child: _buildProfileCard(context),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final titleLarge = Theme.of(context).primaryTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: ColorConstants.tertiaryBlack,
        );
    final headlineSmall =
        Theme.of(context).primaryTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: ColorConstants.tertiaryBlack,
            );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Icon
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              backgroundImage:
                  AssetImage(getProfileIcon(data.accountType ?? '')),
            ),

            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: MarqueeWidget(
                          child: Text(
                            (data.accountType ?? "").isNotNullOrEmpty
                                ? data.accountType.toString()
                                : "-",
                            style: headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ColorConstants.black,
                            ),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Image.asset(
                            AllImages().verifiedIcon,
                            width: 13,
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'CRN:',
                        style: titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: ColorConstants.tertiaryBlack,
                        ),
                      ),
                      Text(
                        ' ${data.crn}',
                        style: titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 16, bottom: 24),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: CommonUI.buildColumnTextInfo(
        //           title: 'Invested Value',
        //           subtitle: WealthyAmount.currencyFormat(data.investedValue, 0),
        //           titleStyle: titleLarge?.copyWith(
        //               fontWeight: FontWeight.w500,
        //               color: ColorConstants.tertiaryBlack),
        //           subtitleStyle: headlineSmall?.copyWith(
        //               fontWeight: FontWeight.w600, color: ColorConstants.black),
        //           gap: 6,
        //         ),
        //       ),
        //       SizedBox(width: 10),
        //       Expanded(
        //         child: CommonUI.buildColumnTextInfo(
        //           title: 'Current Value',
        //           subtitle: WealthyAmount.currencyFormat(data.currentValue, 0),
        //           titleStyle: titleLarge?.copyWith(
        //               fontWeight: FontWeight.w500,
        //               color: ColorConstants.tertiaryBlack),
        //           subtitleStyle: headlineSmall?.copyWith(
        //               fontWeight: FontWeight.w600, color: ColorConstants.black),
        //           gap: 6,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // CommonClientUI.buildProfileReturnUI(
        //   context: context,
        //   returnData: {
        //     'Absolute': (data.absoluteReturnPercent ?? 0) * 100.0,
        //     // Not Supported from backend
        //     // 'Annualised': 0.0,
        //     'Unrealised Gain/Loss': (data.absoluteReturn ?? 0).toDouble(),
        //   }.entries.toList(),
        // )
      ],
    );
  }

  String getProfileIcon(String accountType) {
    accountType = accountType.toUpperCase();
    if (accountType.contains('JOIN')) {
      return AllImages().jointAccountClientIcon;
    } else if (accountType.contains('NRE')) {
      return AllImages().nreClientIcon;
    } else if (accountType.contains('NRO')) {
      return AllImages().nroClientIcon;
    } else {
      return AllImages().normalClientIcon;
    }
  }
}

class ProfileCardShape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.07854406, size.height * 0.06750401);
    path_0.cubicTo(
        size.width * 0.07854406,
        size.height * 0.05137883,
        size.width * 0.09226705,
        size.height * 0.03830693,
        size.width * 0.1091954,
        size.height * 0.03830693);
    path_0.lineTo(size.width * 0.8908046, size.height * 0.03830693);
    path_0.cubicTo(
        size.width * 0.9077318,
        size.height * 0.03830693,
        size.width * 0.9214559,
        size.height * 0.05137883,
        size.width * 0.9214559,
        size.height * 0.06750401);
    path_0.lineTo(size.width * 0.9214559, size.height * 0.8266277);
    path_0.cubicTo(
        size.width * 0.9214559,
        size.height * 0.8427518,
        size.width * 0.9077318,
        size.height * 0.8558248,
        size.width * 0.8908046,
        size.height * 0.8558248);
    path_0.lineTo(size.width * 0.6436782, size.height * 0.8558248);
    path_0.lineTo(size.width * 0.5742337, size.height * 0.8558248);
    path_0.lineTo(size.width * 0.5530996, size.height * 0.8558248);
    path_0.cubicTo(
        size.width * 0.5444483,
        size.height * 0.8558248,
        size.width * 0.5361992,
        size.height * 0.8593102,
        size.width * 0.5303870,
        size.height * 0.8654161);
    path_0.lineTo(size.width * 0.5104674, size.height * 0.8863540);
    path_0.cubicTo(
        size.width * 0.5074253,
        size.height * 0.8895511,
        size.width * 0.5021533,
        size.height * 0.8895511,
        size.width * 0.4991111,
        size.height * 0.8863540);
    path_0.lineTo(size.width * 0.4791916, size.height * 0.8654161);
    path_0.cubicTo(
        size.width * 0.4733793,
        size.height * 0.8593102,
        size.width * 0.4651303,
        size.height * 0.8558248,
        size.width * 0.4564789,
        size.height * 0.8558248);
    path_0.lineTo(size.width * 0.4353448, size.height * 0.8558248);
    path_0.lineTo(size.width * 0.3659004, size.height * 0.8558248);
    path_0.lineTo(size.width * 0.1091954, size.height * 0.8558248);
    path_0.cubicTo(
        size.width * 0.09226705,
        size.height * 0.8558248,
        size.width * 0.07854406,
        size.height * 0.8427518,
        size.width * 0.07854406,
        size.height * 0.8266277);
    path_0.lineTo(size.width * 0.07854406, size.height * 0.06750401);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.08045977, size.height * 0.06750401);
    path_1.cubicTo(
        size.width * 0.08045977,
        size.height * 0.05238686,
        size.width * 0.09332529,
        size.height * 0.04013175,
        size.width * 0.1091954,
        size.height * 0.04013175);
    path_1.lineTo(size.width * 0.8908046, size.height * 0.04013175);
    path_1.cubicTo(
        size.width * 0.9066743,
        size.height * 0.04013175,
        size.width * 0.9195402,
        size.height * 0.05238686,
        size.width * 0.9195402,
        size.height * 0.06750401);
    path_1.lineTo(size.width * 0.9195402, size.height * 0.8266277);
    path_1.cubicTo(
        size.width * 0.9195402,
        size.height * 0.8417445,
        size.width * 0.9066743,
        size.height * 0.8540000,
        size.width * 0.8908046,
        size.height * 0.8540000);
    path_1.lineTo(size.width * 0.6436782, size.height * 0.8540000);
    path_1.lineTo(size.width * 0.5742337, size.height * 0.8540000);
    path_1.lineTo(size.width * 0.5530996, size.height * 0.8540000);
    path_1.cubicTo(
        size.width * 0.5439042,
        size.height * 0.8540000,
        size.width * 0.5351418,
        size.height * 0.8577007,
        size.width * 0.5289693,
        size.height * 0.8641898);
    path_1.lineTo(size.width * 0.5090460, size.height * 0.8851277);
    path_1.cubicTo(
        size.width * 0.5067663,
        size.height * 0.8875255,
        size.width * 0.5028123,
        size.height * 0.8875255,
        size.width * 0.5005326,
        size.height * 0.8851277);
    path_1.lineTo(size.width * 0.4806092, size.height * 0.8641898);
    path_1.cubicTo(
        size.width * 0.4744368,
        size.height * 0.8577007,
        size.width * 0.4656743,
        size.height * 0.8540000,
        size.width * 0.4564789,
        size.height * 0.8540000);
    path_1.lineTo(size.width * 0.4353448, size.height * 0.8540000);
    path_1.lineTo(size.width * 0.3659004, size.height * 0.8540000);
    path_1.lineTo(size.width * 0.1091954, size.height * 0.8540000);
    path_1.cubicTo(
        size.width * 0.09332529,
        size.height * 0.8540000,
        size.width * 0.08045977,
        size.height * 0.8417445,
        size.width * 0.08045977,
        size.height * 0.8266277);
    path_1.lineTo(size.width * 0.08045977, size.height * 0.06750401);
    path_1.close();

    Paint paint_1_stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    paint_1_stroke.color = Color(0xff6725F4).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_stroke);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
