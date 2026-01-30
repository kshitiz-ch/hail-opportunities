class RestApiResponse {
  int? status;
  String? message;
  dynamic data;

  RestApiResponse({this.status, this.message, this.data});
}
