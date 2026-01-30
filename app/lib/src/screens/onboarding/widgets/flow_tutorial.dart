import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:flutter/material.dart';

import 'lottie_animation.dart';

class FlowTutorial extends StatelessWidget {
  final int index;

  const FlowTutorial({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'STEP ${index + 1}',
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorConstants.primaryAppColor,
              ),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          getHeader(),
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headlineLarge!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 7, bottom: 25),
          child: Text(
            getDescription(),
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.6,
                  color: Colors.black.withOpacity(0.6),
                ),
          ),
        ),
        this.index == 4
            ? Expanded(child: LottieAnimation())
            : Container(
                // width: double.infinity,
                height: 440,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    width: 2,
                    color: Color(0xffdbdbdb),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0),
                      blurRadius: 10,
                      spreadRadius: 10,
                      color: Color.fromRGBO(126, 126, 126, 0.23),
                    ),
                  ],
                ),
                child: Card(
                  shadowColor: Color.fromRGBO(126, 126, 126, 0.23),
                  margin: EdgeInsets.zero,
                  elevation: 5,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    getImagePath(),
                    fit: BoxFit.fill,
                    height: double.infinity,
                  ),
                ),
              ),
        Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 7),
          child: carouselDotIndicator(),
        ),
      ],
    );
  }

  Widget carouselDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (this.index) == index
                    ? Color.fromRGBO(0, 0, 0, 0.9)
                    : Color.fromRGBO(0, 0, 0, 0.4)),
          );
        },
      ),
    );
  }

  String getImagePath() {
    switch (this.index + 1) {
      case 1:
        return AllImages().storeOnboardingStep1;
      case 2:
        return AllImages().storeOnboardingStep2;
      case 3:
        return AllImages().storeOnboardingStep3;
      case 4:
        return AllImages().storeOnboardingStep4;
      case 5:
        return AllImages().storeOnboardingStep5;
      default:
        return AllImages().storeOnboardingStep1;
    }
  }

  String getHeader() {
    switch (this.index + 1) {
      case 1:
        return 'Explore Products';
      case 2:
        return 'Choose Product';
      case 3:
        return 'Select Client';
      case 4:
        return 'Review your basket';
      case 5:
        return 'Send & track proposals';
      default:
        return 'Explore Products';
    }
  }

  String getDescription() {
    switch (this.index + 1) {
      case 1:
        return 'Explore 150+ products across MFs, Insurance, Fixed Deposits, and more...';
      case 2:
        return 'Choose the right product for your client';
      case 3:
        return 'Select the client from your contacts';
      case 4:
        return 'Review your suggestion and send the link to close the transaction';
      case 5:
        return 'Client will be notified regarding the proposal';
      default:
        return 'Explore 150+ products across MFs, Insurance, Fixed Deposits, and more...';
    }
  }
}
