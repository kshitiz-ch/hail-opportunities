import 'package:app/src/widgets/card/product_video_card_new.dart';
import 'package:core/modules/dashboard/models/advisor_video_model.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ProductVideoSection extends StatefulWidget {
  final Widget player;
  final ScrollController? scrollController;
  final AdvisorVideoModel? advisorVideo;
  final YoutubePlayerController youtubePlayerController;
  final String productType;
  final bool allowHorizontalPadding;

  ProductVideoSection({
    Key? key,
    this.scrollController,
    this.advisorVideo,
    required this.player,
    required this.youtubePlayerController,
    required this.productType,
    this.allowHorizontalPadding = true,
  }) : super(key: key);

  @override
  State<ProductVideoSection> createState() => _ProductVideoSectionState();
}

class _ProductVideoSectionState extends State<ProductVideoSection> {
  bool playVideo = false;
  PlayerState? playerState;

  @override
  void initState() {
    widget.scrollController?.addListener(() {
      if (widget.scrollController!.offset <
          widget.scrollController!.position.minScrollExtent + 50) {
        if (playerState != PlayerState.playing && playVideo) {
          playVideo = false;
          if (mounted) {
            setState(() {});
          }
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        child: playVideo
            ? ProductVideoPlayer(
                youtubePlayerController: widget.youtubePlayerController,
                player: widget.player,
                advisorVideo: widget.advisorVideo,
                productType: widget.productType,
                allowHorizontalPadding: widget.allowHorizontalPadding,
                updatePlayerState: (state) {
                  playerState = state;
                },
              )
            : ProductVideoCard(
                video: widget.advisorVideo,
                productType: widget.productType,
                allowHorizontalPadding: widget.allowHorizontalPadding,
                onTap: () {
                  playVideo = true;
                  setState(() {});
                },
              ),
      ),
    );
  }
}
