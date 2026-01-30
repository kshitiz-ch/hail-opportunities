import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/store/fixed_deposit/fixed_deposits_controller.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/fd_advantage.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/fd_banner_section.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/fd_products.dart';
import 'package:app/src/screens/store/fixed_deposit_list/widgets/product_video_section.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/store/models/fixed_deposit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

@RoutePage()
class FixedDepositListScreen extends StatefulWidget {
  final List<FixedDepositModel>? products;
  final Client? client;
  final String? defaultProviderId;

  FixedDepositListScreen({this.products, this.client, this.defaultProviderId});

  @override
  State<FixedDepositListScreen> createState() => _FixedDepositListScreenState();
}

class _FixedDepositListScreenState extends State<FixedDepositListScreen> {
  final graphKey = GlobalKey();

  final ScrollController scrollController = ScrollController();
  double _scrollPosition = 0;
  bool showScrollAppBar = false;

  late FixedDepositsController fixedDepositsController;
  late YoutubePlayerController youtubePlayerController;

  void _scrollListener() {
    if (this.mounted) {
      _scrollPosition = scrollController.position.pixels;
      if (showScrollAppBar && _scrollPosition == 0) {
        showScrollAppBar = false;
        setState(() {});
      }
      if (!showScrollAppBar && _scrollPosition > 0) {
        showScrollAppBar = true;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    fixedDepositsController = Get.put<FixedDepositsController>(
        FixedDepositsController(widget.defaultProviderId));
    youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        // use 'https://www.youtube-nocookie.com'
        // temp fix https://github.com/sarbagyastha/youtube_player_flutter/issues/1112
        showControls: true,
        showFullscreenButton: true,
        loop: false,
        strictRelatedVideos: true,
        showVideoAnnotations: false,
      ),
    );
    scrollController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    if (youtubePlayerController != null) {
      youtubePlayerController.close();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: youtubePlayerController,
      builder: (context, player) {
        return Scaffold(
          backgroundColor: ColorConstants.primaryScaffoldBackgroundColor,
          body: GetBuilder<FixedDepositsController>(
            // initState: (_) {
            //   if (Get.isRegistered()) {

            //   }
            // },
            dispose: (_) => Get.delete<FixedDepositsController>(),
            builder: (controller) {
              if (controller.fdsState == NetworkState.error) {
                return Center(
                  child: RetryWidget(
                    controller.fdsErrorMessage,
                    onPressed: () {
                      controller.onReady();
                    },
                  ),
                );
              }
              // show fd list screen only when all api dependencies are over
              if (controller.isScreenLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Padding(
                padding: EdgeInsets.only(
                  top: getSafeTopPadding(50, context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(),

                    // Banner Section
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        controller: scrollController,
                        physics: ClampingScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: FDBannerSection(),
                          ), // Available Products Section
                          FDProducts(widgetKey: graphKey),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30)
                                .copyWith(top: 32),
                            child: Text(
                              'Why Fixed Deposit?',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .headlineMedium!
                                  .copyWith(
                                    color: ColorConstants.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30)
                                .copyWith(top: 4),
                            child: Text(
                              'Offers a safe and secure investment option for risk averse investors',
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: ColorConstants.tertiaryBlack,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          //  Video Section
                          ProductVideoSection(
                            youtubePlayerController: youtubePlayerController,
                            scrollController: scrollController,
                            advisorVideo: controller.productVideo,
                            player: player,
                            productType: ProductVideosType.FIXED_DEPOSIT,
                          ),
                          // FD Advantages Section
                          FDAdvantage(),
                          //Landing icon
                          SafeArea(
                            child: Container(
                              margin: const EdgeInsets.only(top: 48),
                              width: SizeConfig().screenWidth,
                              child: AspectRatio(
                                aspectRatio: 18 / 17,
                                child: Image.asset(
                                  AllImages().fdHomeLandingIcon,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBackButton(context),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fixed Deposit',
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: ColorConstants.black,
                        ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                child: Text(
                  'Invest money Wisely',
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall!
                      .copyWith(
                        color: ColorConstants.tertiaryBlack,
                        letterSpacing: 1,
                      ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 20),
          child: Image.asset(
            AllImages().fdIcon,
            alignment: Alignment.topRight,
            height: 80,
            width: 80,
          ),
        )
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: () {
          AutoRouter.of(context).popForced();
        },
        child: Image.asset(
          AllImages().appBackIcon,
          height: 32,
          width: 32,
        ),
      ),
    );
  }
}
