import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class SalesPlanUnboxScreen extends StatefulWidget {
  const SalesPlanUnboxScreen({Key? key}) : super(key: key);

  @override
  State<SalesPlanUnboxScreen> createState() => _SalesPlanUnboxScreenState();
}

class _SalesPlanUnboxScreenState extends State<SalesPlanUnboxScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late SharedPreferences sharedPreferences;

  @override
  initState() {
    initSharedPreference();
    _lottieController = AnimationController(vsync: this);

    super.initState();
  }

  void initSharedPreference() async {
    sharedPreferences = await prefs;
    sharedPreferences.setBool(
        SharedPreferencesKeys.isSalesPlanScreenViewed, true);
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
        backgroundColor: ColorConstants.primaryAppv2Color,
        body: Container(
          color: ColorConstants.primaryAppv2Color,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Lottie.asset(
            AllImages().salesPlanUnboxLottie,
            controller: _lottieController,
            onLoaded: (composition) {
              _lottieController
                ..duration = composition.duration
                ..forward().whenComplete(
                  () {
                    Get.find<NavigationController>()
                        .enableShowSalesPlanOnMoreScreen();

                    AutoRouter.of(context)
                        .popUntil(ModalRoute.withName(BaseRoute.name));
                    AutoRouter.of(context).push(SalesPlanRoute());
                  },
                );
            },
          ),
        ),
      ),
    );
  }
}
