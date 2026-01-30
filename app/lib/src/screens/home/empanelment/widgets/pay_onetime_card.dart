import 'package:app/src/config/constants/color_constants.dart';
import 'package:flutter/material.dart';

class PayOnetimeCard extends StatelessWidget {
  const PayOnetimeCard({Key? key, required this.isArnHolder}) : super(key: key);

  final bool isArnHolder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Empanel with Wealthy',
            style: Theme.of(context)
                .primaryTextTheme
                .headlineMedium!
                .copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),
          Text.rich(
            TextSpan(
              text: 'For a one-time platform fee of ',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headlineSmall!
                  .copyWith(fontSize: 13, color: ColorConstants.tertiaryBlack),
              children: [
                TextSpan(
                  text: "${isArnHolder ? "₹1,999" : "₹3,999"}* only",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(fontSize: 13),
                ),
                TextSpan(
                  text: ", you get exclusive benefit",
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                          fontSize: 13, color: ColorConstants.tertiaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
