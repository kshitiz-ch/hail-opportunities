import 'dart:convert';

Map<String, dynamic>? jwtDecoder(String token) {
  final splitToken = token.split("."); // Split the token by '.'
  if (splitToken.length != 3) {
    throw FormatException('Invalid token');
  }
  try {
    final payloadBase64 = splitToken[1]; // Payload is always the index 1
    // Base64 should be multiple of 4. Normalize the payload before decode it
    final normalizedPayload = base64.normalize(payloadBase64);
    // Decode payload, the result is a String
    final payloadString = utf8.decode(base64.decode(normalizedPayload));
    // Parse the String to a Map<String, dynamic>
    final decodedPayload = jsonDecode(payloadString);

    // Return the decoded payload
    return decodedPayload;
  } catch (error) {
    return null;
  }
}

/// Transforms old referral URL format to new format
///
/// Old format: https://www.wealthy.in/p/username
/// New format: https://www.wealthy.in/partners/username
///
/// Supports both wealthy.in and wealthydev.in domains
/// Works with http/https and with/without www prefix
String? transformReferralUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  // Simple and explicit replacement
  if (url.contains('wealthy.in/p/')) {
    return url.replaceAll('/p/', '/partners/');
  } else if (url.contains('wealthydev.in/p/')) {
    return url.replaceAll('/p/', '/partners/');
  }

  // Return original URL if no transformation needed
  return url;
}
