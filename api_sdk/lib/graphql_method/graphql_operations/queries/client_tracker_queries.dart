const String allocation = '''
allocation {
  allocationType
  allocationData {
    weight
    category
    currentValue
  }
}
''';

const String familyMfOverview = '''
query mfFamilyOverview(\$panNumber: String,\$userId: String!) {
  phaser(userId: \$userId) {
    familyMfOverview(panNumber: \$panNumber) {
      currentValue
      investedAmount
      absoluteReturns
      $allocation
    }
  }
}
''';

const String familyMfSchemeOverviews = '''
query familyMfSchemeOverviews(\$panNumber: String, \$userId: String!, \$broker: String!){
  phaser(userId: \$userId) {
    id
    familyMfSchemeOverviews(panNumber: \$panNumber, broker: \$broker) {
      currentValue
      investedAmount
      absoluteReturns
      schemeCode
      folioOverviews {
        id
        schemeCode
        folioNumber
        investedAmount
        currentValue
        units
        advisorArn
        isDemat
        withdrawalUnitsAvailable
        withdrawalAmountAvailable
        lockedUnits
      }
      schemeMeta {
        id
        amc
        wpc
        amcCode
        schemeName
        displayName
        category
        subcategory
        fundType
        expenseRatio
        returnType
        planType
        schemeCode
        wschemecode
        exitLoadTime
        exitLoadUnit
        exitLoadPercentage
        minDepositAmt
        minAddDepositAmt
        minSipDepositAmt
        isPaymentAllowed
        sipAllowed
        sipRegistrationStartDate
        navAtLaunch
        nav
        navDate
        isTaxSaver
        minWithdrawalAmt
        returns
        launchDate
        closeDate
        wRating
        wRiskScore
        wReturnScore
        wValuationScore
        sd
        pe
        alpha
        beta
        aum
        yieldTillMaturity
        modifiedDuration
        aaaSovereignAllocation
        holdingInTop20Companies
        wCreditQualityScore
        benchmark
        classCode
        riskOMeterValue
        taxationType
        taxationTypeRemarks
        objective
        fundManagerProfile
        fundManager
        rankInCategory1Year
        rankInCategory3Year
        rankInCategory5Year
        rankOutOfInCategory1Year
        rankOutOfInCategory3Year
        rankOutOfInCategory5Year
        benchmarkTpid
      }
    }
  }
}
''';
