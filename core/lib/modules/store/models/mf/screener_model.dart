import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/dashboard/models/meta_data_model.dart';
import 'package:flutter/material.dart';

class ScreenerListModel {
  String? id;
  String? name;
  List<ScreenerModel>? screeners;

  ScreenerListModel({this.id, this.name, this.screeners});

  ScreenerListModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    name = WealthyCast.toStr(json['name']);
    if (WealthyCast.toList(json['screeners']).isNotEmpty) {
      screeners = <ScreenerModel>[];
      json['screeners'].forEach((v) {
        screeners!.add(ScreenerModel.fromJson(v));
      });
    }
  }
}

class ScreenerModel {
  String? wpc;
  String? name;
  String? instrumentType;
  String? description;
  ScreenerQueryParams? returnParams;
  ScreenerQueryParams? categoryParams;
  ScreenerQueryParams? orderingParams;
  String? uri;

  ScreenerModel({
    this.wpc,
    this.name,
    this.instrumentType,
    this.description,
    this.returnParams,
    this.categoryParams,
    this.orderingParams,
    this.uri,
  });

  ScreenerModel.fromJson(Map<String, dynamic> json) {
    wpc = WealthyCast.toStr(json['wpc']);
    name = WealthyCast.toStr(json['name']);
    instrumentType = WealthyCast.toStr(json['instrument_type']);
    description = WealthyCast.toStr(json['description']);
    if (WealthyCast.toList(json['additional_data']).isNotEmpty) {
      List additionalData = WealthyCast.toList(json["additional_data"]);
      Map<String, dynamic>? returnJson;

      for (var json in additionalData) {
        if (json['category'] == "Returns") {
          returnJson = json;
          break;
        }
      }

      if (returnJson != null) {
        returnJson['choices'] = returnJson['data'];
        returnParams = ScreenerQueryParams.fromJson(returnJson);
      }
      // json['additional_data'].forEach((v) { additionalData!.add(new Null.fromJson(v)); });
    } else {
      returnParams = ScreenerQueryParams.fromJson(
        {
          "choices": List.from(returnOptionsJson),
          "default": "returns_three_years",
          "category": "Returns",
        },
      );
    }

    categoryParams = json['query_params']?['category'] != null
        ? ScreenerQueryParams.fromJson(json['query_params']['category'])
        : null;
    orderingParams = json['query_params']?['ordering'] != null
        ? ScreenerQueryParams.fromJson(json['query_params']['ordering'])
        : ScreenerQueryParams.fromJson({
            "choices": List.from(returnOptionsJson),
          });
    uri = WealthyCast.toStr(json['uri']);
  }
}

class ScreenerQueryParams {
  String? uri;
  List<Choice>? choices;
  String? defaultValue;
  String? dataType;

  ScreenerQueryParams({
    this.uri,
    this.choices,
    this.defaultValue,
    this.dataType,
  });

  ScreenerQueryParams.fromJson(Map<String, dynamic> json) {
    if (json['choices'] != null) {
      choices = <Choice>[];
      json['choices'].forEach((v) {
        choices!.add(new Choice.fromJson(v));
      });
    }
    uri = WealthyCast.toStr(json['uri']);
    defaultValue = WealthyCast.toStr(json['default']);
    dataType = WealthyCast.toStr(json['data_type']);
  }
}

// class ScreenerCategory {
//   String? uri;
//   List<Choices>? choices;
//   String? defaultValue;
//   String? dataType;

//   ScreenerCategory({
//     this.uri,
//     this.choices,
//     this.defaultValue,
//     this.dataType,
//   });

//   ScreenerCategory.fromJson(Map<String, dynamic> json) {
//     if (json['choices'] != null) {
//       choices = <Choices>[];
//       json['choices'].forEach((v) {
//         choices!.add(new Choices.fromJson(v));
//       });
//     }
//     uri = WealthyCast.toStr(json['uri']);
//     defaultValue = WealthyCast.toStr(json['default']);
//     dataType = json['data_type'];
//   }
// }

class Choice {
  String? value;
  String? displayName;

  Choice({this.value, this.displayName});

  Choice.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    displayName = json['display_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['display_name'] = this.displayName;
    return data;
  }
}

List<Map<String, dynamic>> returnOptionsJson = [
  {"value": "returns_since_inception", "display_name": "Since Inception"},
  {"value": "returns_one_week", "display_name": "1 Week"},
  {"value": "returns_one_month", "display_name": "1 Month"},
  {"value": "returns_three_months", "display_name": "3 Months"},
  {"value": "returns_six_months", "display_name": "6 Months"},
  {"value": "returns_one_year", "display_name": "1 Year"},
  {"value": "returns_three_years", "display_name": "3 Years"},
  {"value": "returns_five_years", "display_name": "5 Years"}
];
