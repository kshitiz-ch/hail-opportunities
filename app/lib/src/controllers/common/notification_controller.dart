import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:app/src/controllers/common/common_controller.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:core/modules/notifications/models/notification_count_model.dart';
import 'package:core/modules/notifications/models/notification_ui_model.dart';
import 'package:core/modules/notifications/resources/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' show parse;
import 'package:web_socket_channel/web_socket_channel.dart';

class NotificationController extends GetxController {
  //Fields
  late NotificationsRepository notificationsRepository;
  String? apiKey;
  NotificationsModel? notificationsModel;
  NotificationsCountModel? notificationsCountModel;
  late Map<String, List<NotificationModel>> notificationGroupedData;

  ApiResponse notificationsCountResponse = ApiResponse();

  ApiResponse notificationsDataResponse = ApiResponse();
  MetaDataModel notificationsMetaData = MetaDataModel();

  ApiResponse notificationDescriptionHtmlResponse = ApiResponse();
  String? descriptionHtml;

  List<DataNotificationModel> notifications = [];

  bool isPaginating = false;

  late WebSocketChannel channel;

  ScrollController scrollController = ScrollController();

  NotificationController() {
    notificationsDataResponse.state = NetworkState.loading;
    notificationsCountResponse.state = NetworkState.loading;
    notificationsRepository = NotificationsRepository();
    notificationGroupedData = {
      'Recent': <NotificationModel>[],
      'Earlier': <NotificationModel>[]
    };
  }

  @override
  Future<void> onInit() async {
    scrollController.addListener(handlePagination);
    apiKey = await getApiKey();
    getNotificationUnReadCount();
    // await getNotificationCountData();
    // setNotificationWebSocket();
    super.onInit();
  }

  @override
  void onReady() {
    super.onInit();
  }

  Future<void> getNotifications({bool isTokenRegenerated = false}) async {
    // If not paginating then reset existing notifications list
    if (!isPaginating) {
      notifications.clear();
      notificationsMetaData = MetaDataModel();
    }

    try {
      notificationsDataResponse.state = NetworkState.loading;
      update([GetxId.notificationData]);

      String userToken = await getAgentCommunicationToken() ?? "";

      int offset = notificationsMetaData.page * notificationsMetaData.limit;

      final data = await notificationsRepository.getNotifications(
        userToken,
        screenLocation: "bell-icon",
        limit: notificationsMetaData.limit,
        offset: offset,
      );

      if (data['status'] == '200') {
        notificationsMetaData.totalCount = data["response"]["total_count"] ?? 0;
        WealthyCast.toList(data["response"]["notifications"]).forEach((x) {
          DataNotificationModel notification =
              DataNotificationModel.fromJson(x);
          final parsedData = getHeaderDescriptionAndImage(notification.summary);
          if (parsedData.isNotNullOrEmpty) {
            notification.notificationUIModel = NotificationUIModel(
              createdAt: notification.createdAt,
              headerText: parsedData[0],
              descriptionText: parsedData[1],
              imageSrc: parsedData[2],
            );
            if (notification.dnRenderType != "image") {
              notifications.add(notification);
            }
          }
          ;
        });

        // groupDataByTime();
        notificationsDataResponse.state = NetworkState.loaded;
      } else if (data['status'] == '401' && !isTokenRegenerated) {
        await CommonController.getAgentCommunicationAuthToken();
        await getNotifications(isTokenRegenerated: true);
      } else {
        notificationsDataResponse.message = getErrorMessageFromResponse(data);
        notificationsDataResponse.state = NetworkState.error;
      }
    } catch (error) {
      notificationsDataResponse.message = 'Notification Data not found.';
      notificationsDataResponse.state = NetworkState.error;
    } finally {
      isPaginating = false;

      update([GetxId.notificationData]);
    }
  }

