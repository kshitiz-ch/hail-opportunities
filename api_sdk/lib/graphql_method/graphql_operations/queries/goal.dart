const goalSummary = r'''
  query goalSummary($userId: String, $goalId: ID!){
    taxy(userId: $userId) {
      goal(id: $goalId) {
        id
        goalId
        displayName
        goalSubtype {
          goalType
        }

        currentInvestedValue
        currentValue
        currentIrr
        currentAbsoluteReturns
        currentEquityPercentage
        currentDebtPercentage
      }
    }
  }
''';

const goalOrderCounts = r'''
  query goalSummary($userId: String, $goalId: ID!, $wschemecode: String, $status: String){
    taxy(userId: $userId) {
      mfOrdersCount(goalId: $goalId, status: $status, wschemecode: $wschemecode)

      sipCountV2(goalId: $goalId, wschemecode: $wschemecode) {
        totalCount
        activeCount
      }
      switchCount(goalId: $goalId, wschemecode: $wschemecode) {
        totalCount: totalSwitches
        activeCount: activeSwitches
      }
      swpCount(goalId: $goalId, wschemecode: $wschemecode) {
        totalCount: totalSwps
        activeCount: activeSwps
      }
      mfSchemeOrdersCount(
        goalId: $goalId,
        wschemecode: $wschemecode,
        status: $status
      )
    }
  }
      
''';

const goalDetails = r'''
  query goalDetails($userId: String, $goalId: ID!){
    taxy(userId: $userId) {
      goal(id: $goalId) {
        currentAbsoluteReturns
        currentDebtPercentage
        currentEquityPercentage
        currentInvestedValue
        currentIrr
        currentValue
        displayFormat
        displayName
        transactionActive
        label
        endDate
        goalAmount
        goalId
        switchPeriod
        switchPaymentEnabled
        canMakePayment
        goalSubtype {
          goalType
          subtype
          name
          term
          avgReturns
          minAmount
          pastOneYearReturns
          pastThreeYearReturns
          pastFiveYearReturns
          goalsubtypeschemes {
            wschemecode
            idealWeight
          }
        }
      }
    }
  }
''';

const String customGoalFunds = r'''
    query userGoalSubtypeSchemes($userId: String, $goalId: ID!){
taxy(userId: $userId) {
      id
      userGoalSubtypeSchemes(goalId: $goalId) {
        id
        isDeprecated
        idealWeight
        forSwitch
        currentInvestedValue
        currentValue
        currentAsOn
        currentIrr
        currentAbsoluteReturns
        wpc
        schemeData {
          amc
          id
          wschemecode
          displayName
          schemeName
          fundType
          category
          minDepositAmt
          minAddDepositAmt
          expenseRatio
          exitLoadPercentage
          nav
          oneYrRtrns
          threeYrRtrns
          fiveYrRtrns
          rtrnsSinceLaunch
          minSipDepositAmt
        }
        folioOverview {
          id
          folioNumber
          investedValue
          currentValue
        }
        folioOverviews {
          id
          folioNumber
          investedValue
          currentValue
        }
      }
    }
}
''';

const String goalAllocation = r'''
    query userGoalSubtypeSchemes($userId: String, $goalId: ID!, $wschemecode: String){
taxy(userId: $userId) {
      id
      userGoalSubtypeSchemes(goalId: $goalId, wschemecode: $wschemecode) {
        id
        isDeprecated
        idealWeight
        forSwitch
        currentInvestedValue
        currentValue
        currentAsOn
        currentIrr
        currentAbsoluteReturns
        units
        wpc
        schemeData {
          wschemecode
          displayName
          fundType
          category
          nav
          minDepositAmt
          amc
          minWithdrawalAmt
          navDate
        }
        folioOverview {
          id
          folioNumber
          withdrawalUnitsAvailable
          withdrawalAmountAvailable
          exitLoadFreeAmount
          liveLtcg
          liveStcg
          currentValue
          units
          asOn
        }

        folioOverviews {
          id
          folioNumber
          withdrawalUnitsAvailable
          withdrawalAmountAvailable
          exitLoadFreeAmount
          liveLtcg
          liveStcg
          currentValue
          units
          asOn
        }
      }
    }
}
''';

