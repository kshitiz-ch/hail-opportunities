import 'package:flutter/material.dart';

class FallBackAvatar extends StatefulWidget {
  final AssetImage image;
  final String initials;
  final TextStyle textStyle;
  final Color circleBackground;

  FallBackAvatar(
      {required this.image,
      required this.initials,
      required this.circleBackground,
      required this.textStyle});

  @override
  _FallBackAvatarState createState() => _FallBackAvatarState();
}

class _FallBackAvatarState extends State<FallBackAvatar> {
  bool _checkLoading = true;

  @override
  initState() {
    super.initState();
    // Add listeners to this class
    ImageStreamListener listener =
        ImageStreamListener(_setImage, onError: _setError);

    widget.image.resolve(ImageConfiguration()).addListener(listener);
  }

  void _setImage(ImageInfo image, bool sync) {
    setState(() => _checkLoading = false);
  }

  void _setError(dynamic dyn, StackTrace? st) {
    setState(() => _checkLoading = true);
    dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _checkLoading == true
        ? new CircleAvatar(
            backgroundColor: widget.circleBackground,
            child: new Text(widget.initials, style: widget.textStyle))
        : new CircleAvatar(
            backgroundImage: widget.image,
            backgroundColor: widget.circleBackground,
          );
  }
}
// String getInitials(String name) {
//   List<String> names = name.split(" ");

//   String initials = "";
//   int numWords = 2;

//   if (numWords < names.length) {
//     numWords = names.length;
//   }

//   for (var i = 0; i < numWords; i++) {
//     initials += '${names[i][0]}';
//   }
//   return initials;
// }