  Future<void> dismissDataNotification(
      DataNotificationModel notification) async {
    try {
      final data = await notificationsRepository
          .dismissNotification(notification.userToken ?? "");

      if (data["status"] == "200") {}
    } catch (error) {
      print(error);
    } finally {}
  }

  Future<void> markNotificationRead(DataNotificationModel notification) async {
    try {
      final data = await notificationsRepository
          .markNotificationRead(notification.userToken ?? "");

      notification.isRead = true;
      if (data["status"] == "200") {}
    } catch (error) {
      print(error);
    } finally {
      update([GetxId.notificationData]);
    }
  }

  Future<void> getNotificationDescriptionHtml(
      DataNotificationModel notification) async {
    descriptionHtml = null;
    notificationDescriptionHtmlResponse.state = NetworkState.loading;
    update(['description']);
    try {
      final data = await notificationsRepository
          .getNotificationDescriptionHtml(notification.descriptionHtmlId ?? "");

      if (data["status"] == "200") {
        descriptionHtml = data["response"]["data"]["description_html"];
        notificationDescriptionHtmlResponse.state = NetworkState.loaded;
      } else {
        notificationDescriptionHtmlResponse.state = NetworkState.error;
      }
    } catch (error) {
      notificationDescriptionHtmlResponse.state = NetworkState.error;
    } finally {
      update(['description']);
    }
  }

  Future<void> getNotificationUnReadCount(
      {bool isTokenRegenerated = false}) async {
    try {
      String userToken = await getAgentCommunicationToken() ?? "";

      final data = await notificationsRepository.getNotificationUnReadCount(
          userToken, "bell-icon");

      if (data["status"] == "200") {
        int unreadCount = data["response"]["notification"]["unread_count"] ?? 0;
        notificationsCountModel = NotificationsCountModel(count: unreadCount);
      } else if (data["status"] == "401" && !isTokenRegenerated) {
        await CommonController.getAgentCommunicationAuthToken();
        await getNotificationUnReadCount(isTokenRegenerated: true);
      }
    } catch (error) {
      print(error);
    } finally {
      update([GetxId.notificationCount]);
    }
  }

  Future<void> resetNotificationUnReadCount() async {
    try {
      String userToken = await getAgentCommunicationToken() ?? "";

      final data = await notificationsRepository.resetNotificationUnReadCount(
          userToken, "bell-icon");

      if (data["status"] == "200") {
        notificationsCountModel = NotificationsCountModel(count: 0);
      }
    } catch (error) {
      print(error);
    } finally {
      update([GetxId.notificationCount]);
    }
  }

  handlePagination() {
    if (scrollController.hasClients) {
      bool isScrolledToBottom = scrollController.position.maxScrollExtent <=
          scrollController.position.pixels;
      bool isPagesRemaining = (notificationsMetaData.totalCount! /
              (notificationsMetaData.limit *
                  (notificationsMetaData.page + 1))) >
          1;

      if (isScrolledToBottom &&
          isPagesRemaining &&
          notificationsDataResponse.state != NetworkState.loading) {
        notificationsMetaData.page += 1;
        isPaginating = true;
        getNotifications();
      }
    }
  }

  // void setNotificationWebSocket() {
  //   try {
  //     channel = IOWebSocketChannel.connect('${F.webSocketUrl}$apiKey');
  //     channel.stream.listen((message) async {
  //       LogUtil.printLog('message received=> $message');
  //       try {
  //         final notificationsIncomingModel =
  //             NotificationsIncomingModel.fromJson(message);
  //         if (notificationsIncomingModel.eventName ==
  //             "DATA-NOTIFICATION-CREATED") {
  //           await getNotificationCountData();
  //         }
  //       } catch (error) {
  //         LogUtil.printLog(error);
  //       }
  //     });
  //   } catch (error) {
  //     LogUtil.printLog(error);
  //   }
  // }

