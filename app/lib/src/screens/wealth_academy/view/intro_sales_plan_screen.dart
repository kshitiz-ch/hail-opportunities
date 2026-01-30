import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class IntroSalesPlanScreen extends StatelessWidget {
  const IntroSalesPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: Colors.black.withOpacity(0.6),
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Introducing Sales Plan',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Achieve 10x more sales, tailored just for you!',
                        style: Theme.of(context)
                            .primaryTextTheme
                            .titleLarge!
                            .copyWith(color: ColorConstants.tertiaryBlack),
                      ),
                      SizedBox(height: 20),
                      Image.asset(AllImages().introSalesPlanIcon, width: 150),
                      SizedBox(height: 20),
                      ActionButton(
                        text: 'Explore Sales Guide',
                        onPressed: () {
                          AutoRouter.of(context).push(SalesPlanUnboxRoute());
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        AutoRouter.of(context).popForced();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          color: ColorConstants.tertiaryBlack,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
