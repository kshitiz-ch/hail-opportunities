class SignUpModel {
  String? leadId;
  String? phoneNumber;
  bool? existing;
  int? otp;
  String? name;

  SignUpModel(
      {this.leadId, this.phoneNumber, this.existing, this.otp, this.name});

  SignUpModel.fromJson(Map<String, dynamic> json) {
    leadId = json['lead_id'];
    phoneNumber = json['phone_number'];
    existing = json['existing'];
    otp = json['otp'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lead_id'] = this.leadId;
    data['phone_number'] = this.phoneNumber;
    data['existing'] = this.existing;
    data['otp'] = this.otp;
    data['name'] = this.name;
    return data;
  }
}
