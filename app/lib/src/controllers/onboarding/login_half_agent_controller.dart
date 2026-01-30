import 'package:app/src/config/api_response.dart';
import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/routes/router.gr.dart';
import 'package:app/src/config/constants/string_constants.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/main.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:get/get.dart';

class LoginHalfAgentController extends GetxController {
  ApiResponse accessTokenResponse = ApiResponse();

  String? authCode;
  String accessToken = '';
  int agentId = 0;

  bool isNavigatingToBaseScreen = false;

  LoginHalfAgentController({this.authCode});

  void onInit() {
    getHalfAgentAccessToken();
    super.onInit();
  }

  Future<dynamic> getHalfAgentAccessToken() async {
    accessTokenResponse.state = NetworkState.loading;
    update();

    try {
      Map<String, dynamic> payload = {
        "auth_code": authCode,
        "client_id": getClientIdForHalfAgent()
      };

      var response =
          await AuthenticationRepository().getHalfAgentAccessToken(payload);

      if (response['status'] == '200') {
        var data = response["response"];
        if (data != null && data["access_token"] != null) {
          agentId = WealthyCast.toInt(data["id"]) ?? 0;
          accessToken = WealthyCast.toStr(data["access_token"]) ?? '';
          accessTokenResponse.state = NetworkState.loaded;
        } else {
          accessTokenResponse.state = NetworkState.error;
        }
      } else {
        accessTokenResponse.state = NetworkState.error;
      }
    } catch (error) {
      accessTokenResponse.state = NetworkState.error;
    } finally {
      update();
      if (accessTokenResponse.state == NetworkState.loaded) {
        AuthenticationBlocController()
            .authenticationBloc
            .add(LoginHalfAgent(apiKey: accessToken, agentId: agentId));
      }
    }
  }

  void navigateToBaseScreen(context) async {
    await Future.delayed(Duration(seconds: 2));
    AutoRouter.of(context).popUntilRouteWithName(SplashRoute.name);
    AutoRouter.of(context).push(BaseRoute());
  }
}
