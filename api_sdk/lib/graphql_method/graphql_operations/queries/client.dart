const String clientList = r'''
   query leads($recentLeads: Boolean, $q: String, $limit: Int, $offset: Int, $requestAgentId: String) {
    hydra {
      id
      customerCount
      clients(recentLeads: $recentLeads, q: $q, limit: $limit, offset: $offset, requestAgentId: $requestAgentId) {
      id
      taxyId
      email
      agent {
        id
        name
        email
        externalId
      }
      mfEmail
      phoneNumber
      name
      dob
      panUsageType
      firstName
      lastName
      accountId
      hasMandate 
      firstTransactionAt 
      source 
      wealthyInvestedValue 
      wealthyIrr 
      wealthyCurrentValue 
      trakMfIrr 
      totalFamilyCurrentValue 
      totalSelfCurrentValue
      frequentSeenLocation 
      lastSeenAt 
      investorActivatedAt 
      privilegeActivatedAt  
      currentAgentAssignedAt 
      sourceType 
      investmentCurrentValue 
      loanCurrentValue 
      insuranceCurrentValue 
      unlistedStocksCurrentValue
      currentMonthPipelinedRevenue
      agentTotalRevenue
      totalNoOfInsurance
      emailVerified
      phoneVerified
      crn
      panNumber
    }
    }
  }
''';

const String employeesClientCount = r'''
   query clientsCount ($agentExternalId: String) {
    hydra {
      employee(agentExternalId: $agentExternalId) {
        customersCount
      }
    }
  }
''';

const String clientsCount = r'''
   query clientsCount {
    hydra {
      id
      customerCount
    }
  }
''';

const String accountDetails = r'''
query accountDetails($userId: String) {
  taxy(userId: $userId) {
    users {
      id
      email
      fullName
      phoneNumber
      isEmailVerified
      phoneVerifiedAt
      lastName
      firstName
      crn
    }
    mandates {
      id
      amount
      updatedAt
      stage
      mandateType
      alertAmount
      provider
      isConfirmed
      mandateConfirmedAt
    }
  }
}
''';

const String clientDetails = r'''
   query clientDetails($id: ID, $agentId: ID) {
    hydra {
      id
      customerCount
      client(id: $id, agentId: $agentId) {
        id
        crn
        taxyId
        email
        name
        firstName
        lastName
        mfEmail
        panUsageType
        phoneNumber
        emailVerified
        phoneVerified
      }
    }
  }
''';

const String clientDetailsByTaxyId = r'''
  query clientDetailsByTaxyId($userId: String) {
    hydra {
      clients(userId: $userId) {
        id
        crn
        taxyId
        email
        name
        firstName
        lastName
        mfEmail
        panUsageType
        phoneNumber
        emailVerified
        phoneVerified
      }
    }
  }
''';

const String clientLoginDetails = r'''
   query clientDetails($userId: String) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
        email
        emailVerifiedAt
      }

      wealthyUserDetailsPrefill(onBoardProduct: "MF") {
        firstName
        lastName
        email
        emailVerifiedAt
        phoneNumber
        phoneVerifiedAt
      }
    }
  }
''';

const String clientInvestmentDetailsv2 = r'''
   query clientDetails($userId: String) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
        email
        emailVerifiedAt
      }

      wealthyUserDetailsPrefill(onBoardProduct: "MF") {
        firstName
        lastName
        email
        emailVerifiedAt
        phoneNumber
        phoneVerifiedAt
      }
    }
  }
''';

const String mfProfileDetails = r'''
  query mfProfileDetails($userId: String!) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
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
      wealthyUserDetailsPrefill(onBoardProduct: "MF", declarationType: "basic") {
        email
        emailVerifiedAt
        phoneNumber
        phoneVerifiedAt
        panNumber
        name
        firstName
        lastName
        isEmailVerified
        isPhoneVerified
        dob
        maritalStatus
        gender
        families {
          ownerDetails {
            email
            isEmailVerified
            phoneNumber
            isPhoneVerified
            ownerUserId
          }
        }
      }
    }
  }
''';

