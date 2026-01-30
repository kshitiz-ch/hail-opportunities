import 'package:api_sdk/rest/api_helpers/certified_api_base_helper.dart';

class CertifiedRestApiHandlerData {
  final String certificate;
  final String certificateKey;
  CertifiedRestApiHandlerData({
    required this.certificate,
    required this.certificateKey,
  }) {
    _certifiedApiBaseHelper =
        CertifiedApiBaseHelper(certificate, certificateKey);
  }
  late CertifiedApiBaseHelper _certifiedApiBaseHelper;

  getData(String path, dynamic headers, {bool isUTF8 = false}) async {
    final response =
        await _certifiedApiBaseHelper.get('$path', headers, isUTF8: isUTF8);
    return response;
  }

  postData(String path, dynamic body, dynamic headers) async {
    final response = await _certifiedApiBaseHelper.post('$path', body, headers);
    return response;
  }

  putData(String path, dynamic body, dynamic headers) async {
    final response = await _certifiedApiBaseHelper.put('$path', body, headers);
    return response;
  }
}
