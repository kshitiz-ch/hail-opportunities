import 'package:core/config/string_utils.dart';
import 'package:core/modules/common/resources/wealthy_cast.dart';

class ProfilePrefillModel {
  String? userId;
  String? crn;
  String? requestedAccountType;
  String? currentOnboardingAccountType;
  List<String>? availableAccountType;
  Onboarding? onboarding;

  Map<String, KycStep> kycStepMap = {};

  final completedStatusText = 'COMPLETE';

  // class ProfileStatus(DjangoChoices):
  // NOTFOUND = ChoiceItem("NOTFOUND")
  // INCOMPLETE = ChoiceItem("INCOMPLETE")
  // UNDERPROCESS = ChoiceItem("UNDERPROCESS")
  // INVESTMENTREADY = ChoiceItem("INVESTMENTREADY")
  // BLOCKED = ChoiceItem("BLOCKED")
  // DEACTIVATED = ChoiceItem("DEACTIVATED")

  bool get isInvestmentReady =>
      onboarding?.status?.toUpperCase() == 'INVESTMENTREADY';
  bool get isUnderProcess =>
      onboarding?.status?.toUpperCase() == 'UNDERPROCESS';
  bool get isIncomplete => onboarding?.status?.toUpperCase() == 'INCOMPLETE';
  bool get isProfileNotFound => onboarding?.status?.toUpperCase() == 'NOTFOUND';

  bool get isBrokingKyc => currentOnboardingAccountType == 'BROKING';
  bool get isMfKyc => currentOnboardingAccountType == 'MF';

  bool get isContactDetailsCompleted =>
      onboarding?.steps?.contactDetails?.status?.toUpperCase() ==
      completedStatusText;

  bool get isPanDetailsCompleted =>
      (onboarding?.steps?.accountDetails?.panNumber ?? '').isNotNullOrEmpty;

  bool get isPersonalDetailsCompleted =>
      isKycStepDone('personal_details') ||
      onboarding?.steps?.personalDetails?.status?.toUpperCase() ==
          completedStatusText;

  bool get isBankDetailsCompleted =>
      isKycStepDone('bank_proof') ||
      isKycStepDone('penny_drop') ||
      isKycStepDone('rpd') ||
      onboarding?.steps?.bankDetails?.status?.toUpperCase() ==
          completedStatusText;

  // Onboarding UI Data
  int onboardingPercent = 2;
  String nextStep = 'Tax Status';

  bool isKycStepDone(String stepName) {
    return kycStepMap[stepName]?.stepStatus?.toUpperCase() ==
        completedStatusText;
  }

  bool isKycStepNotFound(String? stepStatus) {
    return stepStatus?.toUpperCase() == 'NOT_FOUND';
  }

