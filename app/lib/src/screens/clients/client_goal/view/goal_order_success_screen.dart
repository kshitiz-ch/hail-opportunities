import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/widgets/app_bar/custom_app_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class GoalOrderSuccessScreen extends StatefulWidget {
  const GoalOrderSuccessScreen({Key? key, required this.orderType})
      : super(key: key);

  final String orderType;

  @override
  _GoalOrderSuccessScreenState createState() => _GoalOrderSuccessScreenState();
}

class _GoalOrderSuccessScreenState extends State<GoalOrderSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    _lottieController = AnimationController(vsync: this);
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
        appBar: CustomAppBar(
          showBackButton: false,
          trailingWidgets: [
            IconButton(
              onPressed: () {
                AutoRouter.of(context)
                    .popUntil(ModalRoute.withName(BaseRoute.name));
              },
              icon: Icon(
                Icons.close,
                size: 20,
                color: ColorConstants.black,
              ),
            )
          ],
        ),
        body: Container(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Center(
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
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      Text(
                        'The ${widget.orderType} Order has been successfully created\nWe have also requested for your client\'s approval.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'You can keep track the status of this order by visiting the Service Requests  section of this client',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(
                                color: ColorConstants.tertiaryBlack,
                                height: 1.5),
                      )
                    ],
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
