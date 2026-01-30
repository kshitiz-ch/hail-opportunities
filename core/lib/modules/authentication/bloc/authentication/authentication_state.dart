abstract class AuthenticationState {
  const AuthenticationState();

  List<Object?> get props => [];
}

class AppAutheticated extends AuthenticationState {}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class HalfAgentAuthenticated extends AuthenticationState {}

class AuthenticationStart extends AuthenticationState {
  final bool? isGuideCompleted;

  AuthenticationStart({this.isGuideCompleted = false});

  @override
  List<Object?> get props => [isGuideCompleted];
}

class UserLogoutState extends AuthenticationState {
  final bool? showLogoutMessage;
  final bool isLogggingOutForHalfAgent;

  UserLogoutState({
    this.showLogoutMessage,
    this.isLogggingOutForHalfAgent = false,
  });

  @override
  List<Object?> get props => [showLogoutMessage];
}

class SendingOtpState extends AuthenticationState {}

class AppUpdateAvailableState extends AuthenticationState {
  final bool? shouldForceUpdate;
  final String? releaseNotes;

  AppUpdateAvailableState({this.shouldForceUpdate, this.releaseNotes});

  @override
  List<Object?> get props => [shouldForceUpdate, releaseNotes];
}

class AppUpdateNotAvailableState extends AuthenticationState {}

class AppUpdateResetState extends AuthenticationState {}

class OtpSent extends AuthenticationState {
  final String message;

  OtpSent({required this.message});

  @override
  List<Object> get props => [message];
}

class OtpSentError extends AuthenticationState {
  final String message;

  OtpSentError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReSendingOtpState extends AuthenticationState {}

class OtpReSent extends AuthenticationState {
  final String message;

  OtpReSent({required this.message});

  @override
  List<Object> get props => [message];
}

class OtpReSentError extends AuthenticationState {
  final String message;

  OtpReSentError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserForgotPasswordState extends AuthenticationState {
  final String url;

  UserForgotPasswordState({required this.url});

  @override
  List<Object> get props => [url];
}

class AuthenticationNotAuthenticated extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class UserLocalAuthState extends AuthenticationState {
  final String? passcode;

  UserLocalAuthState({required this.passcode});

  @override
  List<Object?> get props => [passcode];
}

class OnboardingPending extends AuthenticationState {}

class ResetAuthenticationState extends AuthenticationState {}
