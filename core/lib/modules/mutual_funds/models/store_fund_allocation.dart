import 'package:core/modules/common/resources/wealthy_cast.dart';
import 'package:core/modules/mutual_funds/models/scheme_meta_model.dart';

class StoreFundAllocation {
  String? id;
  List<SchemeMetaModel>? schemeMetas = [];

  StoreFundAllocation({
    this.id,
    this.schemeMetas,
  });

  StoreFundAllocation.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toStr(json['id']);
    schemeMetas = WealthyCast.toList(json['schemeMetas'])
        .map((v) => SchemeMetaModel.fromJson(v))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.schemeMetas != null) {
      data['schemeMetas'] = this.schemeMetas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