const String nominees = '''
 query nominees(\$userId: String!) {
    hagrid(userId: \$userId) {
      mfNominees ${mfTradingNominee}
      userNominees {
        externalId
        userId
        name
        relationship
        panNumber
        nameAsPerPan
        guardianName
        dob
        guardianDob
        source
        aadhaarNumber
        phoneNumber
        email
        nomineeIsNri
        nomineeIdType
        passportNumber
        includeNomineeInSoa
        guardianIdType
        guardianIdValue
        nomineeRelationWithGuardian
        address {
          id
          externalId
          title
          line1
          line2
          line3
          city
          state
          country
          pincode
          address
        }
      }
      brokingNominees ${mfTradingNominee}
    }
 }
''';

const String mfTradingNominee = r'''
  {
    externalId
    userId
    percentage
    source
    nominee {
      externalId
      userId
      name
      relationship
      panNumber
      nameAsPerPan
      guardianName
      dob
      guardianDob
      source
    }
  }
''';

const String bankAccounts = r'''
  query bankAccounts($userId: String!) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
        defaultBankAccountId
      }
      userBankAccounts {
        id
        bank
        ifsc
        micr
        branch
        address
        externalId
        userId
        number
        accType
        isVerified
        bankVerifiedStatus
        bankVerifiedName
        source
      }
    }
  }
''';

const String brokingBankAccounts = r'''
  query brokingBankAccounts($userId: String!) {
    hagrid(userId: $userId) {
      wealthyBrokingProfile {
        defaultBankAccountId
      }
      userBrokingBankAccounts {
        bankVerifiedStatus
        number
        userId
        ifsc
        bank
        id
      }
    }
  }
''';

const String wealthyDematProfile = r'''
query wealthyDematProfile($userId: String){
  hagrid(userId: $userId) {
    wealthyBrokingProfile {
      ucc
      panUsageType
      panUsageSubtype
      kycStatus
      kycId
      segments
      dematId
      frontendStatusText
      poaEnabledAt
    }
  }
}
''';

const String clientAddressDetail = r'''
query clientAddressDetail($userId: String, $addressId: String){
  hagrid(userId: $userId) {
    userAddresses(addressId: $addressId) {
      id
      externalId
      title
      line1
      line2
      line3
      city
      state
      country
      pincode
      address
    }
  }
}
''';

const String mandates = r'''
  query mandates($userId: String) {
    taxy(userId: $userId) {
      mandates {
        stage
        bankAccount {
          id
          number
        }
      }
    }
  }
''';

const String userMandateMeta = r'''
  query userMandateMeta($userId: String) {
    taxy(userId: $userId) {
      userMandateMeta {
        mandateConfirmedAt
        amount
        statusText
      }
    }
  }
''';

const String userMandates = r'''
  query userMandates($userId: String, $sipMetaExternalId: String, $fetchConfirmedOnly: Boolean) {
    taxy(userId: $userId) {
      userMandates(sipMetaExternalId: $sipMetaExternalId, fetchConfirmedOnly: $fetchConfirmedOnly) {
        amount
        failureReason
        isConfirmed
        mandateConfirmedAt
        mandateExpiredAt
        paymentBankIfscCode
        paymentBankName
        paymentBankAccountNumber
        paymentBankId
        bankVerifiedStatus
        stage
        status
        method
        authType
        currentStatus
      }
    }
  }
''';

const String clientInvestmentStatus = r'''
  query clientInvestmentStatus($userId: String) {
    hagrid(userId: $userId) {
      wealthyMfProfile {
        frontendStatusText
        frontendStatusInfo
      }

      wealthyBrokingProfile {
        frontendStatusText
      }

      wealthyUserProfile {
        kraStatusStr
      }
    }
  }
''';

const String kraStatusCheck = r'''
  query fetchKraStatus($userId: String) {
    hagrid(userId: $userId) {
      id
      kraStatusCheck(userId: $userId) {
        userId
        kraStatus
        kraStatusStr
      }
    }
  }
''';

const String deleteClient = r'''
  mutation deleteClient ($clientId: ID) {
    unAssignAgent (clientId: $clientId) {
      client {
        id
      }
    }
  }
''';

const String userPortfolioOverview = '''
  query holdingOverview(\$memberUserId: String!) {
    userPortfolioOverviewV1(memberUserId: \$memberUserId) {
      asOn
      total {
        $portfolioOverview
      }
      mf {
        $portfolioOverview
      }
      pms {
        $portfolioOverview
      }
      fd {
        $portfolioOverview
      }
      deb {
        $portfolioOverview
      }
      preipo {
        $portfolioOverview
      }
    }
  }''';

const String portfolioOverview = '''
    investedValue
    currentValue
    unrealisedGain
    absoluteReturns
    xirr
    costOfCurrentInvestment
''';

