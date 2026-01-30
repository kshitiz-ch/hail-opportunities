import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class DematProposalSuccessScreen extends StatefulWidget {
  const DematProposalSuccessScreen({Key? key}) : super(key: key);

  @override
  State<DematProposalSuccessScreen> createState() =>
      _DematProposalSuccessScreenState();
}

class _DematProposalSuccessScreenState extends State<DematProposalSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  initState() {
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
        body: SingleChildScrollView(
          padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      AutoRouter.of(context)
                          .popUntil(ModalRoute.withName(BaseRoute.name));
                      final NavigationController navController =
                          Get.find<NavigationController>();
                      navController.setCurrentScreen(Screens.PROPOSALS);
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: ColorConstants.tertiaryBlack,
                      ),
                    ),
                  ),
                ),
                Expanded(
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
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Proposal Link Shared\nwith Client',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .primaryTextTheme
                            .headlineMedium!
                            .copyWith(fontWeight: FontWeight.w500, height: 1.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Your Client will receive the proposal link via Whatsapp and Email',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 12,
                                  color: ColorConstants.tertiaryGrey,
                                  height: 1.4),
                        ),
                      ),
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
