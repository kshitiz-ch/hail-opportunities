const String deletePartnerRequest = r'''
  mutation deletePartnerMutation {
    deleteAgentProfileRequest {
      agentProfileDeleteReq
    }
  }
''';

const cancelDeletePartnerRequest = r'''
  mutation cancelDeletePartnerRequest($delReqId: String!) {
  cancelDeleteAgentProfileRequest(delReqId: $delReqId) {
      agentProfileDeleteReq
    }
  }
''';
