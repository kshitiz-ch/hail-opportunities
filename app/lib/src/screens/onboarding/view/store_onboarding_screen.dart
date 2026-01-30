import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:app/src/screens/onboarding/widgets/flow_tutorial.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

@RoutePage()
class StoreOnboardingScreen extends StatefulWidget {
  @override
  State<StoreOnboardingScreen> createState() => _StoreOnboardingScreenState();
}

class _StoreOnboardingScreenState extends State<StoreOnboardingScreen> {
  PageController? pageController;
  int? currentPage;

  @override
  void initState() {
    pageController = PageController();
    currentPage =
        pageController!.hasClients ? (pageController?.page?.toInt() ?? 0) : 0;
    pageController!.addListener(() {
      setState(() {
        currentPage = pageController!.hasClients
            ? (pageController?.page?.toInt() ?? 0)
            : 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Color(0xffF9F6FF),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.toWidth),
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 60.0.toHeight, bottom: 7.toHeight),
                child: Align(
                  alignment: Alignment.topRight,
                  child: (currentPage! + 1) == 5
                      ? SizedBox()
                      : ClickableText(
                          text: 'Skip',
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          onClick: () {
                            AutoRouter.of(context).push(BaseRoute());
                          },
                        ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: 5,
                  itemBuilder: (_, i) {
                    return FlowTutorial(
                      index: i,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.toHeight),
                child: ((currentPage! + 1) == 5)
                    ? ActionButton(
                        text: 'Explore Products'.toUpperCase(),
                        margin: EdgeInsets.zero,
                        onPressed: () {
                          AutoRouter.of(context).push(BaseRoute());
                          final NavigationController navController =
                              Get.find<NavigationController>();
                          navController.setCurrentScreen(
                            Screens.STORE,
                            fromScreen: 'StoreOnboardingScreen',
                          );
                          //it is on the top of base screen popForced it to go to store screen
                          AutoRouter.of(context).popForced();
                        },
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            (currentPage != 1 && currentPage != 5)
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: ((currentPage! + 1) != 1 &&
                                      (currentPage! + 1) != 5)
                                  ? ClickableText(
                                      text: 'Previous',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      onClick: () {
                                        pageController!.animateToPage(
                                          currentPage! - 1,
                                          duration: Duration(milliseconds: 350),
                                          curve: Curves.ease,
                                        );
                                      },
                                    )
                                  : SizedBox(),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: ClickableText(
                                text: 'Next',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                onClick: () {
                                  if ((currentPage! + 1) < 5) {
                                    pageController!.animateToPage(
                                      currentPage! + 1,
                                      duration: Duration(milliseconds: 350),
                                      curve: Curves.ease,
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
