const String createFamilyUserRequest = r'''
  mutation createFamMemberRequest($input: NewFamilyMemberRequest!) {
    createFamMemberRequest(input:$input) {
       ID
       Message
    }
  }''';

const String verifyFamilyUserRequest = r'''
  mutation verifyFamRequest($input: VerifyFamRequest!) {
    verifyFamRequest(input:$input) {
       Message
       FamilyMemberID
    }
  }''';

const String resendFamilyRequestOtp = r'''
  mutation resendFamRequestOtp($input: ResendFamReqOtp!) {
    resendFamRequestOtp(input:$input) {
       ID
       Message
    }
  }''';

const String leaveFamily = r'''
  mutation leaveFamily($input: FamilyID!) {
    leaveFamily(input:$input) {
       Message
    }
  }''';

const String kickFromFamily = r'''
  mutation kickFromFamily($input: FamilyMemberID!) {
    kickFromFamily(input:$input) {
       Message
    }
  }''';
