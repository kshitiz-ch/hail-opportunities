const String fetchPortfolio = r'''
    query fetchPortfolio($userId: String, $category: String){
entreat(userId: $userId) {
      id
      userProducts(
        category: $category,
        transactionActive: true
      ) {
        id
        activatedAt
        externalId
        name
        displayName
        startDate
        endDate
        currentInvestedValue
        currentValue
        currentIrr
        currentAbsoluteReturns
        productCode
        productType
        productVendor
        productManufacturer
        productCategory
        extras
        hasExtrasSchema
        canMakePayment
      }
    }
}
''';

const String fetchGoalSubtype = r'''
query fetchGoalSubtype($userId: String, $goalId: ID) {
   taxy(userId: $userId) {
    goal(id: $goalId) {
      id
      name
      canMakePayment
      goalSubtype {
        goalType
        subtype
      }
    }
  }
}
''';