const String userMFHybridView = '''
  query userMFHybridView(\$filter: GoalQueryFilter!) {
    userMFHybridView (filter:\$filter) {
       overview {
        currentInvested
        currentValue
        currentIrr
      }
      products {
        customPortfolios {
          $portfolioFragment
        }
        otherFunds {
          $portfolioFragment
        }
        wealthyPortfolios {
          $portfolioFragment
        }
      }
    }
  }''';

const String portfolioFragment = '''
    currentAbsoluteReturns
    currentInvestedValue
    currentIrr
    currentValue
    products {
      currentAbsoluteReturns
      currentAsOn
      currentInvestedValue
      currentIrr
      currentValue
      externalId: externalID
      goalType
      productName
      portfolioName
      schemes {
        displayName
        currentAbsoluteReturns
        currentAsOn
        currentInvestedValue
        currentIrr: currentIRR
        currentValue
        folioOverviews {
          absoluteReturns
          asOn
          currentIrr: currentIRR
          currentValue
          folioNumber
          id
          investedValue
        }
        schemeData {
          category
          displayName
          expenseRatio
          fundType
          launchDate
          nav
          navDate
          wschemecode
        }
      }
    }
''';

const String userFdOverview = '''
  query userFdOverview(\$filter: SchemeOverviewFilter!) {
    userFdOverview (filter:\$filter) {
       $schemeOverview
    }
  }''';

const String userPmsOverview = '''
  query userPmsOverview(\$filter: SchemeOverviewFilter!) {
    userPmsOverview (filter:\$filter) {
      userID
      investedValue
      currentValue
      xirr
      name
      instrumentType
      assetClass
      asOnDate
      wschemecode
      unrealisedGain
      navAsOn
      wpc
      tags
      absoluteReturn
       schemeMetaData {
         inflow
         outflow
         netCapital
         lastUpdatedOn
       }
    }
  }''';

const String userUnlistedOverview = '''
  query userUnlistedOverview(\$filter: SchemeOverviewFilter!) {
    userUnlistedOverview (filter:\$filter) {
       $schemeOverview
    }
  }''';

const String userMldOverview = '''
  query userMldOverview(\$filter: SchemeOverviewFilter!) {
    userMldOverview (filter:\$filter) {
       $schemeOverview
    }
  }''';

const String schemeOverview = '''
        userID
        investedValue
        currentValue
        xirr
        name
        instrumentType
        assetClass
        asOnDate
        wschemecode
        navAsOn
        wpc
        tags
        absoluteReturn
    ''';

const userProfile = r'''
      name
      userID
      crn
      relationship
      accountType
      accountSubType
      panNumber
      phoneNumber
      email
      investedValue
      currentValue
      absoluteReturn
      absoluteReturnPercent
''';

const profileInfo = r'''
      investedValue
      currentValue
      unrealisedGain
      absoluteReturns
      xirr
''';

const userProfileView = '''
 query userProfileView {
    userProfileView {
      ${userProfile}
      myProfiles {
        ${userProfile}
      }
      familyProfiles {
        ${userProfile}
      }
      mfProfileInfo {
        ${profileInfo}
      }
      familyProfilesInfo {
        ${profileInfo}
      }
    }
 }
''';

const String clientOnboardingDetails = r'''
   query clientOnboardingDetails($userId: String, $onboardingProduct: String) {
    hagrid(userId: $userId) {
      profilePrefillData(onboardingProduct: $onboardingProduct) {
        userId
        crn
        investorType
        panUsageSubtype
        taxStatus
        requestedAccountType
        currentOnboardingAccountType
        availableAccountType
        onboarding {
          status
          stage
          steps {
            contactDetails {
              status
              missingFields
            }
            accountDetails {
              status
              missingFields
              panNumber {
                value
                isVerified
              }
              taxStatus {
                value
                isVerified
              }
              investorType {
                value
                isVerified
              }
            }
            personalDetails {
              status
              missingFields
            }
            bankDetails {
              status
            }
            nomineeDetails {
              status
            }
            kycDetails {
              url
              stage
              journey {
                projectedPath {
                  stepName
                  displayName
                }
                steps {
                  stepName
                  stepStatus
                  completedAt
                  displayName
                }
                current {
                  name
                  status
                  displayName
                }
              }
            }
          }
        }
      } 
    }
  }
''';
