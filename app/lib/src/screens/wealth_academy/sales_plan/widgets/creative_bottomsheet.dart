import 'package:app/src/config/constants/color_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/wealth_academy/sales_plan/widgets/video_player.dart';
import 'package:app/src/widgets/button/action_button.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/modules/app_resources/models/creatives_model.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';

class CreativeBottomSheet extends StatefulWidget {
  final Function? moveToNextCarousel;
  final Function? moveToPrevCarousel;
  final PageController? pageController;
  final List<CreativeNewModel> creatives;
  final bool showControls;

  CreativeBottomSheet(
      {this.moveToNextCarousel,
      this.moveToPrevCarousel,
      this.pageController,
      required this.creatives,
      this.showControls = true});

  @override
  State<CreativeBottomSheet> createState() => _CreativeBottomSheetState();
}

class _CreativeBottomSheetState extends State<CreativeBottomSheet> {
  double factor = 1.3;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: widget.pageController,
                itemCount: widget.creatives.length,
                itemBuilder: (context, index) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setState(() {
                      currentIndex = index;
                    });
                  });
                  AdvisorVideoModel advisorVideo = AdvisorVideoModel.fromJson(
                      {"link": widget.creatives[index].url});

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildCloseIcon(context),
                      ),
                      Flexible(
                        child: Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height - 20),
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.symmetric(horizontal: 32)
                              .copyWith(top: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: widget.creatives[index].type == "video"
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: VideoPlayer(
                                          advisorVideo: advisorVideo),
                                    ),
                                  ],
                                )
                              : FittedBox(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                          minWidth:
                                              MediaQuery.of(context).size.width,
                                          minHeight: 10,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: InteractiveViewer(
                                            maxScale: 5,
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  widget.creatives[index].url ??
                                                      '',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(bottom: 32),
                        child: Column(
                          children: [
                            if (widget.showControls)
                              _buildCarouselControls(context),
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ).copyWith(top: 18),
                              child: Text(
                                widget.creatives[index].title ?? '',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: ColorConstants.black,
                                    ),
                              ),
                            ),
                            SizedBox(height: 4),
                            if (widget
                                .creatives[index].description.isNotNullOrEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  widget.creatives[index].description ?? '',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .titleMedium!
                                      .copyWith(
                                          color: ColorConstants.tertiaryBlack),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            // height: 50,
            // alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: widget.creatives[currentIndex].type == "image"
                ? _buildShareCreative(
                    creativeUrl: widget.creatives[currentIndex].url ?? '',
                  )
                : _buildShareCreative(
                    creativeUrl: widget.creatives[currentIndex].url ?? '',
                    disableDownload: true,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseIcon(BuildContext context) {
    return InkWell(
      onTap: () {
        AutoRouter.of(context).popForced();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          alignment: Alignment.topRight,
          height: 32,
          width: 32,
          margin: EdgeInsets.only(right: 10, top: 10),
          decoration: BoxDecoration(
            color: ColorConstants.darkScaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              if (widget.moveToPrevCarousel != null) {
                widget.moveToPrevCarousel!();
              }
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${currentIndex + 1}/${widget.creatives.length}',
              style: Theme.of(context).primaryTextTheme.titleMedium!.copyWith(
                    color: ColorConstants.tertiaryBlack,
                  ),
            ),
          ),
          InkWell(
            onTap: () {
              if (widget.moveToNextCarousel != null) {
                widget.moveToNextCarousel!();
              }
            },
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstants.secondaryAppColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ColorConstants.primaryAppColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShareCreative({
    required String creativeUrl,
    bool isDisabled = false,
    bool disableDownload = false,
  }) {
    return ActionButton(
      margin: EdgeInsets.zero,
      text: 'Share',
      isDisabled: isDisabled,
      onPressed: () async {
        await shareImage(
          context: context,
          creativeUrl: creativeUrl,
          disableDownload: disableDownload,
        );
      },
    );
    ;
  }
}
