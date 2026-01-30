const String updateAgentCustomActions = r'''
  mutation UpdateAgentCustomActions ($numActions: Int!, $actions: [ActionInput]!) {
    updateActions (actions: $actions, numActions: $numActions) {
      success
    }
  }
''';
