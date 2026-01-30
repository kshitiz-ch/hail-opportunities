import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/screens/clients/reports/widgets/downloaded_report_bottomsheet.dart';
import 'package:app/src/widgets/misc/common_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
class DownloadController extends GetxController {
  RxBool isFileDownloading = false.obs;
  final ReceivePort receivePort = ReceivePort();

  String downloadUrl = '';
  File? docFile;

  String fileName = '';
  bool shouldOpenDownloadBottomSheet = false;
  final bool authorizationRequired;

  void Function()? shareFileAnalyticFn;
  void Function()? viewFileAnalyticFn;

  DownloadController({
    this.shouldOpenDownloadBottomSheet = false,
    this.authorizationRequired = false,
  });

  void onInit() {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback, step: 1);
    super.onInit();
  }

  @override
  void dispose() {
    receivePort.close();
    _unbindBackgroundIsolate();
    Isolate.current.kill();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    receivePort.listen((message) async {
      int? progress;
      try {
        if (message[2] != null && message[2] >= 0) {
          progress = message[2];
        }
      } catch (e) {
        LogUtil.printLog('errror====>');
      }
      LogUtil.printLog('message==>$message');

      DownloadTaskStatus status = DownloadTaskStatus.fromInt(message[1]);
      if (status == DownloadTaskStatus.running) {
        showToast(
          text: 'Downloading ${progress != null ? '$progress%' : ''}...',
          duration: Duration(seconds: 1),
        );
      } else if (status == DownloadTaskStatus.complete) {
        updateFileDownloadingStatus(false);
        if (shouldOpenDownloadBottomSheet) {
          onDownloadCompleted(message[0]);
        } else {
          await FlutterDownloader.open(taskId: message[0]);
        }
      } else if (status == DownloadTaskStatus.failed) {
        updateFileDownloadingStatus(false);
        if (authorizationRequired) {
          // TODO: handle launch url with headers
          // launch url package not working
          showToast(text: 'Downloading failed');
        } else {
          launch(downloadUrl);
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    LogUtil.printLog(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  void downloadFile({
    required String url,
    required String filename,
    required String extension,
    String? customLaunchUrl,
    Function()? shareFileAnalyticFn,
    Function()? viewFileAnalyticFn,
  }) async {
    shareFileAnalyticFn = shareFileAnalyticFn;
    viewFileAnalyticFn = viewFileAnalyticFn;

    // handle rage clicking
    if (isFileDownloading.value == true) {
      showToast(
          text: 'A download is already in progress. Please try after sometime');
      return;
    }
    fileName = filename;
    downloadUrl = url;
    isFileDownloading.value = true;
    update();

    PermissionStatus storageStatus = await getStorePermissionStatus();

    if (storageStatus.isGranted) {
      try {
        final downloadDirectory = (await getDownloadPath())!;

        // remove invalid characters for file creation
        filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '-');

        // fixed Create a file using java.io API failed
        // for long file names or having special characters
        if (filename.length > 20) {
          filename = filename.substring(0, 20);
        }
        final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
        final dateTimeFileName =
            filename.toString().replaceAll(extension, '') + date + extension;
        docFile = File('${downloadDirectory}/$dateTimeFileName');
        Map<String, String> headers = {};
        if (authorizationRequired) {
          final apiKey = await getApiKey();
          headers = {'Authorization': apiKey!};
        }

        await FlutterDownloader.enqueue(
          timeout: getDownloaderTimeoutDuration(),
          headers: headers,
          url: url,
          savedDir: downloadDirectory,
          fileName: dateTimeFileName,
          showNotification: true,
          openFileFromNotification: true,
        );
      } catch (error) {
        updateFileDownloadingStatus(false);
        if (authorizationRequired) {
          // TODO: handle launch url with headers
          // launch url package not working
          showToast(text: 'Downloading failed');
        } else {
          launch(customLaunchUrl ?? downloadUrl);
        }
      }
    } else {
      updateFileDownloadingStatus(false);
      if (authorizationRequired) {
        showToast(text: "Please enable storage permission");
        // TODO: handle launch url with headers
        // launch url package not working
      } else {
        launch(customLaunchUrl ?? downloadUrl);
      }
    }
  }

  void updateFileDownloadingStatus(bool value) {
    if (value != isFileDownloading.value) {
      isFileDownloading.value = value;
      update();
    }
  }

  void onDownloadCompleted(String taskId) async {
    await CommonUI.showBottomSheet(
      getGlobalContext(),
      child: DownloadedReportBottomSheet(
        onShare: () async {
          try {
            if (shareFileAnalyticFn != null) {
              shareFileAnalyticFn!();
            }
            await shareFiles(docFile?.path ?? '');
          } catch (error) {
            LogUtil.printLog("Failed to share. Please try after some time");
          }
        },
        onView: () async {
          if (viewFileAnalyticFn != null) {
            viewFileAnalyticFn!();
          }
          await FlutterDownloader.open(taskId: taskId);
        },
        reportName: fileName,
      ),
    );
  }

  void downloadFileViaDio({
    required String url,
    required String filename,
    required String extension,
    String? customLaunchUrl,
    Function()? shareFileAnalyticFn,
    Function()? viewFileAnalyticFn,
    bool addTimeStamp = true,
  }) async {
    this.shareFileAnalyticFn = shareFileAnalyticFn;
    this.viewFileAnalyticFn = viewFileAnalyticFn;

    // handle rage clicking
    if (isFileDownloading.value == true) {
      showToast(
          text: 'A download is already in progress. Please try after sometime');
      return;
    }
    fileName = filename;
    downloadUrl = url;
    isFileDownloading.value = true;
    update();

    PermissionStatus storageStatus = await getStorePermissionStatus();

    if (storageStatus.isGranted) {
      try {
        final downloadDirectory = (await getDownloadPath())!;

        // remove invalid characters for file creation
        if (filename.contains('/')) {
          filename = filename.replaceAll('/', '-');
        }

        String realFileName = '';

        if (addTimeStamp) {
          // Append timestamp to filename
          final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
          realFileName =
              filename.toString().replaceAll(extension, '') + date + extension;
        } else {
          // Use original filename without timestamp
          realFileName = filename + extension;
        }

        docFile = File('${downloadDirectory}/$realFileName');

        // Delete existing file if it exists
        if (docFile!.existsSync()) {
          await docFile!.delete();
        }

        // Initialize Dio
        final dio = Dio();

        // Set up headers if authorization is required
        Map<String, String> headers = {};
        if (authorizationRequired) {
          final apiKey = await getApiKey();
          headers = {'Authorization': apiKey!};
        }

        // Configure Dio options
        dio.options.headers.addAll(headers);

        // Start download with progress tracking
        await dio.download(
          url,
          docFile!.path,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = ((received / total) * 100).round();
              showToast(
                text: 'Downloading $progress%...',
                duration: Duration(seconds: 1),
              );
            } else {
              showToast(
                text: 'Downloading...',
                duration: Duration(seconds: 1),
              );
            }
          },
        );

        // Download completed successfully
        updateFileDownloadingStatus(false);
        if (shouldOpenDownloadBottomSheet) {
          onDownloadCompletedViaDio();
        } else {
          // Open the file directly
          await openFile(docFile!.path);
        }
      } catch (error) {
        LogUtil.printLog('Download failed: $error');
        updateFileDownloadingStatus(false);
        if (authorizationRequired) {
          // TODO: handle launch url with headers
          // launch url package not working
          showToast(text: 'Downloading failed');
        } else {
          launch(customLaunchUrl ?? downloadUrl);
        }
      }
    } else {
      updateFileDownloadingStatus(false);
      if (authorizationRequired) {
        showToast(text: "Please enable storage permission");
        // TODO: handle launch url with headers
        // launch url package not working
      } else {
        launch(customLaunchUrl ?? downloadUrl);
      }
    }
  }

  void onDownloadCompletedViaDio() async {
    await CommonUI.showBottomSheet(
      getGlobalContext(),
      child: DownloadedReportBottomSheet(
        onShare: () async {
          try {
            if (shareFileAnalyticFn != null) {
              shareFileAnalyticFn!();
            }
            await shareFiles(docFile?.path ?? '');
          } catch (error) {
            LogUtil.printLog("Failed to share. Please try after some time");
          }
        },
        onView: () async {
          if (viewFileAnalyticFn != null) {
            viewFileAnalyticFn!();
          }
          await openFile(docFile!.path);
        },
        reportName: fileName,
      ),
    );
  }
}

Future<void> openFile(String filePath) async {
  try {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      LogUtil.printLog('Failed to open file: ${result.message}');
      showToast(text: 'Failed to open file: ${result.message}');
    }
  } catch (error) {
    LogUtil.printLog('Failed to open file: $error');
    showToast(text: 'Failed to open file');
  }
}
