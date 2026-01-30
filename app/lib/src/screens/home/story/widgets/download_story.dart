import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:story_view/controller/story_controller.dart';

class DownloadStory extends StatefulWidget {
  final String? imageUrl;
  final StoryController? storyController;

  const DownloadStory({
    Key? key,
    this.imageUrl,
    this.storyController,
  }) : super(key: key);

  @override
  State<DownloadStory> createState() => _DownloadStoryState();
}

class _DownloadStoryState extends State<DownloadStory> {
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onButtonClick();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 1)),
        child: isDownloading
            ? Container(
                width: 15,
                height: 15,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Download',
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headlineSmall!
                        .copyWith(color: Colors.white),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> onButtonClick() async {
    widget.storyController!.pause();

    PermissionStatus permissionStatus = await getStorePermissionStatus();

    if (permissionStatus.isGranted) {
      await _downloadImage();
    } else if (permissionStatus.isPermanentlyDenied) {
      openPermissionDialog(context);
    } else {
      showToast(
        context: context,
        text:
            'Please give permission to access storage / photos for downloading the document',
      );
      widget.storyController!.play();
    }
  }

  Future<void> _downloadImage() async {
    if (isDownloading) {
      return;
    }

    int _total = 0, _received = 0;

    http.StreamedResponse? _response;

    final List<int> _bytes = [];

    try {
      setState(() {
        isDownloading = true;
      });

      List splitBySlash = widget.imageUrl!.split("/");
      final storyFileName = splitBySlash[splitBySlash.length - 1];

      _response = null;

      _total = 0;

      _received = 0;

      _bytes.clear();

      _response = await http.Client().send(
        http.Request(
          'GET',
          Uri.parse(widget.imageUrl!),
        ),
      );

      _total = _response.contentLength ?? 0;

      if (_total == 0) {
        showToast(text: 'Error while downloading image');
        return;
      }

      _response.stream.listen(
        (value) {
          setState(
            () {
              _bytes.addAll(value);

              _received += value.length;

              // final downloadPercentage = (_received / _total) * 100;

              // if (downloadPercentage <= 100) {
              //   CommonUI.showMessageToast(
              //       'Downloading ${downloadPercentage.toStringAsFixed(2)}%',
              //       Colors.black);
              // }
            },
          );
        },
      ).onDone(
        () async {
          try {
            String? downloadPath = await getDownloadPath();

            final File imageFile = File('$downloadPath/$storyFileName');

            await imageFile.writeAsBytes(_bytes);

            showToast(text: 'Downloading completed');
          } catch (error) {
            showToast(text: 'Error downloading image');
          }
        },
      );
    } catch (error) {
      showToast(text: 'Error downloading image');
      return;
    } finally {
      widget.storyController!.play();
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = (await getExternalStorageDirectory())!;
      }
    } catch (err, stack) {
      LogUtil.printLog("Cannot get download folder path $err");
    }
    return directory?.path;
  }
}