  void getOnboardingUIData() {
    final kycSteps = onboarding?.steps?.kycDetails?.journey?.steps;
    for (final step in kycSteps ?? <KycStep>[]) {
      kycStepMap[step.stepName!.toLowerCase()] = step;
    }

    if (isProfileNotFound) {
      return;
    }

    if (isUnderProcess) {
      // kyc detail node null
      onboardingPercent = 100;
      nextStep = 'Under Verification';
      return;
    }

    // check tax status
    final isTaxStatusDone =
        (onboarding?.steps?.accountDetails?.taxStatus ?? '').isNotNullOrEmpty;
    if (isTaxStatusDone) {
      onboardingPercent += 3;
      nextStep = 'Contact Details';
    } else {
      return;
    }

    // check contact details
    if (isContactDetailsCompleted) {
      onboardingPercent += 5;
      nextStep = 'Account Type';
    } else {
      return;
    }

    // check account type
    final isAccountTypeDone =
        (onboarding?.steps?.accountDetails?.investorType ?? '')
            .isNotNullOrEmpty;
    if (isAccountTypeDone) {
      onboardingPercent += 10;
      nextStep = 'Pan Details';
    } else {
      return;
    }

    // check pan details
    if (isPanDetailsCompleted) {
      onboardingPercent += 10;
      // nextStep = isMfKyc ? 'Nominee Details' : 'Digilocker';
      nextStep = 'Digilocker';
    } else {
      return;
    }

    // commented as notFoundText is not coming after skip
    // so we dont know if its skipped or not
    // check nominee mf skippable
    // if (isMfKyc) {
    //   final nomineeStatus =
    //       onboarding?.steps?.nomineeDetails?.status?.toUpperCase();

    //   // since its skippable proceed whether completed or skipped (not found)
    //   final isMfNomineeDone =
    //       nomineeStatus == completedStatusText || nomineeStatus == 'NOT_FOUND';

    //   if (isMfNomineeDone) {
    //     onboardingPercent += 5;
    //     nextStep = 'Digilocker';
    //   }
    // }

    // check digilocker
    if (isKycStepDone('digilocker')) {
      // onboardingPercent += (isMfKyc ? 5 : 10);
      onboardingPercent += 10;
      nextStep = 'Personal Details';
    } else {
      return;
    }

    // check personal details
    if (isPersonalDetailsCompleted) {
      onboardingPercent += 10;
      nextStep = 'Bank Details';
    } else {
      return;
    }

    // check bank details
    if (isBankDetailsCompleted) {
      onboardingPercent += 20;
      // nextStep = isMfKyc ? 'Specimen Signature' : 'Nominee Details';
      nextStep = 'Specimen Signature';
    } else {
      return;
    }

    // commented as notFoundText is not coming after skip
    // so we dont know if its skipped or not
    // check nominee broking skippable
    // if (isBrokingKyc) {
    //   final nomineeStatus =
    //       onboarding?.steps?.nomineeDetails?.status?.toUpperCase();

    //   // since its skippable proceed whether completed or skipped (not found)
    //   final isBrokingNomineeDone =
    //       nomineeStatus == completedStatusText || nomineeStatus == 'NOT_FOUND';

    //   if (isBrokingNomineeDone) {
    //     onboardingPercent += 2;
    //     nextStep = 'Specimen Signature';
    //   }
    // }

    // check Specimen Signature
    if (isKycStepDone('specimen_sign')) {
      // onboardingPercent += (isMfKyc ? 5 : 3);
      onboardingPercent += 5;
      nextStep = 'Selfie Verification';
    } else {
      return;
    }

    // face_match == selfie
    // // check Selfie Verification
    // if (isKycStepDone('selfie')) {
    //   onboardingPercent = 78;
    //   nextStep = 'Face Match';
    // } else {
    //   return;
    // }

    // check Face Match
    if (isKycStepDone('face_match') || isKycStepDone('selfie')) {
      onboardingPercent += 5;
      nextStep = isBrokingKyc ? 'Trading Preferences' : 'Fatca';
    } else {
      return;
    }

    // check Trading Preferences
    if (isBrokingKyc) {
      if (isKycStepDone('trading_preferences')) {
        onboardingPercent += 5;
        nextStep = 'Fatca';
      } else {
        return;
      }
    }

    // check fatca
    if (isKycStepDone('fatca')) {
      onboardingPercent += (isBrokingKyc ? 5 : 10);
      nextStep = 'E Signature';
    } else {
      return;
    }

    // check esign
    if (isKycStepDone('e_sign')) {
      onboardingPercent += 10;
      nextStep = 'Completed';
    }

    // TODO KRA
  }

  ProfilePrefillModel.fromJson(Map<String, dynamic> json) {
    userId = WealthyCast.toStr(json['userId']);
    crn = WealthyCast.toStr(json['crn']);
    requestedAccountType = WealthyCast.toStr(json['requestedAccountType']);
    currentOnboardingAccountType =
        WealthyCast.toStr(json['currentOnboardingAccountType']);
    availableAccountType =
        WealthyCast.toList(json['availableAccountType']).cast<String>();
    if (json['onboarding'] != null) {
      onboarding = Onboarding.fromJson(json['onboarding']);
      getOnboardingUIData();
    }
  }
}

