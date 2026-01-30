import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

class Bonus extends StatelessWidget {
  const Bonus({Key? key, required this.isArnHolder}) : super(key: key);

  final bool isArnHolder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Earn back',
          style: Theme.of(context)
              .primaryTextTheme
              .headlineMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: 'Earn back platform fees ',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineSmall!
                .copyWith(fontSize: 13, color: ColorConstants.tertiaryBlack),
            children: [
              TextSpan(
                text: '₹1,999 ',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontSize: 13),
              ),
              TextSpan(
                text: 'by achieving any of the following within six months',
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(
                        fontSize: 13, color: ColorConstants.tertiaryBlack),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 18),
        _buildBonusPoints(context)
      ],
    );
  }

  Container _buildBonusPoints(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBonusTile(
                  context,
                  'Net equity MF lumpsum sales of ',
                  '₹25 Lacs',
                ),
                _buildOrText(context),
                _buildBonusTile(
                  context,
                  'Net equity MF SIP sales of ',
                  '₹50,000',
                ),
                _buildOrText(context),
                _buildBonusTile(
                  context,
                  'Net PMS sales of ',
                  '₹50 Lacs',
                ),
                _buildOrText(context),
                _buildBonusTile(
                  context,
                  'Net AIF sales of ',
                  '₹1 Crore',
                ),
                _buildOrText(context),
                _buildBonusTile(
                  context,
                  'Insurance (Health+ Life) sales of ',
                  '₹50,000',
                ),
                _buildOrText(context),
                _buildBonusTile(
                  context,
                  'Fixed Deposit Sales of ',
                  '₹10 Lacs',
                ),
                _buildOrText(context),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Image.asset(
                        AllImages().star,
                        width: 12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Net equity lumpsum sales of ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!,
                            ),
                            TextSpan(
                              text: '₹10 Lacs + ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: 'Net equity SIP sales of ',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!,
                            ),
                            TextSpan(
                              text: '₹25,000',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w700),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(
              color: ColorConstants.borderColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "*Amount will be released after 2 payout cycles post achieving the business criteria",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
                SizedBox(height: 10),
                Text(
                  "*Amount will be released net of TDS",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .titleLarge!
                      .copyWith(color: ColorConstants.tertiaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusTile(BuildContext context, String title, String amount) {
    return Row(
      children: [
        Image.asset(
          AllImages().star,
          width: 12,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).primaryTextTheme.headlineSmall,
              ),
              Text(
                amount,
                style: Theme.of(context)
                    .primaryTextTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.w700),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrText(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'OR',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .primaryTextTheme
              .titleMedium!
              .copyWith(color: ColorConstants.tertiaryBlack),
        ),
      ),
    );
  }
}
