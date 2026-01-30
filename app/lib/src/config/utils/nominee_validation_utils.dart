import 'package:app/src/config/constants/enums.dart';
import 'package:app/src/config/constants/util_constants.dart';
import 'package:app/src/config/utils/extension_utils.dart';
import 'package:core/modules/clients/models/client_list_model.dart';
import 'package:flutter/material.dart';

class NomineeValidationUtils {
  // PAN Pattern: 5 letters + 4 digits + 1 letter (e.g., ABCDE1234F)
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  // Passport Pattern: Basic alphanumeric 6-20 characters
  static final RegExp _passportPattern = RegExp(r'^[A-Z0-9]{6,20}$');

  // Aadhaar Pattern: Exactly 4 digits for last 4 digits
  static final RegExp _aadhaarPattern = RegExp(r'^[0-9]{4}$');

  /// Validates age with comprehensive boundary checks
  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) return 'Date of birth is required';

    final today = DateUtils.dateOnly(DateTime.now());
    final birthDateOnly = DateUtils.dateOnly(birthDate);

    // Check for negative age (future date)
    if (birthDateOnly.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }

    var age = today.year - birthDateOnly.year;
    if (birthDateOnly.month > today.month ||
        (birthDateOnly.month == today.month && birthDateOnly.day > today.day)) {
      age--;
    }

    // Check for unrealistic age
    if (age > 100) {
      return 'Age cannot be more than 100 years';
    }

    if (age < 0) {
      return 'Invalid date of birth';
    }

    return null;
  }

  /// Validates guardian age (must be >= 18)
  static String? validateGuardianAge(DateTime? guardianBirthDate) {
    if (guardianBirthDate == null) return 'Guardian date of birth is required';

    final ageValidation = validateAge(guardianBirthDate);
    if (ageValidation != null) return ageValidation;

    if (!isAdult(guardianBirthDate)) {
      return 'Guardian must be at least 18 years old';
    }

    return null;
  }

  /// Validates PAN number format
  static String? validatePanNumber(String? pan) {
    if (pan.isNullOrEmpty) return null; // Optional validation

    if (pan!.length != 10) {
      return 'PAN number must be exactly 10 characters';
    }

    if (!_panPattern.hasMatch(pan.toUpperCase())) {
      return 'Invalid PAN format. Format: ABCDE1234F';
    }

    return null;
  }

  /// Validates Aadhaar last 4 digits
  static String? validateAadhaarLastFour(String? aadhaar) {
    if (aadhaar.isNullOrEmpty) return null; // Optional validation

    if (aadhaar!.length != 4) {
      return 'Please enter exactly 4 digits';
    }

    if (!_aadhaarPattern.hasMatch(aadhaar)) {
      return 'Aadhaar digits must be numeric';
    }

    return null;
  }

  /// Validates passport number format
  static String? validatePassportNumber(String? passport) {
    if (passport.isNullOrEmpty) return null; // Optional validation

    if (passport!.length < 6 || passport.length > 20) {
      return 'Passport number must be between 6-20 characters';
    }

    if (!_passportPattern.hasMatch(passport.toUpperCase())) {
      return 'Passport number can only contain letters and numbers';
    }

    return null;
  }

  /// Checks for duplicate nominee details against account holder
  static String? validateNomineeNotDuplicateOfAccountHolder({
    required Client? accountHolder,
    required String? nomineePan,
    required String? nomineeAadhaar,
    required DateTime? nomineeDob,
  }) {
    if (accountHolder == null) return null;

    // Check PAN match
    if (nomineePan.isNotNullOrEmpty &&
        accountHolder.panNumber.isNotNullOrEmpty &&
        nomineePan!.toUpperCase() == accountHolder.panNumber!.toUpperCase()) {
      return 'Nominee PAN cannot be same as account holder\'s PAN';
    }

    // Check DOB match
    if (nomineeDob != null && accountHolder.dob != null) {
      if (DateUtils.isSameDay(nomineeDob, accountHolder.dob!)) {
        return 'Nominee date of birth cannot be same as account holder\'s date of birth';
      }
    }

    // Check Aadhaar match (this would need account holder's Aadhaar last 4 digits)
    // Note: Account holder's Aadhaar might not be available in current model
    // This validation can be enhanced when Aadhaar data is available

    return null;
  }

  /// Checks for duplicate guardian details against account holder
  static String? validateGuardianNotDuplicateOfAccountHolder({
    required Client? accountHolder,
    required String? guardianPan,
    required String? guardianAadhaar,
    required DateTime? guardianDob,
  }) {
    if (accountHolder == null) return null;

    // Check PAN match
    if (guardianPan.isNotNullOrEmpty &&
        accountHolder.panNumber.isNotNullOrEmpty &&
        guardianPan!.toUpperCase() == accountHolder.panNumber!.toUpperCase()) {
      return 'Guardian PAN cannot be same as account holder\'s PAN';
    }

    // Check DOB match
    if (guardianDob != null && accountHolder.dob != null) {
      if (DateUtils.isSameDay(guardianDob, accountHolder.dob!)) {
        return 'Guardian date of birth cannot be same as account holder\'s date of birth';
      }
    }

    return null;
  }

  /// Validates ID requirements for minor nominees
  static String? validateMinorNomineeIdRequirements({
    required bool isMinor,
    required PersonIDType nomineeIdType,
    required String? nomineeIdValue,
    required PersonIDType guardianIdType,
    required String? guardianIdValue,
  }) {
    if (!isMinor) return null;

    final hasNomineeId = nomineeIdValue.isNotNullOrEmpty;
    final hasGuardianId = guardianIdValue.isNotNullOrEmpty;

    if (!hasNomineeId && !hasGuardianId) {
      return 'For minor nominee, either nominee ID or guardian ID is required';
    }

    return null;
  }

  /// Validates ID requirements for adult nominees
  static String? validateAdultNomineeIdRequirements({
    required bool isNri,
    required PersonIDType nomineeIdType,
    required String? nomineeIdValue,
  }) {
    if (nomineeIdValue.isNullOrEmpty) {
      if (isNri) {
        return 'Passport is required for NRI nominees';
      } else {
        return 'PAN, Aadhaar, or Passport is required for non-NRI nominees';
      }
    }

    if (isNri && nomineeIdType != PersonIDType.Passport) {
      return 'NRI nominees must provide Passport';
    }

    return null;
  }

  /// Comprehensive validation for the entire nominee form
  static List<String> validateNomineeForm({
    required String? nomineeName,
    required DateTime? nomineeDob,
    required String? selectedRelationship,
    required String? email,
    required PersonIDType nomineeIdType,
    required String? nomineeIdValue,
    required bool isNri,
    required String? guardianName,
    required DateTime? guardianDob,
    required String? selectedGuardianRelationship,
    required PersonIDType guardianIdType,
    required String? guardianIdValue,
    required Client? accountHolder,
    required String? nomineeAddressId,
  }) {
    List<String> errors = [];

    // Basic required field validations
    if (nomineeName.isNullOrEmpty) {
      errors.add('Nominee name is required');
    }

    if (nomineeDob == null) {
      errors.add('Nominee date of birth is required');
    }

    if (selectedRelationship.isNullOrEmpty) {
      errors.add('Relationship with nominee is required');
    }

    if (email.isNullOrEmpty) {
      errors.add('Email is required');
    }

    // Address ID validations
    if (nomineeAddressId.isNullOrEmpty) {
      errors.add('Nominee address is required');
    }

    // Age validations
    if (nomineeDob != null) {
      final ageError = validateAge(nomineeDob);
      if (ageError != null) errors.add(ageError);
    }

    final isMinor = nomineeDob != null && !isAdult(nomineeDob);

    // Minor specific validations
    if (isMinor) {
      if (guardianName.isNullOrEmpty) {
        errors.add('Guardian name is required for minor nominee');
      }

      if (guardianDob == null) {
        errors.add('Guardian date of birth is required for minor nominee');
      } else {
        final guardianAgeError = validateGuardianAge(guardianDob);
        if (guardianAgeError != null) errors.add(guardianAgeError);
      }

      if (selectedGuardianRelationship.isNullOrEmpty) {
        errors.add('Guardian relationship is required for minor nominee');
      }

      // ID requirements for minor
      final minorIdError = validateMinorNomineeIdRequirements(
        isMinor: true,
        nomineeIdType: nomineeIdType,
        nomineeIdValue: nomineeIdValue,
        guardianIdType: guardianIdType,
        guardianIdValue: guardianIdValue,
      );
      if (minorIdError != null) errors.add(minorIdError);
    } else {
      // Adult ID requirements
      final adultIdError = validateAdultNomineeIdRequirements(
        isNri: isNri,
        nomineeIdType: nomineeIdType,
        nomineeIdValue: nomineeIdValue,
      );
      if (adultIdError != null) errors.add(adultIdError);
    }

    // ID format validations
    if (nomineeIdValue.isNotNullOrEmpty) {
      String? formatError;
      switch (nomineeIdType) {
        case PersonIDType.Pan:
          formatError = validatePanNumber(nomineeIdValue);
          break;
        case PersonIDType.Aadhaar:
          formatError = validateAadhaarLastFour(nomineeIdValue);
          break;
        case PersonIDType.Passport:
          formatError = validatePassportNumber(nomineeIdValue);
          break;
      }
      if (formatError != null) errors.add('Nominee ID: $formatError');
    }

    if (guardianIdValue.isNotNullOrEmpty) {
      String? formatError;
      switch (guardianIdType) {
        case PersonIDType.Pan:
          formatError = validatePanNumber(guardianIdValue);
          break;
        case PersonIDType.Aadhaar:
          formatError = validateAadhaarLastFour(guardianIdValue);
          break;
        case PersonIDType.Passport:
          formatError = validatePassportNumber(guardianIdValue);
          break;
      }
      if (formatError != null) errors.add('Guardian ID: $formatError');
    }

    // Duplicate validations
    final nomineeDuplicateError = validateNomineeNotDuplicateOfAccountHolder(
      accountHolder: accountHolder,
      nomineePan: nomineeIdType == PersonIDType.Pan ? nomineeIdValue : null,
      nomineeAadhaar:
          nomineeIdType == PersonIDType.Aadhaar ? nomineeIdValue : null,
      nomineeDob: nomineeDob,
    );
    if (nomineeDuplicateError != null) errors.add(nomineeDuplicateError);

    if (isMinor && guardianIdValue.isNotNullOrEmpty) {
      final guardianDuplicateError =
          validateGuardianNotDuplicateOfAccountHolder(
        accountHolder: accountHolder,
        guardianPan:
            guardianIdType == PersonIDType.Pan ? guardianIdValue : null,
        guardianAadhaar:
            guardianIdType == PersonIDType.Aadhaar ? guardianIdValue : null,
        guardianDob: guardianDob,
      );
      if (guardianDuplicateError != null) errors.add(guardianDuplicateError);
    }

    return errors;
  }
}
