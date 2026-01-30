import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

class FundsModel {
  FundsModel({
    this.funds,
  });

  List<SchemeMetaModel>? funds;

  factory FundsModel.fromJson(Map<String, dynamic> json) => FundsModel(
        funds: WealthyCast.toList(json["mf_funds"])
            .map<SchemeMetaModel>((x) => SchemeMetaModel.fromJson(x))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "mf_funds": funds == null
            ? null
            : List<dynamic>.from(funds!.map((x) => x.toJson())),
      };
}
