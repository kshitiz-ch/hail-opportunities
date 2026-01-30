import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/controllers/rewards/rewards_controller.dart';
import 'package:app/src/screens/commons/rating_screen/rating_screen.dart';
import 'package:app/src/utils/fixed_center_docked_fab_location.dart';
import 'package:app/src/utils/wealthy_amount.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class RewardSuccessScreen extends StatefulWidget {
  final int? amount;

  const RewardSuccessScreen({this.amount});

  @override
  _RewardSuccessScreenState createState() => _RewardSuccessScreenState();
}

class _RewardSuccessScreenState extends State<RewardSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
    _lottieController = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(seconds: 1), () {
        CommonUI.showBottomSheet(
          context,
          child: RatingScreen(),
          isScrollControlled: false,
        );
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: ColorConstants.white,
        body: Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      child: Lottie.asset(
                        AllImages().verifiedIconLottie,
                        controller: _lottieController,
                        onLoaded: (composition) {
                          _lottieController
                            ..duration = composition.duration
                            ..forward();
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Your Reward Redemption for ${WealthyAmount.currencyFormat(widget.amount, 0)} is Successful!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FixedCenterDockedFabLocation(),
        floatingActionButton: ActionButton(
          text: 'Back to Rewards',
          onPressed: () async {
            if (isRouteNameInStack(context, RewardsRoute.name)) {
              if (Get.isRegistered<RewardsController>()) {
                Get.find<RewardsController>().getRewardsBalance();
                Get.find<RewardsController>().getPendingRedemption();
              }
            }

            AutoRouter.of(context).popForced();
            AutoRouter.of(context).navigate(
              RewardsRoute(
                fromScreen: 'rewards_success_screen',
              ),
            );
          },
        ),
      ),
    );
  }
}
