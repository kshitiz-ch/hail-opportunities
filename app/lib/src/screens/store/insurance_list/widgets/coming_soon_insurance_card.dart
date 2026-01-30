import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ComingSoonInsuranceCard extends StatefulWidget {
  final String? productVariant;
  final bool showLottieAnimation;

  const ComingSoonInsuranceCard({
    Key? key,
    this.productVariant,
    this.showLottieAnimation = false,
  }) : super(key: key);

  @override
  State<ComingSoonInsuranceCard> createState() =>
      _ComingSoonInsuranceCardState();
}

class _ComingSoonInsuranceCardState extends State<ComingSoonInsuranceCard>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    _lottieController.duration = Duration(seconds: 1);
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLottieAnimation && _lottieController.duration != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _lottieController.forward(from: 0);
      });
    }

    return InkWell(
      onTap: () {
        AutoRouter.of(context).push(
          InsuranceDetailRoute(
            productVariant: widget.productVariant,
            isOffline: true,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xffFFE47A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Text(
                      'Coming Soon Online',
                      style: Theme.of(context)
                          .primaryTextTheme
                          .titleLarge!
                          .copyWith(
                            color: ColorConstants.black,
                          ),
                    ),
                  ),
                  Text(
                    insuranceSectionData[widget.productVariant]!['title'],
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(
                          color: ColorConstants.black,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      insuranceSectionData[widget.productVariant]![
                          'description'],
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall!
                          .copyWith(
                            color: ColorConstants.tertiaryBlack,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 96,
              height: 96,
              child: Lottie.asset(
                insuranceSectionData[widget.productVariant]!['lottie'],
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController..duration = composition.duration;
                },
              ),
            ),
            // Image.asset(
            //   insuranceSectionData[widget.productVariant]['image_path'],
            //   alignment: Alignment.center,
            //   height: 96,
            //   width: 96,
            // )
          ],
        ),
      ),
    );
  }
}
