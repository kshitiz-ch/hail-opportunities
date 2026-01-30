import 'dart:io';

import 'package:api_sdk/log_util.dart';
import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/image_constants.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/config/utils/function_utils.dart';
import 'package:app/src/controllers/home/home_controller.dart';
import 'package:app/src/utils/birthday_card_service.dart';
import 'package:app/src/utils/local_notification_service.dart';
import 'package:app/src/utils/size_utils.dart';
import 'package:core/modules/advisor/resources/advisor_repository.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql/client.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientBirthdaysController extends GetxController {
  ApiResponse clientBirthdaysResponse = ApiResponse();
  List<Client> clientBirthdaysList = [];

  // Filtered birthday lists
  List<Client> todaysBirthdays = [];
  List<Client> tomorrowsBirthdays = [];
  List<Client> next7DaysBirthdays = [];
  List<Client> next30DaysBirthdays = [];

  // API responses for birthday wish and branding
  ApiResponse birthdayWishResponse = ApiResponse();

  ApiResponse brandingUrlResponse = ApiResponse();
  String? brandingUrl;

  ApiResponse birthdayCardDownloadResponse = ApiResponse();

  List<String> birthdayPosterImages = [
    AllImages().birthdayPoster1,
    AllImages().birthdayPoster2,
    AllImages().birthdayPoster3,
  ];
  List<Uint8List?> createdPosters = [];
  int currentPosterIndex = 0;

  // Loading state for birthday card creation
  final RxBool isCreatingCard = false.obs;

  // Text controllers for birthday wish form
  final TextEditingController messageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Future<void> onInit() async {
    getBrandingUrl();
    getClientBirthdays();

    nameController.text =
        (Get.find<HomeController>().advisorOverviewModel?.agent?.name ??
                'Partner Name')
            .toTitleCase();

    super.onInit();
  }

  @override
  void dispose() {
    // Clear stored card bytes on dispose
    brandingUrl = null;

    // Clear birthday card service cache
    BirthdayCardService.clearCache();

    // Dispose text controllers
    messageController.dispose();
    nameController.dispose();

    super.dispose();
  }

  void onInitWishScreen(Client client) {
    messageController.clear();
    currentPosterIndex = 0;
    Future.delayed(
      const Duration(milliseconds: 200),
      () => generateBirthdayWish(client),
    );
  }

  Future<void> getClientBirthdays() async {
    clientBirthdaysResponse.state = NetworkState.loading;
    update();
    try {
      final apiKey = await getApiKey() ?? '';

      QueryResult response =
          await AdvisorRepository().getClientBirthdays(apiKey!);
      if (!response.hasException) {
        clientBirthdaysResponse.state = NetworkState.loaded;
        clientBirthdaysList =
            WealthyCast.toList(response.data!['hydra']['clientBirthdays'])
                .map((clientJson) => Client.fromJson(clientJson))
                .toList();

        // Filter birthdays by categories
        _filterBirthdaysByCategories();
      } else {
        clientBirthdaysResponse.state = NetworkState.error;
        clientBirthdaysResponse.message =
            response.exception!.graphqlErrors[0].message;
      }
    } catch (error) {
      clientBirthdaysResponse.state = NetworkState.error;
      clientBirthdaysResponse.message = genericErrorMessage;
    } finally {
      update();
    }
  }

  /// Generates a birthday wish using AI assistant for a specific client
  /// [clientName] - Name of the client to generate birthday wish for
  /// Returns the generated birthday wish text or null if failed
  Future<void> generateBirthdayWish(Client client) async {
    birthdayWishResponse.state = NetworkState.loading;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      // Create prompt with conditional DOB information
      String prompt = 'wish for ${client.name}';
      if (client.dob != null) {
        prompt += ' having Date of Birth ${client.dob!.toIso8601String()}';
      }

      final variables = {
        'input': {
          'assistantKey': AIAssistantType.birthdayWishPartnerClient.key,
          'prompt': prompt
        }
      };

      QueryResult response = await AdvisorRepository().callAiAssistant(
        apiKey!,
        variables,
      );

      if (!response.hasException) {
        final data = response.data?['callAiAssistant'];
        if (data != null) {
          birthdayWishResponse.state = NetworkState.loaded;
          final generatedWish =
              WealthyCast.toStr(data?['value']?['birthday_message']);
          messageController.text = generatedWish ?? '';
        } else {
          birthdayWishResponse.state = NetworkState.error;
          birthdayWishResponse.message = 'No data received from AI assistant';
        }
      } else {
        birthdayWishResponse.state = NetworkState.error;
        birthdayWishResponse.message =
            response.exception!.graphqlErrors[0].message;
        LogUtil.printLog(
            'Error generating birthday wish: ${response.exception!.graphqlErrors[0].message}');
      }
    } catch (error) {
      birthdayWishResponse.state = NetworkState.error;
      birthdayWishResponse.message = genericErrorMessage;
      LogUtil.printLog('Error generating birthday wish: ${error.toString()}');
    } finally {
      update();
    }
  }

  /// Gets branding configuration URL from external API
  /// [lang] - Optional language parameter
  /// [preview] - Whether to get preview version (default: true)
  /// Returns branding configuration data or null if failed
  Future<void> getBrandingUrl({String? lang, bool preview = true}) async {
    brandingUrlResponse.state = NetworkState.loading;
    brandingUrl = null;
    update();

    try {
      final apiKey = await getApiKey() ?? '';

      final response = await AdvisorRepository().getBrandingDetail(
        apiKey,
        lang: lang,
        preview: preview,
      );

      if (response != null && response['status'] == '200') {
        final newBrandingUrl =
            WealthyCast.toStr(response['response']['branding_logo_url']);

        // Clear cached image bytes if branding URL changed
        if (brandingUrl != newBrandingUrl && brandingUrl != null) {
          BirthdayCardService.clearImageFromCache(brandingUrl!);
          LogUtil.printLog('Branding URL changed, clearing cached image bytes');
        }

        brandingUrl = newBrandingUrl;
        // Only create posters if branding URL is successfully fetched
        if (brandingUrl.isNotNullOrEmpty) {
          await createBirthdayPosters();
        }
        brandingUrlResponse.state = NetworkState.loaded;
      } else {
        brandingUrlResponse.state = NetworkState.error;
        brandingUrlResponse.message = 'No branding data received';
      }

      return null;
    } catch (error) {
      brandingUrlResponse.state = NetworkState.error;
      brandingUrlResponse.message = genericErrorMessage;
      LogUtil.printLog('Error getting branding URL: ${error.toString()}');
    } finally {
      update();
    }
  }

  /// Filters the client birthdays into different categories
  void _filterBirthdaysByCategories() {
    // Create today's date at midnight (00:00:00) for consistent date-only comparisons
    final now = DateTime.now();
    final todayDateOnly = DateTime(now.year, now.month, now.day);

    // Pre-calculate all boundary dates to avoid repeated calculations
    final tomorrow = todayDateOnly.add(const Duration(days: 1));
    final next7DaysEnd = todayDateOnly.add(
        const Duration(days: 8)); // 8 days from today (7 days from tomorrow)
    final next30DaysEnd =
        todayDateOnly.add(const Duration(days: 38)); // 38 days from today

    // Clear existing lists
    todaysBirthdays.clear();
    tomorrowsBirthdays.clear();
    next7DaysBirthdays.clear();
    next30DaysBirthdays.clear();

    for (final client in clientBirthdaysList) {
      final dob = client.dob;
      if (dob == null) continue;

      // Calculate this year's birthday (date only, no time component)
      DateTime thisYearBirthday =
          DateTime(todayDateOnly.year, dob.month, dob.day);

      // If birthday has already passed this year, consider next year's birthday
      if (thisYearBirthday.isBefore(todayDateOnly)) {
        thisYearBirthday = DateTime(todayDateOnly.year + 1, dob.month, dob.day);
      }

      // Categorize based on date comparison (using DateUtils.isSameDay for accuracy)
      if (DateUtils.isSameDay(thisYearBirthday, todayDateOnly)) {
        todaysBirthdays.add(client);
      } else if (DateUtils.isSameDay(thisYearBirthday, tomorrow)) {
        tomorrowsBirthdays.add(client);
      } else if (thisYearBirthday.isAfter(tomorrow) &&
          thisYearBirthday.isBefore(next7DaysEnd)) {
        next7DaysBirthdays.add(client);
      } else if (thisYearBirthday.isAfter(next7DaysEnd) &&
          thisYearBirthday.isBefore(next30DaysEnd)) {
        next30DaysBirthdays.add(client);
      }
    }
  }

  /// Creates birthday posters for all available poster templates
  /// Uses each birthdayPosterImages as background and brandingUrl as watermark
  /// Returns a list of created poster bytes in the same order as birthdayPosterImages
  Future<void> createBirthdayPosters({
    double? width,
    double? height,
  }) async {
    createdPosters.clear();
    try {
      // Check if branding URL is available, fetch only if not available
      if (brandingUrl.isNullOrEmpty) {
        LogUtil.printLog('Branding URL not available, fetching...');
        await getBrandingUrl();

        // If still null after fetching, return without creating posters
        if (brandingUrl.isNullOrEmpty) {
          LogUtil.printLog('Failed to get branding URL for watermark');
          return;
        }
      }

      final aspectRatio = 312 / 374; // width/height
      final width = SizeConfig().screenWidth! - 50;
      final height = width / aspectRatio;

      // Create poster for each birthday poster image
      for (int i = 0; i < birthdayPosterImages.length; i++) {
        final backgroundImagePath = birthdayPosterImages[i];

        LogUtil.printLog(
            'Creating birthday poster ${i + 1}/${birthdayPosterImages.length}');

        try {
          final posterBytes = await BirthdayCardService.createBirthdayCard(
            backgroundImagePath: backgroundImagePath,
            watermarkImagePath: brandingUrl!,
            width: width,
            height: height,
          );

          createdPosters.add(posterBytes);

          if (posterBytes != null) {
            LogUtil.printLog('Successfully created poster ${i + 1}');
          } else {
            LogUtil.printLog('Failed to create poster ${i + 1}');
          }
        } catch (error) {
          LogUtil.printLog(
              'Error creating poster ${i + 1}: ${error.toString()}');
          createdPosters.add(null); // Add null to maintain index consistency
        }
      }
    } catch (error) {
      LogUtil.printLog('Error creating birthday posters: ${error.toString()}');
    }
  }

  /// Downloads a birthday card using the last created card bytes
  /// [clientName] - Client name to include in filename
  /// Returns true if download was successful, false otherwise
  /// Note: createBirthdayCard() must be called first to generate card bytes
  Future<void> downloadBirthdayCard(String clientName) async {
    try {
      birthdayCardDownloadResponse.state = NetworkState.loading;
      update();

      // Check storage permission first
      PermissionStatus permissionStatus = await getStorePermissionStatus();

      if (!permissionStatus.isGranted) {
        if (permissionStatus.isPermanentlyDenied) {
          birthdayCardDownloadResponse.message =
              'Storage permission is permanently denied. Please enable it from settings.';
        } else {
          birthdayCardDownloadResponse.message =
              'Please grant storage permission to download';
        }
        birthdayCardDownloadResponse.state = NetworkState.error;
        update();
        return;
      }

      Uint8List? posterBytes;

      if (currentPosterIndex < createdPosters.length &&
          createdPosters[currentPosterIndex] != null) {
        // Use the branded poster if available
        posterBytes = createdPosters[currentPosterIndex];
      } else {
        // Fallback to loading original poster image
        posterBytes = await BirthdayCardService.loadImageBytes(
            birthdayPosterImages[currentPosterIndex]);
      }

      if (posterBytes == null) {
        birthdayCardDownloadResponse.state = NetworkState.error;
        birthdayCardDownloadResponse.message =
            'Failed to download birthday card';
        update();
        return;
      }

      // Generate filename with timestamp
      final date = DateFormat('ddMMyyyyHHmmss').format(DateTime.now());
      final clientNameSuffix = '_${clientName.replaceAll(' ', '_')}';
      final fileName = 'birthday_card${clientNameSuffix}_$date.png';

      // Save file to device storage
      final savedFilePath = await _saveFileToDocuments(
        fileBytes: posterBytes,
        fileName: fileName,
        subfolder: 'Birthday_Cards',
      );

      if (savedFilePath != null) {
        birthdayCardDownloadResponse.state = NetworkState.loaded;
        birthdayCardDownloadResponse.message =
            'Birthday card saved successfully';

        // Show local notification with proper file path
        try {
          final notificationService = LocalNotificationService();
          await notificationService.showBirthdayCardDownloadNotification(
            clientName: clientName,
            filePath: savedFilePath,
          );

          LogUtil.printLog(
              'Birthday card download notification shown for $clientName');
        } catch (notificationError) {
          LogUtil.printLog(
              'Failed to show notification: ${notificationError.toString()}');
          // Don't fail the download if notification fails
        }
      } else {
        birthdayCardDownloadResponse.state = NetworkState.error;
        birthdayCardDownloadResponse.message = 'Failed to save birthday card';
      }
    } catch (error) {
      birthdayCardDownloadResponse.state = NetworkState.error;
      birthdayCardDownloadResponse.message = 'Failed to download birthday card';
      LogUtil.printLog('Error downloading birthday card: ${error.toString()}');
    } finally {
      update();
    }
  }

  /// Save file to device documents directory
  /// [fileBytes] - The file content as bytes
  /// [fileName] - Name of the file to save
  /// [subfolder] - Optional subfolder within documents directory
  /// Returns the saved file path if successful, null otherwise
  Future<String?> _saveFileToDocuments({
    required List<int> fileBytes,
    required String fileName,
    String? subfolder,
  }) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // On Android, try to get external storage directory first
        directory = await getExternalStorageDirectory();
        if (directory == null) {
          // Fallback to application documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // On iOS, use application documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      // Create subfolder if specified
      if (subfolder != null) {
        directory = Directory('${directory.path}/$subfolder');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }

      // Create the file
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(fileBytes);

      LogUtil.printLog('Birthday card saved successfully to: ${file.path}');
      return file.path;
    } catch (error) {
      LogUtil.printLog('Error saving birthday card file: $error');
      return null;
    }
  }
}
