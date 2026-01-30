const String createTicket = r'''
  mutation createTicket ($input: CreateTicketInput!) {
    createTicket (input: $input) {
      id
      customerTicketUrl
    }
  }
''';

const String markGoalAsCustom = r'''
  mutation markGoalAsCustom ($goalId: ID!) {
    convertGoalToCustom (id: $goalId) {
      goal {
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

const String updateGoal = r'''
  mutation updateGoal ($input: GarageUpdateGoalInput!) {
    updateGoal (input: $input) {
      goal {
        id
      }
    }
  }
''';
