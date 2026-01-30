import 'package:core/modules/common/resources/wealthy_cast.dart';

class BrandingModel {
  String? status;
  String? brandingLogoKey;
  String? businessNumber;
  String? businessWhatsappNumber;
  String? location;
  String? customDomain;
  DateTime? publishedAt;
  String? defaultLanguage;
  String? language;
  String? brandName;
  String? tagLine;
  String? profileBio;
  String? address;
  String? city;
  String? metadata;
  String? previewUrlDraft;
  String? previewUrlPublished;
  String? brandingLogoUrl;
  String? profilePictureUrl;

  BrandingModel.fromJson(Map<String, dynamic> json) {
    status = WealthyCast.toStr(json['status']);
    brandingLogoKey = WealthyCast.toStr(json['branding_logo_key']);
    businessNumber = WealthyCast.toStr(json['business_number']);
    businessWhatsappNumber =
        WealthyCast.toStr(json['business_whatsapp_number']);
    location = WealthyCast.toStr(json['location']);
    customDomain = WealthyCast.toStr(json['custom_domain']);
    publishedAt = WealthyCast.toDate(json['published_at']);
    defaultLanguage = WealthyCast.toStr(json['default_language']);
    language = WealthyCast.toStr(json['language']);
    brandName = WealthyCast.toStr(json['brand_name']);
    tagLine = WealthyCast.toStr(json['tag_line']);
    profileBio = WealthyCast.toStr(json['profile_bio']);
    address = WealthyCast.toStr(json['address']);
    city = WealthyCast.toStr(json['city']);
    metadata = WealthyCast.toStr(json['metadata']);
    previewUrlDraft = WealthyCast.toStr(json['preview_url_draft']);
    previewUrlPublished = WealthyCast.toStr(json['preview_url_published']);
    brandingLogoUrl = WealthyCast.toStr(json['branding_logo_url']);
    profilePictureUrl = WealthyCast.toStr(json['profile_picture_url']);
  }
}
