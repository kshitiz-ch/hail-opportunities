import 'package:core/modules/common/resources/wealthy_cast.dart';

class ClientTrackerSwitchModel {
  String? userId;
  String? ticketNumber;
  String? status;
  List<Schemes>? schemes;
  String? clientName;
  String? partnerName;
  String? partnerPhone;
  String? proposalUrl;

  ClientTrackerSwitchModel({
    this.userId,
    this.ticketNumber,
    this.status,
    this.schemes,
    this.clientName,
    this.partnerName,
    this.partnerPhone,
    this.proposalUrl,
  });

  ClientTrackerSwitchModel.fromJson(Map<String, dynamic> json) {
    userId = WealthyCast.toStr(json['user_id']);
    ticketNumber = WealthyCast.toStr(json['ticket_number']);
    status = WealthyCast.toStr(json['status']);
    if (json['schemes'] != null) {
      schemes = <Schemes>[];
      json['schemes'].forEach(
        (v) {
          schemes!.add(Schemes.fromJson(v));
        },
      );
    }
    clientName = WealthyCast.toStr(json['client_name']);
    partnerName = WealthyCast.toStr(json['partner_name']);
    partnerPhone = WealthyCast.toStr(json['partner_phone']);
    proposalUrl = WealthyCast.toStr(json['customer_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['ticket_number'] = this.ticketNumber;
    data['status'] = this.status;
    if (this.schemes != null) {
      data['schemes'] = this.schemes!.map((v) => v.toJson()).toList();
    }
    data['client_name'] = this.clientName;
    data['partner_name'] = this.partnerName;
    data['partner_phone'] = this.partnerPhone;
    data['customer_url'] = this.proposalUrl;
    return data;
  }
}

class Schemes {
  SwitchModel? switchout;
  SwitchModel? switchin;
  bool? valid;
  String? email;
  String? pan;
  String? amcIconUrl;

  Schemes(
      {this.switchout,
      this.switchin,
      this.valid,
      this.email,
      this.pan,
      this.amcIconUrl});

  Schemes.fromJson(Map<String, dynamic> json) {
    switchout = json['switchout'] != null
        ? SwitchModel.fromJson(json['switchout'])
        : null;
    switchin = json['switchin'] != null
        ? SwitchModel.fromJson(json['switchin'])
        : null;
    valid = WealthyCast.toBool(json['valid']);
    email = WealthyCast.toStr(json['email']);
    pan = WealthyCast.toStr(json['pan']);
    amcIconUrl = WealthyCast.toStr(json['amc_icon_url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.switchout != null) {
      data['switchout'] = this.switchout!.toJson();
    }
    if (this.switchin != null) {
      data['switchin'] = this.switchin!.toJson();
    }
    data['valid'] = this.valid;
    data['email'] = this.email;
    data['pan'] = this.pan;
    data['amc_icon_url'] = this.amcIconUrl;
    return data;
  }
}

class SwitchModel {
  String? wschemecode;
  double? amount;
  double? units;
  bool? full;
  String? folioNumber;
  String? fundName;
  String? isin;

  SwitchModel(
      {this.wschemecode,
      this.amount,
      this.units,
      this.full,
      this.folioNumber,
      this.fundName,
      this.isin});

  SwitchModel.fromJson(Map<String, dynamic> json) {
    wschemecode = WealthyCast.toStr(json['wschemecode']);
    amount = WealthyCast.toDouble(json['amount']);
    units = WealthyCast.toDouble(json['units']);
    full = WealthyCast.toBool(json['full']);
    folioNumber = WealthyCast.toStr(json['folio_number']);
    fundName = WealthyCast.toStr(json['fund_name']);
    isin = WealthyCast.toStr(json['isin']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['wschemecode'] = this.wschemecode;
    data['amount'] = this.amount;
    data['units'] = this.units;
    data['full'] = this.full;
    data['folio_number'] = this.folioNumber;
    data['fund_name'] = this.fundName;
    data['isin'] = this.isin;
    return data;
  }
}