class Onboarding {
  String? status;
  String? stage;
  Steps? steps;

  Onboarding.fromJson(Map<String, dynamic> json) {
    status = WealthyCast.toStr(json['status']);
    stage = WealthyCast.toStr(json['stage']);
    if (json['steps'] != null) {
      steps = Steps.fromJson(json['steps']);
    }
  }
}

class Steps {
  StepDetails? contactDetails;
  AccountDetails? accountDetails;
  StepDetails? personalDetails;
  StepDetails? bankDetails;
  StepDetails? nomineeDetails;
  KycDetails? kycDetails;

  Steps.fromJson(Map<String, dynamic> json) {
    if (json['contactDetails'] != null) {
      contactDetails = StepDetails.fromJson(json['contactDetails']);
    }
    if (json['accountDetails'] != null) {
      accountDetails = AccountDetails.fromJson(json['accountDetails']);
    }
    if (json['personalDetails'] != null) {
      personalDetails = StepDetails.fromJson(json['personalDetails']);
    }
    if (json['bankDetails'] != null) {
      bankDetails = StepDetails.fromJson(json['bankDetails']);
    }
    if (json['nomineeDetails'] != null) {
      nomineeDetails = StepDetails.fromJson(json['nomineeDetails']);
    }
    if (json['kycDetails'] != null) {
      kycDetails = KycDetails.fromJson(json['kycDetails']);
    }
  }
}

class AccountDetails {
  String? status;
  String? panNumber;
  String? taxStatus;
  String? investorType;
  List<String>? missingFields;

  AccountDetails.fromJson(Map<String, dynamic> json) {
    status = WealthyCast.toStr(json['status']);
    panNumber = WealthyCast.toStr(json['panNumber']?['value']);
    taxStatus = WealthyCast.toStr(json['taxStatus']?['value']);
    investorType = WealthyCast.toStr(json['investorType']?['value']);
    if (json['missingFields'] != null) {
      missingFields = WealthyCast.toList(json['missingFields']);
    }
  }
}

class StepDetails {
  String? status;
  List<String>? missingFields;

  StepDetails.fromJson(Map<String, dynamic> json) {
    status = WealthyCast.toStr(json['status']);
    if (json['missingFields'] != null) {
      missingFields = WealthyCast.toList(json['missingFields']);
    }
  }
}

class KycDetails {
  String? url;
  String? stage;
  KycJourney? journey;

  KycDetails.fromJson(Map<String, dynamic> json) {
    url = WealthyCast.toStr(json['url']);
    stage = WealthyCast.toStr(json['stage']);
    if (json['journey'] != null) {
      journey = KycJourney.fromJson(json['journey']);
    }
  }
}

class KycJourney {
  List<KycStep>? projectedSteps;
  List<KycStep>? steps;
  KycStep? currentStep;

  KycJourney.fromJson(Map<String, dynamic> json) {
    if (json['projectedPath'] != null) {
      projectedSteps = WealthyCast.toList(json['projectedPath'])
          .map((projectedStep) => KycStep.fromJson(projectedStep))
          .toList();
    }
    if (json['steps'] != null) {
      steps = WealthyCast.toList(json['steps'])
          .map((step) => KycStep.fromJson(step))
          .toList();
    }
    if (json['current'] != null) {
      currentStep = KycStep.fromJson(json['current']);
    }
  }
}

class KycStep {
  String? stepName;
  String? stepStatus;
  String? completedAt;
  String? displayName;

  KycStep.fromJson(Map<String, dynamic> json) {
    stepName = WealthyCast.toStr(json['stepName'] ?? json['name']);
    stepStatus = WealthyCast.toStr(json['stepStatus'] ?? json['status']);
    completedAt = WealthyCast.toStr(json['completedAt']);
    displayName = WealthyCast.toStr(json['displayName']);
  }
}
