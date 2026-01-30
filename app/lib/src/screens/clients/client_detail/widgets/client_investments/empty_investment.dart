import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

class EmptyInvestment extends StatelessWidget {
  const EmptyInvestment(
      {Key? key, this.emptyText, this.emptyHeader, this.isInsurance = false})
      : super(key: key);

  final String? emptyText;
  final String? emptyHeader;
  final bool isInsurance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
        child: Column(
          children: [
            Image.asset(
              isInsurance
                  ? AllImages().noInsuranceIcon
                  : AllImages().noInvestmentsIcon,
              height: 80,
              width: 80,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 6.0),
              child: Text(
                emptyHeader ?? 'Wealthy Investments',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w600,
                        ),
              ),
            ),
            Text(
              emptyText ?? 'No investments yet!',
              style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
