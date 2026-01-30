import 'package:core/modules/common/resources/wealthy_cast.dart';

class DematModel {
  String? id;
  String? dematId;
  String? dpid;
  String? boid;
  String? docUrl;
  bool? isVerified;
  String? tradingAccountId;
  String? provider;
  String? stockBroker;
  String? dematImageId;

  DematModel({
    this.id,
    this.dematId,
    this.dpid,
    this.boid,
    this.docUrl,
    this.isVerified,
    this.tradingAccountId,
    this.provider,
    this.stockBroker,
    this.dematImageId,
  });

  factory DematModel.fromJson(Map<String, dynamic> json) => DematModel(
        id: WealthyCast.toStr(json['id']),
        dematId: WealthyCast.toStr(json['dematId']),
        dpid: WealthyCast.toStr(json['dpid']),
        boid: WealthyCast.toStr(json['boid']),
        docUrl: WealthyCast.toStr(json['docUrl']),
        isVerified: WealthyCast.toBool(json['isVerified']),
        tradingAccountId: WealthyCast.toStr(json['tradingAccountId']),
        provider: WealthyCast.toStr(json['provider']),
        stockBroker: WealthyCast.toStr(json['stockBroker']),
        dematImageId: WealthyCast.toStr(json['dematImageId']),
      );
}
