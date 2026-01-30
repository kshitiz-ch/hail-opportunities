import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LogUtil {
  /// Holds instances of logger to send log messages to the [LogPrinter].
  static Logger _logger = Logger();

  static JsonEncoder _prettyJsonEncoder = JsonEncoder.withIndent('  ');

  static void printLog(Object? message, {String tag = '!@#'}) {
    if (!kReleaseMode) {
      print('$tag: $message');
    }
  }

  /// If you are using printLog() and output is too much at once,
  /// then Android sometimes discards some log lines.
  /// To avoid this, use debugPrintLog().
  static void debugPrintLog(String message, {String tag = '!@#'}) {
    if (!kReleaseMode) {
      debugPrint('$tag: $message');
    }
  }

  static void printLogger(
      {String tag = '!@#', String message = '', bool isJson = false}) {
    if (!kReleaseMode) {
      isJson
          ? printPrettyJsonString(tag: tag, jsonString: message)
          : _logger.d('$tag: $message');
    }
  }

  /// converts raw json string to human readable with proper indentation
  /// and new line
  ///
  /// {"data":"","error":""} to
  ///
  /// {
  ///  "data": "",
  ///  "error": ""
  /// }
  ///
  static String? prettyString(String? jsonString) {
    if (jsonString == null) return null;
    try {
      return _prettyJsonEncoder.convert(json.decode(jsonString));
    } catch (e) {
      return "Unable to parse\n $e";
    }
  }

  /// print json string in human readable
  /// [info] optional prefix of output json
  static void printPrettyJsonString({String? jsonString, String tag = '!@#'}) {
    _logger.d('${tag}\n${prettyString(jsonString)}');
  }

  static void printBigLog({String tag = '!@#', String message = ''}) {
    if (!kReleaseMode) {
      final pattern = RegExp('.{1,800}'); //Setting 800 as size of each chunk
      pattern.allMatches(message).forEach((element) {
        print(element.group(0));
      });
    }
  }
}
