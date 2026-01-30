import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientFilterModel {
  String? name;
  String? displayName;
  String? dataType;
  List<String>? operators;
  List<String>? category;

  String selectedOperator = '';
  String inputValue = '';
  // for between
  String inputValue2 = '';

  ClientFilterModel.fromJson(Map<String, dynamic> json) {
    name = WealthyCast.toStr(json['name']);
    displayName = WealthyCast.toStr(json['display_name']);
    dataType = WealthyCast.toStr(json['data_type']);
    operators = WealthyCast.toList(json['operators'])
        .map((op) => WealthyCast.toStr(op) ?? '')
        .toList();
    category = WealthyCast.toList(json['category'])
        .map((cat) => WealthyCast.toStr(cat) ?? '')
        .toList();

    inputValue = '';
    inputValue2 = '';
    selectedOperator = (operators?.contains('gte') ?? false)
        ? 'gte'
        : operators?.first ?? 'eq';
  }

  ClientFilterModel.clone(ClientFilterModel filterModel) {
    name = filterModel.name;
    displayName = filterModel.displayName;
    dataType = filterModel.dataType;
    operators = filterModel.operators;
    category = filterModel.category;

    selectedOperator = filterModel.selectedOperator;
    inputValue = filterModel.inputValue;
    inputValue2 = filterModel.inputValue2;
  }
}
