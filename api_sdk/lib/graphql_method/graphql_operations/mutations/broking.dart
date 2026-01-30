const generateUrl = r'''
mutation generateUrl($input: SendKycUrlInput!) {
  sendKycUrl(input: $input) {
    kycUrl
    message
  }
}
''';

const updateDefaultBrokingPlan = r'''
mutation partnerUpdateWealthyBrokingApPlan($agentId: ID!, $apPlanCode: String!) {
  partnerUpdateWealthyBrokingApPlan(agentId: $agentId, apPlanCode:$apPlanCode) {
    message
  }
}
''';

const updateUserBrokeragePlan = r'''
 mutation updateUserBrokeragePlan($input: AgentUpdateUserBrokeragePlanInput!) {
    updateUserBrokeragePlan(input: $input) {
      message
    }
  } 
''';
