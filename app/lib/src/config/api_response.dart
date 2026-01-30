import 'package:app/src/config/constants/enums.dart';

class ApiResponse {
  NetworkState state;
  String message;

  ApiResponse({this.state = NetworkState.cancel, this.message = ''});

  bool get isLoading => state == NetworkState.loading;
  bool get isError => state == NetworkState.error;
  bool get isLoaded => state == NetworkState.loaded;
}