  void getNotificationModelData() async {
    // try {
    //   getNotificationDataState = NetworkState.loading;
    //   update([GetxId.notificationData]);
    //   //clearing all the notifications
    //   notificationGroupedData = {
    //     'Recent': <NotificationModel>[],
    //     'Earlier': <NotificationModel>[]
    //   };
    //   apiKey ??= await getApiKey();

    //   await notificationsRepository.resetNotificationsCount(apiKey!);
    //   final data = await notificationsRepository.getNotifications(apiKey!);
    //   if (data['status'] == '200') {
    //     notificationsModel = NotificationsModel.fromJson(data['response']);
    //     groupDataByTime();
    //     getNotificationDataState = NetworkState.loaded;
    //   } else {
    //     getNotificationDataErrorMessage = getErrorMessageFromResponse(data);
    //     getNotificationDataState = NetworkState.error;
    //   }
    // } catch (error) {
    //   getNotificationDataErrorMessage = 'Notification Data not found.';
    //   getNotificationDataState = NetworkState.error;
    // } finally {
    //   //reset counter
    //   notificationsCountModel = null;
    //   update([GetxId.notificationData, GetxId.notificationCount]);
    // }
  }

  void groupDataByTime() {
    if (notificationsModel != null &&
        notificationsModel!.data.isNotNullOrEmpty) {
      final currentTime = DateTime.now();
      for (final item in notificationsModel!.data!) {
        if (item.summaryHtml.isNullOrEmpty) continue;
        final parsedData = getHeaderDescriptionAndImage(item.summaryHtml);
        if (parsedData.isNullOrEmpty) continue;
        final uiModel = NotificationUIModel(
          createdAt: item.createdAt,
          headerText: parsedData[0],
          descriptionText: parsedData[1],
          imageSrc: parsedData[2],
        );
        item.notificationUIModel = uiModel;
        final diff = currentTime.difference(item.createdAt ?? currentTime);
        if (diff.inDays > 0) {
          notificationGroupedData['Earlier']!.add(item);
        } else {
          notificationGroupedData['Recent']!.add(item);
        }
      }
    }
  }

  // Future<void> getNotificationCountData() async {
  //   try {
  //     notificationsCountResponse.state = NetworkState.loading;
  //     update([GetxId.notificationCount]);
  //     apiKey ??= await getApiKey();
  //     final data = await notificationsRepository.getNotificationsCount(apiKey!);
  //     if (data['status'] == '200') {
  //       notificationsCountModel =
  //           NotificationsCountModel.fromJson(data['response']);
  //       notificationsCountResponse.state = NetworkState.loaded;
  //     } else {
  //       notificationsCountResponse.message = getErrorMessageFromResponse(data);
  //       notificationsCountResponse.state = NetworkState.error;
  //     }
  //   } catch (error) {
  //     notificationsCountResponse.message = 'Notification Data not found.';
  //     notificationsCountResponse.state = NetworkState.error;
  //   } finally {
  //     update([GetxId.notificationCount]);
  //   }
  // }

  List<String?> getHeaderDescriptionAndImage(String? html) {
    try {
      var document = parse(html);
      String headerText =
          (document.querySelector('.n-header')?.text ?? '').trim();
      // Convert only the first two words to title case
      List<String> words = headerText.split(' ');
      for (int i = 0; i < words.length && i < 2; i++) {
        if (words[i].isNotEmpty) {
          words[i] = words[i].substring(0, 1).toUpperCase() +
              words[i].substring(1).toLowerCase();
        }
      }
      headerText = words.join(' ');

      String descriptionText =
          (document.querySelector('.n-description')?.text ?? '').trim();

      // Find the img tag and get its src attribute
      final imgElement = document.getElementsByTagName('img').firstOrNull;
      final imageLink = imgElement?.attributes['src'] ?? '';

      return (headerText.isNullOrEmpty && descriptionText.isNullOrEmpty)
          ? <String>[]
          : [headerText, descriptionText, imageLink];
    } catch (e) {
      return <String>[];
    }
  }
}