const String getGoalSchemesV2 = r'''
query userFolioData ($fetchFundDetails: Boolean, $goalIds: [String], $wschemecode: [String]){
  userFolioData(filter: {goalIds: $goalIds, wschemecode: $wschemecode, fetchFundDetails: $fetchFundDetails}) {
    investedValue
    currentValue
    asOn
    currentIrr
    units
    wpc
    amc
    folioNumber
    withdrawalUnitsAvailable
    withdrawalAmountAvailable
    exitLoadFreeAmount
    wschemecode
    navDate
    schemeDetails {
      displayName
      fundType
      category
      nav
      amc
      wpc
      isPaymentAllowed
      navDate
      amountThresholds {
        minDepositAmt
        minSipDepositAmt
        minWithdrawalAmt
        minAddDepositAmt
      }
    }
  }
}
''';

const String goalSchemeOrders = r'''
  query goalSchemeOrders(
    $goalId: ID!,
    $userId: String!,
    $wschemecode: String,
    $schemeStatus: String,
    $status: String,
    $limit: Int,
    $offset: Int
  ) {
    taxy(userId: $userId) {
      id
      schemeOrders(
        goalId: $goalId,
        wschemecode: $wschemecode,
        schemeStatus: $schemeStatus,
        limit: $limit,
        offset: $offset
      ) {
          id
          navAllocatedAt
          wschemecode
          folioNumber
          units
          displayAmount
          nav
          category
          schemeStatus
      }
      mfSchemeOrdersCount(
        goalId: $goalId,
        wschemecode: $wschemecode,
        status: $status
      )
    }
  }
''';

const String stpOrders = r'''
  query stpOrders(
    $userId: String!,
    $switchMetaId: String,
    $filterDate: DateTime,
    $toDate: DateTime,
    $limit: Int,
    $offset: Int
  ) {
    taxy(userId: $userId) {
      id
      switchesV2(
        switchMetaId: $switchMetaId,
        filterDate: $filterDate,
        toDate: $toDate, 
        limit: $limit,
        offset: $offset
      ) {
        id
        switchDate
        amount
        status
        customerFailureReason
      }
    }
  }
''';

const switches = r'''
  query switches($userId: String, $goalId: ID!) {
    taxy(userId: $userId) {
      switchMetas(goalId: $goalId) {
        id
        createdAt
        externalId
        amount
        frequency
        days
        startDate
        endDate
        isPaused
        pausedAt
        pausedReason
        resumedAt
        ticketNumber
        nextSwitch
        lastSwitchStatus
        customerFailureReason
        switchFunds {
          id
          externalId
          switchinWschemecode
          switchoutWschemecode
          switchinSchemeName
          switchoutSchemeName
          amount
          folioNumber
          __typename
        }
      }
    }
  }
''';

const swpList = r'''
  query swpList($userId: String, $goalId: ID!){
    taxy(userId: $userId) {
      swpMetas(goalId: $goalId) {
      createdAt
      externalId
      amount
      days
      startDate
      endDate
      isPaused
      pausedAt
      resumedAt
      nextSwp
      swpFunds {
          schemeName
          wschemecode
          folioNumber        
        }
      }
    }
  }
''';

const String swpDetails = r'''
query swpsV2($userId: String!, $swpMetaId: String, $filterDateForPast: DateTime, $toDate: DateTime, $limit: Int, $offset: Int) {
    taxy(userId: $userId) {
      swpsV2(swpMetaId: $swpMetaId, filterDate: $filterDateForPast, toDate: $toDate, limit: $limit, offset: $offset) {
        id
        swpDate
        status
        amount
        customerFailureReason
    }
  }
}
  ''';
