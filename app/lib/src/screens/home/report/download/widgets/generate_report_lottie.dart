import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/controllers/home/report_controller.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class GenerateReportLottie extends StatefulWidget {
  const GenerateReportLottie({Key? key}) : super(key: key);

  @override
  State<GenerateReportLottie> createState() => _GenerateReportLottieState();
}

class _GenerateReportLottieState extends State<GenerateReportLottie>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late LottieComposition composition;

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
    return GetBuilder<ReportController>(
      id: GetxId.form,
      builder: (controller) {
        if ((controller.createReport.state == NetworkState.error ||
                controller.createReport.state == NetworkState.loaded) &&
            _lottieController.isAnimating) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _lottieController.reset();
          });
        } else if (controller.createReport.state == NetworkState.loading &&
            !_lottieController.isAnimating &&
            _lottieController.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            // _lottieController
            //   ..duration = composition.duration
            //   ..forward();
            _lottieController.repeat();
          });
        }
        return Padding(
          padding: EdgeInsets.only(bottom: 30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: Container(
                      height: 180,
                      child: OverflowBox(
                        minHeight: 230,
                        maxHeight: 230,
                        child: Lottie.asset(
                          AllImages().generateReportLottie,
                          controller: _lottieController,
                          onLoaded: (composition) {
                            composition = composition;
                            _lottieController
                              ..duration = composition.duration
                              ..forward();
                            _lottieController.repeat();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 24),
                if (controller.createReport.state == NetworkState.error)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: RetryWidget(
                      controller.createReport.message,
                      onPressed: () {
                        controller.createClientReport();
                      },
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      controller.createReport.state == NetworkState.loaded
                          ? 'Report Generated!'
                          : 'Generating Report',
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
        );
      },
    );
  }
}
