const String createBankAccount = r'''
  mutation createUserBankAccount($input: CreateUserBankAccountInput!) {
    createUserBankAccount(input: $input) {
      bankAccount {
        createdAt
        updatedAt
        id
        bank
        ifsc
        micr
        branch
        address
        contact
        city
        district
        state
        externalId
        userId
        number
        accType
        isVerified
        bankVerifiedStatus
        bankVerifiedName
      }
    }
  }
''';

const String updateBankAccount = r'''
  mutation updateUserBankAccount($input: UpdateUserBankAccountInput!) {
    updateUserBankAccount(input: $input) {
      bankAccount {
        createdAt
        updatedAt
        id
        bank
        ifsc
        micr
        branch
        address
        contact
        city
        district
        state
        externalId
        userId
        number
        accType
        isVerified
        bankVerifiedStatus
        bankVerifiedName
      }
    }
  }
''';
const String createMfProfile = r'''
  mutation createMfProfile($input: AgentCreateMFProfileArgsInput!) {
    createUserMfProfile(input: $input) {
      mfProfile{
        id
        externalId
        userId
        name
        fatherName
        motherName
        email
        emailRelation
        emailVerifiedAt
        phoneNumber
        phoneRelation
        phoneVerifiedAt
        panNumber
        panUsageType
        panUsageSubtype
        dob
        activatedAt
        kycStatus
        transactionActiveAt
        accountId
        defaultBankAccountId
        defaultPerAddressId
        defaultCorrAddressId
        maritalStatus
        gender
        citizenshipCountryCode
        panUniquenessKey
        pan2
        pan3
        guardianPan
        guardianName
        jointName2
        jointName3
        phoneVerifiedAt
      }
    }
  }''';

const String addClientAddress = r'''
  mutation addClientAddress($input: AddUserAddressArgsInput!) {
    addAddress(input:$input) {
      userAddress{
        address
        externalId
      }
    }
  }''';

const String updateClientAddress = r'''
  mutation updateClientAddress($input: UpdateUserAddressArgsInput!) {
    updateAddress(input:$input) {
      userAddress{
        address
        externalId
      }
    }
  }''';

const String deleteClientAddress = r'''
  mutation deleteClientAddress($id: ID!) {
    deleteAddress(id:$id) {
       message
    }
  }''';

const String setDefaultBankAccount = r'''
  mutation setDefaultBankAccountt($input: SetDefaultBankAccountInput!) {
    setDefaultBankAccount(input: $input) {
       message
    }
  }''';

const String createUserNominee = r'''
  mutation createUserNominee($input: UserNomineeInput!) {
    createUserNominee(input: $input) {
      nominee {
        id
      }
    }
  }
''';

const String updateUserNominee = r'''
  mutation updateUserNominee($id: ID!, $input: UserNomineeInput!) {
    updateUserNominee(id: $id, input: $input) {
      nominee {
        id
      }
    }
  }
''';

const String createMfNominees = r'''
  mutation createMfNominees($input: [MFNomineeInput]!) {
    createMfNominees(input: $input) {
      mfNominees {
        id
      }
    }
  }
''';

const String requestUserUpdateProfile = r'''
  mutation requestUserUpdateProfile($input: UserUpdateProfileInput!) {
    requestUserUpdateProfile(input: $input) {
      userId
      stage
      nextStep
    }
  }
''';

const String requestUserUpdateVerifiedProfile = r'''
  mutation requestUserUpdateVerifiedProfileDetails {
    requestUserUpdateVerifiedProfileDetails {
      url
    }
  }
''';
