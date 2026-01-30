import 'package:api_sdk/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:core/modules/authentication/auth.dart';
export 'package:core/modules/authentication/bloc/bloc_controller.dart';
export 'package:core/modules/clients/models/client_list_model.dart';
export 'package:core/modules/dashboard/models/agent_delete_request_model.dart';
export 'package:core/modules/notifications/models/notfications_incoming_model.dart';
export 'package:core/modules/notifications/models/notifications_model.dart';
export 'package:core/modules/onboarding/models/signup_model.dart';

Future<SharedPreferences> prefs = SharedPreferences.getInstance();

void getURLFlavourConstants({
  required String url,
  required String graphqlUrl,
  required String taxyUrl,
  required String quinjetUrl,
  required String certifiedBaseUrl,
  required String fundsApiUrl,
  required String apiClientCertificate,
  required String apiClientCertificateKey,
  required bool isProd,
}) {
  ApiConstants().baseUrl = url;
  ApiConstants().graphqlUrl = graphqlUrl;
  ApiConstants().baseUrlTaxy = taxyUrl;
  ApiConstants().certifiedBaseUrl = certifiedBaseUrl;
  ApiConstants().apiClientCertificate = apiClientCertificate;
  ApiConstants().apiClientCertificateKey = apiClientCertificateKey;
  ApiConstants().quinjetBaseUrl = quinjetUrl;
  ApiConstants().fundsApiBaseUrl = fundsApiUrl;
  ApiConstants().isProd = isProd;
}

String getWebSocketUrl(String url) {
  return url;
}
