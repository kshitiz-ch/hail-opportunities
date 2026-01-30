import 'package:core/modules/common/resources/wealthy_cast.dart';

class CreditCardProductModel {
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dateRemoved;
  String? externalId;
  String? userId;
  String? agentId;
  String? thirdPartyReferenceId;
// Null userDetails;
// Null agentDetails;
  CallBack? callBack;
  int? status;

  CreditCardProductModel({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.dateRemoved,
    this.externalId,
    this.userId,
    this.agentId,
    this.thirdPartyReferenceId,
    // this.userDetails,
    // this.agentDetails,
    this.callBack,
    this.status,
  });

  CreditCardProductModel.fromJson(Map<String, dynamic> json) {
    id = WealthyCast.toInt(json['id']);
    createdAt = WealthyCast.toDate(json['created_at']);
    updatedAt = WealthyCast.toDate(json['updated_at']);
    dateRemoved = WealthyCast.toDate(json['date_removed']);
    externalId = WealthyCast.toStr(json['external_id']);
    userId = WealthyCast.toStr(json['user_id']);
    agentId = WealthyCast.toStr(json['agent_id']);
    thirdPartyReferenceId = WealthyCast.toStr(json['third_party_reference_id']);
    // userDetails = json['user_details'];
    // agentDetails = json['agent_details'];
    status = WealthyCast.toInt(json['status']);

    callBack =
        json['call_back'] != null ? CallBack.fromJson(json['call_back']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt?.toString();
    data['updated_at'] = this.updatedAt?.toString();
    data['date_removed'] = this.dateRemoved?.toString();
    data['external_id'] = this.externalId;
    data['user_id'] = this.userId;
    data['agent_id'] = this.agentId;
    // data['user_details'] = this.userDetails;
    data['status'] = this.status;
    if (this.callBack != null) {
      data['call_back'] = this.callBack?.toJson();
    }
    return data;
  }
}

class CallBack {
  String? logo;
  LeadCreationModel? leadCreationModel;
  ApplicationSubmissionModel? applicationSubmissionModel;
  ApplicationStatusUpdateModel? applicationStatusUpdateModel;

  CallBack({
    this.leadCreationModel,
    this.applicationSubmissionModel,
    this.applicationStatusUpdateModel,
    this.logo,
  });

  CallBack.fromJson(Map<String, dynamic> json) {
    leadCreationModel = json['LEAD_CREATION'] != null
        ? LeadCreationModel.fromJson(json['LEAD_CREATION'])
        : null;
    applicationSubmissionModel = json['APPLICATION_SUBMISSION'] != null
        ? ApplicationSubmissionModel.fromJson(json['APPLICATION_SUBMISSION'])
        : null;
    applicationStatusUpdateModel = json['APPLICATION_STATUS_UPDATION'] != null
        ? new ApplicationStatusUpdateModel.fromJson(
            json['APPLICATION_STATUS_UPDATION'])
        : null;
    logo = WealthyCast.toStr(json['logo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.leadCreationModel != null) {
      data['LEAD_CREATION'] = this.leadCreationModel?.toJson();
    }
    if (this.applicationSubmissionModel != null) {
      data['APPLICATION_SUBMISSION'] =
          this.applicationSubmissionModel?.toJson();
    }
    if (this.applicationStatusUpdateModel != null) {
      data['APPLICATION_STATUS_UPDATION'] =
          this.applicationStatusUpdateModel?.toJson();
    }
    return data;
  }
}

class LeadCreationModel {
  LeadCreationData? leadCreationData;
  String? type;

  LeadCreationModel({this.leadCreationData, this.type});

