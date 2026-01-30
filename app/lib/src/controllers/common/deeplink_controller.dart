import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/controllers/common/navigation_controller.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/modules/notifications/resources/notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class DeeplinkController extends GetxController {
  ApiResponse deeplinkDataResponse = ApiResponse();

  String? ntype;
  String? aggregateId;

  PageRouteInfo? routeToNavigate;

  DeeplinkController(this.ntype, this.aggregateId);

  @override
  onInit() {
    getDeeplinkData();
    super.onInit();
  }

  Future<void> getDeeplinkData() async {
    try {
      deeplinkDataResponse.state = NetworkState.loading;
      update();

      final data =
          await NotificationsRepository().getDeeplinkData(ntype!, aggregateId!);

      if (data['status'] == '200') {
        deeplinkDataResponse.state = NetworkState.loaded;

        String deeplinkNtype = data["response"]["data"]["ntype"] ?? ntype;
        Map<String, dynamic> attributes =
            data["response"]["data"]["attributes"] ?? {};
        RemoteMessage message = RemoteMessage(
          data: {'ntype': deeplinkNtype, 'wcontext': attributes},
        );
        routeToNavigate =
            Get.find<NavigationController>().pushNotificationHandler(message);
      } else {
        deeplinkDataResponse.message = getErrorMessageFromResponse(data);
        deeplinkDataResponse.state = NetworkState.error;
      }
    } catch (error) {
      deeplinkDataResponse.state = NetworkState.error;
      deeplinkDataResponse.message = 'Notification Data not found.';
    } finally {
      update();
    }
  }
}
