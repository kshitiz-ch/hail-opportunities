const String schemeMetas = r'''
    query schemeMetas($wSchemeCodes: String) {
metahouse {
      id
      schemeMetas(wschemecodes: $wSchemeCodes) {
        id
        amc
        wpc
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
''';

const String schemeExitLoadDetails = r'''
  query schemeMetas($wSchemeCodes: String) {
    metahouse {
      id
      schemeMetas(wschemecodes: $wSchemeCodes) {
        exitLoadTime
        exitLoadUnit
        sipRegistrationStartDate
    }
  }
}
''';
