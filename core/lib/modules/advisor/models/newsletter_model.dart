import 'package:collection/collection.dart';
import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';

class NewsLetterModel {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? metaAuthor;
  String? title;
  String? subTitle;
  String? description;
  String? slug;
  String? iconUrl;
  bool? isPublished;
  bool? isDraft;
  DateTime? publishedAt;
  DateTime? lastRevisionAt;
  int? readTime;
  String? contentType;
  String? imageUrl;
  String? publisherCode;
  int? score;
  String? htmlContent;

  String? get parsedHtmlContent {
    // without inline style for p & span
    var htmlData = HtmlUnescape().convert(htmlContent ?? '');
    var document = parse(htmlData);
    int count = 0;

    document.querySelectorAll('p, span').forEach((element) {
      count += 1;

      // keep bold font-weight & remove other style attributes
      // to allow custom styling
      if (element.attributes.containsKey('style')) {
        final styleAttributes = element.attributes['style']?.split(';') ?? [];
        final boldFontWeight = styleAttributes.firstWhereOrNull(
          (attribute) =>
              attribute.contains('font-weight') && attribute.contains('bold'),
        );
        if (boldFontWeight.isNullOrEmpty) {
          element.attributes.remove('style');
        } else {
          element.attributes.update('style', (value) => boldFontWeight ?? '');
        }
      }

      // remove empty paragraph causing spacing issue
      if (element.text.isNullOrEmpty && element.localName == 'p') {
        final hasOnlySpanNodes = element.children.every((element2) {
          final isSpanNode = element2.localName == 'span';
          // fix <span><img></span>
          final hasOnlySpanChilds = element2.children
              .every((element3) => element3.localName == 'span');
          return isSpanNode && hasOnlySpanChilds;
        });

        if (hasOnlySpanNodes) {
          element.remove();
        }
      }
    });

    document.querySelectorAll('a').forEach((element) {
      // remove style attribute as it may have text decoration none inline styling
      element.attributes.removeWhere((key, value) => key == 'style');
    });

    if (count == 0) {
      // fix plane text no tag issue
      htmlData = '<p>' + htmlData + '</p>';
      return htmlData;
    } else {
      htmlData = document.outerHtml;
    }

    // remove multiple br tag causing spacing issue
    htmlData = htmlData
        .replaceAll("<br><br><br>", '<br>')
        .replaceAll("<br><br>", '<br>');

    return htmlData;
  }

  NewsLetterModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toInt(json['id']);
    createdAt = WealthyCast.toDate(json['created_at']);
    updatedAt = WealthyCast.toDate(json['updated_at']);
    metaAuthor = WealthyCast.toStr(json['meta_author']);
    title = WealthyCast.toStr(json['title']);
    subTitle = WealthyCast.toStr(json['sub_title']);
    description = WealthyCast.toStr(json['description']);
    slug = WealthyCast.toStr(json['slug']);
    iconUrl = WealthyCast.toStr(json['icon_url']);
    isPublished = WealthyCast.toBool(json['is_published']);
    isDraft = WealthyCast.toBool(json['is_draft']);
    publishedAt = WealthyCast.toDate(json['published_at']);
    lastRevisionAt = WealthyCast.toDate(json['last_revision_at']);
    readTime = WealthyCast.toInt(json['read_time']);
    contentType = WealthyCast.toStr(json['content_type']);
    imageUrl = WealthyCast.toStr(json['image_url']);
    publisherCode = WealthyCast.toStr(json['publisher_code']);
    score = WealthyCast.toInt(json['score']);
    htmlContent = WealthyCast.toStr(json['html_content']);
  }
}
