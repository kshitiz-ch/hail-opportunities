import 'package:youtube_player_iframe/youtube_player_iframe.dart';
// import 'package:youtube_plyr_iframe/youtube_plyr_iframe.dart';

extension VideoEx on String {
  String get youtubeThumbnailUrl {
    return YoutubePlayerController.getThumbnail(
      videoId: YoutubePlayerController.convertUrlToId(this)!,
    );
  }
}