  LeadCreationModel.fromJson(Map<String, dynamic> json) {
    leadCreationData =
        json['data'] != null ? LeadCreationData.fromJson(json['data']) : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.leadCreationData != null) {
      data['data'] = this.leadCreationData?.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class ApplicationSubmissionModel {
  ApplicationSubmissionData? applicationSubmissionData;
  String? type;

  ApplicationSubmissionModel({this.applicationSubmissionData, this.type});

  ApplicationSubmissionModel.fromJson(Map<String, dynamic> json) {
    applicationSubmissionData = json['data'] != null
        ? ApplicationSubmissionData.fromJson(json['data'])
        : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.applicationSubmissionData != null) {
      data['data'] = this.applicationSubmissionData?.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class ApplicationStatusUpdateModel {
  ApplicationStatusUpdateData? applicationStatusUpdateData;
  String? type;

  ApplicationStatusUpdateModel({this.applicationStatusUpdateData, this.type});

  ApplicationStatusUpdateModel.fromJson(Map<String, dynamic> json) {
    applicationStatusUpdateData = json['data'] != null
        ? ApplicationStatusUpdateData.fromJson(json['data'])
        : null;
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.applicationStatusUpdateData != null) {
      data['data'] = this.applicationStatusUpdateData?.toJson();
    }
    data['type'] = this.type;
    return data;
  }
}

class LeadCreationData {
  String? pan;
  String? city;
  String? name;
  int? leadId;
  String? agentId;
  String? product;
  DateTime? createdAt;
  String? bureauProfile;
  String? primaryMobile;
  String? secondaryMobile;
  String? bureauScoreRange;

  LeadCreationData(
      {this.pan,
      this.city,
      this.name,
      this.leadId,
      this.agentId,
      this.product,
      this.createdAt,
      this.bureauProfile,
      this.primaryMobile,
      this.secondaryMobile,
      this.bureauScoreRange});

  LeadCreationData.fromJson(Map<String, dynamic> json) {
    pan = WealthyCast.toStr(json['pan']);
    city = WealthyCast.toStr(json['city']);
    name = WealthyCast.toStr(json['name']);
    leadId = WealthyCast.toInt(json['leadId']);
    agentId = WealthyCast.toStr(json['agentId']);
    product = WealthyCast.toStr(json['product']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    bureauProfile = WealthyCast.toStr(json['bureauProfile']);
    primaryMobile = WealthyCast.toStr(json['primaryMobile']);
    secondaryMobile = WealthyCast.toStr(json['secondaryMobile']);
    bureauScoreRange = WealthyCast.toStr(json['bureauScoreRange']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['pan'] = this.pan;
    data['city'] = this.city;
    data['name'] = this.name;
    data['leadId'] = this.leadId;
    data['agentId'] = this.agentId;
    data['product'] = this.product;
    data['createdAt'] = this.createdAt;
    data['bureauProfile'] = this.bureauProfile;
    data['primaryMobile'] = this.primaryMobile;
    data['secondaryMobile'] = this.secondaryMobile;
    data['bureauScoreRange'] = this.bureauScoreRange;
    return data;
  }
}

class ApplicationSubmissionData {
  int? leadId;
  String? agentId;
  String? product;
  DateTime? createdAt;
  CustomerProfile? customerProfile;
  AdditionalInformation? additionalInformation;

  ApplicationSubmissionData(
      {this.leadId,
      this.agentId,
      this.product,
      this.createdAt,
      this.customerProfile,
      this.additionalInformation});

  ApplicationSubmissionData.fromJson(Map<String, dynamic> json) {
    leadId = WealthyCast.toInt(json['leadId']);
    agentId = WealthyCast.toStr(json['agentId']);
    product = WealthyCast.toStr(json['product']);
    createdAt = WealthyCast.toDate(json['createdAt']);
    customerProfile = json['customerProfile'] != null
        ? CustomerProfile.fromJson(json['customerProfile'])
        : null;
    additionalInformation = json['additionalInformation'] != null
        ? AdditionalInformation.fromJson(json['additionalInformation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['leadId'] = this.leadId;
    data['agentId'] = this.agentId;
    data['product'] = this.product;
    data['createdAt'] = this.createdAt;
    if (this.customerProfile != null) {
      data['customerProfile'] = this.customerProfile?.toJson();
    }
    if (this.additionalInformation != null) {
      data['additionalInformation'] = this.additionalInformation?.toJson();
    }
    return data;
  }
}

class CustomerProfile {
  String? email;
  String? companyName;
  String? officeEmail;
  String? lenderSelected;
  String? primaryBankName;
  String? productSelected;
  String? highestEducation;

  CustomerProfile(
      {this.email,
      this.companyName,
      this.officeEmail,
      this.lenderSelected,
      this.primaryBankName,
      this.productSelected,
      this.highestEducation});

  CustomerProfile.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    companyName = WealthyCast.toStr(json['companyName']);
    officeEmail = WealthyCast.toStr(json['officeEmail']);
    lenderSelected = WealthyCast.toStr(json['lenderSelected']);
    primaryBankName = WealthyCast.toStr(json['primaryBankName']);
    productSelected = WealthyCast.toStr(json['productSelected']);
    highestEducation = WealthyCast.toStr(json['highestEducation']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['companyName'] = this.companyName;
    data['officeEmail'] = this.officeEmail;
    data['lenderSelected'] = this.lenderSelected;
    data['primaryBankName'] = this.primaryBankName;
    data['productSelected'] = this.productSelected;
    data['highestEducation'] = this.highestEducation;
    return data;
  }
}

class AdditionalInformation {
  String? experience;
  String? occupation;
  String? designation;
  String? industryType;
  int? numberOfDependents;

  AdditionalInformation(
      {this.experience,
      this.occupation,
      this.designation,
      this.industryType,
      this.numberOfDependents});

  AdditionalInformation.fromJson(Map<String, dynamic> json) {
    experience = WealthyCast.toStr(json['experience']);
    occupation = WealthyCast.toStr(json['occupation']);
    designation = WealthyCast.toStr(json['designation']);
    industryType = WealthyCast.toStr(json['industryType']);
    numberOfDependents = WealthyCast.toInt(json['numberOfDependents']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['experience'] = this.experience;
    data['occupation'] = this.occupation;
    data['designation'] = this.designation;
    data['industryType'] = this.industryType;
    data['numberOfDependents'] = this.numberOfDependents;
    return data;
  }
}

class ApplicationStatusUpdateData {
  int? leadId;
  String? status;
  String? remarks;
  String? utmLink;
  String? subStatus;
  String? cardSelected;
  String? cardIssuedDate;
  String? selectedLender;
  String? finalCardStatus;
  bool? isNextActionEnabled;
  String? lastStatusUpdatedDate;
  String? nextActionDescription;

  ApplicationStatusUpdateData(
      {this.leadId,
      this.status,
      this.remarks,
      this.utmLink,
      this.subStatus,
      this.cardSelected,
      this.cardIssuedDate,
      this.selectedLender,
      this.finalCardStatus,
      this.isNextActionEnabled,
      this.lastStatusUpdatedDate,
      this.nextActionDescription});

  ApplicationStatusUpdateData.fromJson(Map<String, dynamic> json) {
    leadId = WealthyCast.toInt(json['leadId']);
    isNextActionEnabled = WealthyCast.toBool(json['isNextActionEnabled']);
    status = WealthyCast.toStr(json['status']);
    remarks = WealthyCast.toStr(json['remarks']);
    utmLink = WealthyCast.toStr(json['utmLink']);
    subStatus = WealthyCast.toStr(json['subStatus']);
    cardSelected = WealthyCast.toStr(json['cardSelected']);
    cardIssuedDate = WealthyCast.toStr(json['cardIssuedDate']);
    selectedLender = WealthyCast.toStr(json['selectedLender']);
    finalCardStatus = WealthyCast.toStr(json['finalCardStatus']);
    lastStatusUpdatedDate = WealthyCast.toStr(json['lastStatusUpdatedDate']);
    nextActionDescription = WealthyCast.toStr(json['nextActionDescription']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['leadId'] = this.leadId;
    data['status'] = this.status;
    data['remarks'] = this.remarks;
    data['utmLink'] = this.utmLink;
    data['subStatus'] = this.subStatus;
    data['cardSelected'] = this.cardSelected;
    data['cardIssuedDate'] = this.cardIssuedDate;
    data['selectedLender'] = this.selectedLender;
    data['finalCardStatus'] = this.finalCardStatus;
    data['isNextActionEnabled'] = this.isNextActionEnabled;
    data['lastStatusUpdatedDate'] = this.lastStatusUpdatedDate;
    data['nextActionDescription'] = this.nextActionDescription;
    return data;
  }
}
