const String mutualFunds = r'''
query mutualFunds($subtype: Int) {
   taxy {
    goalSubtypes(subtype: $subtype) {
     id
      subtype
      name
      equityPercentage
      avgReturns
      minReturns
      maxReturns
      minAmount
      goalType
      term
      goalsubtypeschemes {
        id
        wschemecode
        withdrawalPercentage
        percentage
        idealWeight
        forSwitch
        schemeData {
          schemeReturnType
          id
          amc     
          minDepositAmt
          fundType
          schemeName
          displayName
          minWithdrawalAmt
          category
          exitLoadPercentage
          exitLoadTime
          exitLoadUnit
          exitLoadPercentage
          rtrnsSinceLaunch
          oneYrRtrns
          threeYrRtrns
          fiveYrRtrns
          expenseRatio
          totalExpenseRatio
          exitLoadStr
          fundTypeStr
        }
      }
    }
  }
}
''';

const String schemeOrderStatus = r'''
  query schemeOrderStatus ($userId: String, $proposalId: String) {
    taxy(userId: $userId) {
      orders(proposalId: $proposalId) {
        schemeorders {
          navAllocatedAt
          wschemecode
          schemeName
          schemeStatus
        }
      }
    }
  }
''';
