import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ArnBenefits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Color.fromRGBO(1, 138, 128, 0.1)),
          child: Row(
            children: [
              SvgPicture.asset(AllImages().arnBenefitsTrailIncome),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Enjoy life long trail income',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displaySmall!
                      .copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Color.fromRGBO(255, 192, 75, 0.1)),
          child: Row(
            children: [
              SvgPicture.asset(AllImages().arnBenefitsBuildTeam),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Ability to build your own team and earn commisions',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displaySmall!
                      .copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Color.fromRGBO(255, 108, 119, 0.1)),
          child: Row(
            children: [
              SvgPicture.asset(
                AllImages().arnBenefitsBranding,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Your branding on the client app',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displaySmall!
                      .copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.black),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
