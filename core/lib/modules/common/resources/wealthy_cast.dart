import 'dart:convert';

import 'package:api_sdk/log_util.dart';
import 'package:intl/intl.dart';

class WealthyCast {
  /// Converts [dynamic] type to [String]
  static String? toStr(dynamic val) {
    try {
      if (val == null || (val is String && val == 'null')) {
        return null;
      }
      return val.toString();
    } on Exception catch (e) {
      LogUtil.printLog(e.toString());
      return null;
    }
  }

  /// Convert dynamic type to integer
  static int? toInt(dynamic val) {
    try {
      switch (val.runtimeType) {
        case int:
          return val.toInt();
        case String:
          return num.parse(val).toInt();
        case double:
          return val.toInt();
        default:
          return null;
      }
    } on Exception catch (e) {
      LogUtil.printLog(e.toString());
      return null;
    }
  }

  /// Convert dynamic type to double
  static double? toDouble(dynamic val) {
    try {
      switch (val.runtimeType) {
        case double:
          return val;
        case String:
          return double.parse(val);
        case int:
          return val.toDouble();
        default:
          return null;
      }
    } on Exception catch (e) {
      LogUtil.printLog(e.toString());
      return null;
    }
  }

  /// Converts [dynamic] type to [List]
  static List<T> toList<T>(dynamic val) {
    try {
      if (val is List) {
        return List<T>.from(val);
      } else if (val is String) {
        return toList(json.decode(val));
      } else {
        return [];
      }
    } on Exception catch (e) {
      LogUtil.printLog(e.toString());
      return [];
    }
  }

  /// Converts [dynamic] type to [bool]
  static bool? toBool(dynamic val) {
    try {
      switch (val.runtimeType) {
        case bool:
          return val;
        case String:
          if (val.toString().toLowerCase() == 'true') {
            return true;
          }
          return false;

        default:
          return false;
      }
    } on Exception catch (e) {
      LogUtil.printLog(e.toString());
      return false;
    }
  }

  /// Converts [dynamic] type to [DateTime]
  static DateTime? toDate(dynamic val) {
    if (val == null) {
      return null;
    }
    String strVal = val.toString();
    DateTime? parsed;
    // Try ISO and other default formats
    parsed = DateTime.tryParse(strVal);
    if (parsed != null) return parsed.toLocal();
    // Try dd-MM-yyyy
    try {
      parsed = DateFormat('dd-MM-yyyy').parseStrict(strVal);
      return parsed.toLocal();
    } catch (_) {}
    return null;
  }
}
